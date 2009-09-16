function [PredData] = predictSignals(filter,BinnedData)

addpath ..\mimo

if ischar(filter)
    filter = LoadDataStruct(filter,'filter');
end
if ischar(BinnedData)
    BinnedData = LoadDataStruct(BinnedData,'binned');
end

spikeData = BinnedData.spikeratedata;

%get usable units from filter info
matchingInputs = FindMatchingNeurons(BinnedData.spikeguide,filter.neuronIDs);

%% Inputs:
%populate spike data for units in the filter using actual data
    % 1 - preallocate with zeros 
usableSpikeData = zeros(size(spikeData,1),size(filter.neuronIDs,1));
    % 2 - copy spike data for matching units between filter and data
for i = 1:length(matchingInputs)
    if matchingInputs(i)
        usableSpikeData(:,i)= spikeData(:,matchingInputs(i));
    end
end

% Uncomment next line to use EMGs as model inptuts:
%usableSpikeData=BinnedData.emgdatabin;

%% Outputs:  assign memory with real or dummy data, just cause predMIMO requires something there
% just send dummy data as outputs for the function
ActualData=zeros(size(spikeData));

%% Use the neural filter to predict the Data
numsides=1; fs=1;
[PredictedData,spikeDataNew,ActualEMGsNew]=predMIMO3(usableSpikeData,filter.H,numsides,fs,ActualData);

clear ActualData spikeData;

%% Threshold: apply threshold to predicted data
if ~isempty(filter.T)
    BetweenThresholds = false(size(PredictedData));
    for z=1:size(PredictedData,2)
            BetweenThresholds(:,z) = and(PredictedData(:,z)>=filter.T(z,1),PredictedData(:,z)<=filter.T(z,2));
            PredictedData(BetweenThresholds(:,z),z)= filter.patch(z);
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
    
%% Aggregate Outputs in a Structure

[numpts,Nx]=size(usableSpikeData);
[nr,Ny]=size(filter.H);
fillen=nr/Nx;
timeframeNew = BinnedData.timeframe(fillen:numpts);
%timeframeNew = BinnedData.timeframe(fillen+1:numpts); % to account for additional bin removed at beginning of PredictedEMGs

PredData = struct('timeframe', timeframeNew,...
                  'preddatabin', PredictedData,...
                  'spikeratedata', spikeDataNew,...
                  'outnames',filter.outnames,...
                  'spikeguide', filter.neuronIDs);

end
