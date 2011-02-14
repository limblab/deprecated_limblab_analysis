function varargout = ActualvsOLPred(ActualData, PredData, varargin)

    if nargin >2
        plotflag = varargin{1};
        dispflag = 0;
        if nargin>3
            dispflag = varargin{2};
        end
    else
        plotflag = 0;
        dispflag = 0;
    end

    numPredSignals = size(PredData.preddatabin,2);
    
    %match data with timeframes
    idx = false(size(ActualData.timeframe));
    for i = 1:length(PredData.timeframe)
        idx = idx | ActualData.timeframe == PredData.timeframe(i);
    end   
    
    ActSignalsTrunk = zeros(length(nonzeros(idx))       ,numPredSignals);
    ActSignalsFull  = zeros(length(ActualData.timeframe),numPredSignals);
    
    for i=1:numPredSignals
        if ~isempty(ActualData.emgdatabin)
            if all(strcmp(nonzeros(ActualData.emgguide(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignalsTrunk(:,i:i+size(ActualData.emgdatabin,2)-1) = ActualData.emgdatabin(idx,:);
                ActSignalsFull (:,i:i+size(ActualData.emgdatabin,2)-1) = ActualData.emgdatabin;
            end
        end
        if ~isempty(ActualData.forcedatabin)
            if all(strcmp(nonzeros(ActualData.forcelabels(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignalsTrunk(:,i:i+size(ActualData.forcedatabin,2)-1) = ActualData.forcedatabin(idx,:);
                ActSignalsFull (:,i:i+size(ActualData.forcedatabin,2)-1) = ActualData.forcedatabin;
            end
        end
        if ~isempty(ActualData.cursorposbin)
            if all(strcmp(nonzeros(ActualData.cursorposlabels(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignalsTrunk(:,i:i+size(ActualData.cursorposbin,2)-1) = ActualData.cursorposbin(idx,:);
                ActSignalsFull (:,i:i+size(ActualData.cursorposbin,2)-1) = ActualData.cursorposbin;
            end
        end    
        if ~isempty(ActualData.velocbin)
            if all(strcmp(nonzeros(ActualData.veloclabels(1,:)),nonzeros(PredData.outnames(i,:))))
                ActSignalsTrunk(:,i:i+size(ActualData.velocbin,2)-1) = ActualData.velocbin(idx,:);
                ActSignalsFull (:,i:i+size(ActualData.velocbin,2)-1) = ActualData.velocbin;
            end
        end          
    end
    
    R2 = CalculateR2(ActSignalsTrunk,PredData.preddatabin);
    vaf= 1- (var(PredData.preddatabin - ActSignalsTrunk) ./ var(ActSignalsTrunk) );
    mse= mean((PredData.preddatabin-ActSignalsTrunk) .^2);
    varargout = {R2, vaf, mse};

    %Display R2
    if dispflag
        disp('R2\tvaf\tmse');
        for i=1:numPredSignals
           disp(sprintf('%s\t%1.3f\t%1.3f\t%.2f',PredData.outnames(i,:),R2(i),vaf(i),mse(i)));
        end
        aveR2 = mean(R2);
        avevaf= mean(vaf);
        avemse= mean(mse);
        disp(sprintf('Averages:\t%1.3f\t%1.3f\t%.2f',aveR2,avevaf,avemse));
    end
        
    if plotflag               
        for i = 1:numPredSignals
            %Plot both Actual and Predicted signals
            figure;
            plot(ActualData.timeframe,ActSignalsFull(:,i),'k');
            hold on;
            plot(PredData.timeframe,PredData.preddatabin(:,i),'r');
            title(PredData.outnames(i,:));
            legend('Actual',['Predicted (vaf= ' num2str(vaf(i),3) ')']);
        end
    end
end