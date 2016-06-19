function [handle] = plot_tuning(modeled_tuning,curve,max_FR,fig_name)
% PLOT_TUNING makes a single figure showing the tuning curve and PD with
% confidence intervals. Leave either entry blank to skip plotting it.

% set up figure
handle = figure('name',fig_name);

% plot initial point
h=polar(0,max_FR);
set(h,'color','w')
hold all

% tuning curve
if(~isempty(curve))
    h=polar(repmat(curve.bins,2,1),repmat(curve.FR,2,1));
    set(h,'linewidth',2,'color',[1 0 0])
    th_fill = [flipud(curve.bins); curve.bins(end); curve.bins(end); curve.bins];
    r_fill = [flipud(curve.CI_high); curve.CI_high; curve.CI_low; curve.CI_low];
    [x_fill,y_fill] = pol2cart(th_fill,r_fill);
    patch(x_fill,y_fill,[1 0 0],'facealpha',0.3,'edgealpha',0);
end

% PD
if(~isempty(modeled_tuning))
    h=polar(modeled_tuning.dir,max_FR*[0;1]);
    set(h,'linewidth',2,'color',[1 0 0])
    th_fill = [modeled_tuning.dir_CI(2) modeled_tuning.dir modeled_tuning.dir_CI(1) 0];
    r_fill = [max_FR max_FR max_FR 0];
    [x_fill,y_fill] = pol2cart(th_fill,r_fill);
    patch(x_fill,y_fill,[1 0 0],'facealpha',0.3);
end