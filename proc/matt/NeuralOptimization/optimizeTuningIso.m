clear
close all
clc

% slow fluctuations in baseline firing rate?
% add some noise to the neural firing rates?

% CURRENTLY ONLY OPTIMIZED MD AND TOTAL FR

%%% ====================    Parameters   ============================
plotVerbose = false;

% hand control files
hcbdfname = '/Users/Matt/Desktop/lab/data/BDFStructs/09-19-12/HC.mat';
hcbinname = '/Users/Matt/Desktop/lab/data/BinnedData/09-19-12/HC.mat';
decname = '/Users/Matt/Desktop/lab/data/Decoders/09-19-12/Dec.mat';

% brain control files
bcbdfname = '/Users/Matt/Desktop/lab/data/BDFStructs/09-19-12/BC.mat';
bcbinname = '/Users/Matt/Desktop/lab/data/BinnedData/09-19-12/BC.mat';

holdTime = 0.5; % outer target hold time in seconds

%%% Tuning cuve limits
minOff = 0;
maxOff = 100;
minMD = 0;
maxMD = 100;
minPD = -pi;
maxPD = pi;

%%% Gradient descent parameters
numIters = 100;

lr1 = 5e-4; %offset, modulation, theta learning rates
lr2 = 5e-4;
lr3 = 5e-5;
p1 = 1; % relative contribution of fx, fy, and neural activation
p2 = 1;
p3 = 0.5;

%%% neural gen parameters
tau = 0.1; %time in seconds for offset


%%% ====================    Load Data   ============================
% Load neural firing and velocity data
load(hcbinname);
binTime = binnedData.timeframe;
force = binnedData.cursorposbin;
theta = atan2(force(:,2),force(:,1));
realFR = binnedData.spikeratedata;
numCells = size(binnedData.spikeratedata,2);
sg = binnedData.spikeguide;


%%% =====================    Load Decoder   ==============================
% Decoder used by monkey
load(decname,'filter');

fillen = filter.fillen;
binSize = filter.binsize;
filtBins = int16(fillen/binSize);
nBins = length(force);
binVec = 0:binSize:binSize*(nBins-1);

H = filter.H;

decWeights = zeros(numCells,size(H,2));
for i=1:numCells
    decWeights(i,:) = sum(H(1+filtBins*(i-1):filtBins*i,:));
end
clear H sc
%%%%%%


%%% ====================    Tuning Curves   ============================
% Fit tuning curves to each cell
%   [Offset, 1/2 modulation depth, PD]

% Isometric files are based on hold period so velocity is irrelevant
[tcs,offs,ids,holdPeriods,pHC] = fitIsoTuningCurve(hcbdfname,holdTime,tau);

% Only keep the tuning curves that are in spike guide
temp = str2num(sg(:,3:4))';
tcs = tcs(ismember(ids,temp),:);
offs = offs(ismember(ids,temp));
pHC = pHC(ismember(ids,temp));

%%%%%%

% This code looks at hold periods in the isometric task
%   Make a vector of time indices for the binned data that represent the
%   hold periods for all of the trials. Then, I just look at the error in
%   these times for the cost function later.
holdTimes = [];
for iTrial = 1:size(holdPeriods,1)
    holdTimes = [holdTimes; find(binTime >= holdPeriods(iTrial,1) & binTime <= holdPeriods(iTrial,2))];
end

% Get proportional force at each point in time... ranges from 0 to 1
%   Normalized by magnitude of force when in target
normForce = sqrt(force(:,1).^2 + force(:,2).^2) ./ mean(sqrt(force(holdTimes,1).^2 + force(holdTimes,2).^2));

%%% =================    Generate Spike Rate   =========================
% Now generate firing rate data

fr = zeros(size(force,1),numCells);

