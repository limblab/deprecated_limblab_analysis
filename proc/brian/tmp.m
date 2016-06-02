% tmp.m

th = 0:.1:2*pi;
tgt = 0:pi/4:7*pi/4;

weights = [0 .1 .2 .5 .8 .9 1];
m = 30; a = 10; pd = pi/2;
num_trials = 5;
t = .25;

for i=1:length(weights)
    w = weights(i);
    f = @(th) w*cos(th-pd) + (1-w)*cos(2*(th-pd));
    lambda = @(th) m+a*f(th);
    
    s = random('Poisson', repmat(lambda(tgt),num_trials,1)*t, num_trials, 8);
    
    figure; 
    subplot(2,1,1); hold on;
    plot(th, lambda(th), 'k-');
    plot(tgt, mean(s)/t, 'ko');
    axis([-.1 2*pi+.1 0 50]);
    
    data = cell(1,8);
    for d = 1:8
        data{d} = s(:,d)';
    end
    
    res = bootstrap(@vector_sum_pd, data, 'all', 1000);
    q = hist(mod(res(:,1),2*pi), th);
    subplot(2,1,2), bar(th, q);
    axis([-.1 2*pi+.1 0 200]);
    suptitle(sprintf('w = %f', w));
end







