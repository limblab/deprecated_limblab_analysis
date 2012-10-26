function [PredictedData,spikeDataNew,Hnew] = predAdapt2(BinnedData,Inputs,H,Adapt)

    % Adapt is a structure:
    % Adapt.LR          : learning rate Typically ~ 1e-7
    % Adapt.EMGpatterns : provides the expected EMG values from which to measure prediction
    %                     errors. This is an array of size (numTargets+1) x numEMGs, the first
    %                     row provides the EMG estimate during rest state (touch pad or center)
    %                     and each following rows contain the expected EMG values in each muscle
    %                     for each target
    % Adapt.Lag         : Adapt.Lag = [timeBefore timeAfter]. This is the time around each "Reward"
    %                     or "Go Cue" over which we want to compare our predictions with the expected
    %                     EMG values.
    % Adapt.jtype       : 1, if want to use EMG patterns
    %                     2, if want to use real EMG

    % multiplying then dividing by 1000 because of occasional floating point error that leads to
    % calculating binsize of e.g. 0.0499999s instead of 0.05s
    binsize = round(1000*(BinnedData.timeframe(2)-BinnedData.timeframe(1)))/1000;
    
    % Find times at which error detection should occur.
    %  Adapt_ts : is an array of size (num_ts x numEMGs+1), containing all the valid "Reward"
    %             and "Go" time stamp in the first column, and the corresponding expected
    %             EMG values for each muscles in the columns 2:end
    %
%     Adapt_ts = get_tgt_center(BinnedData.trialtable);
%     Adapt_ts = get_expected_EMGs_MG(BinnedData.trialtable,Adapt.EMGpatterns);

    if (Adapt.jtype == 1)
        Adapt_ts = get_expected_EMGs_WF(BinnedData.trialtable,Adapt.EMGpatterns);
    elseif (Adapt.jtype == 2)
        timeBefore = 0.5;
        timeAfter = 0;
        EMGvector = 1:size(BinnedData.emgguide,1);
        Adapt_ts = get_Real_EMGs_WF(BinnedData, timeBefore, timeAfter,EMGvector);
    end
        
    %convert first column of Adapt_ts to bins
    Adapt_bins = [ceil((Adapt_ts(:,1)-BinnedData.timeframe(1))/binsize) Adapt_ts(:,2:end)];
    %remove first adapt step if too early
    Adapt_bins = Adapt_bins(Adapt_bins(:,1)>Adapt.Lag,:); 

    %Predict data, remove 
    [PredictedData,spikeDataNew,Hnew]= predMIMOadapt10(Inputs, Adapt_bins, H, Adapt);
%      [PredictedData,spikeDataNew,Hnew] = predMIMOadapt9(usableSpikeData,H,Adapt.LR,Adapt_bins,Lag_bins);    
%      [PredictedData,spikeDataNew,Hnew] = predMIMOadapt7b(usableSpikeData,H,LR,Adapt_bins,Lag_bins);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt6(usableSpikeData,filter.H,ActualData,LR,Adapt_bins,Lag_bins);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt5(usableSpikeData,filter.H,ActualData,LR);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt4(usableSpikeData,filter.H,ActualData,LR,Adapt_bins,window);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt3(usableSpikeData,filter.H,ActualData,LR,Adapt_bins,window);
%    [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt1(usableSpikeData,filter.H,ActualData,LR);

end