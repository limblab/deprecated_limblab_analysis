function out = fitTuningCurves_GLM(data,tuningPeriod,useArray,doPlots)
% notes about inputs
% notes about outputs
%
% NOTE: right now, target direction or 'pre' window for movement don't work with RT

if nargin < 4
    doPlots = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load all of the parameters
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
movementTime = str2double(params.movement_time{1});
latency = str2double(params.([lower(useArray) '_latency']){1});
confLevel = str2double(params.confidence_level{1});
bootNumIters = str2double(params.number_iterations{1});
glmModel = params.glm_model{1};
glmBinSize = params.glm_bin_size{1};
excludeTrials = str2double(params.exclude_trials{1});
excludeFraction = str2double(params.exclude_fraction{1});
temp = params.exclude_time_range;
excludeTimeRange = zeros(size(temp));
for i = 1:length(temp) % hack to make this work... do it better someday
    excludeTimeRange(i) = str2double(temp{i});
end
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mt = [];

%% Get data
sg = data.(useArray).unit_guide;

disp('Binning data...');
% Compute continuous firing rate for each unit
% use bin sizes of glmBinSize
t = data.cont.t;
binT = t(1):glmBinSize/1000:t(end);

if strfind(lower(glmModel),'vel')
    binVel = interp1(t, data.cont.vel, binT,'linear','extrap');
    glmVel = [];
end
if strfind(lower(glmModel),'pos')
    binPos = interp1(t, data.cont.pos, binT,'linear','extrap');
    glmPos = [];
end
if strfind(lower(glmModel),'force')
    binForce = interp1(t, data.cont.force, binT,'linear','extrap');
    glmForce = [];
end

% Make the number of samples equal to the number of points for bootstrap
use_samp = length(binT);

fr = zeros(length(binT),size(sg,1));

for unit = 1:size(sg,1)
    % compute firing in the window for each unit
    ts = data.(useArray).units.(['elec' num2str(sg(unit,1))]).(['unit' num2str(sg(unit,2))]).ts;
    ts = ts(ts >= t(1) & ts <= t(end));
    
    %  the latency to account for transmission delays
    ts = ts + latency;
    
    % bin the data
    fr(:,unit) = train2bins(ts, binT);
end


if ~strcmpi(tuningPeriod,'file')
    % Get the movement table
    mt = data.movements.movement_table;
    mt = filterMovementTable(data,mt);
    
    disp(['Using ' tuningPeriod ' movement period, ' num2str(movementTime) ' second window...']);
    
    %% Get spike count for each channel in desired window
    useWin = zeros(size(mt,1),2);
    
    for trial = 1:size(mt,1)
        % Time window for which to look for neural activity
        % Time window for which to look for neural activity
        if strcmpi(tuningPeriod,'peak') % Use 0.5 sec period around peak speed
            useWin(trial,:) = [mt(trial,5) - movementTime/2, mt(trial,5) + movementTime/2];
        elseif strcmpi(tuningPeriod,'initial') %Use initial movement period
            useWin(trial,:) = [mt(trial,4), mt(trial,4)+movementTime];
        elseif strcmpi(tuningPeriod,'final') % Use the final movement period
            useWin(trial,:) = [mt(trial,end)-movementTime, mt(trial,end)];
        elseif strcmpi(tuningPeriod,'pre') % Use pre-movement period
            useWin(trial,:) = [mt(trial,4)-movementTime, mt(trial,4)];
        elseif strcmpi(tuningPeriod,'full') % Use entire movement
            useWin(trial,:) = [mt(trial,3), mt(trial,end)];
        else
            error('Could not identify the tuning period');
        end
        
        % build vector of firing rate and relevant binned velocity
        idx = binT >= useWin(trial,1) & binT < useWin(trial,2);
        
        if strfind(lower(glmModel),'vel')
            glmVel = [glmVel; binVel(idx,:)];
        end
        if strfind(lower(glmModel),'pos')
            glmPos = [glmPos; binPos(idx,:)];
        end
        if strfind(lower(glmModel),'force')
            glmForce = [glmForce; binForce(idx,:)];
        end
    end
    
    
    
else % don't break down by movements, use whole file continuously
    
    disp('Using whole data file...');
    if strfind(lower(glmModel),'vel')
        glmVel = binVel;
    end
    if strfind(lower(glmModel),'pos')
        glmPos = binPos;
    end
    if strfind(lower(glmModel),'force')
        glmForce = binForce;
    end
    
end

clear binVel binPos binForce trial moveTimes goodTrials