% Schwartz model is velocity sensitive
% iso model is position sensitive, using the same ideas
for unit = 1:numCells
    fr(:,unit) = offs(unit) + normForce.*( tcs(unit,1) + tcs(unit,2).*cos(theta - tcs(unit,3)) );
    fr(fr(:,unit) < 0, unit) = 0;
end

% Make sure no values are below zero
fr = poissrnd(fr);


%%% ====================    Predictions   ============================
% Predict force from cells
pred = predictOutput(filter, fr, binSize, sg, force);
y = pred.actualdata;
yp = pred.preddatabin;
t = binVec(1:end-(int16(fillen/binSize)-1));
th = theta(filtBins:end);
fr = pred.spikeratedata;

% Check performance
[VAF, R2, MSE] = computeStats(yp,y);
R2
% Use aggregate metrics
disp(['VAF: ' num2str(mean(VAF)) '  |  R2: ' num2str(mean(R2)) '  |  MSE: ' num2str(mean(MSE))]);

if 1
    % Plot the results
    figure;
    subplot1(2,1);
    subplot1(1);
    hold all;
    plot(t,y(:,1),'b','LineWidth',2);
    plot(t,yp(:,1),'r','LineWidth',2);
    subplot1(2);
    hold all;
    plot(t,y(:,2),'b','LineWidth',2);
    plot(t,yp(:,2),'r','LineWidth',2);
end
%%%%%%

% store the original parameters for reference later
ogFR = fr;
ogtcs = tcs;
ogyp = yp;

oldFR = fr;


%%% ====================    Optimize   ============================
% Iterate on gradient descent
VAF = zeros(numIters,size(force,2));
R2 = zeros(numIters,size(force,2));
MSE = zeros(numIters,size(force,2));

grad = zeros(numIters,3);
for iter = 1:numIters
    
    delta = zeros(size(tcs));
    % Find the change in tuning functions using the cost function
    %   Because tuning is only based on hold period, we should only
    %   optimize for data from hold period.
    for unit = 1:size(tcs,1) 
        dfx = sum( (yp(holdTimes,1)-y(holdTimes,1)).*decWeights(unit,1) );
        dfy = sum( (yp(holdTimes,2)-y(holdTimes,2)).*decWeights(unit,2) );
        dn = sum( (mean(fr(holdTimes,:),1) - mean(oldFR(holdTimes,:),1)).*(decWeights(unit,1)+decWeights(unit,2))./2 );
        d1 = 2*(p1*dfx + p2*dfy + p3*dn);
        
        dfx = sum( (yp(holdTimes,1)-y(holdTimes,1)) .* (decWeights(unit,1).*cos(th(holdTimes) - tcs(unit,3))) );
        dfy = sum( (yp(holdTimes,2)-y(holdTimes,2)) .* (decWeights(unit,2).*cos(th(holdTimes) - tcs(unit,3))) );
        d2 = 2*(p1*dfx + p2*dfy);
        
        dfx = sum( (yp(holdTimes,1)-y(holdTimes,1)) .* (decWeights(unit,1).*tcs(unit,2).*sin(th(holdTimes) - tcs(unit,3))) );
        dfy = sum( (yp(holdTimes,2)-y(holdTimes,2)) .* (decWeights(unit,2).*tcs(unit,2).*sin(th(holdTimes) - tcs(unit,3))) );
        d3 = 2*(p1*dfx + p2*dfy);
        
        delta(unit,:) = [lr1 lr2 lr3].*[d1 d2 d3];
    end
    
    tcs = tcs - delta;
    
    grad(iter,:) = mean(delta,1);
    
    tcs(tcs(:,1) < minOff,1) = minOff;
    tcs(tcs(:,1) > maxOff,1) = maxOff;
    tcs(tcs(:,2) < minMD,2) = minMD;
    tcs(tcs(:,2) > maxMD,2) = maxMD;
    tcs(tcs(:,3) < minPD,3) = minPD;
    tcs(tcs(:,3) > maxPD,3) = maxPD;
    
    oldFR = fr;
    
    % Now generate firing rate data
    fr = zeros(size(force,1),numCells);
    for unit = 1:numCells
        fr(:,unit) = offs(unit) + normForce.*( tcs(unit,1) + tcs(unit,2).*cos(theta - tcs(unit,3)) );
        fr(fr(:,unit) < 0, unit) = 0;
    end
    
    if 0
        fr = poissrnd(fr);
    end
    
    %%%%%%
    
    % Predict velocity from cells
    pred = predictOutput(filter, fr, binSize, sg, force);
    y = pred.actualdata;
    yp = pred.preddatabin;
    t = binVec(1:end-(int16(fillen/binSize)-1));
    fr = pred.spikeratedata;
    
    [VAF(iter,:), R2(iter,:), MSE(iter,:)] = computeStats(yp,y);
    
    
    if iter > 1
