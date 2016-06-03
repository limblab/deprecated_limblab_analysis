



title('Horizontal Targets - Same Day - Unblocked')
subplot('Position',[.13 .13 .2 .7]) 
PlotIsoMetrics(IsoTaskMetrics1_unblocked_0830)
%set(gca, 'Color', [1 0.81 0.9])
title('1')
subplot('Position',[.33 .13 .2 .7])
PlotIsoMetrics(IsoTaskMetrics2_unblocked_0830)
%set(gca, 'Color', [1 0.81 0.9])
set(gca, 'YTick', [])
title('2')
subplot('Position',[.53 .13 .2 .7])
PlotIsoMetrics(IsoTaskMetrics3_unblocked_0830)
set(gca, 'YTick', [])
%set(gca, 'Color', [1 0.81 0.9])
title('3')

% Pink color  [1 0.81 0.9]
