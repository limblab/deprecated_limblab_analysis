function ActualvsRTPred(ActualBinnedEMGs, PredictedEMGs,plotflag)

    numEMGs = size(ActualBinnedEMGs.emgguide,1);

    if size(PredictedEMGs,1)~=size(ActualBinnedEMGs,1)
        %raw Predictions from NLMS, have to work on them a bit
        
        Pred_ts = PredictedEMGs(:,1);
        

        for i=1:length(Pred_ts)-1
            %check if unsorted timestamps
            if Pred_ts(i)>Pred_ts(i+1)
                disp('ts in predictions are not sequential, operation aborted');
                return;
            end
                
            %check if redundant timestamps
            if Pred_ts(i) == Pred_ts(i+1)
                %if so, remove 0.1 ms to the first occurence
                disp(sprintf('Redundant ts in Predicted EMGs at indexes %d and %d', i,i+1));
                disp(sprintf('ts at index %f changed to %f',Pred_ts(i),Pred_ts(i)-0.0001));
                Pred_ts(i) = Pred_ts(i)-0.0001;
            end
        end

        %check which file starts first (should always be the actual data)
        if min(Pred_ts)<min(ActualBinnedEMGs.timeframe)
            disp('The Prediction file was started first, operation aborted');
            return;
        else
            %find the first index in timeframe after the prediction started
            first_i = length(find(ActualBinnedEMGs.timeframe < min(Pred_ts)))+1;
            disp(sprintf('first time bin after prediction began : %f',ActualBinnedEMGs.timeframe(first_i)));
        end            
        
        %check which file ends first
        if max(Pred_ts)>max(ActualBinnedEMGs.timeframe)
            %Prediction file longer
            disp('Prediction file ended after actual data');
            last_i = length(ActualBinnedEMGs.timeframe);
            disp(sprintf('last time bin of actual data used : %f',ActualBinnedEMGs.timeframe(end)));
        else
            %actual data file longer
            disp('Actual data file longer than Prediction data');
            skip_ts_i = length(find(ActualBinnedEMGs.timeframe > max(Pred_ts)));
            last_i = length(ActualBinnedEMGs.timeframe)-skip_ts_i;            
            disp(sprintf('last time bin of actual data used : %f',ActualBinnedEMGs.timeframe(last_i)));
        end
    
        %interpolate the predictions to the binned timeframe
        for i=size(PredictedEMGs,2)-1:-1:1
            Pred_int(:,i) = interp1(Pred_ts,PredictedEMGs(:,i+1),ActualBinnedEMGs.timeframe(first_i:last_i),'spline');
        end
    else
        Pred_int = PredictedEMGs(:,2:end);
    end
    
    %Display R2
    disp('R2 = ');    
    R2 = zeros(numEMGs,1);
    for i = 1:numEMGs
        %Calculate R2
%        R=corrcoef(PredictedEMGs(:,i),ActualBinnedEMGs.emgdatabin(fillen:end,i));
        R=corrcoef(Pred_int(:,i),ActualBinnedEMGs.emgdatabin(first_i:last_i,i));
        R2(i)=R(1,2).^2;
        clear R
        disp(sprintf('%s\t%1.4f',ActualBinnedEMGs.emgguide(i,:),R2(i,1)));

        if plotflag
            %Plot both Actual and Predicted EMG signals
            figure;
            plot(ActualBinnedEMGs.timeframe(first_i:last_i),ActualBinnedEMGs.emgdatabin(first_i:last_i,i),'k');
            hold on;
    %        plot(ActualBinnedEMGs.timeframe(fillen:end),PredictedEMGs(:,i),'r');
            plot(ActualBinnedEMGs.timeframe(first_i:last_i),Pred_int(:,i),'r');
            title(ActualBinnedEMGs.emgguide(i,:));
            legend('Actual',['Predicted (R2= ' num2str(R2(i),3) ')']);
        end
    end

    aveR2 = mean(R2);
    disp(sprintf('Average:\t%1.4f',aveR2));
    
end