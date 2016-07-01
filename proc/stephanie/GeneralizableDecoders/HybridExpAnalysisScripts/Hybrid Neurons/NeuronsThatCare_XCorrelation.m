function NeuronsThatCare_XCorrelation(binnedData,plotTitle)
% This script takes cross-correlations between the firing rate of every
% neuron and

% Cross-correlations for neurons to EMG
for Nind=1:length(binnedData.spikeratedata(1,:))
    for Mind = 1:length(binnedData.emgdatabin(1,:));
        [Correlation Lags] = xcorr(detrend(binnedData.spikeratedata(:,Nind)),detrend(binnedData.emgdatabin(:,Mind)),'coeff');
        %figure;plot(Lags, Correlation);
        % Each lag represents 50ms
        zeroInd = find(Lags==0);
      %  figure;plot(Lags(zeroInd-40:1:zeroInd+40),Correlation(zeroInd-40:1:zeroInd+40));
       % hold on; plot([-10;-10], [-.2; .2]);
        PeakLocation_EMG(Mind,1)=11-find(Correlation(zeroInd-10:1:zeroInd)==max(Correlation(zeroInd-10:1:zeroInd)));
        Peak_EMG(Mind,1) = max(Correlation(zeroInd-10:1:zeroInd));
        if PeakLocation_EMG(Mind,1)==0 || PeakLocation_EMG(Mind,1)==10 || PeakLocation_EMG(Mind,1)==11
            Data=Correlation(zeroInd-10:1:zeroInd); DataInv=max(Data)-Data;
            [DataInvValue DataInvLocation] = max(DataInv);
            Peak_EMG(Mind,1)=abs(Data(DataInvLocation));
            PeakLocation_EMG(Mind,1)=11-DataInvLocation;
            if PeakLocation_EMG(Mind,1)==0 || PeakLocation_EMG(Mind,1)==10 || PeakLocation_EMG(Mind,1)==11
            Peak_EMG(Mind,1)=NaN; PeakLocation_EMG(Mind,1)=NaN;
            end
        end
       Correlation=[];Lags=[]; DataInvValue = []; DataInvLocation=[];
    end
    MaxPeak_EMG(Nind,1)=max(Peak_EMG);
%     if isempty(find(Peak_EMG==max(Peak_EMG)))
%         MaxPeakLocation_EMG(Nind,1)=NaN
%     else
%         MaxPeakLocation_EMG(Nind,1)=find(Peak_EMG==max(Peak_EMG));
%     end
    Peak_EMG=[];PeakLocation_EMG=[];
end
EMGnans = find(isnan(MaxPeak_EMG));

% Cross-correlations for neurons to velocity
for Nind=1:length(binnedData.spikeratedata(1,:))
        [Correlation Lags] = xcorr(detrend(binnedData.spikeratedata(:,Nind)),detrend(binnedData.velocbin(:,1)),'coeff');
        %figure;plot(Lags, Correlation);
        % Each lag represents 50ms
        zeroInd = find(Lags==0);
        %figure;plot(Lags(zeroInd-40:1:zeroInd+40),Correlation(zeroInd-40:1:zeroInd+40));
        %hold on; plot([-10;-10], [-.2; .2]);
        [Peak_Vel(Nind,1), PeakVelLocation(Nind,1)] = max(Correlation(zeroInd-10:1:zeroInd));
        PeakVelLocation(Nind,1)=11-PeakVelLocation(Nind,1); 
        if PeakVelLocation(Nind,1)==1 || PeakVelLocation(Nind,1)==11 || PeakVelLocation(Nind,1)==10
            Data=Correlation(zeroInd-10:1:zeroInd); DataInv=max(Data)-Data;
            [DataInvValue DataInvLocation] = max(DataInv);
            Peak_Vel(Nind,1)=abs(Data(DataInvLocation));
            PeakVelLocation(Nind,1)=11-DataInvLocation;
            if PeakVelLocation(Nind,1)==1 || PeakVelLocation(Nind,1)==11 || PeakVelLocation(Nind,1)==10
                Peak_Vel(Nind,1)=NaN; PeakVelLocation(Nind,1)=NaN;
            end
        end
        Correlation=[];Lags=[]; DataInvValue = []; DataInvLocation=[];
end
Velnans = find(isnan(Peak_Vel));

% Combine the Nans from both groups and get a list of all indices where at
% least one correlation result (either the EMG or the Vel) is a nan. Then
% remove these indices!
Allnans=unique(cat(1,EMGnans,Velnans));
MaxPeak_EMG(Allnans)=[];
Peak_Vel(Allnans)=[];

% figure;
% plot(MaxPeak_EMG,Peak_Vel,'.k','MarkerSize',15)
% xlabel('EMG neurons')
% ylabel('Velocity neurons')
% hold on; x=0:.1:1; y=x; plot(x,y)
% title('Peak xcorr')


% Find ranking
% NumofNans=length(find(isnan(Peak_Vel)));
% for a=1:length(MaxPeak_EMG)
%     if isnan(MaxPeak_EMG(a))
%         MaxPeak_EMG(a)=0;
%         MaxPeak_EMG(a)=0;
%     end
%     if MaxPeak_EMG(a)<0
%     end
% end
rankedEMG=tiedrank(MaxPeak_EMG)/length(MaxPeak_EMG);
rankedVel=tiedrank(Peak_Vel)/length(Peak_Vel);

 figure
 plot(rankedEMG,rankedVel,'.','MarkerSize',10)
hold on; x=0:.01:1; y=x; plot(x,y);
 xlabel('Ranked EMG neurons');ylabel('Ranked Velocity neurons')
 title(plotTitle)


% [sortedEMGNeurons sortedEMGIndex]=sort(MaxPeak_EMG,'ascend');
% % Label each neuron with its place in the distribution (percentile)
% for d=1:length(sortedEMGNeurons)
%     if isnan(MaxPeak_EMG(d))
%        WhereInTheRankNeuronIs_EMG(d,1) =  0; NeuronPercentile_EMG(d,1) =0;
%     else 
%     WhereInTheRankNeuronIs_EMG(d,1) =  find(MaxPeak_EMG(d)==sortedEMGNeurons);
%     NeuronPercentile_EMG(d,1) =  WhereInTheRankNeuronIs_EMG(d,1)/(length(sortedEMGIndex)/100);
%     end
% end

% Find ranking
% NumofNans=length(find(isnan(Peak_Vel)));
% for a=1:length(Peak_Vel)
%     if isnan(Peak_Vel(a))
%         Peak_Vel(a)=0;
%     end
%     if Peak_Vel(a)<0
%         Peak_Vel(a)=0;
%     end
% end
% rankedVel=tiedrank(Peak_Vel);
% [sortedVelNeurons sortedVelIndex]=sort(Peak_Vel,'ascend');
% % Label each neuron with its place in the distribution (percentile)
% for k=1:length(Peak_Vel)
%     if Peak_Vel(k)==-1;
%        WhereInTheRankNeuronIs_Vel(k,1)=0; NeuronPercentile_Vel(k,1)=0;
%     else
%       WhereInTheRankNeuronIs_Vel(k,1) =  find(Peak_Vel(k)==sortedVelNeurons);
%       NeuronPercentile_Vel(k,1) =  WhereInTheRankNeuronIs_Vel(k,1)/(length(sortedVelIndex)/100);
%     end
% end
% 
% figure
% plot(NeuronPercentile_EMG,NeuronPercentile_Vel,'.','MarkerSize',10)
% hold on; x=1:100; y=x; plot(x,y);
% xlabel('EMG neurons');ylabel('Velocity neurons')
% title(plotTitle)


end