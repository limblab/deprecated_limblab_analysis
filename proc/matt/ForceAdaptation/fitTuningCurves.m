function [pds,cis,sg,trialTable] = fitTuningCurves(filename,trialTable,doType,doPlots)
% notes about inputs
% notes about outputs
% notes about providing M1 vs PMd files
% doType is vector
%`  [0 0] does full movement period to target
%   [0 1] does initial movement to target
%   [0 2] does final movement to target
%   [1 0] does full movement period to movement direction
%   [1 1] does initial movement to movement direction
%   [1 2] does initial movement to movement direction

if nargin < 2
    trialTable = [];
    doType = [0 0];
    doPlots = false;
end

% INITIAL PARAMETERS
moveTime = 0.5; %seconds
numIters = 1000; %number iterations for bootstrapping
sig = 0.95; %confidence interval

latency = 0.1; %latency of PMd in seconds (kurata and tanji?)
% This will be overwritten below if an M1 file is used

% exclude anticipated movements or outliers (Xiao et al 2006)
%   Mr T moves real slowly...
excludeTimeRange = [0.2 1.2];
holdTime = 0.5; %used hold time in these trials

% Angles of targets
targAngs = [0, pi/4, pi/2, 3*pi/4, pi, -3*pi/4, -pi/2, -pi/4];

% Load data
if isempty(trialTable)
    latency = 0.1; %latency of M1 in seconds
    load(filename);
    
    % moveTime is for angle of movement... if positive, use initial
    % period... if negative, use final period of moveTime length... if
    % zero, use window around peak velocity
    if doType(2)==0 % use period around peak speed
        moveTime = 0;
    elseif doType(2)==1 % use initial movement period
        %do nothing
    elseif doType(2)==2 % use final movement period
        moveTime = -moveTime;
    end
    
    trialTable = ff_trial_table(out_struct,targAngs,moveTime);
    %    1: Start time
    %    2: Target                  -- -1 for none
    %    3: OT on time
    %    4: Go cue
    %    5: Movement start time
    %    6: Peak speed time
    %    7: End of movement window (for pd purposes)
    %    8: Trial End time
    %    9: Angle of target
    %   10: Angle of movement
    
    % exclude anticipated movements or outliers
    moveTimes = trialTable(:,8)-trialTable(:,5)-holdTime;
    goodTrials = moveTimes >= excludeTimeRange(1) & moveTimes <= excludeTimeRange(2);
    trialTable = trialTable(goodTrials,:);
else
    % for adaptation and washout, we want to ignore trials where the monkey
    % is adapting.
    %   Currently assume that this happens if a trialTable is passed in, and
    %   assume that I should exclude the first 30% of trials
    trialTable = trialTable(floor(0.3*size(trialTable,1)):end,:);
end
% 
% % Plot force traces
% figure;
% for iTrial = 1:size(trialTable,1)
%     hold all;
%     useWin = [trialTable(iTrial,4), trialTable(iTrial,8)];
%     idx = out_struct.pos(:,1) >= useWin(1) & out_struct.pos(:,1) < useWin(2);
%     plot(out_struct.pos(idx,2),out_struct.pos(idx,3));
% end


% Now we can load the file that has the neural data
load(filename);
neural = out_struct.units;
sg = reshape([neural.id],2,length(neural))';

goodCells = sg(:,1) < 97;
sg = sg(goodCells,:);
neural = neural(goodCells);

% Get spike count for each channel in each hold period
spikeCounts = zeros(size(trialTable,1),length(neural));
fr = zeros(size(trialTable,1),length(neural));
for unit = 1:length(neural)
    ts = neural(unit).ts;
    for iTrial = 1:size(trialTable,1)
        
        % Time window for which to look for neural activity
        if doType(2)==0 % Use 0.5 sec period around peak speed
            useWin = [trialTable(iTrial,6)-0.25-latency, trialTable(iTrial,6)+0.25-latency];
        elseif doType(2)==1 %Use initial movement period
            useWin = [trialTable(iTrial,4)-latency, trialTable(iTrial,4)+moveTime-latency];
        elseif doType(2)==2 % Use the final movement period
            useWin = [trialTable(iTrial,4)-latency, trialTable(iTrial,4)+moveTime-latency];
        elseif doType(2)==3 % Use pre-movement period
            useWin = [trialTable(iTrial,3), trialTable(iTrial,5)];
            moveTime = trialTable(iTrial,5)-trialTable(iTrial,3);
        end
        
        % how many spikes are in this window?
        %   subtract the latency to account for transmission delays
        spikeCounts(iTrial,unit) = length(ts(ts > useWin(1) & ts <= useWin(2) ));
        fr(iTrial,unit) = spikeCounts(iTrial,unit)./moveTime; % Compute a firing rate
    end
end

%%% Here is the data we need
if ~doType(1)    % Regress to target
    disp('Regressing to target direction')
    theta = trialTable(:,9); % Get angles at each trial's target ID
else    % Regress to movement direction
    disp('Regressing to movement direction')
    theta = trialTable(:,10);
end
theta = wrapAngle(theta,0); % make sure it goes from [-pi,pi)

% Do bootstrapping
pds = zeros(length(neural),numIters);

for iter = 1:numIters
    tempfr = zeros(size(fr));
    tempTheta = zeros(size(fr));
    for unit = 1:length(neural)
        randInds = randi([1 size(fr,1)],size(fr,1),1);
        tempfr(:,unit) = fr(randInds,unit);
        tempTheta(:,unit) = theta(randInds);
    end
    [tunCurves, ~] = regressTuningCurves(tempfr,zeros(size(tempfr)),tempTheta,doPlots);
    pds(:,iter) = tunCurves(:,3);
end

pds = sort(pds,2);
cis = [pds(:,ceil(numIters - sig*numIters)), pds(:,floor(sig*numIters))].*180./pi;
pds = mean(pds,2).*180./pi;
