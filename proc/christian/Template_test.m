timeWindow = 1;
samplefreq = 20;

% numBins = timeWindow*samplefreq;

% [Center_ts, Reward_ts] = get_tgt_id(out_struct);
CR_ts = Get_Center_and_Reward_ts(out_struct);
% clear out_struct;

signals = [binnedData.timeframe binnedData.emgdatabin(:,[3 4 5 9])];
S = ave_tgt_EMGs(signals,CR_ts,timeWindow);
clear signals;
% 
% [ModelData, tmpData,ActualData] = Get_Rate_Template_pairs(binnedData,S,Center_ts,Reward_ts,timeWindow);
[ModelData,ActualData_Mod] = Get_Model_Data_Template(binnedData,S,CR_ts,timeWindow);


% clear binnedData CR_ts S timeWindow samplefreq;


dataPath = '';
fillen = 0.2;
UseAllInputsOption = 1;
PolynomialOrder = 2;

[filter,PredModelData] = BuildModel_Templates(ModelData,  dataPath, fillen, UseAllInputsOption, PolynomialOrder);
% clear ModelData;
% 

[PredData] = predictSignals(filter,binnedData);

EMGvector = [3 4 5 9];
ActualData = binnedData;
ActualData.emgdatabin = binnedData.emgdatabin(:,EMGvector);
ActualData.emgguide   = binnedData.emgguide  (EMGvector,:);

plotflag=1;
ActualvsOLPred(ActualData, PredData, plotflag)
% 
% for i = 1:4
% 
%     figure; plot(BinnedData.emgdatabin(:,EMGvector(i)),'k');
%     hold on;
%     plot(PredictedData.preddatabin(:,i),'r');
% end

%          BuildModel_Templates(binnedData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, varargin)