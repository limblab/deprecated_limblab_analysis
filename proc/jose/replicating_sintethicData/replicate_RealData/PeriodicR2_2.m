function [R2, varargout] = PeriodicR2_2(filter,binnedData,foldlength,varargin)

%       R2                  : returns a (numFold,numSignals) array of R2 values 
%
%       filter              : decoder
%       binnedData          : data structure to build model from
%       foldlength          : fold length in seconds
%       varargin            : [Adapt Smooth];
%       varargout = {filter, vaf, mse, PredData, ActSignalsTrunk};

numPredSigs = size(filter.outnames,1);
binsize = filter.binsize;
numlags = round(filter.fillen/binsize);
numpts  = size(binnedData.timeframe,1);
numNeur = size(filter.neuronIDs,1);

if nargin > 3
    Adapt = varargin{1};
    % sliding window of input R2 every Adapt.NeurWindow bins
    numCorrSteps   = floor(numpts/Adapt.NcorrWindow);
    NR2 = NaN(numCorrSteps,numNeur);
    NPred = zeros(Adapt.NcorrWindow,numNeur);
    
    if nargin > 4
        Smooth = varargin{2};
    else
        Smooth = false;
    end
else
    Adapt.Enable = false;
    Smooth = false;
end

if mod(round(foldlength*1000), round(binsize*1000)) %all this rounding because of floating point errors
    disp('specified fold length must be a multiple of the data bin size');
    disp('operation aborted');
    return;
else
    %convert foldlenght from seconds to bins
    foldlength = round(foldlength/binsize);
end



%% Generate a control signal for learning rate

% Inactive for now
Adapt.NeuralControl = false;

if Adapt.Enable && Adapt.NeuralControl
    
    for currentCorr = 1:numCorrSteps
        windowStart = 1+(currentCorr-1)*Adapt.NcorrWindow;
        windowEnd   = windowStart+Adapt.NcorrWindow-1;

        % Make inputs predictions for current time window:
        for n = 1:numNeur
            if n==1
                otherNs = 2:numNeur;
            elseif n==numNeur
                otherNs = 1:numNeur-1;
            else
                otherNs = [1:n-1 n+1:numNeur];
            end
            %acutal prediction for neuron n
            NPred(:,n) = glmval(B(:,n),round(binnedData.spikeratedata(windowStart:windowEnd,otherNs)*binsize),'log');
            
            %Calculate correlation between pred and actual spike count for this neuron
            NR2(currentCorr,n) = calculateR2(NPred(windowStart:windowEnd,:),binnedData.spi(start:stop,:));
        end
        
        if mean(NR2(currentCorr,:),2)<Adapt.NcorrThresh
            %adapt
            %rebuild glm
        end 
        
    end
end
        

% Make outputs predictions:
if isfield(filter, 'PC')
    numPCs = size(filter.PC,2);
    [PredData, Hnew] = predictSignals2(filter,binnedData,Smooth,Adapt,numPCs);
else
    [PredData, Hnew] = predictSignals2(filter,binnedData,Smooth,Adapt);
end

% Update filter if adaptation was on
if Adapt.Enable
    filter.H = Hnew;
end

duration = size(binnedData.timeframe,1)-numlags+1;
nfold = floor(duration/foldlength);

R2 = zeros(nfold,numPredSigs);
vaf= zeros(nfold,numPredSigs);
mse= zeros(nfold,numPredSigs);

%% match predicted and actual data wrt to timeframes and outputs

% idx = false(size(binnedData.timeframe));
% for i = 1:length(PredData.timeframe)
%     idx = idx | binnedData.timeframe == PredData.timeframe(i);
% end

ActSignalsTrunk = zeros(numpts-numlags+1,numPredSigs);

for i=1:numPredSigs
    if isfield(binnedData,'emgdatabin')
        if ~isempty(binnedData.emgdatabin)
            if all(strcmp(nonzeros(binnedData.emgguide(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignalsTrunk(:,i:i+size(binnedData.emgdatabin,2)-1) = binnedData.emgdatabin(numlags:end,:);
            end
        end
    end
    if isfield(binnedData,'forcedatabin')
        if ~isempty(binnedData.forcedatabin)
            if all(strcmp(nonzeros(binnedData.forcelabels(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignalsTrunk(:,i:i+size(binnedData.forcedatabin,2)-1) = binnedData.forcedatabin(numlags:end,:);
            end
        end
    end
    if isfield(binnedData,'cursorposbin')
        if ~isempty(binnedData.cursorposbin)
            if all(strcmp(nonzeros(binnedData.cursorposlabels(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignalsTrunk(:,i:i+size(binnedData.cursorposbin,2)-1) = binnedData.cursorposbin(numlags:end,:);
            end
        end
    end

    if isfield(binnedData,'velocbin')
        if ~isempty(binnedData.velocbin)
            if all(strcmp(nonzeros(binnedData.veloclabels(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignalsTrunk(:,i:i+size(binnedData.velocbin,2)-1) = binnedData.velocbin(numlags:end,:);
            end
        end
    end
end

%% Calculate R2, vaf and mse for every fold, skip remaining time
for i=1:nfold
    
    %move the test block from beginning of file up to the end
    DataStart = (i-1)*foldlength+1;
    DataEnd   = DataStart + foldlength - 1;
    Act       = ActSignalsTrunk(DataStart:DataEnd,:);
    Pred      = PredData.preddatabin(DataStart:DataEnd,:);
    
    %calculate prediction accuracy
    R2(i,:)   = CalculateR2(Act,Pred)';
    vaf(i,:)  = 1 - sum( (Pred-Act).^2 ) ./ sum( (Act - repmat(mean(Act),size(Act,1),1)).^2 );
    mse(i,:)  = mean((Pred-Act).^2);

end


varargout = {filter, PredData, vaf, mse, ActSignalsTrunk};
   
    
    