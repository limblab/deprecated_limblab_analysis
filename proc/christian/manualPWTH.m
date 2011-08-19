
wordsVect= binnedData.words;
W = BD_Words;
wordToAve = W.Pickup;
timeBefore =  0.8 ;
timeAfter  =  3 ;

% Jaco
% FDSr FDSu FDPr FDPu ECR1 FCR2 ECRb FCU2 EDCu OP ECU2 EPL
%  1     2   3    4    5     6    7    8   9   10  11   12

% Theo
% FDSu FDSm FDPu FDPm FCR1  FCU  FPB  FDI ECR EDC 1/2IO ECU
%  1     2   3    4    5     6    7    8   9  10    11   12

EMGsToPlot = [2 3 5];

signals = [binnedData.timeframe binnedData.emgdatabin(:,EMGsToPlot)];
ActualAveEMGs = PWTH(signals,wordsVect,wordToAve,timeBefore,timeAfter);

signals = [OLPredData.timeframe OLPredData.preddatabin(:,EMGsToPlot)];
PredAveEMGs = PWTH(signals,wordsVect,wordToAve,timeBefore,timeAfter);
figure;
plot(ActualAveEMGs(:,1),ActualAveEMGs(:,2:end));
hold on;
plot(PredAveEMGs(:,1),PredAveEMGs(:,2:end),':');

legend(deblank(binnedData.emgguide(EMGsToPlot,:)));


%-----------------------------------------------------------------------


W = BD_Words;
timeBefore =  2 ;
timeAfter  =  2 ;
% EMGsToPlot = [2 4 5 8 9];
EMGsToPlot = [2 3 5];


EarlyAve = PWTH([OLPredDataEarly0211.timeframe OLPredDataEarly0211.preddatabin(:,EMGsToPlot)],...
                 binnedDataEarly0211.words, W.Pickup, timeBefore, timeAfter);
LateAve  = PWTH([OLPredDataLate0211.timeframe OLPredDataLate0211.preddatabin(:,EMGsToPlot)],...
                 binnedDataLate0211.words, W.Pickup, timeBefore, timeAfter);
             
figure;
plot(EarlyAve(:,1),EarlyAve(:,2:end),'Linewidth',2);
hold on;
plot(LateAve(:,1),LateAve(:,2:end),':','Linewidth',2);
legend(deblank(binnedDataEarly0211.emgguide(EMGsToPlot,:)));
Title('Predictions around pick up time \newline Jaco\_02-11-11 \newline - Early(\_006) -- Late(\_015)');
