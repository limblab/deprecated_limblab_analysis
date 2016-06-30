S=[];
% Initialize staircase
S.trial_num=0;
S.value=1;
S.max_reversals=50;
S.init_stepsize=1;
S.min_stepsize=0.05;
S.terminated=0;
S.updown=[2 1];
S.resp=[];

% Update staircase...
while ~S.terminated
    fprintf('.')
    % Simulate responses from a logistic function
    S.resp(length(S.resp)+1) = (rand(1)>(1/(1+exp(4*S.value(end)))))*2-1;
    S=updateStaircase(S,1);
end

% Check result...
clf;plot(S.value,S.resp>0,'o')
hold on
b = glmfit(S.value',(S.resp>0)','binomial');
xl=xlim(); x0=linspace(xl(1),xl(2),256);
yhat = glmval(b,x0,'logit');
plot(x0,yhat)
yhat = glmval([0 4]',x0,'logit');
plot(x0,yhat,'r')
legend({'Data','Estimated','True'})
hold off

% For multiple staircases, use S(1),S(2)