%         disp([num2str(iter) '  |  ' num2str(R2(iter,:)) '  |  ' num2str(any(VAF(iter,:)-VAF(iter-1,:) < 0))])
        disp([num2str(iter) '  |  ' num2str(mean(VAF(iter,:))-mean(VAF(iter-1,:)) < 0) ' VAF: ' num2str(mean(VAF(iter,:))) '  |  ' num2str(mean(R2(iter,:))-mean(R2(iter-1,:)) < 0) ' R2: ' num2str(mean(R2(iter,:))) '  |  ' num2str(mean(MSE(iter,:))-mean(MSE(iter-1,:)) > 0) '  MSE: ' num2str(mean(MSE(iter,:)))]);

    end
    clear tempVAF tempErr
    
    if plotVerbose
        % Plot the results
        figure;
        subplot1(2,1);
        subplot1(1);
        hold all;
        plot(t,y(:,1),'b','LineWidth',2);
        plot(t,yp(:,1),'r','LineWidth',2);
        subplot1(2);
        hold all;
        plot(t,y(:,2),'b','LineWidth',2);
        plot(t,yp(:,2),'r','LineWidth',2);
    end
    %%%%%%
    
end
clear pred oldFR

% mean(VAF(1:floor(numIters/3),:))
% mean(VAF(ceil(2*numIters/3):end,:))
% [~,p] = ttest2(VAF(1:floor(numIters/3),1),VAF(ceil(2*numIters/3):end,1))

% Plot the results
figure;
subplot1(2,1);
subplot1(1);
hold all;
plot(t,y(:,1),'b','LineWidth',2);
plot(t,yp(:,1),'r','LineWidth',2);
subplot1(2);
hold all;
plot(t,y(:,2),'b','LineWidth',2);
plot(t,yp(:,2),'r','LineWidth',2);



% Load brain control data and fit tuning curves
%%% ====================    Load Data   ============================
% Load neural firing and velocity data
load(hcbinname);
binTime = binnedData.timeframe;
force = binnedData.cursorposbin;
theta = atan2(force(:,2),force(:,1));
realFR = binnedData.spikeratedata;
numCells = size(binnedData.spikeratedata,2);
sg = binnedData.spikeguide;


%%% ====================    Tuning Curves   ============================
% Fit tuning curves to each cell
%   [Offset, 1/2 modulation depth, PD]

% Isometric files are based on hold period so velocity is irrelevant
[bctcs,bcoffs,ids,holdPeriods,pBC] = fitIsoTuningCurve(bcbdfname,holdTime,tau);

% Only keep the tuning curves that are in spike guide
temp = str2num(sg(:,3:4))';
bctcs = bctcs(ismember(ids,temp),:);
bcoffs = bcoffs(ismember(ids,temp));
pBC = pBC(ismember(ids,temp));

% Only consider well-tuned cells?
sigTCsHand = ogtcs(pHC<=0.05,:);
sigTCsBrain = bctcs(pBC<=0.05,:);
sigTCsOpt = tcs(pHC<=0.05 | pBC<=0.05,:);


