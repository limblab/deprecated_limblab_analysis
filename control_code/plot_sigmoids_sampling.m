function plot_sigmoids_sampling(rcurve,vecGood)
opts.TOOLBOX_HOME=pwd;
addpath(genpath(opts.TOOLBOX_HOME));
tc_func_name = 'sigmoid';
S = rcurve.S;
for ii = 1:length(rcurve.S);
    figure(vecGood(ii)+10); subplot(2,1,1);
    % Pull out variables
    x1 = rcurve.x1(:,ii);
    y2 = rcurve.y2(ii).data;
    y = rcurve.y(:,ii);
    x = rcurve.x(:,ii);
    x0 = rcurve.amps(:,ii)';
    
    % Plot all curves from sampling
    h0 = plot(x1,y2,'Color',[0.8 0.1 0.1]);
    hold on;

    % Median
    y1 = getTCval(x1,tc_func_name,[S(ii).P1_median S(ii).P2_median S(ii).P3_median S(ii).P4_median]);
    h1 = plot(x1,y1,'k','linewidth',1);
    
    % Data
    h2 = plot(x+randn(size(y))*mean(diff(x0))/20,y,'.');
%     h3 = plot(x0,rcurve.magForce(:,k),'r.');
    
%     % Experimental fit used
%     y3 = getTCval(x1, tc_func_name,params);
%     h4 = plot(x1,y3,'m','linewidth',2);
    xlabel('Direction')
    ylabel('Response')
%     legend([h2; h3; h0(1); h1; h4],{'Samples','Mean','Sample fits','Median fit','Exp Fit'},'Location','NorthWest')
    title(['Experimental data from recruitment curve of muscle ',num2str(ii)])
    legend([h2; h0(1); h1],{'Samples','Sample fits','Median fit'},'Location','NorthWest')
    xlabel('amplitude of stimulus')
    ylabel('force magnitude')
    axis tight
end