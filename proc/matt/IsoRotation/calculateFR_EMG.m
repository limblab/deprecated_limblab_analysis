function fr = calculateFR_EMG(emg,ints,timeCenters,winSize,iCenter)


fr = zeros(size(ints,1),size(emg,2)-1);
for unit = 2:size(emg,2)
    for iTrial = 1:size(ints,1)
        % how many spikes are in this window?
        if timeCenters(iTrial,iCenter) > 0
            totAct = sum(emg(emg(:,1) > ints(iTrial,1) & emg(:,1) <= ints(iTrial,2),unit));
            fr(iTrial,unit) = totAct ./ winSize;
        else
            fr(iTrial,unit) = 0;
        end
    end
end
