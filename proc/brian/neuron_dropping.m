% $Id$

% Cycles through several iterations of predictions.m dropping neurons and
% measuring the resulting VAF 

primary_signal = 'pos';
secondary_signal = 'vel';

units = unit_list(bdf);
%units = [5 1; 7 1; 11 1; 11 2; 15 1];

max_dropped = size(units,1) - 2;

means = zeros(1,max_dropped+1);
vars = zeros(1,max_dropped+1);
alt_means = zeros(1,max_dropped+1);
alt_vars = zeros(1,max_dropped+1);
dropped_units = zeros(max_dropped,2);

for num_dropped_neurons = 1:max_dropped
    disp(sprintf('\n\nDropping %d Neurons\n------------------------', num_dropped_neurons));
    
    vafs = zeros(size(units,1),1);
    
    best_mean = -Inf;
    best_var = 0;
    dropped_row = -1;
    
    for iteration = 1:size(units,1)
        disp(sprintf('Iteration: %d', iteration));
        
        cur_units = units(1:size(units,1) ~= iteration, :);
        
        vafs = predictions(bdf, primary_signal, cur_units, 10);
        mean_vaf = mean(vafs(1:end-1,1));
        var_vaf = var(vafs(1:end-1,1));
        
        if mean_vaf > best_mean
            best_mean = mean_vaf;
            best_var = var_vaf;
            dropped_row = iteration;
            
            alt_vafs = predictions(bdf, secondary_signal, cur_units, 10);
            best_alt_mean = mean(alt_vafs(1:end-1,1));
            best_alt_var = var(alt_vafs(1:end-1,1));
        end
            
    end

    dropped_units(num_dropped_neurons, :) = units(dropped_row,:);
    units = units(1:size(units,1) ~= dropped_row, :);
    
    means(num_dropped_neurons + 1) = best_mean;
    vars(num_dropped_neurons + 1) = best_var;
    
    alt_means(num_dropped_neurons + 1) = best_alt_mean;
    alt_vars(num_dropped_neurons + 1) = best_alt_var;
    
    filename = sprintf('intermediate_%d.mat', num_dropped_neurons);
    save(filename, 'means', 'vars', 'alt_means', 'alt_vars');
end



