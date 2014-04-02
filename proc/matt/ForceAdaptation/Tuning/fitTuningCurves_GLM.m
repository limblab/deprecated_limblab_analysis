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
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
latency = str2double(params.([lower(useArray) '_latency']){1});
confLevel = str2double(params.confidence_level{1});
bootNumIters = str2double(params.number_iterations{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mt = [];
% statTestType = 'bootstrap';
% hack for confidence without bootstrapping
statTestType = 'glm';
seFactor = 1;

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

if strfind(lower(glmModel),'targ')
    glmTarg = [];
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
            useWin(trial,:) = [mt(trial,6)-movementTime, mt(trial,6)];
        elseif strcmpi(tuningPeriod,'pre') % Use pre-movement period
            useWin(trial,:) = [mt(trial,2), mt(trial,4)];
        elseif strcmpi(tuningPeriod,'full') % Use entire movement
            useWin(trial,:) = [mt(trial,2), mt(trial,6)];
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
        if strfind(lower(glmModel),'targ')
            % target direction
            glmTarg = [glmTarg; atan2(centers(trial,2)-binPos(idx,2),centers(trial,1)-binPos(idx,1))+pi];
        end
        
    end
    
    % Make the number of samples equal to the number of points for bootstrap
    use_samp = length(glmT);
    
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
    if strfind(lower(glmModel),'targ')
        % target direction
        binTarg = zeros(size(binPos,1),1);
        for iMove = 1:size(centers,1)
            tstart = mt(2);
            tend = mt(6);
            
            inds = binT >= tstart & binT < tend;
            binTarg(inds) = atan2(centers(iMove,2)-binPos(inds,2),centers(iMove,1)-binPos(inds,1))+pi;
        end
        glmTarg = binTarg(idx);
    end
    
    glmT = binT(idx,:);
    
    fr = fr(idx,:);
    
    use_samp = length(glmT);
end

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
    case 'targ'
        % direction of target relative to hand at each time point
        glm_input = [glmTarg];
    otherwise
        error('unknown model: %s', model);
end


%% Bootstrap
switch lower(statTestType)
    case 'bootstrap'
        disp(['Running bootstrap with ' num2str(bootNumIters) ' iterations...']);
        
        bootMDs = zeros(size(sg,1),bootNumIters);
        bootPDs = zeros(size(sg,1),bootNumIters);
        pds = zeros(size(sg,1),1);
        mds = zeros(size(sg,1),1);
        for unit = 1:size(sg,1)
            disp(['Starting unit ' num2str(unit) '...']);
            b_mat = zeros(size(glm_input,2)+1,bootNumIters);
            for bootCt=1:bootNumIters
                if mod(bootCt,50)==0
                    disp(['Iteration ' num2str(bootCt) '...']);
                end
                % grab test set indices randomly
                
                % randomly grab binned data points
                idx = randi([1,length(glmT)],use_samp,1);
                
                % fit glm model
                [b,~,s] = glmfit(glm_input(idx,:),fr(idx,unit),'poisson');
                
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
                    case 'targ'
                        bootMDs(unit,bootCt) = norm([b(2) b(3)]);
                        bootPDs(unit,bootCt) = atan2(b(3),b(2));
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
                case 'targ'
                    bv = [avg_b(2) avg_b(3)]; % glm weights on x and y velocity
            end
            
            % Set outputs
            mds(unit) = norm(bv);
            pds(unit) = atan2(bv(2),bv(1));
            
        end
        
        
        %% Find 95 percent confidence interval bounds
        % Throw out top and bottom 2.5 percent of samples for each channel
        % (according to PD)
        
        pds = circ_mean(bootPDs')';
        mds = circ_mean(bootMDs')';
        
        % Build vector of distances from mean for each channel
        ang_dist = bootPDs-pds(:,ones(1,bootNumIters));
        ang_dist(ang_dist>pi) = ang_dist(ang_dist>pi)-2*pi;
        ang_dist(ang_dist<-pi) = ang_dist(ang_dist<-pi)+2*pi;
        
        % sort vectors along angle distance for each unit
        ang_dist_sort = sort(ang_dist,2);
        
        % calculate index range for 2.5 to 97.5 percent
        ang_ind_low = ceil(bootNumIters*(1-confLevel)/2);
        ang_ind_high = floor(bootNumIters*confLevel);
        
        if ang_ind_low < 1
            ang_ind_low = 1;
        end
        
        % Calculate confidence bounds (vector, each element corresponds to a
        % channel)
        pd_cis = [ang_dist_sort(:,ang_ind_low) + pds, ang_dist_sort(:,ang_ind_high) + pds];
        pd_cis(pd_cis>pi) = pd_cis(pd_cis>pi)-2*pi;
        pd_cis(pd_cis<-pi) = pd_cis(pd_cis<-pi)+2*pi;
        
        %     for i = 1:100,
        %         figure;
        %         polar(bootPDs(i,:),ones(size(bootPDs(i,:))),'.');
        %         hold all;
        %         polar([pds(i) pds(i)],[0 1],'r');
        %         polar([pd_cis(i,1) pd_cis(i,1)],[0 1],'g');
        %         polar([pd_cis(i,2) pd_cis(i,2)],[0 1],'g');
        %         title(num2str([pds(i) pd_cis(i,:)].*180/pi));
        %         pause; close all;
        %     end
        %     bootpds = BL.M1.glm.file.boot_pds;
        %     pds = BL.M1.glm.file.pds;
        %     for i = 1:100,
        %         figure;
        %         polar(bootpds(i,:),ones(size(bootpds(i,:))),'.');
        %         hold all;
        %         polar([pds(i,1) pds(i,1)],[0 1],'r');
        %         polar([pds(i,2) pds(i,2)],[0 1],'g');
        %         polar([pds(i,3) pds(i,3)],[0 1],'g');
        %         pause; close all;
        %     end
        
        % Build vector of distances from mean for each channel
        md_dist = bootMDs - mds(:,ones(1,bootNumIters));
        % sort vectors along angle distance for each unit
        md_dist_sort = sort(md_dist,2);
        md_cis = [md_dist_sort(:,ang_ind_low) + mds, md_dist_sort(:,ang_ind_high) + mds];
        
    case 'glm'
        pds = zeros(size(sg,1),1);
        mds = zeros(size(sg,1),1);
        for unit = 1:size(sg,1)
            disp(['Starting unit ' num2str(unit) '...']);
            % fit glm model
            try
                [b,~,s] = glmfit(glm_input,fr(:,unit),'poisson');
            catch
                disp('error in fit... fitTuningCurves_GLM.m');
                keyboard
            end
            
            % Get model outputs
            switch lower(glmModel)
                case 'posvel'
                    bv = [b(4) b(5)]; % glm weights on x and y velocity
                    sv = [s.se(4) s.se(5)];
                case 'forceonly'
                    bv = [b(2) b(3)]; % glm weights on x and y force
                case 'pos'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'vel'
                    bv = [b(2) b(3)]; % glm weights on x and y velocity
                    sv = [s.se(2) s.se(3)];
                case 'nospeed'
                    bv = [b(4) b(5)]; % glm weights on x and y velocity
                    sv = [s.se(4) s.se(5)];
                case 'forcevel'
                    bv = [b(4) b(5)]; % glm weights on x and y velocity
                    sv = [s.se(4) s.se(5)];
                case 'forceposvel'
                    bv = [b(6) b(7)]; % glm weights on x and y velocity
                    sv = [s.se(6) s.se(7)];
                case 'ppforcevel'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'ppforceposvel'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'powervel'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'ppcartfvp'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'targ'
                    bv = [b(2) b(3)]; % glm weights on x and y velocity
                    sv = [s.se(2) s.se(3)];
            end
            
            % Set outputs
            mds(unit) = norm(bv);
            pds(unit) = atan2(bv(2),bv(1));
            
            pd_cis(unit,:) = [atan2(bv(2)-seFactor*sv(2),bv(1)-seFactor*sv(1)) atan2(bv(2)+seFactor*sv(2),bv(1)+seFactor*sv(1))];
            md_cis(unit,:) = [0 0];
            
            bootPDs = [];
            bootMDs = [];
            
        end
end


%% build output struct
out.pds = [pds pd_cis];
out.mds = [mds md_cis];

out.boot_pds = bootPDs;
out.boot_mds = bootMDs;

out.sg = sg;
out.mt = mt;
out.params.stats = {'bootstrap', bootNumIters, confLevel};
out.params.tune_type = tuningPeriod;
out.params.movement_time = movementTime;
out.params.glm_model = glmModel;
out.params.glm_bin_size = glmBinSize;

