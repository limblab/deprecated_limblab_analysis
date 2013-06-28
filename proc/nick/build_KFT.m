function build_KFT(dataFile,delayBins,genPlots)
% function build_KFT(dataFile,delayBins,genPlots)
%
% Builds a Kalman Filter with target information in the state vector from a
% CENTER OUT data file specified in DATAFILE.
%
% If dataFile is a Plexon file or bdf file, the build_KFT will convert it
% to a binnedData file with 50ms bins in order to train the KFT.
%
% DELAYBINS specifies the delay between spikes and predicitons in bins. 
% Default is 0 (use current observations).
%
% GENPLOTS should be 1 to generate plots of the fit. Default is 0.

% check inputs
if (nargin < 1 || nargin >3);
    disp('wrong number of inputs')
    return
end
if (nargin < 3)
    genPlots = 0;
    if (nargin == 1)
        delayBins = 0;
    end
end

% set paths to include necessary functions
if isempty(strfind(path,'Kalman'))
    addpath('Kalman'); % for kalman_filter
    addpath('KPMstats'); % for gaussian_prob in kalman_filter
end
if (exist('BMI_analysis','dir') ~= 7)
    load_paths; % for s1_analysis functions
end

% enter handle offsets... only necessary for binnedData files
x_offset = 0;
y_offset = 0;

% get datafile
[pathstr, name, ext] = fileparts(dataFile);

% if dataFile is a .plx file convert it to bdf and load into workspace
if strcmp(ext,'.plx')
    disp('converting .plx file to bdf...');
    out_struct = get_plexon_data(dataFile);
    disp('extracting offsets...');
    x_offset = bytes2float(out_struct.databursts{1,2}(7:10));
    y_offset = bytes2float(out_struct.databursts{1,2}(11:14));
else
    load(dataFile);
end

% if dataFile is bdf covert it to binnedData file with 50ms bins
if exist('out_struct','var')
    disp('converting bdf file to binnedData...');
    assignin('base','temp_out_struct',out_struct);
    binnedData = convertBDF2binned('temp_out_struct', 0.05, 1, 0);
    evalin('base','clear temp_out_struct');
end

% to remove potential small timing discrepencies
binnedData.timeframe = round(binnedData.timeframe.*100)./100;

% set up fields for output structure
binsize = binnedData.timeframe(2) - binnedData.timeframe(1); % in seconds
neuronIDs = spikeguide2neuronIDs(binnedData.spikeguide);
outnames = ['x_pos       ';
            'y_pos       ';
            'x_vel       ';
            'y_vel       ';
            'x_accel     ';
            'y_accel     ';
            'one         '];
FromData = [name ext];

pos = binnedData.cursorposbin + repmat([x_offset y_offset],length(binnedData.cursorposbin),1);
% vel = binnedData.velocbin(:,1:2);
% acc = binnedData.accelbin(:,1:2);
vel = [0 0; diff(pos)]/binsize;
acc = [0 0; diff(vel)]/binsize;
spikes = binnedData.spikeratedata;
% PCcoeffs = princomp(binnedData.spikeratedata);
% spikes = binnedData.spikeratedata*(PCcoeffs(1:10,:))';

% adjust timing of words and target info to coincide with bins
binnedData.words(:,1) = round((ceil(binnedData.words(:,1)./binsize).*binsize).*100)./100;
binnedData.targets.corners(:,1) = round((ceil(binnedData.targets.corners(:,1)./binsize).*binsize).*100)./100;

% extract target times and positions for center and outer targets
centergoals = zeros(length(find(binnedData.words(:,2) == 48)),3);
centergoals(:,1) = binnedData.words(binnedData.words(:,2) == 48,1);

outergoals = repmat(binnedData.words([false; false; (binnedData.words(3:end-3,2) >= 64 & binnedData.words(3:end-3,2) < 80)],1),1,3);
for x = 1:length(outergoals)
    outergoals(x,2) = mean(binnedData.targets.corners(find(binnedData.targets.corners(:,1) > outergoals(x,1),1,'first'),[2 4]),2);
    outergoals(x,3) = mean(binnedData.targets.corners(find(binnedData.targets.corners(:,1) > outergoals(x,1),1,'first'),[3 5]),2);
end
goals = sortrows([centergoals; outergoals],1);
startindex = find(binnedData.timeframe == goals(1,1));

