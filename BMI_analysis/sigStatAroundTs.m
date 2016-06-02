function [meanSig, stdSig, N] = sigStatAroundTs(signals,ts,timebefore,timeafter,binsize)

% This function calculates the mean and std of signal(s) around time stamps provided as a vector in argin.
% timebefore and timeafter both have positive values.
% the first column of the signals array should be a time vector in
% seconds

numTs = length(ts);
%remove any ts that would fall out of range:
ts = ts(ts-timebefore>=signals(1,1) &...
          ts+timeafter<=signals(end,1));
if numTs ~=length(ts)
    disp(sprintf('%g out of %g events analyzed, %g event(s)  in out of range time window',...
                  length(ts), numTs, numTs-length(ts)));
    numTs = length(ts);
end
      
numSig = size(signals,2)-1;

timeWindow   = -timebefore:binsize:timeafter-binsize;
windowLength = length(timeWindow);

concatSigs = zeros(windowLength,numSig,numTs);

for i = 1:numTs
    low  = find(signals(:,1)>= ts(i)-timebefore,1,'first');
    high = low + windowLength -1;
    concatSigs(:,:,i) = signals(low:high,2:end);
end

meanSig = permute(mean(concatSigs,1),[3 2 1]);
% meanSig = mean(mean(concatSigs,1),3);
stdSig  =  std(mean(concatSigs,1),0,3);
N       = numTs;

end