% ConcatenateTargetHolds
% Concatenate the EMG data only for target holds. Also have to concatenate
% the spike rate data.

% Use binnedData file because this has all your trialtable information in
% it
trialtable = binnedData.trialtable;
for i=1:length(trialtable)
    find 