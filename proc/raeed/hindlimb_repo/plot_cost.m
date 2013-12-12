%% plot cost function with respect to one weight
test_wt = linspace(-2,2,1000)';
weights = repmat(neurons(1,:),length(test_wt),1);
weights(:,1) = test_wt;

cost = zeros(length(test_wt),1);

for i = 1:length(test_wt)
    cost(i) = ep_costfunc(weights(i,:),endpoint_positions,scaled_lengths_unc,scaled_lengths_con);
end

figure
plot(test_wt,cost)