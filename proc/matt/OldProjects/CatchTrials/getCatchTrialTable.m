function trialTable = getCatchTrialTable(out_struct,BCTrial)
% Adds 11th column to trial table with a value of 0 for hand control, a
% value of 1 for a BCCatch trial, and the go cue column always has the word
% time instead of displaying -1 for CTs like wf_trial_table output
%
% Note: if the file is full continuous BC, set BCTrial true and it will
% set the 11th column to be value of 2 to separate the table from HC trial
% tables when data is being grouped together.

if nargin < 2
    BCTrial = false;
end

trialTable = wf_trial_table(out_struct);

% Catch trials have -1 in the go cue
% we still want to know the times of the Go Cue
word_CT = hex2dec('32'); %value of catch trial
words = out_struct.words;
ct_words = words(words(:,2) == word_CT, 1);

% Find the time of each catch word to signify the go cue time
ctInds = find(trialTable(:,7) == -1);
ct_times = zeros(size(ctInds));
for i = 1:ctInds
    ct_times(i) = ct_words(find(ct_words > trialTable(ctInds(i),1),1));
end

% Use 2 for BC file (if user specified) otherwise default to 0
if BCTrial
    ctVector = 2*ones(size(trialTable,1),1);
else
    ctVector = zeros(size(trialTable,1),1);
end

ctVector(ctInds) = 1;

trialTable(ctInds,7) = ct_times;
trialTable = [trialTable ctVector];


end