targets = zeros(length(pos),2);
goal_index = 0;
for x = startindex:length(binnedData.timeframe)
    if goal_index < length(goals)
        if binnedData.timeframe(x) == goals(goal_index + 1,1)
            goal_index = goal_index + 1;
        end
    end
    targets(x,:) = goals(goal_index,2:3);
end

state = [pos vel acc ones(length(pos),1) targets];
% state = [pos vel ones(length(pos),1) targets];

[A, C, Q, R] = train_kf(state(delayBins+startindex:end,:), spikes(startindex:end-delayBins,:));

%% Test and plot predictions - Need to update to work with KFT

if genPlots

    reach_spikes = cell(length(goals),1);
    goal_index = 0;
    for x = startindex:length(binnedData.timeframe)
        if goal_index < length(goals)
            if binnedData.timeframe(x) == goals(goal_index + 1,1)
                goal_index = goal_index + 1;
            end
        end
        if x > delayBins
            reach_spikes{goal_index} = [reach_spikes{goal_index}(:,:); spikes(x-delayBins,:)];
        end
    end
    
    pred_state = state(startindex,:)';
    initV = zeros(size(state,2));
    for x = 1:length(reach_spikes)
        initState = [pred_state(1:end-2,end); goals(x,2); goals(x,3)];
        [reach_pred_state, V, VV, loglik] = kalman_filter(reach_spikes{x}(:,:)', A, C, Q, 8*R, initState, initV);
        pred_state = [pred_state reach_pred_state];
        initV = V(:,:,end);
    end
    pred_state = pred_state(:,2:end);

    [xpr2 xpvaf xpmse] = getvaf(pos(max(delayBins+1,startindex):end,1),pred_state(1,:)');
    [ypr2 ypvaf ypmse] = getvaf(pos(max(delayBins+1,startindex):end,2),pred_state(2,:)');
    [xvr2 xvvaf xvmse] = getvaf(vel(max(delayBins+1,startindex):end,1),pred_state(3,:)');
    [yvr2 yvvaf yvmse] = getvaf(vel(max(delayBins+1,startindex):end,2),pred_state(4,:)');

    figure; plot(binsize:binsize:binsize*length(pred_state),vel(max(delayBins+1,startindex):end,1),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(3,:),'r')
    title(['x velocity prediction, delay = ' num2str(delayBins) ' vaf = ' num2str(xvvaf)])
    xlabel('time (s)')
    ylabel('velocity (cm/s)')

    figure; plot(binsize:binsize:binsize*length(pred_state),vel(max(delayBins+1,startindex):end,2),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(4,:),'r')
    title(['y velocity prediction, delay = ' num2str(delayBins) ' vaf = ' num2str(yvvaf)])
    xlabel('time (s)')
    ylabel('velocity (cm/s)')

    figure; plot(binsize:binsize:binsize*length(pred_state),targets(max(delayBins+1,startindex):end,1),'b'); hold on; plot(binsize:binsize:binsize*length(pred_state),pos(max(delayBins+1,startindex):end,1),'k'); plot(binsize:binsize:binsize*length(pred_state),pred_state(1,:),'r');
    title(['x position prediction, delay = ' num2str(delayBins) ' vaf = ' num2str(xpvaf)])
    xlabel('time (s)')
    ylabel('position (cm)')

    figure; plot(binsize:binsize:binsize*length(pred_state),targets(max(delayBins+1,startindex):end,2),'b'); hold on; plot(binsize:binsize:binsize*length(pred_state),pos(max(delayBins+1,startindex):end,2),'k'); plot(binsize:binsize:binsize*length(pred_state),pred_state(2,:),'r')
    title(['y position prediction, delay = ' num2str(delayBins) ' vaf = ' num2str(ypvaf)])
    xlabel('time (s)')
    ylabel('position (cm)')

    figure; plot(binsize:binsize:binsize*length(pred_state),targets(max(delayBins+1,startindex):end,1),'b'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(8,:),'r');
    title(['x target estimate, delay = ' num2str(delayBins)])
    xlabel('time (s)')
    ylabel('position (cm)')

    figure; plot(binsize:binsize:binsize*length(pred_state),targets(max(delayBins+1,startindex):end,2),'b'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(9,:),'r')
    title(['y target estimate, delay = ' num2str(delayBins)])
    xlabel('time (s)')
    ylabel('position (cm)')
end

disp(['file saved as ' pathstr '\' name '_KFT.mat']);
save([pathstr '\' name '_KFT.mat'],'A','C','Q','R','binsize','delayBins','neuronIDs','outnames','FromData');

end