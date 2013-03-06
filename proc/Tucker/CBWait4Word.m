function [ Status Delay ] = CBWait4Word( myword, interval, maxwait, mode )
% CBWait4Word: Run a tight loop, returning when the required word appears at Cerebus
%
% myword:   code, the upper 4 bits of which must appear before the function returns
% interval: time to wait between Cerebus queries
% maxwait:  time to return if myword does not appear
% mode:     'test' to read mat file, '' to wait for Cerebus

if nargin ~= 4
    help CBWait4Word
    return
end
switch mode
    case 'test'
        cyclenum = 1;
end

% Data words use this code:
CHAN = 151;
% Words from Cerebus are shifted left 16 bits
% Ignore the data specified in the lower 4 bits; for stimulus this is "g"
WordCode = bitshift(bitand(myword,double(hex2dec('F0'))),8);
et_col = tic;
Delay = toc(et_col); % elapsed time of collection
Status = 'Success';
%% MAIN LOOP
% Data Collection section
while (Delay < maxwait)
    if strcmp(mode, 'test')
        trialdata = cbmextest(cyclenum);
        cyclenum = cyclenum+1;
        %            bCollect=false;
    else
        trialdata = cbmex('trialdata',1); % read some data
    end
    %t_col0 = tic;   % restart timer for next collection period
    
    if numel(trialdata)==0 % no words in this raw batch
        continue
    end
    raw.ts=trialdata{CHAN,2};
    raw.codes=trialdata{CHAN,3};
    % Data words have some of their top 4 bits set.
    % Here are their indices in the raw buffer
    RawIndices = find(bitand(raw.codes, WordCode)==WordCode,1,'first');
    if RawIndices
        return
    end
    if interval
        pause(interval)
    end
    Delay = toc(et_col); % elapsed time of collection
end
Status = 'Timeout';
end


