function [ Status words Delay ] = CBWait4Word( myword, interval, maxwait, mask, mode )
% CBWait4Word: Run a tight loop, returning when the required word appears at Cerebus
%
% Parameters:
%
% myword:   code, the upper 4 bits of which must appear before the function returns
% interval: time to wait between Cerebus queries
% maxwait:  time to return if myword does not appear
% mask:     use if looking for a particular group of bits, default is 0xFF
% mode:     'test' to read mat file, '' to wait for Cerebus
%
% Returns:
%
% Status:	Success/Fail/Timeout
% words:	Array of timestamps and words seen
% Delay:	Elapsed time of data collection
%
% Note that ONLY the last 'interval' of data following the first hit will be returned
Status = 'Fail';
words = [];
Delay = [];

if nargin < 3 || nargin > 5	
    help CBWait4Word
    return
end
if nargin == 3 || nargin == 4 ,mode='open';end
if nargin == 3 , mask = 'FF';end
switch mode
    case 'test'
        cyclenum = 1;
end

% Digital input is channel 151:
CHAN = 151;
% Words from Cerebus are shifted left 16 bits
% Ignore the data specified in the lower 4 bits; for stimulus this is "g"
try 
	myword = hex2dec(myword);
catch
	help CBWait4Word
	return
end

try 
	mask = hex2dec(mask);
	mask = bitshift(mask,8);
catch
	help CBWait4Word
	return
end

% myword = bitand(mask,myword);
WordCode = myword;
% WordCode = bitshift(bitand(myword,double(hex2dec('F0'))),8);
et_col = tic;
Delay = toc(et_col); % elapsed time of collection

words=-1;
%% MAIN LOOP
% Data Collection section
while (Delay < maxwait)
    if strcmp(mode, 'test')
        trialdata = cbmextest(cyclenum);
        cyclenum = cyclenum+1;
    else
        try
            trialdata = cbmex('trialdata',1); % read some data
        catch % maybe cbmex wasn't initialized yet
            CBInitWordRead(mode);
            trialdata = cbmex('trialdata',1); % read some data
        end
	end    
    
    if numel(trialdata)==0 % no words in this raw batch
        continue
    end
    raw.ts=trialdata{CHAN,2};
    raw.codes=trialdata{CHAN,3};
	% Find our masked word in raw data
	RawIndices = find(bitshift(bitand(raw.codes,mask),-8)==bitand(bitshift(mask,-8),WordCode));

    if RawIndices
		% Return timestamps and words
        words = [double(raw.ts(RawIndices))/30000 double(bitshift(bitand(raw.codes(RawIndices),hex2dec('FF00')),-8))];
		if size(words,1) > 1
			words = words(diff(words(:,1))>.0005,:);
		end
		Delay = toc(et_col); % elapsed time of collection
		Status = 'Success';
        return
    end
    if interval
        pause(interval)
	end    
end
Status = 'Timeout';
end


