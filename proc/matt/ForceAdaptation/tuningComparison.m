% test GLM versus regression
clear;
clc;
close all;

%% Define parameters
aSig = 0.1; % significance level for ANOVA
sig = 0.95; % for bootstrapping
ciSig = 30; % ci size in degrees

doPlots = false;
moveTime = 0.5;
numIters = 250;

tuneType = 'full';
tuneDir = 'move';

glmNumSamps = 'all';
glmModel = 'vel';
glmBin = 10;


%% Load a bdf
filename = 'Z:\MrT_9I4\PMd\Matt\BDFStructs\2013-05-27\MrT_PMd_CO_FF_kin_BL_05272013_001.mat';
load(filename)

neur = out_struct.units;
sg = reshape([neur.id],2,length(neur))';

% We use 96 channel arrays so there should not be higher than 97
%  This is a hack to deal with a weird problem where seemingly meaningless
%  units were appended. Perhaps due to syncing?
% goodCells = sg(:,1) < 97;
% sg = sg(goodCells,:);
% neur = neur(goodCells);

%% Get the trial table
% exclude anticipated movements or outliers (Xiao et al 2006)
%   Mr T moves real slowly...
excludeTimeRange = [0.2 1.2];

holdTime = 0.5; %used hold time in these trials

% Angles of targets
targAngs = [0, pi/4, pi/2, 3*pi/4, pi, -3*pi/4, -pi/2, -pi/4];

% moveTime is for angle of movement... if positive, use initial
% period... if negative, use final period of moveTime length... if
% zero, use window around peak velocity. This is kind of a "hack"
% solution but it's okay for now
if strcmpi(tuneType,'peak') || strcmpi(tuneType,'full') % use period around peak speed
    moveTime = 0;
elseif strcmpi(tuneType,'initial') % use initial movement period
    %do nothing
elseif strcmpi(tuneType,'final') % use final movement period
    moveTime = -moveTime;
end

trialTable = ff_trial_table(out_struct,targAngs,moveTime);
%    1: Start time
%    2: Target  --  -1 for none
%    3: OT on time
%    4: Go cue
%    5: Movement start time
%    6: Peak speed time
%    7: End of movement window (for pd purposes)
%    8: Trial End time
%    9: Angle of target
%   10: Angle of movement

% exclude anticipated movements or outliers, as well as bad trials
moveTimes = trialTable(:,8)-trialTable(:,5)-holdTime;
goodTrials = moveTimes >= excludeTimeRange(1) & moveTimes <= excludeTimeRange(2);
trialTable = trialTable(goodTrials,:);

%% Get spike count for each channel in each trial
spikeCounts = zeros(size(trialTable,1),length(neur));
fr = zeros(size(trialTable,1),length(neur));
for unit = 1:length(neur)
    % subtract the latency to account for transmission delays
    % DO THIS PROPERLY
    latency = 0.1; %seconds
    
    ts = neur(unit).ts-latency;
    for iTrial = 1:size(trialTable,1)
        
        % Time window for which to look for neural activity
        if strcmpi(tuneType,'peak') % Use 0.5 sec period around peak speed
            useWin = [trialTable(iTrial,6)-0.25, trialTable(iTrial,6)+0.25];
        elseif strcmpi(tuneType,'initial') %Use initial movement period
            useWin = [trialTable(iTrial,4), trialTable(iTrial,4)+moveTime];
        elseif strcmpi(tuneType,'final') % Use the final movement period
            useWin = [trialTable(iTrial,4), trialTable(iTrial,4)+moveTime];
        elseif strcmpi(tuneType,'pre') % Use pre-movement period
            useWin = [trialTable(iTrial,3), trialTable(iTrial,5)];
        elseif strcmpi(tuneType,'full') % use full movement
            useWin = [trialTable(iTrial,5), trialTable(iTrial,8)];
        end
        
        moveTime = useWin(2)-useWin(1);
        
        % how many spikes are in this window?
        spikeCounts(iTrial,unit) = length(ts(ts > useWin(1) & ts <= useWin(2) ));
        fr(iTrial,unit) = spikeCounts(iTrial,unit)./moveTime; % Compute a firing rate
    end
end

%% Do one way ANOVA with direction as factor to determine if the cell is tuned
p = zeros(length(neur),1);
for unit = 1:length(neur)
    p(unit) = anova1(fr(:,unit),trialTable(:,9),'off');
end

p = p < aSig;

%% Use regression to find tuning
% Only use the units that are tuned
fr  = fr(:,p);

if strcmpi(tuneDir,'targ')    % Regress to target
    disp('Regressing to target direction')
    theta = trialTable(:,9); % Get angles at each trial's target ID
else    % Regress to movement direction
    disp('Regressing to movement direction')
    theta = trialTable(:,10);
end
theta = wrapAngle(theta,0); % make sure it goes from [-pi,pi)

% Do bootstrapping
[tcs,cis] = regressTuningCurves(fr,theta,{'bootstrap',numIters,sig},'doplots',doPlots);
pdsR = tcs(:,3);
mdsR = 2*tcs(:,2);
cisR = cis;

sigR = ( angleDiff(pdsR,cisR(:,1)) + angleDiff(pdsR,cisR(:,2)) ) <= ciSig;

%% Use GLM to find tuning
[pds, ci_l, ci_h, moddepth] = glm_bootstrap(out_struct, 1, glmModel, numIters, glmNumSamps, glmBin, p);
% pds = pds(goodCells);
% ci_l = ci_l(goodCells);
% ci_h = ci_h(goodCells);
% mdsG = moddepth(goodCells);
cis = [ci_l, ci_h];

pdsG = pds.*180/pi;
cisG = cis.*180/pi;
mdsG = moddepth;

clear pds ci_l ci_h cis moddepth unit iTrial

cidiffR = angleDiff(cisR(:,1),cisR(:,2));
cidiffG = angleDiff(cisG(:,1),cisG(:,2));
pddiff = angleDiff(pdsR,pdsG);
cidiff = angleDiff(cidiffR,cidiffG);


