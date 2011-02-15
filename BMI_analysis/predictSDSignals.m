function [PredData, varargout] = predictSDSignals(varargin)

models       = varargin{1};
BinnedData   = varargin{2};
State_index  = varargin{3};
if nargin    >= 4
    Smooth_Pred = varargin{4};
    Adapt_Enable = varargin{5};
    LR = varargin{6};
    Adapt_lag = varargin{7};
    if nargin > 7
        numPCs = varargin{8};
    end
else
    Smooth_Pred = false;
    Adapt_Enable = false;
    LR = [];
    Adapt_lag = [];
end

if ischar(models)
    models = load(models);
    field_names = fieldnames(models);
    models = getfield(models, field_names{1,:});
end

if ischar(BinnedData)
    BinnedData = LoadDataStruct(BinnedData,'binned');
end


neuronIDs = models{1,1}.neuronIDs;
fillen    = models{1,1}.fillen;
if isfield(models{1,1},'PC')
    numPCs = models{1,1}.PC;
else
    numPCs = 0;
end

if any(any(neuronIDs~=models{1,2}.neuronIDs)) || any(any(fillen~=models{1,2}.fillen))
    disp('Different decoders must be built with same units and filter length for now');
    disp('Operation aborted');
    return
end

binsize   = BinnedData.timeframe(2)-BinnedData.timeframe(1);
numlags   = round(fillen/binsize); %round in case of floating point errror
numStates = size(models,2);

%% Inputs:

%get usable units from filter info
matchingInputs = FindMatchingNeurons(BinnedData.spikeguide,neuronIDs);

%populate spike data for data units matching the filter units
usableSpikeData = zeros(size(BinnedData.spikeratedata,1),size(neuronIDs,1));
usableSpikeData(:,logical(matchingInputs)) = BinnedData.spikeratedata(:,nonzeros(matchingInputs));

% Duplicate and shift neural channels so we don't have to look in the past with the linear filter.
Inputs = DuplicateAndShift(usableSpikeData,numlags); numlags = 1;
clear usableSpikeData;

if numPCs
    % use PCs as model inputs
    Inputs = Inputs*filter.PC(:,1:numPCs);
end

%% Outputs:  assign memory with real or dummy data, just cause predMIMO requires something there
% just send dummy data as outputs for the function
Outputs = zeros(size(Inputs,1),2);

%% Use the neural filter to predict the Data
 numsides=1; fs=1;
if Adapt_Enable
%     [PredictedData,spikeDataNew,Hnew] = predAdaptSD(BinnedData,usableSpikeData,filter.H,LR,Adapt_lag);
%     varargout(1) = {Hnew};
else
    numPoints     =  size(Inputs,1);
    numOutputs    =  size(models{1,1}.H,2);
    PredictedData =  zeros(numPoints,numOutputs);
    for state = 1:numStates
        [TempPred,spikeDataNew,ActualDataNew]=predMIMO3(Inputs,models{1,state}.H,numsides,fs,Outputs);
%         TempPred = DS_spikes*models{1,state}.H;
        State_Mask = repmat(state-1==BinnedData.states(:,State_index),1,numOutputs);
        TempPred = TempPred .* State_Mask;
        if ~isempty(models{1,state}.P)
            for z=1:numOutputs;
                TempPred(State_Mask(:,z),z) = polyval(models{1,state}.P(z,:),TempPred(State_Mask(:,z),z));
            end
        end
        PredictedData = PredictedData + TempPred;
    end
end
        
clear ActualData spikeData TempPred Inputs;
H_new = [];
varargout{1}=H_new;

%% Aggregate Outputs in a Structure

% [numpts,Nx]=size(usableSpikeData);
% [nr,Ny]=size(filter.H);
% fillen=nr/Nx;
% timeframeNew = BinnedData.timeframe(numlags:numpts);
% spikeDataNew = usableSpikeData(numlags:numpts,:);
%timeframeNew = BinnedData.timeframe(fillen+1:numpts); % to account for additional bin removed at beginning of PredictedEMGs

PredData = struct('timeframe', BinnedData.timeframe(numlags:numPoints),...
                  'preddatabin', PredictedData,...
                  'outnames',models{1,1}.outnames,...
                  'spikeguide', neuronIDs2spikeguide(models{1,1}.neuronIDs));

end
    