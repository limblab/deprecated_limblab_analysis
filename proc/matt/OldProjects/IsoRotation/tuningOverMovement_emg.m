% Fit tuning curve to target location during hold period
%   tunCurves: tuning curves with model b0+b1*cos(theta)+b2*sin(theta)
%   sg: spike guide
function tuningOverMovement_emg(filename,doPlots)
close all
outFilename = 'testResults.mat';

tau = 0.1; %time in seconds accounting for transmission delay
winSize = 0.300; % sec
stepSize = 0.100; % sec
holdTime = 0.400; %sec... the outer target hold time

% Want some criterion for how many trials we need to fit tuning curves
%   Let's say... 50
reqTrialNum = 40;

% Bin into 45 degree bins?
angSize = pi/4;


if nargin < 2
    doPlots = false;
end

% You can pass in a bdf struct (pre-loaded) if you want
if ischar(filename)
    load(filename);
else
    out_struct = filename;
    clear filename;
end

% Get the data from the struct
neural = out_struct.units;
sg = reshape([neural.id],2,length(neural))';
emg = out_struct.emg;

emg = filterEMG(emg);

force = out_struct.force;
if isstruct(force)
    force = force.data;
end
% it appears as though the force +/- is opposite of what I expect
force(:,2:3) = -force(:,2:3);

trialTable = wf_trial_table(out_struct);
% Trim unusable trials from the trial table
trialTable = trimTrialTable(trialTable);

clear out_struct

% plotForceTraces(trialTable, force,holdTime);

% Get the target direction (for each movement)
thetaTarg = getTargAngles(trialTable,'move',force,angSize);

% Calculate non-directional component
offsetFR = computeBaselineFR(neural, trialTable, tau);
offsetFR = zeros(size(offsetFR));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Full Movement Tuning
[pdFull, pFull] = computeFullTuning_EMG(emg, offsetFR, thetaTarg, trialTable, tau,false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hold Period tuning
[pdHold, pHold] = computeHoldPeriodTuning_EMG(emg, offsetFR, thetaTarg, trialTable, holdTime, tau,doPlots);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set bin times
[timeCenters, uTimes] = getTimeBinCenters(trialTable, holdTime, winSize, stepSize, reqTrialNum);

% timeCenters = ones(size(trialTable,1),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute tuning curves over movement period

tcsT = zeros(size(emg,2)-1,3,size(timeCenters,2));
tcsM = zeros(size(emg,2)-1,3,size(timeCenters,2));
%%%
% Loop along time points
for iCenter = 1:size(timeCenters,2)
    
    % Define time window
    timeWin = [timeCenters(:,iCenter)-winSize/2, timeCenters(:,iCenter)+winSize/2];
    
    
    % Get the starting times of each trial and make a matrix of time
    % intervals for each trial
    ints = [trialTable(:,7) + timeWin(:,1), trialTable(:,7) + timeWin(:,2)];
%     ints = [trialTable(:,7), trialTable(:,8)];
    
    % To account for delay in transmission for cortex to muscles, shift the
    % time window relative to the neurons by some amount of time
    ints = ints - tau;
    
    % Compute the firing rate
    fr = calculateFR_EMG(emg,ints,timeCenters,winSize,iCenter);
    
    % Calculate movement direction in time window
    thetaMove = getMoveAngles(force, ints, angSize, thetaTarg, trialTable);

    % Remove trials that have no activity
    %   MAKE SURE THIS ISN'T DOING FUNNY THINGS
    temp = thetaTarg(timeCenters(:,iCenter)>0);
    thetaMove = thetaMove(timeCenters(:,iCenter)>0);
    fr = fr(timeCenters(:,iCenter)>0,:);
    
%     % Compare target and movement tuning
%     dtheta = thetaMove-temp;
    
    
    % Fit cosine tuning curves
    [tcsT(:,:,iCenter), pT(:,iCenter)] = regressTuningCurves(fr,offsetFR,temp,doPlots);
    [tcsM(:,:,iCenter), pM(:,iCenter)] = regressTuningCurves(fr,offsetFR,thetaMove,doPlots);
    
%     [pdTarg(:,iCenter), pT(:,iCenter)] = computeTuningCurves(fr,temp,200,true);
%     [pdMove(:,iCenter), pM(:,iCenter)] = computeTuningCurves(fr,thetaMove,20,doPlots);
    
    disp(iCenter)
    
end


% skip the first bin
tcsT(:,:,1) = [];
tcsM(:,:,1) = [];
pT(:,1) = [];
pM(:,1) = [];
uTimes(1) = [];

% Make plot showing targ - move
pdTarg = squeeze(tcsT(:,3,:));
pdMove = squeeze(tcsM(:,3,:));

% Find the cells that are significantly tuned in all epochs
goodCellsTarg = sum(pT,2)==length(uTimes);
goodCellsMove = sum(pM,2)==length(uTimes);

% goodCellsTarg = sum(pT<alpha,2)>1;
% goodCellsMove = sum(pM<alpha,2)>1;

goodCells = goodCellsTarg & goodCellsMove;
goodCellsTarg = goodCells;
goodCellsMove = goodCells;

disp(['This many cells were significant:   ' num2str(sum(goodCells))]);

save(outFilename);

% Make plots
makePDPlots;

% keyboard

end

