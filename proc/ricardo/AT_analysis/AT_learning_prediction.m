num_repetitions = 100000;
percent_training = 0;
training_step = 0;
last_percent_training = zeros(num_repetitions,1);
reward_ratio = zeros(num_repetitions,1);
actual_rewards = 212;
actual_fails = 185;
num_trials = actual_rewards+actual_fails;

for iRep = 1:num_repetitions
    percent_training_history = zeros(num_trials,1);
    reward = zeros(num_trials,1);
    for i=1:num_trials
        percent_training = max(min(percent_training,100),0);
        percent_training_history(i) = percent_training;
        training_trial = percent_training > rand*100;
        if training_trial
            reward(i) = 1;
        else
            reward(i) = rand>0.5;
        end
        if reward(i)
            percent_training = percent_training-training_step;
        else
            percent_training = percent_training+3*training_step;
        end    
    end
    last_percent_training(iRep) = percent_training;
    reward_ratio(iRep) = sum(reward)/num_trials;
end

% mean(reward_ratio)
[hist_reward bins_reward] = hist(reward_ratio,100);
std_bounds = [mean(reward_ratio)-std(reward_ratio) mean(reward_ratio)+std(reward_ratio)];
cum_reward_ratio = cumsum(hist_reward)/length(reward_ratio);
figure(1)
clf
plot(bins_reward,cum_reward_ratio)
learned_ratio = bins_reward(find(cum_reward_ratio>.95,1,'first'));
actual_ratio = actual_rewards/num_trials;
hold on
plot([actual_ratio actual_ratio],[0 1],'-r')
p_learned = cum_reward_ratio(find(cum_reward_ratio>actual_ratio,1,'first'))
plot([std_bounds(1) std_bounds(1)],[0 1],'-b')
plot([std_bounds(2) std_bounds(2)],[0 1],'-b')
% std(reward_ratio)

