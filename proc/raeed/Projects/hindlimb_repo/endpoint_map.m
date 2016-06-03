%% optimize endpoint mapping
% start with random neuron start from foo2

% end_wt = zeros(size(neurons));
end_cost = zeros(length(neurons),1);

options = optimset('MaxFunEvals', 5000, 'MaxIter', 1000, 'Display', 'off', 'Algorithm', 'active-set');

for neuron_ct = 1:length(neurons)
    disp(neuron_ct)
%     start_wt = neurons(neuron_ct,:);
    start_wt = random('Normal',0,1,size(neurons,2),1);
    [end_wt(neuron_ct,:),end_cost(neuron_ct)] = fmincon(@(x) ep_costfunc(x,endpoint_positions,scaled_lengths_unc,scaled_lengths_con),start_wt,[],[],[],[],[],[],@(x) ep_constraint(x,endpoint_positions,scaled_lengths_unc,scaled_lengths_con), options);
end