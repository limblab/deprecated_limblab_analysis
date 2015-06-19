%% make heatmap histogram
VAF_dat = [VAF_unc;VAF_con]';
VAF_hist = hist3(VAF_dat,[20 20]);
VAF_hist(21,21) = 0;

xb = linspace(min(VAF_unc),max(VAF_unc),21);
yb = linspace(min(VAF_con),max(VAF_con),21);
h = pcolor(xb,yb,VAF_hist');

xlabel 'Unconstrained R^2'
ylabel 'Constrained R^2'