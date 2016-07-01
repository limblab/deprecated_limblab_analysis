function [EpochMeansDifference EpochMeansDifference_Tgt1  EpochMeansDifference_Tgt2  EpochMeansDifference_Tgt3] = EvaluateCDHybriddecoders(binnedData, OLPredData,n);
sorted = 1;

% Create trial table
%trialtable = GetFixTrialTable(out_struct,'contextdep');
%trialtable = binnedData.trialtable;



% Get your movement on timestamps
totalPos = hypot(binnedData.cursorposbin(:,1),binnedData.cursorposbin(:,2));
Vel = diff(totalPos); Vel = double(Vel);
peakInd = find(findpeaks(Vel, 'minpeakdistance', 23));
[VelPeaks VelIndices] = findpeaks(Vel,'minpeakheight',0.8,'minpeakdistance',10);
MoveONind = VelIndices-2;
MoveON = (binnedData.timeframe(MoveONind-1));

suptitle('03-10-14 | Epoch Means Difference | 3FL decoder on 2FL data')
subplot(1,n,1);
xlabel('Target 1');
subplot(1,n,2)
xlabel('Target 2');
if n == 3
    subplot(1,n,3)
    xlabel('Target 3');
end


for trialNo = 1:length(MoveON)
    
    
    
    % Find the indices for each trial
    PredIndices = find(OLPredData.timeframe >= MoveON(trialNo)+0.6 & OLPredData.timeframe <= MoveON(trialNo)+1);
    ActualIndices = find(binnedData.timeframe >= MoveON(trialNo)+0.6 & binnedData.timeframe <= MoveON(trialNo)+1);
    PredEpochForceX = OLPredData.preddatabin(PredIndices,1);
    ActualEpochForceX = binnedData.forcedatabin(ActualIndices,1);
    EpochMeansDifference(trialNo,1) = mean(abs(PredEpochForceX)) - mean(abs(ActualEpochForceX));
    if max(abs(ActualEpochForceX))<700
        EpochMeansDifference_Tgt1(trialNo,1) = mean(abs(PredEpochForceX)) - mean(abs(ActualEpochForceX));
        subplot(1,n,1)
        hold on
        plot(ActualEpochForceX,'b')
        plot(PredEpochForceX,'r')
        EpochMeansDifference(trialNo,2) = 1;
    else if max(abs(ActualEpochForceX))>960
            EpochMeansDifference_Tgt3(trialNo,1) = mean(abs(PredEpochForceX)) - mean(abs(ActualEpochForceX));
            subplot(1,n,3)
            hold on
            plot(ActualEpochForceX,'b')
            plot(PredEpochForceX,'r')
            EpochMeansDifference(trialNo,2) = 3;
        else
            EpochMeansDifference_Tgt2(trialNo,1) = mean(abs(PredEpochForceX)) - mean(abs(ActualEpochForceX));
            subplot(1,n,2)
            hold on
            plot(ActualEpochForceX,'b')
            plot(PredEpochForceX,'r')
            EpochMeansDifference(trialNo,2) = 2;
        end
        
        
        
    
 
end

 

TgtNoindices = find(EpochMeansDifference(:,2)==1);
EpochMeansDifference_Tgt1 =  EpochMeansDifference(TgtNoindices);
TgtNoindices = find(EpochMeansDifference(:,2)==2);
EpochMeansDifference_Tgt2 =  EpochMeansDifference(TgtNoindices);
TgtNoindices = find(EpochMeansDifference(:,2)==3);
if isempty(TgtNoindices) == 0
    EpochMeansDifference_Tgt3 =  EpochMeansDifference(TgtNoindices);
else
    EpochMeansDifference_Tgt3 = [];
end

 
%  
% % 
% figure; 
% boxplot(EpochMeansDifference(:,1),EpochMeansDifference(:,2))
% title('03-10-14 | Epoch Means Difference | 2FL decoder  within')
% xlabel('Target Number')


end