%% Compare histograms of parameter shifts
figure;
subplot(3,1,1);
title('Compare hand to optimal');
hist(sigTCsOpt(:,2),20);
ylabel('Count','FontSize',14);
xlabel('MD: Optimal','FontSize',14);
subplot(3,1,2);
hist(sigTCsHand(:,2),20);
ylabel('Count','FontSize',14);
xlabel('MD: Hand','FontSize',14);
subplot(3,1,3);
hist(sigTCsBrain(:,2),20);
ylabel('Count','FontSize',14);
xlabel('MD: Brain','FontSize',14);

figure;
subplot(3,1,1);
title('Compare hand to optimal');
hist(sigTCsOpt(:,3),20);
ylabel('Count','FontSize',14);
xlabel('PD: Optimal','FontSize',14);
subplot(3,1,2);
hist(sigTCsHand(:,3),20);
ylabel('Count','FontSize',14);
xlabel('PD: Hand','FontSize',14);
subplot(3,1,3);
hist(sigTCsBrain(:,3),20);
ylabel('Count','FontSize',14);
xlabel('PD: Brain','FontSize',14);


figure;
subplot(3,1,1);
title('Compare hand to optimal');
hist(sigTCsOpt(:,1),20);
ylabel('Count','FontSize',14);
xlabel('O: Optimal','FontSize',14);
subplot(3,1,2);
hist(sigTCsHand(:,1),20);
ylabel('Count','FontSize',14);
xlabel('O: Hand','FontSize',14);
subplot(3,1,3);
hist(sigTCsBrain(:,1),20);
ylabel('Count','FontSize',14);
xlabel('O: Brain','FontSize',14);



%======================================================================
% %% Compare histograms of parameter shifts
% figure;
% subplot(3,1,1);
% title('Compare hand to optimal');
% hist(sigTCsOpt(:,1)-sigTCsHand(:,1),20);
% ylabel('Count','FontSize',14);
% xlabel('Change in cosine offset','FontSize',14);
% subplot(3,1,2);
% hist(sigTCsOpt(:,2)-sigTCsHand(:,2),20);
% ylabel('Count','FontSize',14);
% xlabel('Change in Modulation Depth','FontSize',14);
% subplot(3,1,3);
% hist(sigTCsOpt(:,3)-sigTCsHand(:,3),20);
% ylabel('Count','FontSize',14);
% xlabel('Change in Preferred Direction','FontSize',14);
% 
% %% Compare histograms of parameter shifts
% figure;
% title('Compare hand to brain');
% subplot(3,1,1);
% hist(sigTCsHand(:,1)-sigTCsBrain(:,1),20);
% ylabel('Count','FontSize',14);
% xlabel('Change in cosine offset','FontSize',14);
% subplot(3,1,2);
% hist(sigTCsHand(:,2)-sigTCsBrain(:,2),20);
% ylabel('Count','FontSize',14);
% xlabel('Change in Modulation Depth','FontSize',14);
% subplot(3,1,3);
% hist(sigTCsHand(:,3)-sigTCsBrain(:,3),20);
% ylabel('Count','FontSize',14);
% xlabel('Change in Preferred Direction','FontSize',14);
% 
% %% Compare histograms of parameter shifts
% figure;
% title('Compare optimal to brain');
% subplot(3,1,1);
% hist(sigTCsOpt(:,1)-sigTCsBrain(:,1),20);
% ylabel('Count','FontSize',14);
% xlabel('Change in cosine offset','FontSize',14);
% subplot(3,1,2);
% hist(sigTCsOpt(:,2)-sigTCsBrain(:,2),20);
% ylabel('Count','FontSize',14);
% xlabel('Change in Modulation Depth','FontSize',14);
% subplot(3,1,3);
% hist(sigTCsOpt(:,3)-sigTCsBrain(:,3),20);
% ylabel('Count','FontSize',14);
% xlabel('Change in Preferred Direction','FontSize',14);