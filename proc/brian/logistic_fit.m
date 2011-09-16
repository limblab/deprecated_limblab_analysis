% logistic_fit.m

a = .2; b = .75; c = .3; d = 33;
logi = @(t) a+(b-a)./(1 + exp(c*(d-t)));

figure; hold on;

points = 10:10:60;
reps = 20;

% Structured points
pm = repmat(points,reps,1);
p = logi(pm);

tf = rand(size(p)) < p;
m = mean(tf);
v = var(tf);

curvefun = @(beta, x) beta(1)+(beta(2)-beta(1))./(1 + exp(beta(3)*(beta(4)-x)));
xa = lsqcurvefit(curvefun, [0 1 .1 30], points, m);

% Untructured points
pm = (max(points)-min(points))*rand(reps*length(points),1) + min(points);
p = logi(pm);

tf = rand(size(p)) < p;

L = @(x) -sum(log(tf.*curvefun(x,pm) + (1-tf).*(1-curvefun(x,pm))));
xb = fminsearch(L, [0 1 .1 30]);

plot(points, m, 'ko');
plot(1:.1:70, logi(1:.1:70), 'r-');
plot(1:.1:70, curvefun(xa,1:.1:70), 'k-');
plot(1:.1:70, curvefun(xb,1:.1:70), 'b-');
axis([0 70 0 1]);
