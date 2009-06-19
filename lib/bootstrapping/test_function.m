function result = test_function(data)
% A test function.  Displays data and returns a normally distributed random
% number

dispdata = zeros(length(data), length(data{1}));
for i = 1:length(data)
    disp(data{i});
end

result = randn(1);
