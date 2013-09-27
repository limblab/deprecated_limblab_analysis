function adaptation = getAdaptationMetrics(expParamFile)
% GETADAPTATIONMETRICS  Gets metrics to show adaptation progression
%
%   Current returns mean curvature for each movement and a sliding window
% average of that curvature
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
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
baseDir = params.out_dir{1};
useDate = params.date{1};
taskType = params.task{1};
adaptType = params.adaptation_type{1};
epochs = params.epochs;
clear params

dataPath = fullfile(baseDir,useDate);

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
    load(getFile);
    
    t = data.cont.t;
    vel = data.cont.vel;
    acc = data.cont.acc;
    
    % filter the data to smooth out curvature calculation
    f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
    svel = filter(f, 1, vel);
    sacc = filter(f, 1, acc);
    
    t = t(filtWidth/2:end-filtWidth/2);
    vel = svel(filtWidth/2:end-filtWidth/2,:);
    acc = sacc(filtWidth/2:end-filtWidth/2,:);
    
    mt = data.movement_table;
    holdTime = data.params.hold_time;
    
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
    timeToTargets = ( mt(:,end) - mt(:,4) ) - holdTime;
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
        
        adaptation.(epochs{iEpoch}).curvature_means = allCurvMeans;
        adaptation.(epochs{iEpoch}).sliding_curvature_mean = curvMeans;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    adaptation.(epochs{iEpoch}).movement_table = mt;
    adaptation.(epochs{iEpoch}).vel = vel;
    adaptation.(epochs{iEpoch}).acc = acc;
    adaptation.(epochs{iEpoch}).block_times = blockTimes';
    adaptation.(epochs{iEpoch}).meta = data.meta;

    params.metrics = useMetrics;
    params.behavior_window = behavWin;
    params.step_size = stepSize;
    params.filter_width = filtWidth;
    params.movement_threshold = moveThresh;
    adaptation.(epochs{iEpoch}).params = params;
end

% save the new file with adaptation info
disp(['Saving data to ' saveFile]);
save(saveFile,'adaptation');

