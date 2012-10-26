clear all; close all; clc

%% Loading structures and setting some parameters

load fakeNeurRealEMGs_AdaptParams4.mat
numPredSigs = size(filter.outnames,1);
binsize = filter.binsize;
numlags = round(filter.fillen/binsize);
numpts  = size(binnedData.timeframe,1);
numNeur = size(filter.neuronIDs,1);
filter.P = filter.P';
PredData = predictSignals(filter,testData);
duration = size(binnedData.timeframe,1)-numlags+1;
foldlength = 120; % 120 sec = 2 min

if mod(round(foldlength*1000), round(binsize*1000)) %all this rounding because of floating point errors
    disp('specified fold length must be a multiple of the data bin size');
    disp('operation aborted');
    return;
else
    %convert foldlenght from seconds to bins
    foldlength = round(foldlength/binsize);
end

nfold = floor(duration/foldlength);

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

%% Fixed no drop

Adapt.Enable = false;
% [R2FF, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2(filter,testData,foldlength,Adapt);
R2FF=R2;
% Plot predictions:
[numR2,numEMGs] = size(R2FF);
xa = PredData.timeframe/60;

for i = 1:numEMGs
    figure; hold on;
    plot(xa,ActSignalsTrunk(:,i),'k');
    plot(xa,PredData.preddatabin(:,i),'r');
    title(sprintf('%s\nFixed Linear Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('EMG');
end


% Plot R2:
[numR2,numEMGs] = size(R2FF);
xa = (1:numR2)*foldlength/60;
for i = 1:numEMGs
    figure; plot(xa,R2FF(:,i)); ylim([0 1]);
    title(sprintf('%s\nFixed Linear Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('R2');
end

% Plot average EMG R2
figure; plot(xa, mean(R2FF,2));ylim([0 1]);
title(sprintf('Average Accross Muscles\nFixed Linear Decoder'));
xlabel('Time (min)');
ylabel('R2');    