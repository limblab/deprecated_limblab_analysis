function fr = calculateFR(neural,ints,timeCenters,winSize,iCenter)

   % Find spikes in time window
    spikeCounts = zeros(size(ints,1),length(neural));
    for unit = 1:length(neural)
        ts = neural(unit).ts;
        for iTrial = 1:size(ints,1)
            if timeCenters(iTrial,iCenter) > 0
                % how many spikes are in this window?
                spikeCounts(iTrial,unit) = length(ts(ts > ints(iTrial,1) & ts <= ints(iTrial,2)));
            else
                spikeCounts(iTrial,unit) = 0;
            end
        end
    end
    
    fr = spikeCounts./winSize; % Compute a firing rate