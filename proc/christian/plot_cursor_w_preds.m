interval = 120; %2mins
mintime = OLPredData.timeframe(1);
numwind = floor((OLPredData.timeframe(end)-mintime)/interval);

time = [mintime round(mintime+interval):interval:mintime+interval*numwind];

for t=1:length(time)-1

start =time(t);
stop  =time(t+1);

startAct = find(binnedData.timeframe==start);
stopAct  = find(binnedData.timeframe==stop);

startPred = find(OLPredData.timeframe==start);
stopPred  = find(OLPredData.timeframe==stop);

if any([isempty(startAct) isempty(stopAct) isempty(startPred) isempty(stopPred)])
    error('Invalid Time Range');
end

R2=CalculateR2(binnedData.cursorposbin(startAct:stopAct,:), OLPredData.preddatabin(startPred:stopPred,:));
disp(sprintf('%g to %g\n %1.4f\n%1.4f\n', time(t),time(t+1),R2));

    if t ==1 || t==length(time)-1
        for i = 1:2
        figure;
        plot(binnedData.timeframe(startAct:stopAct), binnedData.cursorposbin(startAct:stopAct,i),'k');
        hold on;
        plot(OLPredData.timeframe(startPred:stopPred), OLPredData.preddatabin(startPred:stopPred,i),'r');
        title(OLPredData.outnames(i,:));
        legend('Actual', sprintf('Predicted (R2=%1.3f)', R2(i)));
        end
    end
end

% %% -------Plot----------
% start = time(end-1);
% stop  = time(end);
% 
% startAct = find(binnedData.timeframe==start);
% stopAct  = find(binnedData.timeframe==stop);
% 
% startPred = find(OLPredData.timeframe==start);
% stopPred  = find(OLPredData.timeframe==stop);
% 
% for i = 1:2
%     figure;
%     plot(binnedData.timeframe(startAct:stopAct), binnedData.cursorposbin(startAct:stopAct,i),'k');
%     hold on;
%     plot(OLPredData.timeframe(startPred:stopPred), OLPredData.preddatabin(startPred:stopPred,i),'r');
%     title(OLPredData.outnames(i,:));
%     legend('Actual', sprintf('Predicted (R2=%1.3f)', R2(i)));
% end
