%PredictionScatterplotSummaryAcrossDays_mse_2

% mse within versus hybrid
% within = [meanIonI__PC_mse_0515 meanIonI__PC_mse_0519 meanIonI__PC_mse_0520  meanIonI__PC_mse_0521 meanIonI__PC_mse_0525 meanIonI__PC_mse_0604 meanIonI__PC_mse_0606];
% hybrid = [meanHonI__PC_mse_0515 meanHonI__PC_mse_0519 meanHonI__PC_mse_0520 meanHonI__PC_mse_0521 meanHonI__PC_mse_0525 meanHonI__PC_mse_0604 meanHonI__PC_mse_0606];
% withinError = [stdIonI__PC_mse_0515 stdIonI__PC_mse_0519 stdIonI__PC_mse_0520 stdIonI__PC_mse_0521 stdIonI__PC_mse_0525 stdIonI__PC_mse_0604 stdIonI__PC_mse_0606];
% hybridError = [stdHonI__PC_mse_0515 stdHonI__PC_mse_0519 stdHonI__PC_mse_0520 stdHonI__PC_mse_0521 stdHonI__PC_mse_0525 stdHonI__PC_mse_0604 stdHonI__PC_mse_0606];

within = [meanIonI_PC_mse meanIonI_PC_mse meanIonI_PC_mse meanIonI_PC_mse meanIonI_PC_mse];
hybrid = [meanHonI_PC_mse meanHonI_PC_mse meanHonI_PC_mse meanHonI_PC_mse meanHonI_PC_mse];
withinError = [stdIonI_PC_mse stdIonI_PC_mse stdIonI_PC_mse stdIonI_PC_mse stdIonI_PC_mse];
hybridError = [stdHonI_PC_mse stdHonI_PC_mse stdHonI_PC_mse stdHonI_PC_mse stdHonI_PC_mse];


figure;
errorbarxy(within,hybrid,withinError,hybridError,{'k.', 'k', 'k'})
x=[0 200];
y = [0 200];
hold on;
plot(x,y)
xlabel('Within')
ylabel('Hybrid')
title('Isometric predictions | mse')

% mse within versus hybrid
% across = [meanWonI__PC_mse_0515 meanWonI__PC_mse_0519 meanWonI__PC_mse_0520 meanWonI__PC_mse_0521 meanWonI__PC_mse_0525 meanWonI__PC_mse_0604 meanWonI__PC_mse_0606];
% hybrid = [meanHonI__PC_mse_0515 meanHonI__PC_mse_0519 meanHonI__PC_mse_0520 meanHonI__PC_mse_0521 meanHonI__PC_mse_0525 meanHonI__PC_mse_0604 meanHonI__PC_mse_0606];
% hybridError = [stdHonI__PC_mse_0515 stdHonI__PC_mse_0519 stdHonI__PC_mse_0520 stdHonI__PC_mse_0521 stdHonI__PC_mse_0525 stdHonI__PC_mse_0604 stdHonI__PC_mse_0606];
% acrossError = [stdWonI__PC_mse_0515 stdWonI__PC_mse_0519 stdWonI__PC_mse_0520 stdWonI__PC_mse_0521 stdWonI__PC_mse_0525 stdWonI__PC_mse_0604 stdWonI__PC_mse_0606];

across = [meanWonI_PC_mse_0515 meanWonI_PC_mse_0819 meanWonI_PC_mse_0820 meanWonI_PC_mse_0925 meanWonI_PC_mse_1011];
hybrid = [meanHonI_PC_mse_0515 meanHonI_PC_mse_0819 meanHonI_PC_mse_0820 meanHonI_PC_mse_0925 meanHonI_PC_mse_1011];
hybridError = [stdHonI_PC_mse_0515 stdHonI_PC_mse_0819 stdHonI_PC_mse_0820 stdHonI_PC_mse_0925 stdHonI_PC_mse_1011];
acrossError = [stdWonI_PC_mse_0515 stdWonI_PC_mse_0819 stdWonI_PC_mse_0820 stdWonI_PC_mse_0925 stdWonI_PC_mse_1011];


figure;
errorbarxy(across,hybrid,acrossError,hybridError,{'k.', 'k', 'k'})
%x=[0 300];
%y = [0 300];
hold on;
plot(x,y)
title('Isometric predictions | mse')
xlabel('Across')
ylabel('Hybrid')


%----

