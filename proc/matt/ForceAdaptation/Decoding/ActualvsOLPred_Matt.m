function varargout = ActualvsOLPred_Matt(ActualData, PredData, varargin)

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
        if isfield(ActualData,'emgdatabin')
            if ~isempty(ActualData.emgdatabin)
                if all(strcmp(nonzeros(ActualData.emgguide(1,:)),nonzeros(PredData.outnames(i,:))))
                    ActSignalsTrunk(:,i:i+size(ActualData.emgdatabin,2)-1) = ActualData.emgdatabin(idx,:);
                    ActSignalsFull (:,i:i+size(ActualData.emgdatabin,2)-1) = ActualData.emgdatabin;
                end
            end
        end
        if isfield(ActualData,'forcedatabin')
            if ~isempty(ActualData.forcedatabin)
                if all(strcmp(nonzeros(ActualData.forcelabels(1,:)),nonzeros(PredData.outnames(i,:))))
                    ActSignalsTrunk(:,i:i+size(ActualData.forcedatabin,2)-1) = ActualData.forcedatabin(idx,:);
                    ActSignalsFull (:,i:i+size(ActualData.forcedatabin,2)-1) = ActualData.forcedatabin;
                end
            end
        end
        if isfield(ActualData,'cursorposbin')
            if ~isempty(ActualData.cursorposbin)
                if all(strcmp(nonzeros(ActualData.cursorposlabels(1,:)),nonzeros(PredData.outnames(i,:))))
                    ActSignalsTrunk(:,i:i+size(ActualData.cursorposbin,2)-1) = ActualData.cursorposbin(idx,:);
                    ActSignalsFull (:,i:i+size(ActualData.cursorposbin,2)-1) = ActualData.cursorposbin;
                end
            end
        end

        if isfield(ActualData,'velocbin')
            if ~isempty(ActualData.velocbin)
                if all(strcmp(nonzeros(ActualData.veloclabels(1,:)),nonzeros(PredData.outnames(i,:))))
                    ActSignalsTrunk(:,i:i+size(ActualData.velocbin,2)-1) = ActualData.velocbin(idx,:);
                    ActSignalsFull (:,i:i+size(ActualData.velocbin,2)-1) = ActualData.velocbin;
                end
            end
        end
        
        if isfield(ActualData,'targetanglebin')
            if ~isempty(ActualData.targetanglebin)
                if all(strcmp(nonzeros(ActualData.targetanglelabels(1,:)),nonzeros(PredData.outnames(i,:))))
                    ActSignalsTrunk(:,i:i+size(ActualData.targetanglebin,2)-1) = ActualData.targetanglebin(idx,:);
                    ActSignalsFull (:,i:i+size(ActualData.targetanglebin,2)-1) = ActualData.targetanglebin;
                end
            end
        end
        
        if isfield(ActualData,'compvelocbin')
            if ~isempty(ActualData.compvelocbin)
                if all(strcmp(nonzeros(ActualData.compveloclabels(1,:)),nonzeros(PredData.outnames(i,:))))
                    ActSignalsTrunk(:,i:i+size(ActualData.compvelocbin,2)-1) = ActualData.compvelocbin(idx,:);
                    ActSignalsFull (:,i:i+size(ActualData.compvelocbin,2)-1) = ActualData.compvelocbin;
                end
            end
        end
        
        if isfield(ActualData,'movedirbin')
            if ~isempty(ActualData.movedirbin)
                if all(strcmp(nonzeros(ActualData.movedirbin(1,:)),nonzeros(PredData.outnames(i,:))))
                    ActSignalsTrunk(:,i:i+size(ActualData.movedirbin,2)-1) = ActualData.movedirbin(idx,:);
                    ActSignalsFull (:,i:i+size(ActualData.movedirbin,2)-1) = ActualData.movedirbin;
                end
            end
        end
    end
  
    R2 = CalculateR2(ActSignalsTrunk,PredData.preddatabin)';

%     vaf= 1- (var(PredData.preddatabin - ActSignalsTrunk) ./ var(ActSignalsTrunk) );
    vaf = 1 - sum( (PredData.preddatabin-ActSignalsTrunk).^2 ) ./ sum( (ActSignalsTrunk - repmat(mean(ActSignalsTrunk),size(ActSignalsTrunk,1),1)).^2 );
    mse= mean((PredData.preddatabin-ActSignalsTrunk) .^2);
    varargout = {R2, vaf, mse,ActSignalsTrunk};

    assignin('base','R2',R2);
    assignin('base','vaf',vaf);
    assignin('base','mse',mse);
    aveR2 = mean(R2);
    avevaf= mean(vaf);
    avemse= mean(mse);
%     assignin('base','aveR2',aveR2);
%     assignin('base','avevaf',avevaf);
%     assignin('base','avemse',avemse);
        
    %Display R2
    if dispflag
        disp(sprintf('\t\tR2  \tvaf  \tmse  '));
        for i=1:numPredSignals
           disp(sprintf('%s\t%1.3f\t%1.3f\t%.2f',PredData.outnames(i,:),R2(i),vaf(i),mse(i)));
        end
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