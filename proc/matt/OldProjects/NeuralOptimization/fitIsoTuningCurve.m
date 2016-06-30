function [tunCurves, offsetFR, sg, outHoldPeriods,p] = fitIsoTuningCurve(filename,holdTime,tau)
% Fit tuning curve to target location during hold period
%   tunCurves: tuning curves with model b0+b1*cos(theta)+b2*sin(theta)
%   sg: spike guide

if nargin < 3
    tau = 0.1; %time in seconds accounting for transmission delay
end

doPlots = false;

% You can pass in a bdf struct (pre-loaded) if you want
if ischar(filename)
    load(filename);
else
    out_struct = filename;
    clear filename;
end
trialTable = wf_trial_table(out_struct);
% Exclude failed trials
trialTable=trialTable(trialTable(:,9)==82,:);
neural = out_struct.units;
sg = [neural.id];
sg = sg(1:2:end);

% Using the trial table, compute the hold periods of outer target
outHoldPeriods = [trialTable(:,8)-holdTime, trialTable(:,8)]; % trial end time - hold time

% Use the inner hold period to calculate offset for each cell
%   ie this is when there is no activation
inHoldPeriods = [trialTable(:,1), trialTable(:,6)];

% To account for delay in transmission for cortex to muscles, shift the
% hold periods relative to the neurons by some amount of time
outHoldPeriods = outHoldPeriods - tau;
inHoldPeriods = inHoldPeriods - tau;


% Get spike count for each channel in each hold period
offsetFR = zeros(size(inHoldPeriods,1),length(neural));
for unit = 1:length(neural)
    ts = neural(unit).ts;
    for iTrial = 1:size(inHoldPeriods,1)
        % how many spikes are in this window?
        spikeCounts = length(ts(ts > inHoldPeriods(iTrial,1) & ts <= inHoldPeriods(iTrial,2)));
        offsetFR(iTrial,unit) = spikeCounts ./ (inHoldPeriods(iTrial,2)-inHoldPeriods(iTrial,1));
    end
end

% let offset be mean across trials
offsetFR = mean(offsetFR,1);

clear spikeCounts


% Get spike count for each channel in each hold period
spikeCounts = zeros(size(outHoldPeriods,1),length(neural));
for unit = 1:length(neural)
    ts = neural(unit).ts;
    for iTrial = 1:size(outHoldPeriods,1)
        % how many spikes are in this window?
        spikeCounts(iTrial,unit) = length(ts(ts > outHoldPeriods(iTrial,1) & ts <= outHoldPeriods(iTrial,2)));
    end
end


% Get target data
% Get the target centers
targIDs = trialTable( :, 10);

targetCenters = [(trialTable(:,4)+trialTable(:,2))/2 (trialTable(:,5)+trialTable(:,3))/2];
% map targids to target centers
targIDList = sort(unique(targIDs));
targMap = zeros(length(targIDList),4);
% Get angles and positions to the target centers
for i = 1:length(targIDList)
    target = targetCenters(find(targIDs==targIDList(i),1),:);
    targMap(i,:) = [atan2(target(2),target(1)) targIDList(i) target(1) target(2)];
end


%%% Here is the data we need
fr = spikeCounts./holdTime; % Compute a firing rate for outer target
theta = targMap(targIDs,1); % Get angles at each trial's target ID
theta = wrapAngle(theta,0); % make sure it goes from [-pi,pi)

oldfr = fr;

% Subtract non-directional component and find the directional tuning curve
for unit = 1:length(neural)
    fr(:,unit) = fr(:,unit) - offsetFR(unit);
end

tunCurves = zeros(size(fr,2),3);

st = sin(theta);
ct = cos(theta);
X = [ones(size(theta)) st ct];

for iN = 1:size(fr,2)
    % model is b0+b1*cos(theta)+b2*sin(theta)
    b = regress(fr(:,iN),X);
    
    % convert to model b0 + b1*cos(theta+b2)
    b  = [b(1); sqrt(b(2).^2 + b(3).^2); atan2(b(2),b(3))];
    if doPlots
        temp = offsetFR(iN) + b(1) + b(2)*cos(theta-b(3));
        [~,I] = sort(theta);
        plot(theta(I),temp(I),'b','LineWidth',2)
        hold all
        plot(theta,oldfr(:,iN),'r.')
        plot([b(3) b(3)],[0 max(oldfr(:,iN))],'k')
        pause;
        close all
    end
    tunCurves(iN,:) = b;
end

% Test for significance
% Bin the angles

%% Only consider well-tuned cells
%   Do one way ANOVA for tuning?
% Put into bins
angSize = pi/8;
for i = 1:size(outHoldPeriods,1)
    thetaBin = ceil(theta./angSize);
end

for i = 1:size(fr,2)
    p(i) = anova1(fr(:,i),thetaBin,'off');
end


