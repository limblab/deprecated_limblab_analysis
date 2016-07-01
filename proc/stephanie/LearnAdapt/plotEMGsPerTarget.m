function plotEMGsPerTarget(binnedData,savePlots)
% This script plots the mean +- ste of EMG activity for trials separated by
% target. Only plots EMG for FCU, ECU, FCR, ECR

% Step 1


% Get indices for muscles
FCUind = strmatch('FCU',binnedData.emgguide(1,:)); FCUind = FCUind(1);
FCRind = strmatch('FCR',binnedData.emgguide(1,:)); FCRind = FCRind(1);
ECUind = strmatch('ECU',binnedData.emgguide(1,:)); ECUind = ECUind(1);
ECRind = strmatch('ECR',binnedData.emgguide(1,:)); ECRind = ECRind(1);

for targetNo = 1:8
    targetInd = find(binnedData.trialtable(:,10)==targetNo);
    if isempty(targetInd)
        continue
    end
    targetTrials = binnedData.trialtable(targetInd,:);
    figure; hold on;title(num2str(targetNo));
    
    for trialNo = 1:length(targetTrials(:,1))
        Go = targetTrials(trialNo, 7);
        End = targetTrials(trialNo, 8);
        timeInds = find(binnedData.timeframe>=End-1 & binnedData.timeframe<=End);
        FCUemg = binnedData.emgdatabin(timeInds, FCUind);
         FCRemg = binnedData.emgdatabin(timeInds, FCRind);
         ECUemg = binnedData.emgdatabin(timeInds, ECUind);
          ECRemg = binnedData.emgdatabin(timeInds, ECRind);
        plot(FCUemg,'b')
        plot(FCRemg,'c')
        plot(ECUemg,'r')
        plot(ECRemg,'m')
    end
    legend('FCU', 'FCR', 'ECU', 'ECR')
   % saveas(gcf,strcat(savefolder,'Fig\',date,'EMGsForTarget', num2str(targetNo),'_', file1,'.fig'));saveas(gcf,strcat(savefolder,'PDF\',date,'EMGsForTarget', num2str(targetNo),'_', file1,'.pdf'));
end
       
end