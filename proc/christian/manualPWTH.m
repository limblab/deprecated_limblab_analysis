
wordsVect= binnedData.words;
W = BD_Words;
wordToAve = W.Pickup;
timeBefore = -1 ;
timeAfter  =  1 ;

% Jaco
% FDSr FDSu FDPr FDPu ECR1 FCR2 ECRb FCU2 EDCu OP ECU2 EPL
%  1     2   3    4    5     6    7    8   9   10  11   12

% Theo
% FDSu FDSm FDPu FDPm FCR1  FCU  FPB  FDI ECR EDC 1/2IO ECU
%  1     2   3    4    5     6    7    8   9  10    11   12

EMGsToPlot = [1 3 5 9 10];

signals = [binnedData.timeframe binnedData.emgdatabin(:,EMGsToPlot)];
ActualAveEMGs = PWTH(signals,wordsVect,wordToAve,timeBefore,timeAfter);

signals = [PredData.timeframe preddatabin(:,EMGsToPlot)];
PredAveEMGs = PWTH(signals,wordsVect,wordToAve,timeBefore,timeAfter);
figure;
plot(ActualAveEMGs(:,1),ActualAveEMGs(:,2:end));
hold on;
plot(PredAveEMGs(:,1),PredAveEMGs(:,2:end));

legend(deblank(binnedData.emgguide(EMGsToPlot,:)));