function adaptation = getAdaptationMetrics(expParamFile,outDir)
% GETADAPTATIONMETRICS  Gets metrics to show adaptation progression
%
%   Current returns mean curvature for each movement and a sliding window
% average of that curvature
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   outDir: (string) directory for output
%
% OUTPUTS:
%   adaptation: (struct) result struct with metrics on adaptation for each
%     file specified by expParamFile (under "epochs")
%       - Time to Target
%       - Reaction Time
%       - Curvature (velocity and acceleration are filtered here)
%
% NOTES:
%   -This function requires several bits of pre-processing
%       1) Create a data struct from the Cerebus files (makeDataStruct)
%   - This function will automatically write the struct to an output file
%   - See "experimental_parameters_doc.m" for documentation on expParamFile
%   - Analysis parameters file must exist (see "analysis_parameters_doc.m")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(expParamFile);
useDate = params.date{1};
taskType = params.task{1};
adaptType = params.adaptation_type{1};
epochs = params.epochs;
rotationAngle = str2double(params.rotation_angle{1});
clear params

dataPath = fullfile(outDir,useDate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(dataPath, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
useMetrics = params.adaptation_metrics;
behavWin = str2double(params.behavior_window{1});
stepSize = str2double(params.behavior_step{1});
filtWidth = str2double(params.filter_width{1});
moveThresh = str2double(params.movement_threshold{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

saveFile = fullfile(dataPath,[taskType '_' adaptType '_adaptation_' useDate '.mat']);

% load files
for iEpoch = 1:length(epochs)
    
    disp(['Loading data for ' epochs{iEpoch} '...']);

    getFile = fullfile(dataPath,[taskType '_' adaptType '_' epochs{iEpoch} '_' useDate '.mat']);
    load(getFile,'cont');
    load(getFile,'params');
    load(getFile,'meta');
    
    t = cont.t;
    pos = cont.pos;
    vel = cont.vel;
    acc = cont.acc;
    
    % put hand coordinates into cursor coordinates
    if ( strcmp(adaptType,'VR') || strcmp(adaptType,'VRFF') ) && strcmp(epochs{iEpoch},'AD')
        xoffset = 5;
        yoffset = -35;
        pos(:,1) = pos(:,1)-xoffset;
        pos(:,2) = pos(:,2)-yoffset;
        
        R = [cos(rotationAngle) -sin(rotationAngle); sin(rotationAngle) cos(rotationAngle)];
        newPos = zeros(size(pos));
        for j = 1:length(pos)
            newPos(j,:) = R*(pos(j,:)');
        end
        
        % adjust for an offset from my math above
        offset = [newPos(1,1)-pos(1,1), newPos(1,2)-pos(1,2)];
        pos(:,1) = pos(:,1)+offset(1);
        pos(:,2) = pos(:,2)+offset(2);
        
        rotAng = rotationAngle;
    else
        rotAng = 0;
    end
    
    % filter the data to smooth out curvature calculation
    f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
    svel = filter(f, 1, vel);
    sacc = filter(f, 1, acc);
    
    t = t(filtWidth/2:end-filtWidth/2);
    vel = svel(filtWidth/2:end-filtWidth/2,:);
    acc = sacc(filtWidth/2:end-filtWidth/2,:);
    
    load(getFile,'movement_table');
    mt = movement_table;
%     data = load(getFile);
%     mt = filterMovementTable(data,'movement',false,[]);
    clear movement_table;
    holdTime = params.hold_time;
    
    % find the time windows of each movement
    disp('Getting movement data...')
    moveWins = zeros(size(mt,1),2);
    for iMove = 1:size(mt,1)
        % movement table: [ target angle, on_time, go cue, move_time, peak_time, end_time ]
        % has the start of movement window, end of movement window
        moveWins(iMove,:) = [mt(iMove,4), mt(iMove,6)];
    end
    
    blockTimes = 1:stepSize:size(mt,1)-behavWin;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get time to target and reaction time
    timeToTargets = ( mt(:,6) - mt(:,4) ) - holdTime;
    reactionTimes = mt(:,4) - mt(:,3);
    
    rtMeans = zeros(length(blockTimes)-1,1);
    rtSTDs = zeros(length(blockTimes)-1,1);
    tttMeans = zeros(length(blockTimes)-1,1);
    tttSTDs = zeros(length(blockTimes)-1,1);
    for iMove = 1:length(blockTimes)
        relMoveInds = blockTimes(iMove):blockTimes(iMove)+behavWin;
        
        % compute mean reaction time over movements
        rtMeans(iMove) = mean(reactionTimes(relMoveInds));
        rtSTDs(iMove) = std(reactionTimes(relMoveInds));
        
        % compute mean time to target over movements
        tttMeans(iMove) = mean(timeToTargets(relMoveInds));
        tttSTDs(iMove) = std(timeToTargets(relMoveInds));
        
    end
    
    adaptation.(epochs{iEpoch}).reaction_time = reactionTimes;
    adaptation.(epochs{iEpoch}).reaction_time_mean = [rtMeans rtSTDs];
    adaptation.(epochs{iEpoch}).time_to_target = timeToTargets;
    adaptation.(epochs{iEpoch}).time_to_target_mean = [tttMeans tttSTDs];
    
    % time from movement onset to peak
    adaptation.(epochs{iEpoch}).move_to_peak = mt(:,5) - mt(:,4);
    adaptation.(epochs{iEpoch}).targ_to_peak = mt(:,5) - mt(:,3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get movement information
    if any(ismember(useMetrics,'curvature'))
        % find times when velocity goes above that threshold
        disp('Getting curvature data...')
        allCurvMeans = zeros(size(mt,1),1);
        for iMove = 1:size(mt,1)
            % get curvature in that window
            idx = find(t >= moveWins(1) & t < moveWins(2));
            
            tempAcc = acc(idx,:);
            tempVel = vel(idx,:);
            % ran into a problem sometimes where velocity/acc drop almost to
            % zero seemingly sproadically so my curvatures went towards infinity
            badInds = sqrt(tempVel(:,1).^2 + tempVel(:,2).^2) < moveThresh;
            tempVel(badInds,:) = [];
            tempAcc(badInds,:) = [];
            
            tempCurv = ( tempVel(:,1).*tempAcc(:,2) - tempVel(:,2).*tempAcc(:,1) )./( (tempVel(:,1).^2 + tempVel(:,2).^2).^(3/2) );
            allCurvMeans(iMove) = mean(tempCurv);
        end
        
        % now group curvatures in blocks to track adaptation
        curvMeans = zeros(length(blockTimes),2);
        for tMove = 1:length(blockTimes)
            relMoveInds = blockTimes(tMove):blockTimes(tMove)+behavWin;
            relMoves = moveWins(relMoveInds,:);
            
            tempMean = zeros(size(relMoves,1),1);
            for iMove = 1:size(relMoves,1)
                idx = find(t >= relMoves(iMove,1) & t < relMoves(iMove,2));
                tempAcc = acc(idx,:);
                tempVel = vel(idx,:);
                % ran into a problem sometimes where velocity/acc drop almost to
                % zero seemingly sproadically so my curvatures went towards infinity
                badInds = sqrt(tempVel(:,1).^2 + tempVel(:,2).^2) < moveThresh;
                tempVel(badInds,:) = [];
                tempAcc(badInds,:) = [];
                
                tempCurv = ( tempVel(:,1).*tempAcc(:,2) - tempVel(:,2).*tempAcc(:,1) )./( (tempVel(:,1).^2 + tempVel(:,2).^2).^(3/2) );
                tempMean(iMove) = mean(tempCurv);
            end
            
            curvMeans(tMove,:) = [mean(tempMean) std(tempMean)];
        end
        
        adaptation.(epochs{iEpoch}).curvatures = allCurvMeans;
        adaptation.(epochs{iEpoch}).curvature_mean = curvMeans;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(ismember(useMetrics,'angle_error'))
        disp('Getting angle error data...')
        % look at error between angle at peak speed and target angle
        targAngs = mt(:,1);
                
        % loop along all movements and get angle at time of peak speed
        % peak speed is mt(trial,5)
        moveAngs = zeros(size(mt,1),1);
        for iMove = 1:size(mt,1)
            t_start = mt(iMove,4);
            t_peak = mt(iMove,5);
            t_end = mt(iMove,6);

            % find direction of movement at time of peak speed
            %   compare position and peak to position at start
            pos_start = pos(find(t <= t_start,1,'last'),:);
            pos_peak = pos(find(t <= t_peak,1,'last'),:);
            pos_end = pos(find(t <= t_end,1,'last'),:);

            % get takeoff angle
            moveAngs(iMove,1) = atan2(pos_peak(2)-pos_start(2),pos_peak(1)-pos_start(1));

            targAngs(iMove,1) = atan2(pos_end(2)-pos_start(2),pos_end(1)-pos_start(1))+rotAng;
            
        end
        
        % if it's visual rotation, must adjust for visual offset
        if (strcmp(adaptType,'VR') || strcmp(adaptType,'VRFF')) && strcmp(epochs{iEpoch},'AD')
            moveAngs = moveAngs + rotationAngle;
        end
        
        errs = angleDiff( targAngs, moveAngs, true, true);
        
        % now group error in blocks to track adaptation
        errMeans = zeros(length(blockTimes),2);
        for tMove = 1:length(blockTimes)
            relMoveInds = blockTimes(tMove):blockTimes(tMove)+behavWin;
            relErrs = errs(relMoveInds,:);
            
            errMeans(tMove,:) = [mean(relErrs) std(relErrs)];
        end
        
        adaptation.(epochs{iEpoch}).errors = errs;
        adaptation.(epochs{iEpoch}).angle_error_mean = errMeans;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(ismember(useMetrics,'time_to_target'))
        disp('Getting time to target data...')
        % get time to target from movement table
        % end time minus go cue
        ttts = mt(:,6)-mt(:,3);
        
        % now group error in blocks to track adaptation
        tttMeans = zeros(length(blockTimes),2);
        for tMove = 1:length(blockTimes)
            relMoveInds = blockTimes(tMove):blockTimes(tMove)+behavWin;
            relTTTs = ttts(relMoveInds,:);
            
            tttMeans(tMove,:) = [mean(relTTTs) std(relTTTs)];
        end
        
        adaptation.(epochs{iEpoch}).time_to_target = ttts;
        adaptation.(epochs{iEpoch}).time_to_target_mean = tttMeans;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    adaptation.(epochs{iEpoch}).movement_table = mt;
    adaptation.(epochs{iEpoch}).vel = vel;
    adaptation.(epochs{iEpoch}).acc = acc;
    adaptation.(epochs{iEpoch}).block_times = blockTimes';
    adaptation.(epochs{iEpoch}).meta = meta;
    
    params.metrics = useMetrics;
    params.behavior_window = behavWin;
    params.step_size = stepSize;
    params.filter_width = filtWidth;
    params.movement_threshold = moveThresh;
    adaptation.(epochs{iEpoch}).params = params;
end

% save the new file with adaptation info
disp(['Saving data to ' saveFile]);
save(saveFile,'-struct','adaptation');

