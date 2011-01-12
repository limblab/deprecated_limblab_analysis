function state = GFR_clas(spikedata,binsize)

%calculate average firing rate:
AveFR = mean(spikedata,2);

%smooth AveFR
FR_smoothlag = 5; %5-point moving average
AveFR_S = tsmovavg(AveFR','m',FR_smoothlag); %smooth FR
AveFR(FR_smoothlag:end) = AveFR_S(FR_smoothlag:end);

%threshold the signal using mean
threshold = mean(AveFR);
% threshold = mean(AveFR)+std(AveFR);
FR_thresh = AveFR>= threshold;
% FR_thresh = false(length(AveFR),1);
% FR_thresh(AveFR >= threshold) = true;

%"debounce" threshold signal
offset_FR_thresh = [FR_thresh(2:end); false];
Edges = find(bitxor(FR_thresh,offset_FR_thresh));
clear offset_FR_thresh;
minBinDuration = ceil(0.300/binsize); %300 ms in number of bins (20Hz->6bins)
step =1;
for i = 1:step:length(Edges)-minBinDuration
    if mean(FR_thresh(Edges(i):Edges(i)+minBinDuration))>0.5
        %mostly "up" -> debounce up
        FR_thresh(Edges(i):Edges(i)+minBinDuration) = true;
    else
        %mostly "down" -> debounce down
        FR_thresh(Edges(i):Edges(i)+minBinDuration) = false;
    end
    step = find(Edges(i+1:end)-Edges(i)>=minBinDuration,1);
    if ~step
        break;
    end
end
% we have the threshold signal:
state = FR_thresh;

% But we want to include a delay between the change
% in cortical activity and the change in state. use 100ms.
FR_Mvt_delta = round(0.100/binsize); %100ms delay (in number of bins) between FR_mod and Preds
% shift the threshold signal by the appropriate number of bins,
% using initial state to patch at beginning.
state = [repmat(state(1),FR_Mvt_delta,1); state(1:end-FR_Mvt_delta) ];

end




