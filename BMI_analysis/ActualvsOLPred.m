function ActualvsOLPred(ActualData, PredData, plotflag)

    numPredSignals = size(PredData.preddatabin,2);
    
    max_mintime = max(ActualData.timeframe(1),PredData.timeframe(1));
    min_maxtime = min(ActualData.timeframe(end),PredData.timeframe(end));
    
    start_Act  = find(ActualData.timeframe == max_mintime);
    finish_Act = find(ActualData.timeframe == min_maxtime);    

    start_Pred  = find(PredData.timeframe == max_mintime);
    finish_Pred = find(PredData.timeframe == min_maxtime);
    
    ActSignals = zeros(length(start_Act:finish_Act), numPredSignals);
    
    for i=1:numPredSignals
        if ~isempty(ActualData.emgdatabin)
            if all(strcmp(nonzeros(ActualData.emgguide(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignals(:,i:i+size(ActualData.emgdatabin,2)-1) = ActualData.emgdatabin(start_Act:finish_Act,:);
            end
        end
        if ~isempty(ActualData.forcedatabin)
            if all(strcmp(nonzeros(ActualData.forcelabels(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignals(:,i:i+size(ActualData.forcedatabin,2)-1) = ActualData.forcedatabin(start_Act:finish_Act,:);
            end
        end
        if ~isempty(ActualData.cursorposbin)
            if all(strcmp(nonzeros(ActualData.cursorposlabels(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignals(:,i:i+size(ActualData.cursorposbin,2)-1) = ActualData.cursorposbin(start_Act:finish_Act,:);
            end
        end    
    end
    
    R2 = CalculateR2(ActSignals,PredData.preddatabin(start_Pred:finish_Pred,:));
    
    %Display R2
    disp('R2 = ');

    for z=1:numPredSignals
        disp(sprintf('%s\t%1.4f',PredData.outnames(z,:),R2(z,1)));
    end
    aveR2 = mean(R2);
    disp(sprintf('Average:\t%1.4f',aveR2));
        
    if plotflag==1
               
        for i = 1:numPredSignals
            %Plot both Actual and Predicted signals
            figure;
            plot(ActualData.timeframe(start_Act:finish_Act),ActSignals(:,i),'k');
            hold on;
            plot(PredData.timeframe,PredData.preddatabin(:,i),'r');
            title(PredData.outnames(i,:));
            legend('Actual',['Predicted (R2= ' num2str(R2(i),3) ')']);
        end
    end
end