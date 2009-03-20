% $Id: $

% Cycles through several iterations of predictions.m dropping neurons and
% measuring the resulting VAF 

iterations = 4;
max_dropped = 1;

%units = unit_list(bdf);
units = [1 1;1 2; 1 3; 1 4];

means = zeros(1,max_dropped);

for num_dropped_neurons = 0:max_dropped
    disp(sprintf('\n\nDropping %d Neurons\n------------------------', num_dropped_neurons));
    
    total_vaf = 0;
    
    for iteration = 1:iterations
        disp(sprintf('Iteration: %d', iteration));
        
        % Generate random unit list with num_dropped_neurons removed
        kept_units = units;
        for i = 0:num_dropped_neurons-1
            drop_row = ceil(rand()*size(kept_units,1));
            kept_units = kept_units(1:size(kept_units,1) ~= drop_row, :);
        end
        
        
        
    end
end
