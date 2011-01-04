function [PredictedData,spikeDataNew,Hnew] = predAdapt(BinnedData,usableSpikeData,H,LR,Adapt_lag)

% only test on Force for now
    ActualData = BinnedData.cursorposbin;
%     ActualData = BinnedData.forcedatabin;
%     ActualData = BinnedData.emgdatabin;
%     LR = 1e-7; %Learning rate
    binsize = round(1000*(BinnedData.timeframe(2)-BinnedData.timeframe(1)))/1000;
    %find bins at which to measure error
%     w = BD_Words;
    
    %use a 500ms window before Adapt_bins to measure force error:
    Lag_bins =  round(Adapt_lag/(BinnedData.timeframe(2)-BinnedData.timeframe(1)))-1;
    

% %     Adapt_ts = BinnedData.words( bitor(BinnedData.words(:,2)==w.Go_Cue,isWord(BinnedData.words,'endtrial')),1);
%     Go_ts  = BinnedData.words(BinnedData.words(:,2)==w.Go_Cue,1);
%     Pos0   = zeros(length(Go_ts),1);
%     Go_ts  = [Go_ts Pos0];
%     EOT_ts = BinnedData.words(isWord(BinnedData.words,'endtrial'),1);
%     EOT_ts = [EOT_ts type1];
% 
%     Adapt_ts = [Go_ts;EOT_ts];
    

     Adapt_ts = get_tgt_center(BinnedData); %includes only trials ending with a reward
%     Adapt_ts = get_tgt_center_EOT(BinnedData); %includes all trials ending with Reward or Failure
    Adapt_bins = [ceil((Adapt_ts(:,1)-BinnedData.timeframe(1))/binsize) Adapt_ts(:,2:end)]; %convert first column of Adapt_ts to bins
    Adapt_bins = Adapt_bins(Adapt_bins(:,1)>Lag_bins,:); %remove first adapt step if too early
    
%     [PredictedData,spikeDataNew,Hnew] = predMIMOadapt8(usableSpikeData,H,LR,Adapt_bins,Lag_bins);    
     [PredictedData,spikeDataNew,Hnew] = predMIMOadapt7b(usableSpikeData,H,LR,Adapt_bins,Lag_bins);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt6(usableSpikeData,filter.H,ActualData,LR,Adapt_bins,Lag_bins);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt5(usableSpikeData,filter.H,ActualData,LR);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt4(usableSpikeData,filter.H,ActualData,LR,Adapt_bins,window);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt3(usableSpikeData,filter.H,ActualData,LR,Adapt_bins,window);
%    [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt1(usableSpikeData,filter.H,ActualData,LR);

end