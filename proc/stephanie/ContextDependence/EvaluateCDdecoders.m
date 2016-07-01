function [EpochMeansDifference EpochMeansDifference_Tgt1  EpochMeansDifference_Tgt2  EpochMeansDifference_Tgt3] = EvaluateCDdecoders(out_struct, binnedData, OLPredData)

sorted = 1;

% Create trial table
trialtable = GetFixTrialTable(out_struct,'contextdep');


OTon = trialtable(:,6); 
TargetAcq = trialtable(:,8)-0.5;
EndofTrial = trialtable(:,8);
EndofTrialThenSome = trialtable(:,8)+0.4;


% Get your movement on timestamps
totalPos = hypot(out_struct.pos(:,2),out_struct.pos(:,3));
Vel = diff(totalPos);

suptitle('03-10-14 | Epoch Means Difference | 2FL decoder on 3FL data')
subplot(1,2,1);
xlabel('Target 1');
subplot(1,2,2)
xlabel('Target 2');
EpochMeansDifference(:,2)=trialtable(:,10);
for trialNo = 1:length(trialtable)
    
    % Get your movement on timestamps
    PosInd = find((out_struct.pos(:,1) >= OTon(trialNo)) & out_struct.pos(:,1) <= EndofTrial(trialNo));
    VelOTon2End = Vel(PosInd+1);
    [peak peakInd] = max(VelOTon2End);
    MoveONind = peakInd-10+PosInd(1);
    MoveON = out_struct.pos(MoveONind,1);
    
        
    % Find the indices for each trial
    PredIndices = find(OLPredData.timeframe >= MoveON & OLPredData.timeframe <= EndofTrialThenSome(trialNo));
    ActualIndices = find(binnedData.timeframe >= MoveON & binnedData.timeframe <= EndofTrialThenSome(trialNo));
    PredEpochForceX = OLPredData.preddatabin(PredIndices,1);
    ActualEpochForceX = binnedData.forcedatabin(ActualIndices,1);
    EpochMeansDifference(trialNo,1) = mean(abs(PredEpochForceX)) - mean(abs(ActualEpochForceX));  
    %EpochPeakDifference(trialNo,1) = min(PredEpochForceX) - min(ActualEpochForceX);
        
     if EpochMeansDifference(trialNo,2)==1
        EpochMeansDifference_Tgt1(trialNo,1) = mean(abs(PredEpochForceX)) - mean(abs(ActualEpochForceX));
        subplot(1,3,1)
        hold on
        plot(ActualEpochForceX,'b')
        plot(PredEpochForceX,'r')
        EpochMeansDifference(trialNo,2) = 1;
    else if EpochMeansDifference(trialNo,2)==3
            EpochMeansDifference_Tgt3(trialNo,1) = mean(abs(PredEpochForceX)) - mean(abs(ActualEpochForceX));
            subplot(1,3,3)
            hold on
            plot(ActualEpochForceX,'b')
            plot(PredEpochForceX,'r')
            EpochMeansDifference(trialNo,2) = 3;
        else if EpochMeansDifference(trialNo,2)==2
                EpochMeansDifference_Tgt2(trialNo,1) = mean(abs(PredEpochForceX)) - mean(abs(ActualEpochForceX));
                subplot(1,3,2)
                hold on
                plot(ActualEpochForceX,'b')
                plot(PredEpochForceX,'r')
                EpochMeansDifference(trialNo,2) = 2;
            end
            
            
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

% xlim([0 60])
% ylim([-1200 -200])
% 
% 
% figure; 
% boxplot(EpochMeansDifference(:,1),EpochMeansDifference(:,2))
% title('03-10-14 | Epoch Means Difference | 2FL decoder on 3FL data')
% xlabel('Target Number')
% ylim([-280 130])


end

