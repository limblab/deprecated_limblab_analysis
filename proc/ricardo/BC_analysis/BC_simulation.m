
iter = 100000;
smooth_samples = 5000;
MinDelay = 1;
MaxDelay = 5;
MaxMove = 1.3;

StimTimes = rand(1,iter)*(MaxDelay-MinDelay)+MinDelay;
DelayTimes = rand(1,iter)*MaxDelay;
Aborts = DelayTimes < StimTimes;
Incompletes = (DelayTimes - StimTimes ) > MaxMove;
Rewards = ~Incompletes & ~Aborts;

[a,b] = sort(DelayTimes);
DelayTimes = DelayTimes(b);
Aborts = smooth(Aborts(b),smooth_samples)';
Incompletes = smooth(Incompletes(b),smooth_samples)';
Rewards = smooth(Rewards(b),smooth_samples)';

figure;
plot(DelayTimes,[Rewards;Incompletes;Aborts])