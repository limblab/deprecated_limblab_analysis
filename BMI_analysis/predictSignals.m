function [PredData, varargout] = predictSignals(varargin)

filter       = varargin{1};
BinnedData   = varargin{2};

% default values
numPCs = 0;
FiltPred = false;
Adapt.Enable = false;

if nargin    >= 3
    FiltPred = varargin{3};
    if nargin > 3
        Adapt = varargin{4};
        if nargin > 4
            numPCs = varargin{5};
        end
    end
end

if ischar(filter)
    filter = LoadDataStruct(filter,'filter');
end
if ischar(BinnedData)
    BinnedData = LoadDataStruct(BinnedData,'binned');
end

binsize = BinnedData.timeframe(2)-BinnedData.timeframe(1);
numlags = round(filter.fillen/binsize); %round in case of floating point errror

%get usable units from filter info
matchingInputs = FindMatchingNeurons(BinnedData.spikeguide,filter.neuronIDs);

%% Inputs:
%populate spike data for data units matching the filter units
usableSpikeData = zeros(size(BinnedData.spikeratedata,1),size(filter.neuronIDs,1));
usableSpikeData(:,logical(matchingInputs)) = BinnedData.spikeratedata(:,nonzeros(matchingInputs));

% Uncomment next line to use EMGs as model inputs:
%usableSpikeData=BinnedData.emgdatabin;


if numPCs
    % use PCs as model inputs
    usableSpikeData = DuplicateAndShift(usableSpikeData,numlags); numlags = 1;
    usableSpikeData = usableSpikeData*filter.PC(:,1:numPCs);
end

%% Outputs:  assign memory with real or dummy data, just cause predMIMO requires something there
% just send dummy data as outputs for the function
ActualData=zeros(size(usableSpikeData));

%% Use the neural filter to predict the Data
numsides=1; fs=1;
if Adapt.Enable
%     [PredictedData,spikeDataNew,Hnew] = predAdaptEMGs(BinnedData,usableSpikeData,filter.H,Adapt);
    [PredictedData,spikeDataNew,Hnew] = predAdapt(BinnedData,usableSpikeData,filter.H,Adapt);
    varargout(1) = {Hnew};
else
    [PredictedData,spikeDataNew,ActualEMGsNew]=predMIMO3(usableSpikeData,filter.H,numsides,fs,ActualData);
%     [PredictedData]=predMIMOCE1(usableSpikeData,filter.H,numlags);
%     PredictedData = PredictedData(numlags:end,:);
    varargout(1) = {filter.H};
end

clear ActualData spikeData;

%% Threshold: apply threshold to predicted data
if isfield(filter, 'T')
if ~isempty(filter.T)
    BetweenThresholds = false(size(PredictedData));
    for z=1:size(PredictedData,2)
            BetweenThresholds(:,z) = and(PredictedData(:,z)>=filter.T(z,1),PredictedData(:,z)<=filter.T(z,2));
            PredictedData(BetweenThresholds(:,z),z)= filter.patch(z);
    end
end 
end
%% If you have one, convolve the predictions with a Wiener cascade polynomial.
if ~isempty(filter.P)
    Ynonlinear=zeros(size(PredictedData));
    for z=1:size(PredictedData,2);
        Ynonlinear(:,z) = polyval(filter.P(z,:),PredictedData(:,z));
    end
    PredictedData=Ynonlinear;
end

%% Smooth EMG Predictions, moving average with variable length based on 1st deriv of ave FR
if FiltPred
   [PredictedData] = FiltPred(PredictedData,spikeDataNew,binsize);
end

%% Aggregate Outputs in a Structure

[numpts,Nx]=size(usableSpikeData);
[nr,Ny]=size(filter.H);
fillen=nr/Nx;
timeframeNew = BinnedData.timeframe(fillen:numpts);
spikeDataNew = usableSpikeData(fillen:numpts,:);

PredData = struct('timeframe', timeframeNew,...
                  'preddatabin', PredictedData,...
                  'spikeratedata', spikeDataNew,...
                  'outnames',filter.outnames,...
                  'spikeguide', neuronIDs2spikeguide(filter.neuronIDs));

end
    