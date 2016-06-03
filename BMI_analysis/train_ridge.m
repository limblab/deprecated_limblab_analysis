function H = train_ridge(inputs, outputs, condition_desired)

% Train a linear model using ridge regression
%
% inputs = NxM matrix of input vectors.  Columns are samples.
%
% outputs = KxM matrix of output vectors.  Columns are samples.
%
% condition_desired = maximum allowed condition number for the inner product
%   matrix (smaller values -> more conditioning).  
%   
%   For ~1K features & ~2-20K samples, condition_desired of values 
%    10^3 - 10^4  are good
%
% Returns model = a linear model
%

%% SR-PINV algorithm
model.process_mean = mean(outputs,2);

% subtract the mean from output
outputs = outputs - model.process_mean*ones(1,size(outputs,2));

% Inner product matrix
AAt = inputs * inputs';                   

% calculate condition number inner product matrix
d=eig(AAt);
eig_min=min(d);
eig_max=max(d);
model.condition_old=abs(eig_max/eig_min);

% condition_desired is the upper bound on the true condition number
if(model.condition_old > condition_desired)
  model.alpha = (eig_max - eig_min * condition_desired)/(condition_desired-1);
else
  model.alpha = 0;
end;

model.condition_desired = condition_desired;

% Condition the inner product matrix
AAt = AAt+model.alpha*eye(size(AAt));

% calculate new eigen ratio
d=eig(AAt);
eig_min=min(d);
eig_max=max(d);
model.condition_new=abs(eig_max/eig_min);



%solve for weights
H = ((outputs*inputs')/(AAt))';

