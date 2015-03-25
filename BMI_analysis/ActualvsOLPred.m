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
        if isfield(ActualData,'emgdatabin')
            if ~isempty(ActualData.emgdatabin)
                emg_i = strcmp(ActualData.emgguide,PredData.outnames(i));
                if any(emg_i)
                    ActSignalsTrunk(:,i) = ActualData.emgdatabin(idx,emg_i);
                    ActSignalsFull (:,i) = ActualData.emgdatabin(:,emg_i);
                end
            end
        end
        if isfield(ActualData,'forcedatabin')
            if ~isempty(ActualData.forcedatabin)
                force_i = strcmp(ActualData.forcelabels,PredData.outnames(i));
                if any(force_i)
                    ActSignalsTrunk(:,i) = ActualData.forcedatabin(idx,force_i);
                    ActSignalsFull (:,i) = ActualData.forcedatabin(:,force_i);
                end
            end
        end
        if isfield(ActualData,'cursorposbin')
            if ~isempty(ActualData.cursorposbin)
                curs_i = strcmp(ActualData.cursorposlabels,PredData.outnames(i));
                if any(curs_i)
                    ActSignalsTrunk(:,i) = ActualData.cursorposbin(idx,curs_i);
                    ActSignalsFull (:,i) = ActualData.cursorposbin(:,curs_i);
                end
            end
        end

        if isfield(ActualData,'velocbin')
            if ~isempty(ActualData.velocbin)
                vel_i = strcmp(ActualData.veloclabels,PredData.outnames(i));
                if any(vel_i)
                    ActSignalsTrunk(:,i) = ActualData.velocbin(idx,vel_i);
                    ActSignalsFull (:,i) = ActualData.velocbin(:,vel_i);
                end
            end
        end
    end
    
    R2 = CalculateR2(ActSignalsTrunk,PredData.preddatabin)';
%     vaf= 1- (var(PredData.preddatabin - ActSignalsTrunk) ./ var(ActSignalsTrunk) );
    vaf = 1 - sum( (PredData.preddatabin-ActSignalsTrunk).^2 ) ./ sum( (ActSignalsTrunk - repmat(mean(ActSignalsTrunk),size(ActSignalsTrunk,1),1)).^2 );
    mse= mean((PredData.preddatabin-ActSignalsTrunk) .^2);
    varargout = {R2, vaf, mse};

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
        fprintf('\t\tR2  \tvaf  \tmse\n');
        for i=1:numPredSignals
           fprintf('%s\t%1.3f\t%1.3f\t%.2f\n',PredData.outnames{i},R2(i),vaf(i),mse(i));
        end
        fprintf('Averages:\t%1.3f\t%1.3f\t%.2f\n',aveR2,avevaf,avemse);
    end
        
    if plotflag               
        for i = 1:numPredSignals
            %Plot both Actual and Predicted signals
            figure;
            plot(ActualData.timeframe,ActSignalsFull(:,i),'k');
            hold on;
            plot(PredData.timeframe,PredData.preddatabin(:,i),'r');
            title(PredData.outnames{i});
            legend('Actual',['Predicted (vaf= ' num2str(vaf(i),3) ')']);
        end
    end
end