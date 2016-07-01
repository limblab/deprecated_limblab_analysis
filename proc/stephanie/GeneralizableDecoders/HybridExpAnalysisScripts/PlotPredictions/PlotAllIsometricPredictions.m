function PlotAllIsometricPredictions(IsoBinned,IsoTest,IonIact,HonIpred,IonIpred,WonIpred,VAFstruct,save,foldername, filename)
% Run this after you run the main generalizability code

if nargin < 8
    save=0;
end

for emgInd = 1:length(IsoBinned.emgdatabin(1,:))
%Make figures
% Make figure showing hybrid, across, within predictions
linewidth = 1.5;
x = (0:0.05:length(IonIact)*.05-0.05)';
% Plot predictions of isometric data---------------------------------------
%--------------------------------------------------------------------------
figure;hold on;
plot(x,IonIact(:,emgInd),'k','LineWidth', linewidth)
plot(x,IonIpred(:,emgInd),'b','LineWidth', linewidth)
plot(x,HonIpred(:,emgInd),'g','LineWidth', linewidth)
plot(x,WonIpred(:,emgInd),'r','LineWidth', linewidth)
xlabel('Time (sec)')
xlim([30 50]);ylim([-.15 1]);
title(strcat(num2str(IsoBinned.meta.datetime(1:9)), ':', IsoBinned.emgguide(emgInd), ' Predictions | Isometric data'))
muscleVAF.IonI = calculateVAF(IonIpred(:,emgInd),IonIact(:,emgInd));
muscleVAF.HonI = calculateVAF(HonIpred(:,emgInd),IonIact(:,emgInd));
muscleVAF.WonI = calculateVAF(WonIpred(:,emgInd),IonIact(:,emgInd));
legend('Actual',strcat('Within | vaf=',num2str(muscleVAF.IonI)),strcat('Hybrid | vaf=',num2str(muscleVAF.HonI)),strcat('Across | vaf=',num2str(muscleVAF.WonI)))
MillerFigure

% Save figure
if save == 1
    SaveFigure(foldername, strcat(filename,'_',char(IsoBinned.emgguide(emgInd))))
end
 
end



end