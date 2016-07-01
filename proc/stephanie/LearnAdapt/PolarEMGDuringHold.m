% This function plots EMG activity for the 4 wrist muscles during the hold
% period
function PolarEMGDuringHold(binnedData)

% Get successful trialtable
goodTrials = find(binnedData.trialtable(:,9)==82);
goodTrialtable = binnedData.trialtable(goodTrials,:);
% Find index for the 4 wrist muscles
FCUind = strmatch('FCU',binnedData.emgguide(1,:)); FCUind = FCUind(1);
FCRind = strmatch('FCR',binnedData.emgguide(1,:)); FCRind = FCRind(1);
ECUind = strmatch('ECU',binnedData.emgguide(1,:)); ECUind = ECUind(1);
ECRind = strmatch('ECR',binnedData.emgguide(1,:)); ECRind = ECRind(1);

for targetNo = 1:8
    targetInd = find(goodTrialtable(:,10)==targetNo);
    if isempty(targetInd)
        continue
    end
    targetTrials = goodTrialtable(targetInd,:);
    NumSuccesses = length(targetTrials(:,1));
   FCUemg=[]; FCRemg = []; ECUemg = []; ECRemg = [];
   FCUdata = []; FCRdata = []; ECUdata = []; ECRdata = [];
    SingleTrialFCUmeans = [];  SingleTrialFCRmeans = [];
     SingleTrialECUmeans = [];  SingleTrialECRmeans = [];

    for trialNo = 1:length(targetTrials(:,1))
         
        Go = targetTrials(trialNo, 7);
        End = targetTrials(trialNo, 8);
        timeInds = find(binnedData.timeframe>=End-0.3 & binnedData.timeframe<=End);
        FCUemg(trialNo,:) = binnedData.emgdatabin(timeInds, FCUind);
        FCRemg(trialNo,:) = binnedData.emgdatabin(timeInds, FCRind);
        ECUemg(trialNo,:) = binnedData.emgdatabin(timeInds, ECUind);
        ECRemg(trialNo,:) = binnedData.emgdatabin(timeInds, ECRind);
        SingleTrialFCUmeans(trialNo,:) = mean(FCUemg(trialNo,:));
        SingleTrialFCRmeans(trialNo,:) = mean(FCRemg(trialNo,:));
        SingleTrialECUmeans(trialNo,:) = mean(ECUemg(trialNo,:));
        SingleTrialECRmeans(trialNo,:) = mean(ECRemg(trialNo,:));
    end
    meanFCU(targetNo) = mean(SingleTrialFCUmeans); meanFCR(targetNo) = mean(SingleTrialFCRmeans);
    steFCU(targetNo) = (std(SingleTrialFCUmeans')/(sqrt(length(SingleTrialFCUmeans))))';  steFCR(targetNo) = (std(SingleTrialFCRmeans')/(sqrt(length(SingleTrialFCRmeans))))';
    plusFCUste(targetNo) = meanFCU(targetNo)+steFCU(targetNo); minusFCUste(targetNo) = meanFCU(targetNo)-steFCU(targetNo); 
    plusFCRste(targetNo) = meanFCR(targetNo)+steFCR(targetNo); minusFCRste(targetNo) = meanFCR(targetNo)-steFCR(targetNo);
    meanECU(targetNo) = mean(SingleTrialECUmeans); meanECR(targetNo) = mean(SingleTrialECRmeans);
    steECU(targetNo) = (std(SingleTrialECUmeans')/(sqrt(length(SingleTrialECUmeans))))';  steECR(targetNo) = (std(SingleTrialECRmeans')/(sqrt(length(SingleTrialECRmeans))))';
    plusECUste(targetNo) = meanECU(targetNo)+steECU(targetNo); minusECUste(targetNo) = meanECU(targetNo)-steECU(targetNo); 
    plusECRste(targetNo) = meanECR(targetNo)+steECR(targetNo); minusECRste(targetNo) = meanECR(targetNo)-steECR(targetNo);


    % saveas(gcf,strcat(savefolder,'Fig\',date,'EMGsForTarget', num2str(targetNo),'_', file1,'.fig'));saveas(gcf,strcat(savefolder,'PDF\',date,'EMGsForTarget', num2str(targetNo),'_', file1,'.pdf'));
end

PolarSetup
polarPlotLearnAdapt(meanFCR, plusFCRste, minusFCRste,'c')
polarPlotLearnAdapt(meanFCU, plusFCUste, minusFCUste,'b')
polarPlotLearnAdapt(meanECR, plusECRste, minusECRste,'m')
polarPlotLearnAdapt(meanECU, plusECUste, minusECUste,'r')

end


