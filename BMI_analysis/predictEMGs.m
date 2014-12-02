function [PredData] = predictEMGs(filter,BinnedData)

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
if isfield(BinnedData,'emgdatabin')
    ActualEMGs=BinnedData.emgdatabin;
else % just send dummy data as outputs for the function
    ActualEMGs=spikeData;
end

%% Use the neural filter to predict the EMGs
numsides=1; fs=1;
try
    [PredictedEMGs,spikeDataNew,ActualEMGsNew]=predMIMO3(usableSpikeData,filter.H,numsides,fs,ActualEMGs);
catch
    [PredictedEMGs,spikeDataNew,ActualEMGsNew]=predMIMO4(usableSpikeData,filter.H,numsides,fs,ActualEMGs);
end
%% remove firts bin of Predicted EMGs since it appears to be garbage...
%PredictedEMGs = PredictedEMGs(2:end, :);

clear ActualEMGs spikeData;

%% If you have one, convolve the predictions with a Wiener cascade polynomial.
if size(filter.P)>1
    Ynonlinear=zeros(size(PredictedEMGs));
    for z=1:size(PredictedEMGs,2);
        Ynonlinear(:,z) = polyval(filter.P(:,z),PredictedEMGs(:,z));
    end
    PredictedEMGs=Ynonlinear;
end

%% Aggregate Outputs in a Structure

[numpts,Nx]=size(usableSpikeData);
[nr,Ny]=size(filter.H);
fillen=nr/Nx;
timeframeNew = BinnedData.timeframe(fillen:numpts);
%timeframeNew = BinnedData.timeframe(fillen+1:numpts); % to account for additional bin removed at beginning of PredictedEMGs

PredData = struct('timeframe', timeframeNew,...
                  'predemgbin', PredictedEMGs,...
                  'spikeratedata', spikeDataNew,...
                  'emgguide',BinnedData.emgguide,...
                  'spikeguide', filter.neuronIDs);

end
