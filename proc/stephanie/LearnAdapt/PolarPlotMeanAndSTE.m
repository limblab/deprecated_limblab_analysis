function PolarPlotMeanAndSTE(meanVals, plusSTE, minusSTE,color)
% This function plots mean values as well as STE for an 8 target task. You
% must input a 1x8 vector for each metric as well as the color you want the
% plot to be.


meanVals(9) = meanVals(1);
plusSTE(9) = plusSTE(1);
minusSTE(9) = minusSTE(1);
theta = 0:(2*pi)/8:2*pi;
%ste1=polar(theta,plusSTE,color);
ste1=polar(theta,plusSTE,'k*');
set( findobj(ste1, 'Type', 'line'),'MarkerSize',15);
hold on;
h=polar(theta,meanVals,strcat(color,'.-'));
hold on; %
set( findobj(h, 'Type', 'line'),'LineWidth',2,'MarkerSize',30);
%ste2=polar(theta,minusSTE,color);  
ste2=polar(theta,minusSTE,'k*');
set( findobj(ste2, 'Type', 'line'),'MarkerSize',15);