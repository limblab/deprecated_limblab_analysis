function adaptation = getAdaptationMetrics(expParamFile)
% NEURONREPORTS  Constructs html document to summarize a session's data
%
%   This function will load processed data and generate html for a summary
% report with data and figures.
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

% resampling for CO correlation purposes
n = 3000;

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
behavWin = str2double(params.behavior_window{1});
winSize = str2double(params.movement_time{1});
stepSize = str2double(params.behavior_step{1});
filtWidth = str2double(params.filter_width{1});
moveThresh = str2double(params.movement_threshold{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

saveFile = fullfile(dataPath,[taskType '_' adaptType '_adaptation_' useDate '.mat']);

% for center out, get baseline movement trajectories to each target
if strcmpi(taskType,'CO')
    getFile = fullfile(dataPath,[taskType '_' adaptType '_BL_' useDate '.mat']);
    if ~exist(getFile,'file')
        error('Could not locate baseline file');
    end
    load(getFile);
    
    blTraces = getCOBaselineTrajectories(data);
    
end

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
    
    %     figure;
    %     hold all
    %     plot(vel(1:3000),'b','LineWidth',2);
    %     plot(y(w/2:3000+w/2),'r');
    
    mt = filterMovementTable(data,false);
    holdTime = data.params.hold_time;
    
    %% Get movement information
    % find times when velocity goes above that threshold
    disp('Getting movement data...')
    moveWins = zeros(size(mt,1),2);
    for iMove = 1:size(mt,1)
        % movement table: [ target angle, on_time, go cue, move_time, peak_time, end_time ]
        % has the start of movement window, end of movement window
        moveWins(iMove,:) = [mt(iMove,5)-winSize/2, mt(iMove,5)+winSize/2];
    end
    
    % compute metrics
    moveCurvs = ( vel(:,1).*acc(:,2) - vel(:,2).*acc(:,1) )./( (vel(:,1).^2 + vel(:,2).^2).^(3/2) );
    timeToTargets = ( mt(:,end) - mt(:,4) ) - holdTime;
    reactionTimes = mt(:,4) - mt(:,3);
    
    blockTimes = t(1):stepSize:t(end)-behavWin;
    
    % now group curvatures in blocks to track adaptation
    curvMeans = zeros(length(blockTimes),2);
    curvMaxes = zeros(length(blockTimes),2);
    rtMeans = zeros(length(blockTimes),1);
    rtSTDs = zeros(length(blockTimes),1);
    tttMeans = zeros(length(blockTimes),1);
    tttSTDs = zeros(length(blockTimes),1);
    
    moveCount = zeros(length(blockTimes),1);
    
    disp('Getting adaptation data...')
    for tMove = 1:length(blockTimes)
        
        relMoveInds = moveWins(:,1) >= blockTimes(tMove) & moveWins(:,1) < blockTimes(tMove) + behavWin;
        
        % how many total movements have occured up until this point?
        moveCount(tMove) = sum(moveWins(:,1) < blockTimes(tMove));
        
        relMoves = moveWins(relMoveInds,:);
        tempMean = zeros(size(relMoves,1),1);
        tempMax = zeros(size(relMoves,1),1);
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
            tempMax(iMove) = max(abs(tempCurv));
        end
        
        curvMeans(tMove,:) = [mean(tempMean) std(tempMean)];
        curvMaxes(tMove,:) = [mean(tempMax) std(tempMax)];
        
        % compute mean reaction time over movements
        rtMeans(tMove) = mean(reactionTimes(relMoveInds));
        rtSTDs(tMove) = std(reactionTimes(relMoveInds));
        
        % compute mean time to target over movements
        tttMeans(tMove) = mean(timeToTargets(relMoveInds));
        tttSTDs(tMove) = std(timeToTargets(relMoveInds));
        
    end
    
    adaptation.(epochs{iEpoch}).vel = vel;
    adaptation.(epochs{iEpoch}).acc = acc;
    
    adaptation.(epochs{iEpoch}).curvature = moveCurvs;
    adaptation.(epochs{iEpoch}).curvature_max = curvMaxes;
    adaptation.(epochs{iEpoch}).curvature_mean = curvMeans;
    adaptation.(epochs{iEpoch}).reaction_time = reactionTimes;
    adaptation.(epochs{iEpoch}).reaction_time_mean = [rtMeans rtSTDs];
    adaptation.(epochs{iEpoch}).time_to_target = timeToTargets;
    adaptation.(epochs{iEpoch}).time_to_target_mean = [tttMeans tttSTDs];
    
    adaptation.(epochs{iEpoch}).movement_table = mt;
    adaptation.(epochs{iEpoch}).movement_counts = moveCount';
    adaptation.(epochs{iEpoch}).block_times = blockTimes';
    adaptation.(epochs{iEpoch}).meta = data.meta;
end


% save the new file with adaptation info
disp(['Saving data to ' saveFile]);
save(saveFile,'adaptation');

