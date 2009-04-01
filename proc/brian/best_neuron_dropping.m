% $Id$

% Cycles through several iterations of predictions.m dropping neurons and
% measuring the resulting VAF 

max_dropped = 40;
%max_dropped = 2;

units = unit_list(bdf);
%units = [1 1; 1 2; 2 1; 4 1];

means = zeros(1,max_dropped+1);
vars = zeros(1,max_dropped+1);
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
        
        vafs = predictions(bdf, 'pos', cur_units, 10);
        mean_vaf = mean(vafs(1:end-1,1));
        var_vaf = var(vafs(1:end-1,1));
        
        if mean_vaf > best_mean
            best_mean = mean_vaf;
            best_var = var_vaf;
            dropped_row = iteration;
        end
            
    end

    dropped_units(num_dropped_neurons, :) = units(dropped_row,:);
    units = units(1:size(units,1) ~= dropped_row, :);
    
    means(num_dropped_neurons + 1) = best_mean;
    vars(num_dropped_neurons + 1) = best_var;
    
    filename = sprintf('intermediate_%d.mat', num_dropped_neurons);
    save(filename, 'means', 'vars');
end



