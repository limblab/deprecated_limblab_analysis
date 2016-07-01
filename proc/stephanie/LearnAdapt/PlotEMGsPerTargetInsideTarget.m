function PlotEMGsPerTargetInsideTarget(out_struct,binnedData)
% This script plots the mean +- ste of EMG activity for trials separated by
% target. Only plots EMG for FCU, ECU, FCR, ECR

% Step 1
%Extract target info from trial table and plot targets
trialtable = GetFixTrialTable(out_struct,'learnadapt',0);
[~, TgtInd] = unique(trialtable(:,10));
figure; hold on; axis('square'); xlim([-14 14]); ylim([-14 14]);
MillerFigure;
rectangle('Position',[-2,-2,4,4],'EdgeColor',[0.7 0.7 0.7])
for i=1:length(TgtInd)
    width = trialtable(TgtInd(i),4)-trialtable(TgtInd(i),2);
    height = trialtable(TgtInd(i),3)-trialtable(TgtInd(i),5);
    % Get lower left target coordinates
    LLx = trialtable(TgtInd(i),2); LLy = trialtable(TgtInd(i),5);
    %Plot targets
    rectangle('Position',[LLx,LLy,width,height],'EdgeColor',[0 0 0])
end

% Get indices for muscles
FCUind = strmatch('FCU',binnedData.emgguide(1,:)); FCUind = FCUind(1);
FCRind = strmatch('FCR',binnedData.emgguide(1,:)); FCRind = FCRind(1);
ECUind = strmatch('ECU',binnedData.emgguide(1,:)); ECUind = ECUind(1);
ECRind = strmatch('ECR',binnedData.emgguide(1,:)); ECRind = ECRind(1);
% Get length of target side
side=4;
newXticks = side*(0.05:0.05:1);

goodTrials = find(binnedData.trialtable(:,9)==82);
goodTrialtable = binnedData.trialtable(goodTrials,:);
for targetNo = 1:8
    targetInd = find(goodTrialtable(:,10)==targetNo);
    if isempty(targetInd)
        continue
    end
    targetTrials = goodTrialtable(targetInd,:);
    NumSuccesses = length(targetTrials(:,1));
   FCUemg=[]; FCRemg = []; ECUemg = []; ECRemg = [];
   FCUdata = []; FCRdata = []; ECUdata = []; ECRdata = [];

    for trialNo = 1:length(targetTrials(:,1))
         
        LLx = targetTrials(trialNo,2); LLy = targetTrials(trialNo,5);
        Go = targetTrials(trialNo, 7);
        End = targetTrials(trialNo, 8);
        timeInds = find(binnedData.timeframe>=End-1 & binnedData.timeframe<=End);
        FCUemg(trialNo,:) = binnedData.emgdatabin(timeInds, FCUind);
        FCRemg(trialNo,:) = binnedData.emgdatabin(timeInds, FCRind);
        ECUemg(trialNo,:) = binnedData.emgdatabin(timeInds, ECUind);
        ECRemg(trialNo,:) = binnedData.emgdatabin(timeInds, ECRind);
        FCUdata(trialNo,:) = (FCUemg(trialNo,:)*side)+LLy; FCRdata(trialNo,:) = (FCRemg(trialNo,:)*side)+LLy;
        ECUdata(trialNo,:) = (ECUemg(trialNo,:)*side)+LLy;   ECRdata(trialNo,:) = (ECRemg(trialNo,:)*side)+LLy;
        newX = newXticks+LLx;
%                 plot(newX, FCUdata,'b')
%                 plot(newX,FCRdata,'c')
%                 plot(newX,ECUdata,'r')
%                 plot(newX,ECRdata,'m')
    end
    meanFCU = mean(FCUdata,1); meanFCR = mean(FCRdata,1);
    steFCU = std(FCUdata,1,1)/(sqrt(length(FCUdata)));  steFCR = std(FCRdata,1,1)/(sqrt(length(FCRdata)));
    plusFCUste = meanFCU+steFCU; minusFCUste = meanFCU-steFCU; plusFCRste = meanFCR+steFCR; minusFCRste = meanFCR-steFCR;
    meanECU = mean(ECUdata,1); meanECR = mean(ECRdata,1);
    steECU = std(ECUdata,1,1)/(sqrt(length(ECUdata)));  steECR = std(ECRdata,1,1)/(sqrt(length(ECRdata)));
    plusECUste = meanECU+steECU; minusECUste = meanECU-steECU; plusECRste = meanECR+steECR; minusECRste = meanECR-steECR;
    plot(newX, meanFCU,'b','LineWidth',1.5)
    plot(newX, meanFCR,'c','LineWidth',1.5)
    plot(newX, meanECU,'r','LineWidth',1.5)
    plot(newX, meanECR,'m','LineWidth',1.5)
    plot(newX, plusFCUste,'b--'); plot(newX, minusFCUste,'b--')
    plot(newX, plusFCRste,'c--'); plot(newX, minusFCRste,'c--')
    plot(newX, plusECUste,'r--'); plot(newX, minusECUste,'r--')
    plot(newX, plusECRste,'m--'); plot(newX, minusECRste,'m--')
    text((LLx+side/2)-.5,LLy-.5,strcat(['n = ',num2str(NumSuccesses)]))

    % saveas(gcf,strcat(savefolder,'Fig\',date,'EMGsForTarget', num2str(targetNo),'_', file1,'.fig'));saveas(gcf,strcat(savefolder,'PDF\',date,'EMGsForTarget', num2str(targetNo),'_', file1,'.pdf'));
end
 legend('FCU', 'FCR', 'ECU', 'ECR')
    legend boxoff

end