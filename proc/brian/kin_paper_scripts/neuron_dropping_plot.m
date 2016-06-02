% neuron_dropping_plot.m

clear all;
load mappings;

% t2
load rts_t2_run
m = mapping_t2;

means = means(2:end);
vars = vars(2:end);

[c, ia, ib] = intersect(dropped_units, m(:,[1 2]), 'rows');
tact = (m(ib,3) == 1);
prop = (m(ib,3) == 2);
idx = 1:length(ib);

figure; hold on;
errorbar(idx(tact), means(tact), sqrt(vars(tact)), 'k.');
errorbar(idx(prop), means(prop), sqrt(vars(prop)), 'r.');
title('t2');

last = find(means>.1,1,'last');
tact(last:end)=0;prop(last:end)=0;
[p,h,stats]=ranksum(idx(tact), idx(prop))

% p
load rts_p_run
m = mapping_p;

means = means(2:end);
vars = vars(2:end);

[c, ia, ib] = intersect(dropped_units, m(:,[1 2]), 'rows');
tact = (m(ib,3) == 1);
prop = (m(ib,3) == 2);
idx = 1:length(ib);

figure; hold on;
errorbar(idx(tact), means(tact), sqrt(vars(tact)), 'k.');
errorbar(idx(prop), means(prop), sqrt(vars(prop)), 'r.');
title('p');

last = find(means>.1,1,'last');
tact(last:end)=0;prop(last:end)=0;
[p,h,stats]=ranksum(idx(tact), idx(prop))
