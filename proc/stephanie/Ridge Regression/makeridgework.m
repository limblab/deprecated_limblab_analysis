        

        neuronIDs=spikeguide2neuronIDs(binnedData.spikeguide);
        desiredInputs=1:size(neuronIDs,1);
        
    inputs = binnedData.spikeratedata(:,desiredInputs);
    inputs = inputs';

    outputs = [];
    outNames = [];
    

        outputs = [outputs binnedData.cursorposbin]';
        outNames = [outNames;  binnedData.cursorposlabels]';
        condition_desired = 10^3;
       
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
model.W = (outputs*inputs')/(AAt);

Predoutputs = model.W * inputs + model.process_mean*ones(1, size(inputs,2));
