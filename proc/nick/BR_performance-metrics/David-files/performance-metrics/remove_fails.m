function successful_trials = remove_fails(words, START_TRIAL)
% INPUT: bdf.words; START_TRIAL (trial start code for given behavior)
% Takes 'bdf.words', removes all non-successful trials, returns condensed
% version of 'bdf.words'
% FUTURE: make this more robust to be able to handle 'words' tables even if
% the number of events per trial changes within a file (changed bhvr
% parameters during file)
%   Potential problems: maybe a bit slower (shouldn't be a big deal), and
%   dynamic memory allocation. Maybe, instead of dynamic allocation,
%   initially create cell array with each cell holding one trial, then
%   later move stuff back into normal array

REWARD = 32;

%-Initialize
rewards   = find(words(:,2) == REWARD);
rewards   = rewards(2:end); % make sure we get the first FULL successful trial

num_trials  = length(find(words(:,2) == START_TRIAL));
num_rewards = length(rewards);
disp(sprintf('Total number of trials: %i.',num_trials));
disp(sprintf('Number of successful trials: %i.',num_rewards));
trials_cell = cell(num_rewards,1);

%Parse successful trials
for trial = 1:num_rewards
    
    %Calculate next trial's indices
    FINISH = rewards(trial);
    START  = find(words(1:FINISH,2)==START_TRIAL, 1, 'last'); %only need start_idx closest to rwd_idx
    
    %Assign events/timestamps to cell for current trial
    trials_cell{trial} = words(START:FINISH,:);
    
end

% Count total number of events among all successful trials
num_events = cellfun(@length,trials_cell);
successful_trials = zeros(sum(num_events),2);

%Move event info from cell array to matrix
idx = 1;
for trial = 1:num_rewards
    
    successful_trials(idx:idx+num_events(trial)-1,:) = trials_cell{trial};
    idx = idx + num_events(trial);
    
end

