function testIsoTuningModel()

close all

bdfname = '/Users/Matt/Desktop/lab/data/BDFStructs/09-19-12/HC.mat';
binname = '/Users/Matt/Desktop/lab/data/BinnedData/09-19-12/HC.mat';
decname = '/Users/Matt/Desktop/lab/data/Decoders/09-19-12/Dec.mat';

holdTime = 0.5; % outer target hold time in seconds

%%% neural gen parameters
tau = 0.1; %time in seconds for offset


%%% ====================    Load Data   ============================
% Load neural firing and velocity data
load(binname);
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
[tcs,offs,ids,holdPeriods] = fitIsoTuningCurve(bdfname,holdTime,tau);

% Only keep the tuning curves that are in spike guide
temp = str2num(sg(:,3:4))';
tcs = tcs(ismember(ids,temp),:);
offs = offs(ismember(ids,temp));

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
end

fr = poissrnd(fr);


% Compare this firing rate data to real data
%   Plot, for each time point, the summed error across units
figure;
hold all;
plot(binTime,sum(realFR,2),'b','LineWidth',2);
plot(binTime,sum(fr,2),'r','LineWidth',2);