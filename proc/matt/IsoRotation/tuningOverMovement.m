% Fit tuning curve to target location during hold period
%   tunCurves: tuning curves with model b0+b1*cos(theta)+b2*sin(theta)
%   sg: spike guide
function tuningOverMovement(filename,doPlots)

outFilename = 'testResults.mat';

tau = 0.1; %time in seconds accounting for transmission delay
totalTime = 0.600; % sec
winSize = 0.300; % sec
stepSize = 0.100; % sec

numResamples = 500;

% Bin into 45 degree bins?
angSize = pi/4;

timeCenters = winSize/2:stepSize:totalTime-winSize/2;

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

trialTable = wf_trial_table(out_struct);
% exclude failed trials
trialTable = trialTable(trialTable(:,9)=='R',:);

force = out_struct.force;

neural = out_struct.units;
sg = reshape([neural.id],2,length(neural))';

clear out_struct

% Get target data
% Get the target centers for each trial
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

% get directions for each trial to use for Target PDs
thetaTarg = targMap(targIDs,1); % Get angles at each trial's target ID
thetaTarg = wrapAngle(thetaTarg,0); % make sure it goes from [-pi,pi)



% Loop along time points
for iCenter = 1:length(timeCenters)
    
    % Define time window
    timeWin = [timeCenters(iCenter)-winSize/2, timeCenters(iCenter)+winSize/2];
    
    % Get the starting times of each trial and make a matrix of time
    % intervals for each trial
    ints = [trialTable(:,7) + timeWin(1), trialTable(:,7) + timeWin(2)];
    
    % To account for delay in transmission for cortex to muscles, shift the
    % time window relative to the neurons by some amount of time
    ints = ints - tau;
    
    % Find spikes in time window
    spikeCounts = zeros(size(ints,1),length(neural));
    for unit = 1:length(neural)
        ts = neural(unit).ts;
        for iTrial = 1:size(ints,1)
            % how many spikes are in this window?
            spikeCounts(iTrial,unit) = length(ts(ts > ints(iTrial,1) & ts <= ints(iTrial,2)));
        end
    end
    
    fr = spikeCounts./winSize; % Compute a firing rate
    
    % Calculate movement direction in time window
    thetaMove = zeros(size(ints,1),1);
    for iTrial = 1:size(ints,1)
        relInds = [find(force(:,1) > ints(iTrial,1),1,'first')  find(force(:,1) <= ints(iTrial,2),1,'last')];
        thetaMove(iTrial) = atan2(force(relInds(end),3)-force(relInds(1),3),force(relInds(end),2)-force(relInds(1),2));
    end
    
    % Put into bins
    thetaMove = ceil(thetaMove./angSize);
    
    thetaMove = wrapAngle(thetaMove,0); % make sure it goes from [-pi,pi)

    % Fit cosine tuning curves
    [pdAngTarg(:,iCenter),sigTarg(:,iCenter)] = computeTuningCurves(fr,thetaTarg,numResamples,doPlots);
    [pdAngMove(:,iCenter), sigMove(:,iCenter)] = computeTuningCurves(fr,thetaMove,numResamples,doPlots);
    
    disp(iCenter)
    
end

% Find the cells that are significantly tuned in all epochs
goodCellsTarg = sum(sigTarg,2)==4;
goodCellsMove = sum(sigMove,2)==4;

pdTarg = pdAngTarg(goodCellsTarg,:);
pdMove = pdAngMove(goodCellsMove,:);

for i= 1:size(pdTarg,1)
    temp = (wrapAngle(pdTarg,pi)+2*pi).*180./pi;
    dPDTarg(i,:) = abs(temp(i,:) - temp(i,1));
end

for i = 1:size(pdMove)
    temp = (wrapAngle(pdMove,pi)+2*pi).*180./pi;
    dPDMove(i,:) = abs(temp(i,:) - temp(i,1));
end

% Make plot showing number of significantly tuned cells over time
figure;
hold all;
plot(timeCenters,sum(sigTarg,1),'r','LineWidth',2);
plot(timeCenters,sum(sigMove,1),'b','LineWidth',2);
legend({'Target', 'Movement'});
ylabel('Number of tuned cells');
xlabel('Time After go cue');

% Make plot showing PDs over time relevant to baseline
figure;
hold all;

plot(timeCenters,mean(dPDTarg,1),'r','LineWidth',2);
plot(timeCenters,mean(dPDMove,1),'b','LineWidth',2);
plot(timeCenters,mean(dPDTarg,1)+std(dPDTarg,1),'r--','LineWidth',1);
plot(timeCenters,mean(dPDMove,1)+std(dPDMove,1),'b--','LineWidth',1);
plot(timeCenters,mean(dPDTarg,1)-std(dPDTarg,1),'r--','LineWidth',1);
plot(timeCenters,mean(dPDMove,1)-std(dPDMove,1),'b--','LineWidth',1);

legend({'Target', 'Movement'});
ylabel('Change in PD');
xlabel('Time After go cue');

% % Plot color plot showing distribution of PDs over time
% nBins = 20;
% % allPDMove = zeros(nBins,length(timeCenters));
% allPDMove = hist(pdMove,nBins);
% allPDTarg = hist(pdTarg,nBins);
% 
% figure;
% imagesc(flipud(allPDMove));
% colorbar;

figure;
hold all;
hist(pdAngTarg(:,1),30);
set(get(gca,'child'),'FaceColor','r','EdgeColor','r');
hist(pdAngMove(:,1),30);
% set(get(gca,'child'),'FaceColor','none','EdgeColor','b');
legend({'Target','Movement'});
xlabel('PD');
ylabel('Count');

save(outFilename);

    