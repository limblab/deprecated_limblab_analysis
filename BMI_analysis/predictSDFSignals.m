function [PredData, varargout] = predictSDFSignals(varargin)

model       = varargin{1};
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

if ischar(model)
    models = load(model);
    field_names = fieldnames(model);
    models = getfield(models, field_names{1,:});
end

if ischar(BinnedData)
    BinnedData = LoadDataStruct(BinnedData,'binned');
end


neuronIDs = model.neuronIDs;
fillen    = model.fillen;
binsize   = BinnedData.timeframe(2)-BinnedData.timeframe(1);
numlags   = round(fillen/binsize); %round in case of floating point errror
numStates = size(BinnedData.states,2);

%% Inputs:

%get usable units from filter info
matchingInputs = FindMatchingNeurons(BinnedData.spikeguide,neuronIDs);

%populate spike data for data units matching the filter units
usableSpikeData = zeros(size(BinnedData.spikeratedata,1),size(neuronIDs,1));
usableSpikeData(:,logical(matchingInputs)) = BinnedData.spikeratedata(:,nonzeros(matchingInputs));

% Duplicate and shift neural channels so we don't have to look in the past with the linear filter.
% DS_spikes = DuplicateAndShift(usableSpikeData,numlags); numlags = 1;
% clear usableSpikeData;

%% Outputs:  assign memory with real or dummy data, just cause predMIMO requires something there
% just send dummy data as outputs for the function
Outputs = zeros(size(usableSpikeData,1),2);

%% Use the neural filter to predict the Data
 numsides=1; fs=1;
if Adapt_Enable
    [PredictedData,spikeDataNew,Hnew] = predAdaptSD(BinnedData,usableSpikeData,filter.H,LR,Adapt_lag);
    varargout(1) = {Hnew};
else
    numPoints     =  size(usableSpikeData,1);
    numOutputs    =  size(model.H,2);

    [PredictedData,spikeDataNew,ActualDataNew]=predMIMO3(usableSpikeData,model.H,numsides,fs,Outputs);
    Rest_idxs = find(BinnedData.states(numlags:end,State_index)==0);

    if ~isempty(model.P)
        for z=1:numOutputs;
            PredictedData(:,z) = polyval(model.P(z,:),PredictedData(:,z));
        end
    end
    
    %Smooth Predictions during Rest State
    dt = binsize;
    RC = 0.3; %300ms time constant
    a = dt/(RC+dt); %inertia
    
    for i=1:length(Rest_idxs)
        if Rest_idxs(i)==1
            %skip first bin
            continue;
        end
        PredictedData(Rest_idxs(i),:)= PredictedData(Rest_idxs(i)-1,:) + a*( PredictedData(Rest_idxs(i),:)-PredictedData(Rest_idxs(i)-1,:) );
    end
end
        
clear ActualData spikeData TempPred;
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
                  'outnames',model.outnames,...
                  'spikeguide', neuronIDs2spikeguide(model.neuronIDs));

end
    