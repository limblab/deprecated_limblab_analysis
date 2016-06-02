% $Id$

% Cycles through several iterations of predictions.m dropping neurons and
% measuring the resulting VAF 

files = { ... 
    'parallel_dropping_helper.m'; ...
    '../../spike/'; ...
    '../../bdf'; ...
    '../../mimo'; ...
    '../..'; ...
    };

max_dropped = 67;
%max_dropped = 4;

units = unit_list(bdf);
%units = [2 1; 3 1; 3 2; 4 1; 5 1; 5 2];

means = zeros(1,max_dropped+1);
vars = zeros(1,max_dropped+1);
dropped_units = zeros(max_dropped,2);

jm = findResource('scheduler','type','jobmanager', 'Name','gobjm');

tic; 
for num_dropped_neurons = 1:max_dropped
    et = toc;
    disp(sprintf('\n\nDropping %d Neurons | ET: %d', num_dropped_neurons, et));
            
%     cur_units = cell(1,size(units,1));
%     cur_row = cell(1,size(units,1));
%     bdfs = cell(1,size(units,1));
%     for i = 1:size(units,1)
%         cur_units{i} = units;
%         cur_row{i} = i;
%         bdfs{i} = bdf;
%     end
%     
    %results = dfeval(@parallel_dropping_helper, bdfs, cur_units, cur_row, ...
    %    'FileDependencies', files );
    
    j = createJob(jm,'FileDependencies', files);
    %set(j, 'JobData', bdf);
    
    for i = 1:size(units,1)
        createTask(j, @parallel_dropping_helper, 1, {units, i});
    end
    
    submit(j);
    waitForState(j);
    results = getAllOutputArguments(j);
    destroy(j);
    
    r2 = cell2mat(results);
    dropped_row = find(r2(:,1) == min(r2(:,1)));
    
    dropped_units(num_dropped_neurons, :) = r2(dropped_row,[3 4]);
    units = units(1:size(units,1) ~= dropped_row, :);
    
    means(num_dropped_neurons + 1) = r2(dropped_row,1);
    vars(num_dropped_neurons + 1) = r2(dropped_row,2);
    
    %filename = sprintf('intermediate_%d.mat', num_dropped_neurons);
    %save(filename, 'means', 'vars');
end



