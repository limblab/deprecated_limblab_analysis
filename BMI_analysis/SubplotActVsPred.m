function SubplotActVsPred(ActualData, PredData, Signals)
% this function creates a figure with plots of the actual and predicted
% EMGs. ActualData is a binnedData structure, PredData is the corresponding OLPredData
% structure and Signals is a vector indicating the EMGs to plot. Refer to
% OLPredData.outnames or binnedData.emgguide for corresponding muscles
% indices.


% find time window were we have data for both actual and predicted signals
numSigs = length(Signals);
max_mintime = max(ActualData.timeframe(1),PredData.timeframe(1));
min_maxtime = min(ActualData.timeframe(end),PredData.timeframe(end));

start_Act  = find(ActualData.timeframe == max_mintime);
finish_Act = find(ActualData.timeframe == min_maxtime);    

start_Pred  = find(PredData.timeframe == max_mintime);
finish_Pred = find(PredData.timeframe == min_maxtime);


%Calculate R2 for all muscles
R2 = CalculateR2(ActualData.emgdatabin(start_Act:finish_Act,:),PredData.preddatabin(start_Pred:finish_Pred,:));
disp('R2 = ');
for i=1:numSigs
    disp(sprintf('%s\t%1.4f',PredData.outnames(Signals(i),:),R2(Signals(i),1)));
end
aveR2 = mean(R2(Signals));
disp(sprintf('Average:\t%1.4f',aveR2));

%plot actual vs predicted:
figure;
for i=1:numSigs
    subplot(numSigs,1,i);
    plot(ActualData.timeframe(start_Act:finish_Act),ActualData.emgdatabin(start_Act:finish_Act,Signals(i)),'k');
    hold on;
    plot(PredData.timeframe(start_Pred:finish_Pred),PredData.preddatabin(start_Pred:finish_Pred,Signals(i)),'r');
    ylabel(ActualData.emgguide(Signals(i),:));
    legend('Actual',['Predicted (R2= ' num2str(R2(Signals(i)),3) ')']);
end
