function out = fitTuningCurves_GLM(data,params,tuningPeriod,useArray)
% notes about inputs
% notes about outputs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get all of the parameters
holdTime = str2double(params.exp.target_hold_high{1});
epochs = params.exp.epochs;
movementTime = params.tuning.movementTime;
blocks = params.tuning.blocks;
glmModel = params.tuning.glmModel;
glmBinSize = params.tuning.glmBinSize;
glmBlockTime = params.tuning.glmBlockTime;
glmRandSample = params.tuning.glmRandomSample;
doType = params.tuning.doGLMType;
latency = params.tuning.([lower(useArray) '_latency']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mt = [];

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
    [blockMT,~] = filterMovementTable(data,params,true);
    
    disp(['Using ' tuningPeriod ' movement period, ' num2str(movementTime) ' second window...']);
    
    for iBlock = 1:length(blockMT)
        mt = blockMT{iBlock};
        % Get spike count for each channel in desired window
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
        
        buildGLMInputs;
        switch lower(doType)
            case 'subset'
                [pds,mds,pds_all] = calculateGLMTuning(glm_input,fr,idx1,idx2,doType,blockLength,glmRandSample);
            case 'fit'
                [pds,mds,pds_all] = calculateGLMTuning(glm_input,fr,idx1,idx2,doType);
        end
        
        out(iBlock).pds = pds;
        out(iBlock).mds = mds;
        out(iBlock).pds_all = pds_all;
        
        out(iBlock).sg = sg;
        out(iBlock).mt = mt;
        out(iBlock).params = params;
        
    end
    
else % don't break down by movements, use whole file continuously
    % use data in block segment only. Doesn't support number of trials for
    % block divisions, only proportion of total file
    disp('Using continuous data file...');
    blockIdx = strcmpi(epochs,data.meta.epoch);
    b = blocks{blockIdx};
    
    if isempty(b)
        b = [0 1];
    end
    
    for iBlock = 1:length(b)-1
        first = floor(b(iBlock)*length(binT));
        last = ceil(b(iBlock+1)*length(binT));
        if first < 1
            first = 1;
        end
        if last > length(binT)
            last = length(binT);
        end
        idx = first:last;
        
        
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
        
        % now do GLM fitting
        buildGLMInputs;
        switch lower(doType)
            case 'subset'
                [pds,mds,pds_all] = calculateGLMTuning(glm_input,fr,idx1,idx2,doType,blockLength,glmRandSample);
            case 'fit'
                [pds,mds,pds_all] = calculateGLMTuning(glm_input,fr,idx1,idx2,doType);
        end
        
        out(iBlock).pds = pds;
        out(iBlock).mds = mds;
        out(iBlock).pds_all = pds_all;
        out(iBlock).sg = sg;
        out(iBlock).mt = mt;
        out(iBlock).params = params;
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calculateGLMTuning(glm_input,fr,idx1,idx2,varargin)

doType = varargin{1};

for unit = 1:size(fr,2)
    %disp(['Starting unit ' num2str(unit) '...']);
    
    % this fits model multiple times on different chunks of data to get a
    % sense for parameter variability
    switch lower(doType)
        case 'subset'
            blockLength = varargin{2};
            glmRandSample = varargin{3};
            
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

end