%% Now do tuning
switch lower(glmModel)
    case 'pos'
        glm_input = glmPos;
    case 'vel'
        glm_input = [glmVel sqrt(glmVel(:,1).^2 + glmVel(:,2).^2)];
    case 'posvel'
        glm_input = [glmPos glmVel sqrt(glmVel(:,1).^2 + glmVel(:,2).^2)];
    case 'nospeed'
        glm_input = [glmPos glmVel];
    case 'forcevel'
        glm_input = [glmVel glmForce];
    case 'forceonly'
        glm_input = [glmForce];
    case 'forceposvel'
        glm_input = [glmForce glmPos glmVel sqrt(glmVel(:,1).^2 + glmVel(:,2).^2)];
    otherwise
        error('unknown model: %s', model);
end


%% Bootstrap
disp(['Running bootstrap with ' num2str(bootNumIters) ' iterations...']);

bootMDs = zeros(size(sg,1),bootNumIters);
bootPDs = zeros(size(sg,1),bootNumIters);
pds = zeros(size(sg,1),1);
mds = zeros(size(sg,1),1);
for unit = 1:size(sg,1)
    disp(['Starting unit ' num2str(unit) '...']);
    b_mat = zeros(size(glm_input,2)+1,1,bootNumIters);
    for bootCt=1:bootNumIters
        if mod(bootCt,50)==0
            disp(['Iteration ' num2str(bootCt) '...']);
        end
        % grab test set indices randomly
        
        % randomly grab binned data points
        idx = uint32(1+use_samp-1)*rand(use_samp,1));
        
        % fit glm model
        b = glmfit(glm_input(idx,:),fr(idx,unit),'poisson');
        
        switch lower(glmModel)
            case 'pos'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No bootstrap case defined for model type: ',model))
            case 'vel'
                bootMDs(unit,bootCt) = norm([b(2) b(3)]);
                bootPDs(unit,bootCt) = atan2(b(3),b(2));
            case 'posvel'
                bootMDs(unit,bootCt) = norm([b(4) b(5)]);
                bootPDs(unit,bootCt) = atan2(b(5),b(4));
            case 'nospeed'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No bootstrap case defined for model type: ',model))
            case 'forcevel'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No bootstrap case defined for model type: ',model))
            case 'forceonly'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No bootstrap case defined for model type: ',model))
            case 'forceposvel'
                bootMDs(unit,bootCt) = norm([b(6) b(7)]);
                bootPDs(unit,bootCt) = atan2(b(6),b(7));
        end
        
        b_mat(:,bootCt) = b;
    end
    avg_b = mean(b_mat,2);
    
    
    % Get model outputs
    switch lower(glmModel)
        case 'posvel'
            bv = [avg_b(4) avg_b(5)]; % glm weights on x and y velocity
        case 'forceonly'
            bv = [avg_b(2) avg_b(3)]; % glm weights on x and y force
        case 'pos'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'vel'
            bv = [avg_b(2) avg_b(3)]; % glm weights on x and y velocity
        case 'nospeed'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'forcevel'
            bv = [avg_b(4) avg_b(5)]; % glm weights on x and y velocity
        case 'forceposvel'
            bv = [avg_b(6) avg_b(7)]; % glm weights on x and y velocity
        case 'ppforcevel'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'ppforceposvel'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'powervel'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'ppcartfvp'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
    end
    
    % Set outputs
    mds(unit) = norm(bv);
    pds(unit) = atan2(bv(2),bv(1));
    
end


%% Find 95 percent confidence interval bounds
% Throw out top and bottom 2.5 percent of samples for each channel
% (according to PD)

% Build vector of distances from mean for each channel
ang_dist = bootPDs - pds(:,ones(1,bootNumIters));
ang_dist(ang_dist>pi) = ang_dist(ang_dist>pi)-2*pi;
ang_dist(ang_dist<-pi) = ang_dist(ang_dist<-pi)+2*pi;

% sort vectors along angle distance for each unit
ang_dist_sort = sort(ang_dist,2);

% calculate index range for 2.5 to 97.5 percent
ang_ind_low = ceil(bootNumIters*(1-confLevel)/2);
ang_ind_high = floor(bootNumIters*(1-confLevel)/2);

% Calculate confidence bounds (vector, each element corresponds to a
% channel)
pd_cis = [ang_dist_sort(:,ang_ind_low) + pds, ang_dist_sort(:,ang_ind_high) + pds];


% Build vector of distances from mean for each channel
md_dist = bootMDs - mds(:,ones(1,bootNumIters));
% sort vectors along angle distance for each unit
md_dist_sort = sort(md_dist,2);
md_cis = [md_dist_sort(:,ang_ind_low) + mds, md_dist_sort(:,ang_ind_high) + mds];

%% build output struct
out.pds = [pds pd_cis];
out.mds = [mds md_cis];

out.unit_guide = sg;
out.mt = mt;
out.params.stats = {'bootstrap', bootNumIters, confLevel};
out.params.exclude_trials = excludeTrials;
out.params.tune_type = tuningPeriod;
out.params.movement_time = movementTime;
out.params.glm_model = glmModel;
out.params.glm_bin_size = glmBinSize;

