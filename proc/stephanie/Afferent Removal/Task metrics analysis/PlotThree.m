



title('Horizontal Targets - Same Day')
subplot('Position',[.13 .13 .2 .7]) 
boxplot(theData,theGroup)
set(gca, 'Color', [1 0.81 0.9])
title('1')
subplot('Position',[.33 .13 .2 .7])
boxplot(theData,theGroup)
set(gca, 'YTick', [])
title('2')
subplot('Position',[.53 .13 .2 .7])
boxplot(theData,theGroup)
set(gca, 'YTick', [])
set(gca, 'Color', [1 0.81 0.9])
title('3')

