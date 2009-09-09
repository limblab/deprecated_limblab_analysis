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

%% Outputs:  (assign memory with real or dummy data, just cause predMIMO requires something there
% just send dummy data as outputs for the function
ActualEMGs=zeros(size(spikeData));


%% Use the neural filter to predict the EMGs
numsides=1; fs=1;
[PredictedData,spikeDataNew,ActualEMGsNew]=predMIMO3(usableSpikeData,filter.H,numsides,fs,ActualEMGs);
%% remove firts bin of Predicted EMGs since it appears to be garbage...
%PredictedEMGs = PredictedEMGs(2:end, :);

clear ActualEMGs spikeData;

%% If you have one, convolve the predictions with a Wiener cascade polynomial.
if size(filter.P)>1
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
