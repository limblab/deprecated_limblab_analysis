%%plot cos hist
figure
hist(cosdthetay_rand,20)
xlabel 'cos(\DeltaPD)'
ylabel 'Number of Neurons'
title 'Cosine of Change in Preferred Direction'
axis([-1 1 0 50])
set(findobj(gca,'Type','patch'),'FaceColor','b')

%%
figure
hist(cosdthetay_trained,20)
xlabel 'cos(\DeltaPD)'
ylabel 'Number of Neurons'
title 'Cosine of Change in Preferred Direction'
axis([-1 1 0 50])
set(findobj(gca,'Type','patch'),'FaceColor','g')