function PredData = predictOutput(filter, data, binsize, spikeguide, actualdata)


numlags = round(filter.fillen/binsize); %round in case of floating point errror

%get usable units from filter info
matchingInputs = FindMatchingNeurons(spikeguide,filter.neuronIDs);

%% Inputs:

% default inputs is spike data
%populate spike data for data units matching the filter units
Inputs = zeros(size(data,1),size(filter.neuronIDs,1));
Inputs(:,logical(matchingInputs)) = data(:,nonzeros(matchingInputs));


%% Use the neural filter to predict the Data
numsides=1; fs=1;

%   predict with all of the channels
% [PredictedData,spikeDataNew,ActualDataNew]=predMIMO3_Matt(Inputs,filter.H,numsides,fs,actualdata);
[PredictedData,spikeDataNew,ActualDataNew]=predMIMO3(Inputs,filter.H,numsides,fs,actualdata);

%% If you have one, convolve the predictions with a Wiener cascade polynomial.
if ~isempty(filter.P)
    Ynonlinear=zeros(size(PredictedData));
    for z=1:size(PredictedData,2);
        Ynonlinear(:,z) = polyval(filter.P(:,z),PredictedData(:,z));
    end
    PredictedData=Ynonlinear;
    
end

%% Aggregate Outputs in a Structure

[numpts,Nx]=size(Inputs);
[nr,Ny]=size(filter.H);
fillen=nr/Nx;
spikeDataNew = Inputs(fillen:numpts,:);


PredData = struct('preddatabin', PredictedData,...
    'spikeratedata', spikeDataNew,...
    'outnames',filter.outnames,...
    'spikeguide', neuronIDs2spikeguide(filter.neuronIDs),...
    'actualdata',ActualDataNew);

end
