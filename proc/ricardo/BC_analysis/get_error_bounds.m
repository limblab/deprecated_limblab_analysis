function error_bars = get_error_bounds(result1,result2,boot_iter,conf)

% Bootstrapping
size_result1 = size(result1);
result1 = reshape(result1,1,[]);

size_result2 = size(result2);
result2 = reshape(result2,1,[]);

temp = result1+result2;
sample_length = min(temp(temp>0));
reward_bootstrapped = zeros(length(result1),sample_length,boot_iter);
for i=1:length(result1)
    reward_temp = [ones(result1(i),1);zeros(result2(i),1)];
    if ~isempty(reward_temp)
        reward_temp = reward_temp(ceil(length(reward_temp)*rand(length(reward_temp),boot_iter)));
        reward_temp = reward_temp(1:sample_length,:);
        reward_bootstrapped(i,:,:) = reward_temp;
    end
end
reward_bootstrapped = squeeze(mean(reward_bootstrapped,2));

hist_centers = 0:.001:1;
hist_rewards = zeros(length(result1),length(hist_centers));
for i = 1:length(result1)
    hist_rewards(i,:) = hist(reward_bootstrapped(i,:),hist_centers);
end
cum_hist_rewards = cumsum(hist_rewards,2);
error_bars = zeros(length(result1),2);
for i = 1:length(result1)
    error_bars_temp = hist_centers(find(cum_hist_rewards(i,:)<max(cum_hist_rewards(i,:))*conf/2,1,'last'));
    if isempty(error_bars_temp)
        error_bars_temp = 0;
    end
    error_bars(i,1) = error_bars_temp;
    error_bars_temp = hist_centers(find(cum_hist_rewards(i,:)>max(cum_hist_rewards(i,:))*(1-conf/2),1,'first'));
    if isempty(error_bars_temp)
        error_bars_temp = 1;
    end
    error_bars(i,2) = error_bars_temp;
end
error_bars = reshape(error_bars,[size_result1 2]);
