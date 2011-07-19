function [STA,STV] = STA(stim_ts, signals, timeBefore, timeAfter)
    % this function averages signals (e.g. EMG or Force) from timeBefore
    % and timeAfter around the time of the timestamps in stim_ts.
    % the first colomn of the signals array should be a time vector in
    % seconds
    
    sigFreq = 1/(signals(2,1)-signals(1,1));
    windowTimeFrame = -timeBefore:1/sigFreq:timeAfter;
    windowLength = length(windowTimeFrame);
    numSignals = size(signals,2)-1;
    
    %discard stim_ts that are out of bound of signals ts
    numStim = length(stim_ts);
    stim_ts = stim_ts( stim_ts-timeBefore >= signals(1,1) &...
                       stim_ts+timeAfter  <= signals(end,1));
                                 
    numStim_ok = length(stim_ts);
    %disp(sprintf('%d out of %d stimulus were averaged',numStim_ok,numStim));
    
    %pre-allocate
    STA = zeros(windowLength,numSignals+1);
    STA(:,1) = windowTimeFrame;
    tempSTA = zeros(windowLength,numSignals,numStim_ok);
    
    %Average
    for i=1:numStim_ok
        low = find(signals(:,1)>=stim_ts(i)-timeBefore,1,'first');
        high= round(low) + windowLength-1;
        tempSTA(:,:,i)= signals(low:high,2:end);
    end
        
    STA(:,2:end) = mean(tempSTA(:,:,:),3);
    STV(:,2:end) = var(tempSTA(:,:,:),3);
end