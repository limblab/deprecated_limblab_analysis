function ActualvsOLPred(EMGData, PredData, plotflag)

    numEMGs = size(EMGData.emgguide,1);

    max_mintime = max(EMGData.timeframe(1),PredData.timeframe(1));
    min_maxtime = min(EMGData.timeframe(end),PredData.timeframe(end));
    
    start_EMG  = find(EMGData.timeframe == max_mintime);
    finish_EMG = find(EMGData.timeframe == min_maxtime);    

    start_Pred  = find(PredData.timeframe == max_mintime);
    finish_Pred = find(PredData.timeframe == min_maxtime);
    
    R2 = CalculateR2(EMGData.emgdatabin(start_EMG:finish_EMG,:),PredData.predemgbin(start_Pred:finish_Pred,:));
    
    %Display R2
    disp('R2 = ');

    for z=1:numEMGs
        disp(sprintf('%s\t%1.4f',EMGData.emgguide(z,:),R2(z,1)));
    end
    aveR2 = mean(R2);
    disp(sprintf('Average:\t%1.4f',aveR2));
        
    if plotflag==1
               
        for i = 1:numEMGs
            %Plot both Actual and Predicted EMG signals
            figure;
            plot(EMGData.timeframe,EMGData.emgdatabin(:,i),'k');
            hold on;
    %        plot(ActualBinnedEMGs.timeframe(fillen:end),PredictedEMGs(:,i),'r');
            plot(PredData.timeframe,PredData.predemgbin(:,i),'r');
            title(EMGData.emgguide(i,:));
            legend('Actual',['Predicted (R2= ' num2str(R2(i),3) ')']);
        end
    end
end