% within = [meanWonW_PC_mse_0515 meanWonW_PC_mse_0519 meanWonW_PC_mse_0520 meanWonW_PC_mse_0521 meanWonW_PC_mse_0525 meanWonW_PC_mse_0604 meanWonW_PC_mse_0606];
% hybrid = [meanHonW_PC_mse_0515 meanHonW_PC_mse_0519 meanHonW_PC_mse_0520 meanHonW_PC_mse_0521 meanHonW_PC_mse_0525 meanHonW_PC_mse_0604 meanHonW_PC_mse_0606];
% withinError = [stdWonW_PC_mse_0515 stdWonW_PC_mse_0519 stdWonW_PC_mse_0520 stdWonW_PC_mse_0521 stdWonW_PC_mse_0525 stdWonW_PC_mse_0604 stdWonW_PC_mse_0606];
% hybridError = [stdHonW_PC_mse_0515 stdHonW_PC_mse_0519 stdHonW_PC_mse_0520 stdHonW_PC_mse_0521 stdHonW_PC_mse_0525 stdHonW_PC_mse_0604 stdHonW_PC_mse_0606];

within = [meanWonW_PC_mse_0515 meanWonW_PC_mse_0819 meanWonW_PC_mse_0820 meanWonW_PC_mse_0925 meanWonW_PC_mse_1011];
hybrid = [meanHonW_PC_mse_0515 meanHonW_PC_mse_0819 meanHonW_PC_mse_0820 meanHonW_PC_mse_0925 meanHonW_PC_mse_1011];
withinError = [stdWonW_PC_mse_0515 stdWonW_PC_mse_0819 stdWonW_PC_mse_0820 stdWonW_PC_mse_0925 stdWonW_PC_mse_1011];
hybridError = [stdHonW_PC_mse_0515 stdHonW_PC_mse_0819 stdHonW_PC_mse_0820 stdHonW_PC_mse_0925 stdHonW_PC_mse_1011];


figure;
errorbarxy(within,hybrid,withinError,hybridError,{'k.', 'k', 'k'})
%x=[0 300];
%y = [0 300];
hold on;
plot(x,y)
xlabel('Within')
ylabel('Hybrid')
title('Movement predictions | mse')

% mse within versus hybrid
% across = [meanIonW_PC_mse_0515 meanIonW_PC_mse_0519 meanIonW_PC_mse_0520 meanIonW_PC_mse_0521 meanIonW_PC_mse_0525 meanIonW_PC_mse_0604 meanIonW_PC_mse_0606];
% hybrid = [meanHonW_PC_mse_0515 meanHonW_PC_mse_0519 meanHonW_PC_mse_0520  meanHonW_PC_mse_0521 meanHonW_PC_mse_0525 meanHonW_PC_mse_0604 meanHonW_PC_mse_0606];
% acrossError = [stdIonW_PC_mse_0515 stdIonW_PC_mse_0519 stdIonW_PC_mse_0520 stdIonW_PC_mse_0521 stdIonW_PC_mse_0525 stdIonW_PC_mse_0604 stdIonW_PC_mse_0606];
% hybridError = [stdHonW_PC_mse_0515 stdHonW_PC_mse_0519 stdHonW_PC_mse_0520 stdHonW_PC_mse_0521 stdHonW_PC_mse_0525 stdHonW_PC_mse_0604 stdHonW_PC_mse_0606];

across = [meanIonW_PC_mse_0515 meanIonW_PC_mse_0819 meanIonW_PC_mse_0820 meanIonW_PC_mse_0925 meanIonW_PC_mse_1011];
hybrid = [meanHonW_PC_mse_0515 meanHonW_PC_mse_0819 meanHonW_PC_mse_0820  meanHonW_PC_mse_0925 meanHonW_PC_mse_1011];
acrossError = [stdIonW_PC_mse_0515 stdIonW_PC_mse_0819 stdIonW_PC_mse_0820 stdIonW_PC_mse_0925 stdIonW_PC_mse_1011];
hybridError = [stdHonW_PC_mse_0515 stdHonW_PC_mse_0819 stdHonW_PC_mse_0820 stdHonW_PC_mse_0925 stdHonW_PC_mse_1011];



figure;
errorbarxy(across,hybrid,acrossError,hybridError,{'k.', 'k', 'k'})
% x=[0 300];
% y = [0 300];
hold on;
plot(x,y)
xlabel('Across')
ylabel('Hybrid')
title('Movement predictions | mse')