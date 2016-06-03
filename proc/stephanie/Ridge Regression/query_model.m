function outputs = query_model(model, inputs)

% Query a linear model
%
% model = a trained linear model
%
% inputs = NxM matrix of input vectors.  Columns are samples.
%

if(size(inputs,1) ~= size(model.W,2))
  error('Model size does not match input size');
end;

outputs = model.W * inputs + model.process_mean*ones(1, size(inputs,2));
