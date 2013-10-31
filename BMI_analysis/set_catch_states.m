function binnedData = set_catch_states(binnedData)
% this function adds a .state variable to the binnedData structure
% the first column of state is 1 during normal trials, and 0 during catch
% trials. The second column is its inverse.

catch_trial_times = [binnedData.trialtable(binnedData.trialtable(:,11)==1,1) ... 
                      binnedData.trialtable(binnedData.trialtable(:,11)==1,8)];

num_catch = size(catch_trial_times,1);
                  
binnedData.states = zeros(length(binnedData.timeframe),2);

for i = 1:num_catch
    catch_idx = find( binnedData.timeframe>=catch_trial_times(i,1) & ...
                      binnedData.timeframe<=catch_trial_times(i,2) );
    binnedData.states(catch_idx,2) = ones(length(catch_idx),1);
end

binnedData.states(:,1) = double(~binnedData.states(:,2));

% non_catch_idx = binnedData.states(:,2) == 0;
% 
% binnedData.states(non_catch_idx,1) = ones(
                  
