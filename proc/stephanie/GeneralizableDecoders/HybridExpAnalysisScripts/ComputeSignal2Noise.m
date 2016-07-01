function SNR = ComputeSignal2Noise(EMG)

% 1. Take the diff of your signal
% 2. Find a .3second stretch where the diff is less than ___
% 3. 


windowLength = ceil(.3/.05);
changingIndices = [1:1:windowLength];
for i=1:length(EMG)-length(changingIndices)
    SlidingEMGmean(i) = mean(EMG(changingIndices));
    changingIndices = changingIndices+ones(1,windowLength);
end
sortedEMGmean = sort(SlidingEMGmean,'ascend');
FiveNoiseMeans = sortedEMGmean(1:5);
FiveSignalMeans = sortedEMGmean(end-3:-1:end-7);
allSNR = FiveSignalMeans./FiveNoiseMeans;
SNR = mean(allSNR);





% old code
% sortedEMG = sort(EMG, 'ascend');
% lowThreshold = sortedEMG(5000);
% % find a stretch where your signal is below threshold for .3s
% belowThresh = find(EMG<=lowThreshold);
% diffEMG = diff(belowThresh);
% 
%   counter = 0;
%   goodNoiseIndices = zeros(6,1);
% for i = 1:length(diffEMG)
%     if diffEMG(i)==1
%         counter = counter+1;
%         goodNoiseIndices(counter)=belowThresh(i);
%     else
%         counter=0;
%     end
%     if counter==6
%         break
%     end
% end
% noiseMean = mean(EMG(goodNoiseIndices));
% 
% highThreshold = sortedEMG(end-2000);
% aboveThresh = find(EMG>=highThreshold);
% diffEMG = diff(aboveThresh);
% 
%   counter = 0;
%   goodSignalIndices = zeros(6,1);
% for i = 1:length(diffEMG)
%     if diffEMG(i)==1
%         counter = counter+1;
%         goodSignalIndices(counter)=aboveThresh(i);
%     else
%         counter=0;
%     end
%     if counter==6
%         break
%     end
% end
% signalMean = mean(EMG(goodSignalIndices));
% 
% SNR = signalMean/noiseMean;
% 
% end
% 
