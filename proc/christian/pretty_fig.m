function pretty_fig(current_axes)

set(current_axes,'Box','Off',...
        'FontName','Arial','FontSize',16,'FontWeight','Bold',...
        'TickDir','Out','LineWidth',2);

% change line colors to the jet colormap
lines     = get(current_axes,'Children');
for i = 1:numel(lines)
    set(lines(i),'LineWidth',2);
 
end

legend('Fx','Fy');

xlabel('Training time')
title('Performance with Training Time');
% 
% % title('Learning Rate Optimization');
% % xlabel('Learning Rate');
% 
ylim([-0.2 0.7])
ylabel('VAF')
% 
% ylim([0 .7])
% ylabel('R^2')
