%% make heatmap histogram
VAF_dat = [VAF_unc;VAF_con]';
VAF_hist = hist3(VAF_dat,[20 20]);
VAF_hist(21,21) = 0;

xb = linspace(min(VAF_unc),max(VAF_unc),21);
yb = linspace(min(VAF_con),max(VAF_con),21);
figure
h = pcolor(xb,yb,VAF_hist');
colormap jet
colorbar

xlabel 'Elastic R^2'
ylabel 'Knee-fixed R^2'

%% make heatmap histogram for cartesian
VAF_dat = [VAF_cart_unc;VAF_cart_con]';
VAF_hist = hist3(VAF_dat,[20 20]);
VAF_hist(21,21) = 0;

xb = linspace(min(VAF_cart_unc),max(VAF_cart_unc),21);
yb = linspace(min(VAF_cart_con),max(VAF_cart_con),21);
figure
h = pcolor(xb,yb,VAF_hist');
colormap jet
colorbar

xlabel 'Elastic R^2'
ylabel 'Knee-fixed R^2'

%% make heatmap histogram for unconstrained
VAF_dat = [VAF_cart_unc;VAF_unc]';
VAF_hist = hist3(VAF_dat,[20 20]);
VAF_hist(21,21) = 0;

xb = linspace(min(VAF_cart_unc),max(VAF_cart_unc),21);
yb = linspace(min(VAF_unc),max(VAF_unc),21);
figure
h = pcolor(xb,yb,VAF_hist');
colormap jet
colorbar

xlabel 'Cartesian R^2'
ylabel 'Polar R^2'

%% make pvalue plots
subplot(411)
hist(log(p_polar_unc))
subplot(412)
hist(log(p_polar_con))
subplot(413)
hist(log(p_cart_unc))
subplot(414)
hist(log(p_cart_con))