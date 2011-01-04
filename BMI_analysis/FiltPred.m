function PredictedData = FiltPred(PredictedData,spikeDataNew,binsize)

%% 1 - Binary average lag time
% if FiltPred
%     PredictedData_S = zeros(size(PredictedData));
%     
%     PredRate = round(1/(BinnedData.timeframe(2)-BinnedData.timeframe(1)));
%     Pred_smoothlag_max = int32(0.5*PredRate); % whatever number of bins that makes 500ms
%     Pred_smoothlag_min = 0; %no smoothing.
%     
%     %abs of first derivative of (5-point smoothed) firing rate
%     FR_smoothlag = 5; %5-point moving average
%     AveFR = mean(spikeDataNew,2);
%     AveFR_S = tsmovavg(AveFR','m',FR_smoothlag);
%     AveFR(FR_smoothlag:end) = AveFR_S(FR_smoothlag:end);
%     
%     FR_mod = [ 0; abs(diff(AveFR)) ]; %abs of first derivative
% %    FR_mod = 1-(FR_mod/max(FR_mod));%normalize & inverse
% 
%     threshold = mean(FR_mod)+std(FR_mod);
%     FR_thresh = false(length(FR_mod),1);
%     FR_thresh( FR_mod >= threshold) = true;
% 
%     %now "debounce" threshold signal
%     offset_FR_thresh = [FR_thresh(2:end); false];
%     risingEdge   = find(~FR_thresh &  offset_FR_thresh);
%     clear offset_FR_thresh;
%     minBinDuration = 0.300*PredRate; %300 ms in number of bins (20Hz->6bins)
%     debounced_FR_thresh = false(size(FR_thresh));
%     
%     step =1;    
%     for i = 1:step:length(risingEdge)-minBinDuration
%         if mean(FR_thresh(risingEdge(i):risingEdge(i)+minBinDuration))>0.5
%             %mostly "up" -> debounce up
%             debounced_FR_thresh(risingEdge(i):risingEdge(i)+minBinDuration) = true;
%             step = find(risingEdge(i+1:end)-risingEdge(i)>minBinDuration,1);
%             if ~step
%                 break;
%             end
%         else
%             step = 1;
%         end
%     end     
%     
%     %higher cortical modulation -> shorter moving window for preds
%     FR_EMG_delta = round(0.1*PredRate); %100ms delay (in number of bins) between FR_mod and Preds
%     PredictedData_S(1:FR_EMG_delta) = PredictedData(1:FR_EMG_delta);
%     max_lag = FR_EMG_delta;
%         
%     FR_thresh = debounced_FR_thresh;
%     for i=1+FR_EMG_delta:size(PredictedData,1);
%         smooth_flag = true;
%         if FR_thresh(i-FR_EMG_delta)
%              %cortical activity is changing, don't smooth Preds
%             Pred_smoothlag = Pred_smoothlag_min;
%             if smooth_flag
%                 %we just entered a change in cortical activity
%                 %reset max_lag to 0 so future lag won't include
%                 %predictions older than this point
%                 max_lag = 0;
%                 smooth_flag = false;
%             end
%         else
%             %no much change in cortical activity, smooth preds
%             Pred_smoothlag = Pred_smoothlag_max;
%             smooth_flag = true;
%         end
%         Pred_smoothlag = min(max_lag,Pred_smoothlag); % in case Pred_smoothlag is longer than previous data
%         PredictedData_S(i,:) = mean(PredictedData((i-Pred_smoothlag):i,:),1);
%         max_lag = max_lag+1;
%     end
%     PredictedData = PredictedData_S;
%     clear PredictedData_S;
% end

%% 2- truely variable window length
% if FiltPred
%     PredictedData_S = zeros(size(PredictedData));
%     
%     PredRate = round(1/binsize);
%     Pred_smoothlag_max = round(0.5*PredRate); % whatever number of bins that makes 500ms
%     
%     %abs of first derivative of (5-point smoothed) firing rate
%     FR_smoothlag = 5; %5-point moving average
%     AveFR = mean(spikeDataNew,2);
%     AveFR_S = tsmovavg(AveFR','m',FR_smoothlag);
%     AveFR(FR_smoothlag:end) = AveFR_S(FR_smoothlag:end);
%     
%     FR_mod = [ 0; abs(diff(AveFR)) ]; %abs of first derivative
%     FR_mod = 1-(FR_mod/max(FR_mod));%normalize & inverse
%     %use exponential to weight average window length:
%     % weigth w is set so when FR_mod is average, window = 63%*Pred_smoothlag_max
%     w = log(1-(1/exp(1)))/(mean(FR_mod)-1);
%     mod_index = round(  Pred_smoothlag_max * exp( w * (FR_mod-1))  );
%     
%     %then make sure mod_index do not increase by more than one from one
%     %bin to the next (it can and should decrease as fast as it is though)
%     mod_index_offset = [NaN; mod_index(1:end-1)];
%     steep_rises = mod_index-mod_index_offset > 1;
%     while any(steep_rises)
%         mod_index(steep_rises) = mod_index(find(steep_rises)-1)+1;
%         mod_index_offset = [NaN; mod_index(1:end-1)];
%         steep_rises = mod_index-mod_index_offset > 1;
%     end
%     
%     %higher cortical modulation -> shorter moving window for preds
%     FR_EMG_delta = round(0.1*PredRate); %100ms delay (in number of bins) between FR_mod and Preds
%     PredictedData_S(1:FR_EMG_delta) = PredictedData(1:FR_EMG_delta);
%     
%     for i=1+FR_EMG_delta:size(PredictedData,1);
%         
%         Pred_smoothlag = mod_index(i-FR_EMG_delta);
%         Pred_smoothlag = min(i-1,Pred_smoothlag);        
%         PredictedData_S(i,:) = mean(PredictedData((i-Pred_smoothlag):i,:),1);
%     end
%     PredictedData = PredictedData_S;
%     clear PredictedData_S;
% end
%% 3- Varying a LP filter's time constant
%if FiltPred
    
    RC_max = 0.2; % 200ms
    
    %Smooth Firing Rate:
    RC = 0.1; %100 ms
    AveFR = SmoothLP(mean(spikeDataNew,2), binsize, RC);
 
    %abs of first derivative of AveFR
    FR_mod = [ 0; abs(diff(AveFR)) ]; %abs of first derivative
    FR_mod = 1-(FR_mod/max(FR_mod)); %normalize & inverse
    
    %weight exponentially from 0 to RC_max with a sigmoid:
    Top = RC_max;Bottom = 0;V50 = 0.6;Slope = 0.1;
    RC = Bottom + (Top-Bottom)./(1+exp((V50-FR_mod)/Slope));

    %then make sure RC do not increase by more than binsize from one
    %bin to the next (it can and should decrease fast when appropriate though)
    RC_offset = [NaN; RC(1:end-1)];
    steep_rises = RC-RC_offset > binsize;
    max_inc = binsize-0.0001;
    while any(steep_rises)
        RC(steep_rises) = RC(find(steep_rises)-1) + max_inc;
        RC_offset = [NaN; RC(1:end-1)];
        steep_rises = RC-RC_offset > binsize;
    end

    %Smooth Predictions:
    dt = binsize;
    for i=2:size(PredictedData,1)
        a = dt/(RC(i)+dt);
        PredictedData(i,:)= PredictedData(i-1,:) + a*( PredictedData(i,:)-PredictedData(i-1,:) );
    end
end