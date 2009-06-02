function result = bootstrap(f, data, n, reps)
% BOOTSTRAP - runs a function on a center-out data set multiple times
%
%   RESULT = BOOTSTRAP(@F, DATA, N, REPS)
%       Returns a list of results from running the analysis function F on
%       the dataset supplied in DATA.  BOOTSTRAP creates a virtual data set
%       containing N randomly chosen reaches to each target, and is
%       repeated REPS times.
%
%   RESULT = BOOTSTRAP(@F, DATA, 'all', REPS) {{ NOT IMPLEMENTED }}
%       To use the number of reaches actually present in the data set pass
%       the string 'all' for parameter N.

ntargets = length(data);

%all_data_result = f(data);
%result = zeros(reps,length(all_data_result));
%result = zeros(reps,1);
result = [];

for i = 1:reps
    % Generate test set and run analysis for each repititon

    % Build test set
    test_set = cell(1,ntargets);
    for targ = 1:ntargets
        test_set{targ} = zeros(1,n);
        for trial = 1:n
            % for each trial pick a trial from the dataset to use
            idx = 1 + floor(length(data{targ})*rand(1));
            test_set{targ}(trial) = data{targ}(idx);
        end
    end
    
    %result(i,:) = f(test_set);
    result = [result; f(test_set)];  %#ok<AGROW>
end

