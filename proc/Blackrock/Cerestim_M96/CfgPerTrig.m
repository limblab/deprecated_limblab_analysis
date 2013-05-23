function CfgPerTrig(TRIGNUM, chList)
% CfgPerTrig: function to issue Cerestim stimulations selected by TRIGNUM
%
% TRIGNUM:  word from Cerebus
%           There are currently 9 different triggers
% chList    electrode channels to have stimuli applied
%           The number of channels actually used varies with the trigger
%
% NOTE: if this function is called in a loop, the times measured by "toc"
% subsequent to the first call will increase by hundreds of milliseconds,
% unless a "pause" is inserted, e.g:
% for i=1:8,CfgPerTrig(i,chList);pause(0.3),end
%
% The csmex commands mirror the function calls in the Blackrock Cerestim
% API.

global a
global idx
if ~nargin || numel(chList)<4
    help CfgPerTrig
    error('CfgPerTrig requires 4 electrode channels')
end

if TRIGNUM>8 || TRIGNUM < 0
    error('TRIGNUM out of range: should be 0-8')
end

if TRIGNUM ~= floor(TRIGNUM)
    error('TRIGNUM must be integral')
end
total=tic; % time this 
switch TRIGNUM
    case 0
        issueStim(1, chList);
    case 1
        issueStim(2, chList);
    case 2
        issueStim(3, chList);
    case 3
        issueStim(4, chList);
    case 4
        issueStim(4, chList);
    case 5
        issueStim(4, chList(1));
    case 6
        issueStim(4, chList(2));
    case 7
        issueStim(4, chList(3));
    case 8
        issueStim(4, chList(4));
end
csmex('play',1);
a(idx)=toc(total);
fprintf('TRIGNUM=%d, elapsed time=%.1f\n',TRIGNUM,1000*a(idx))
idx=idx+1;
end

% Function to send the requested stimulus configuration to Cerestim
function issueStim(configID, channels)

csmex('beginningOfSequence');
csmex('beginningOfGroup');
for i=1:numel(channels)
    if channels(i)==0
        break
    end
    as=tic;
    csmex('autoStimulus',channels(i),configID);
    fprintf('as=%d\n',toc(as))
end
csmex('endOfGroup');
csmex('endOfSequence');

end


