function out = fitTuningCurves_GLM(data,tuningPeriod,useArray,paramSetName,useBlock)
% notes about inputs
% notes about outputs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load all of the parameters
paramFile = fullfile(data.meta.out_directory, paramSetName, [data.meta.recording_date '_' paramSetName '_tuning_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
movementTime = str2double(params.movement_time{1});
adBlocks = str2double(params.ad_exclude_fraction);
woBlocks = str2double(params.wo_exclude_fraction);
glmModel = params.glm_model{1};
glmBinSize = str2double(params.glm_bin_size{1});
glmBlockTime = str2double(params.glm_block_time{1});
glmRandSample = str2double(params.glm_randomly_sample{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
latency = str2double(params.([lower(useArray) '_latency']){1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mt = [];
holdTime = 0.5;

% compute the number of bins for each block based on blocktime and binsize
blockLength = glmBlockTime/(glmBinSize/1000);

%% Get data
sg = data.(useArray).sg;

disp('Binning data...');
% Compute continuous firing rate for each unit
% use bin sizes of glmBinSize
t = data.cont.t;
binT = t(1):glmBinSize/1000:t(end);
glmT = [];
if size(binT,1)==1
    binT = binT';
end

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

if strfind(lower(glmModel),'nospeed')
    binPos = interp1(t, data.cont.pos, binT,'linear','extrap');
    glmPos = [];
    binVel = interp1(t, data.cont.vel, binT,'linear','extrap');
    glmVel = [];
end

fr = zeros(length(binT),size(sg,1));
for unit = 1:size(sg,1)
    % compute firing in the window for each unit
    ts = data.(useArray).units(unit).ts;
    ts = ts(ts >= t(1) & ts <= t(end));
    
    %  the latency to account for transmission delays
    ts = ts + latency;
    
    % bin the data
    fr(:,unit) = train2bins(ts, binT);
    
end
backup_fr = fr;

if ~strcmpi(tuningPeriod,'file')
    fr = [];
    % Get the movement table
    [mt,centers] = filterMovementTable(data,paramSetName,true,useBlock);
    
    disp(['Using ' tuningPeriod ' movement period, ' num2str(movementTime) ' second window...']);
    
    %% Get spike count for each channel in desired window
    useWin = zeros(size(mt,1),2);
    
    for trial = 1:size(mt,1)
        % Time window for which to look for neural activity
        if strcmpi(tuningPeriod,'peak') % Use period around peak speed
            useWin(trial,:) = [mt(trial,5) - movementTime/2, mt(trial,5) + movementTime/2];
        elseif strcmpi(tuningPeriod,'initial') %Use initial movement period
            useWin(trial,:) = [mt(trial,4), mt(trial,4)+movementTime];
        elseif strcmpi(tuningPeriod,'final') % Use the final movement period
            useWin(trial,:) = [mt(trial,6)-movementTime-holdTime, mt(trial,6)-holdTime];
        elseif strcmpi(tuningPeriod,'pre') % Use pre-movement period
            useWin(trial,:) = [mt(trial,2), mt(trial,4)];
        elseif strcmpi(tuningPeriod,'full') % Use entire movement
            useWin(trial,:) = [mt(trial,2), mt(trial,6)-holdTime];
        elseif strcmpi(tuningPeriod,'onpeak') % use from onset to peak
            useWin(trial,:) = [mt(trial,4), mt(trial,5)];
        elseif strcmpi(tuningPeriod,'befpeak') % window ending at peak
            useWin(trial,:) = [mt(trial,5)-movementTime, mt(trial,5)];
        end
        
        % build vector of firing rate and relevant binned velocity
        idx = binT >= useWin(trial,1) & binT < useWin(trial,2);
        
        fr = [fr; backup_fr(idx,:)];
        
        glmT = [glmT; binT(idx)];
        
        if strfind(lower(glmModel),'vel')
            glmVel = [glmVel; binVel(idx,:)];
        end
        if strfind(lower(glmModel),'pos')
            glmPos = [glmPos; binPos(idx,:)];
        end
        if strfind(lower(glmModel),'force')
            glmForce = [glmForce; binForce(idx,:)];
        end
        if strfind(lower(glmModel),'nospeed')
            glmPos = [glmPos; binPos(idx,:)];
            glmVel = [glmVel; binVel(idx,:)];
        end
        
    end
    
else % don't break down by movements, use whole file continuously
    
    % use data in block segment only
    disp('Using continuous data file...');
    
    % if the epoch is separated into blocks, then remove unwanted data
    if strcmp(data.meta.epoch,'AD')
        if ~isempty(adBlocks)
            if useBlock ~= -1 % then pick the correct indices
                adBlocks = adBlocks(useBlock:useBlock+1);
            end
            
            if length(adBlocks) == 1
                % remove the first fraction of time
                idx = 1:ceil(adBlocks*length(binT));
            else
                first = floor(adBlocks(1)*length(binT));
                last = ceil(adBlocks(2)*length(binT));
                if first < 1
                    first = 1;
                end
                if last > length(binT)
                    last = length(binT);
                end
                idx = first:last;
            end
        end
    elseif strcmp(data.meta.epoch,'WO')
        % Do the same for washout
        if ~isempty(woBlocks)
            if useBlock ~= -1 % then pick the correct indices
                woBlocks = woBlocks(useBlock:useBlock+1);
            end
            
            if length(woBlocks) == 1
                % remove the first fraction of time
                idx = 1:ceil(woBlocks*length(binT));
            else
                first = floor(woBlocks(1)*length(binT));
                last = ceil(woBlocks(2)*length(binT));
                if first < 1
                    first = 1;
                end
                if last > length(binT)
                    last = length(binT);
                end
                idx = first:last;
            end
        end
    else
        % it's a baseline, for now I use the whole file
        idx = 1:length(binT);
    end
    
    
    if strfind(lower(glmModel),'vel')
        glmVel = binVel(idx,:);
    end
    if strfind(lower(glmModel),'pos')
        glmPos = binPos(idx,:);
    end
    if strfind(lower(glmModel),'force')
        glmForce = binForce(idx,:);
    end
    if strfind(lower(glmModel),'nospeed')
        glmPos = binPos(idx,:);
        glmVel = binVel(idx,:);
    end
    
    fr = fr(idx,:);
end

% Build the variables for model building
switch lower(glmModel)
    case 'pos'
        glm_input = glmPos;
        idx1 = 2;
        idx2 = 3;
    case 'vel'
        glm_input = [glmVel sqrt(glmVel(:,1).^2 + glmVel(:,2).^2)];
        idx1 = 2;
        idx2 = 3;
    case 'posvel'
        glm_input = [glmPos glmVel sqrt(glmVel(:,1).^2 + glmVel(:,2).^2)];
        idx1 = 4;
        idx2 = 5;
    case 'nospeed'
        glm_input = [glmPos glmVel];
        idx1 = 4;
        idx2 = 5;
    case 'forcevel'
        glm_input = [glmForce glmVel];
        idx1 = 4;
        idx2 = 5;
    case 'forceonly'
        glm_input = [glmForce];
        idx1 = 2;
        idx2 = 3;
    case 'forceposvel'
        glm_input = [glmForce glmPos glmVel sqrt(glmVel(:,1).^2 + glmVel(:,2).^2)];
        idx1 = 6;
        idx2 = 7;
    otherwise
        error('unknown model: %s', model);
end


%% Now do tuning

for unit = 1:size(fr,2)
    %disp(['Starting unit ' num2str(unit) '...']);
    
    doType = 'fit';
    
    % this fits model multiple times on different chunks of data to get a
    % sense for parameter variability
    switch lower(doType)
        case 'subset'
            [b,nb] = estimateGLMError(glm_input,fr(:,unit),blockLength,glmRandSample);
            
            % get the relevant parameters for PDs
            b = b(:,[idx1 idx2]);
            
            pd_all = atan2(b(:,2),b(:,1));
            
            sd = std(b,1);
            b = mean(b,1);
            
            % get error for each parameter
            %[b,sd] = normfit(b);
            % get standard error
            % se = sd./sqrt(nb);
            
            % Set outputs
            md = norm(mean(b,1));
            pd = atan2(b(2),b(1));
            
            % propagate error using the derivative (chain rule applies)
            %   for pd, y=arctan(v_y/v_x)
            pd_err = abs( sd(1)*(-1)*( b(2)/(b(1)^2+b(2)^2) ) + sd(2)*( b(1)/(b(1)^2+b(2)^2) ) );
            %   for md, derivative of norm y=|| [v_x, v_y] ||
            md_err = abs(sd(1)*( b(1)/sqrt(b(1)^2+b(2)^2) ) + sd(2)*( b(2)/sqrt(b(1)^2+b(2)^2) ));
            
            % convert std into a confidence interval
            tc = 1.96; % critical t value
            
            pds(unit,:) = [pd, pd-pd_err*tc, pd+pd_err*tc];
            mds(unit,:) = [md, md-md_err*tc, md+md_err*tc];
            
            pds_all(unit,:) = pd_all';
            
        case 'fit'
            [b,~,STATS] = glmfit(glm_input,fr(:,unit),'poisson');
            
            % get the relevant parameters for PDs
            b = b([idx1; idx2]);
            se = STATS.se([idx1; idx2]);
            sd = se;
            % turn standard error into standard deviation for propagation
            %sd = se.*sqrt(length(fr(:,unit)));
            %             sd = se;
            
            pds_all = [];
            
            % Set outputs
            md = norm(mean(b,1));
            pd = atan2(b(2),b(1));
            
            % propagate error using the derivative (chain rule applies)
            %   for pd, y=arctan(v_y/v_x)
            pd_err = abs( sd(1)*(-1)*( b(2)/(b(1)^2+b(2)^2) ) + sd(2)*( b(1)/(b(1)^2+b(2)^2) ) );
            %   for md, derivative of norm y=|| [v_x, v_y] ||
            md_err = abs(sd(1)*( b(1)/sqrt(b(1)^2+b(2)^2) ) + sd(2)*( b(2)/sqrt(b(1)^2+b(2)^2) ));
            
            % convert std into a confidence interval
            tc = 1.96; % critical t value
            
            pds(unit,:) = [pd, pd-pd_err*tc, pd+pd_err*tc];
            mds(unit,:) = [md, md-md_err*tc, md+md_err*tc];
    end
    
    
    
end


%% build output struct
out.pds = pds;
out.mds = mds;
out.pds_all = pds_all;

out.sg = sg;
out.mt = mt;
out.params.tune_type = tuningPeriod;
out.params.movement_time = movementTime;
out.params.array = useArray;
out.params.glm_model = glmModel;
out.params.glm_bin_size = glmBinSize;
out.params.glm_block_time = glmBlockTime;

