function [binned_stim_array, stimT] = binPW_atStimFreq(stim_array)
%stim_array        = [ts ch I PW]
%binned_stim_array = [ts pw_ch1 pw_ch2 ...]
%stimT             = 1/stimfreq

if isempty(stim_array)
    binned_stim_array = [];
    stimT = [];
else
    
    chans         = unique(stim_array(:,2));
    numchans      = length(chans);
    stim_array_ch = cell(1,numchans);

    % find stim period
    stimT = inf;
    for ch = 1:numchans
        idx = find(stim_array(:,2)==chans(ch));
        stim_array_ch{ch} = stim_array(idx,:);
    %     T_temp = min(diff(stim_array(idx,1)));
        T_temp = diff(stim_array(idx,1)); %inter pulse periods
        T_temp = T_temp(T_temp<0.05); %exclude long intervals (>50ms,<20Hz)
        T_temp = prctile(T_temp,50); %this should exclude very short period outliars (10th percentile)
        if T_temp < stimT
            stimT = T_temp;
        end
    end

    %round period to .01 ms
    stimT = round(100000*stimT)/100000;

    numbins = round(stim_array(end,1)/stimT);
    binned_stim_array = zeros(numbins,numchans+1);
    timeframe = 0:stimT:stimT*(numbins-1);
    binned_stim_array(:,1) = timeframe;

    for cmd = 1:size(stim_array,1)
        idx = find(timeframe<stim_array(cmd,1),1,'last');
        binned_stim_array(idx,stim_array(cmd,2)+1) = stim_array(cmd,4);  
    end
end