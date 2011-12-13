function [PWTH,varargout] = PWTH(signals,wordsVect,wordToAve,timeBefore,timeAfter)
    % this function averages signals (e.g. EMG or Force) from timeBefore
    % and timeAfter around the word with dec value 'wordToAve'.
    % the first colomn of the signals array should be a time vector in
    % seconds

    binsize = signals(2,1)-signals(1,1);
    windowTimeFrame = -timeBefore:binsize:timeAfter-binsize;
    windowLength = length(windowTimeFrame);
    numSignals = size(signals,2)-1;
  
    wordToAve_ts = wordsVect(wordsVect(:,2)==wordToAve &...
                                  wordsVect(:,1)-timeBefore>=signals(1,1) &...
                                  wordsVect(:,1)+timeAfter <=signals(end,1),1);
                                  
                              
    numWords = length(wordToAve_ts);
    
    PWTH = zeros(windowLength,numSignals+1);
    PWTH(:,1) = windowTimeFrame;
    
    tempPWTH = zeros(windowLength,numSignals,numWords);
    
    for i=1:numWords
        low = find(signals(:,1)>=wordToAve_ts(i)-timeBefore,1,'first');
        high= low + windowLength-1;
        tempPWTH(:,:,i)= signals(low:high,2:end);
    end
    
    SD            = std (tempPWTH,0,3);
    PWTH(:,2:end) = mean(tempPWTH,3);

    varargout = {SD};
end