function [PWTH] = PWTH(signals,sigFreq,wordsVect,wordToAve,timeBefore,timeAfter)
    % this function averages signals (e.g. EMG or Force) from timeBefore
    % and timeAfter around the word with dec value 'wordToAve'.
    % the first colomn of the signals array should be a time vector in
    % seconds

    windowTimeFrame = -timeBefore:1/sigFreq:timeAfter;
    windowLength = length(windowTimeFrame);
    numSignals = size(signals,2)-1;
    
%     wordToAve_ts = wordsVect(find(wordsVect(:,2)==wordToAve &...
%                                   wordsVect(:,1)-timeBefore>=signals(1,1) &...
%                                   wordsVect(:,1)+timeAfter <=signals(end,1)),1);

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
        
    PWTH(:,2:end) = mean(tempPWTH(:,:,:),3);

end