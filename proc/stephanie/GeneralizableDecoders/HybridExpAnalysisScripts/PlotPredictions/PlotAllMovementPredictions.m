function PlotAllMovementPredictions(WmBinned,WmTest,WonWact,HonWpred,WonWpred,IonWpred,VAFstruct,save,foldername, filename)
% Run this after you run the main generalizability code

if nargin < 8
    save=0;
end


% Plot predictions of movement data----------------------------------------
%--------------------------------------------------------------------------
linewidth = 1.5;
x = (0:0.05:length(WonWact)*.05-0.05)';
for emgInd = 1:length(WmBinned.emgdatabin(1,:))
figure;hold on;
plot(x,WonWact(:,emgInd),'k','LineWidth', linewidth)
plot(x,WonWpred(:,emgInd),'b','LineWidth', linewidth)
plot(x,HonWpred(:,emgInd),'g','LineWidth', linewidth)
plot(x,IonWpred(:,emgInd),'r','LineWidth', linewidth)
xlim([30 50]);ylim([-.15 1]);
title(strcat(num2str(WmBinned.meta.datetime(1:9)), ':', WmBinned.emgguide(emgInd), ' Predictions | Movement data'))
muscleVAF.WonW = calculateVAF(WonWpred(:,emgInd),WonWact(:,emgInd));
muscleVAF.HonW = calculateVAF(HonWpred(:,emgInd),WonWact(:,emgInd));
muscleVAF.IonW = calculateVAF(IonWpred(:,emgInd),WonWact(:,emgInd));
legend('Actual',strcat('Within | vaf=',num2str(muscleVAF.WonW)),strcat('Hybrid | vaf=',num2str(muscleVAF.HonW)),strcat('Across | vaf=',num2str(muscleVAF.IonW)))
MillerFigure;

% Save figure
if save == 1
    SaveFigure(foldername, strcat(filename,'_',char(WmBinned.emgguide(emgInd))))
end

end
 
 % Plot target number

%  for i = 1:length(WmTest.trialtable)
%     Go_ts = WmTest.trialtable(i,7);
%     TgtNo = num2str(WmTest.trialtable(i,10));
%     TrialEnd_ts = WmTest.trialtable(i,8);
%     start(i)= find(abs(WmTest.timeframe-Go_ts) <= 0.05,1,'first'); %to convert to sec
%     stop(i) = find(abs(WmTest.timeframe-TrialEnd_ts) <= 0.05,1,'first'); %to convert to sec
%     patch([start(i)*.05 stop(i)*.05 stop(i)*.05 start(i)*.05],[0.4 0.4 40 40],'k','FaceAlpha',0.1,'EdgeAlpha',0);
%     text(((start(i)*.05)+(stop(i)*.05))/2, 10,TgtNo,'FontSize',20);
%  end
 
 
 end
 
 

 
 