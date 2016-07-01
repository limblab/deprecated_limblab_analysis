function NeuronsThatCare_XCorrelation_Stats(binnedData,plotTitle)
% This script takes cross-correlations between the firing rate of every
% neuron and

% Cross-correlations for neurons to EMG
for Nind=1:length(binnedData.spikeratedata(1,:))
    for Mind = 1:length(binnedData.emgdatabin(1,:));
        [Correlation Lags] = xcorr(detrend(binnedData.spikeratedata(:,Nind)),detrend(binnedData.emgdatabin(:,Mind)),'coeff');
        %figure;plot(Lags, Correlation);
        % Each lag represents 50ms
        zeroInd = find(Lags==0);
        %figure;plot(Lags(zeroInd-40:1:zeroInd+40),Correlation(zeroInd-40:1:zeroInd+40));
       % hold on; plot([-10;-10], [-.2; .2]);
       AbsSnippet = abs(Correlation(zeroInd-10:1:zeroInd+10));
       [Peak_EMG(Mind,1) PeakLocation_EMG(Mind,1)]=max(AbsSnippet);
       PeakLocation_EMG(Mind,1)=PeakLocation_EMG(Mind,1)-11; %negative values should mean positive lag 'tween spike&EMG
%         PeakLocation_EMG(Mind,1)=11-find(Correlation(zeroInd-10:1:zeroInd+10)==max(Correlation(zeroInd-10:1:zeroInd+10)));
%         Peak_EMG(Mind,1) = max(Correlation(zeroInd-10:1:zeroInd+10));
%         if PeakLocation_EMG(Mind,1)==-10 || PeakLocation_EMG(Mind,1)==10 || PeakLocation_EMG(Mind,1)==11
%             Peak_EMG(Mind,1)=NaN; PeakLocation_EMG(Mind,1)=NaN;
%         end
       Correlation=[];Lags=[]; DataInvValue = []; DataInvLocation=[]; AbsSnippet=[];
    end
    [MaxPeak_EMG(Nind,1) MaxPeakLocationIndex]=max(Peak_EMG); MaxPeakLocation(Nind,1) = PeakLocation_EMG(MaxPeakLocationIndex);
    [Correlation Lags] = xcorr(detrend(binnedData.spikeratedata(:,MaxPeakLocationIndex)),detrend(binnedData.emgdatabin(:,MaxPeakLocationIndex)),'coeff');
     zeroInd = find(Lags==0);
    figure;plot(Lags(zeroInd-40:1:zeroInd+40),Correlation(zeroInd-40:1:zeroInd+40));
     SaveFigure('Z:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\NeuronsThatCare\', ['Spikes and EMG Xcorr ', monkeyname,' ',datalabel num2str(Nind)])
close
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
         AbsSnippet = abs(Correlation(zeroInd-10:1:zeroInd+10));
       [Peak_Vel(Nind,1) PeakVelLocation(Nind,1)]=max(AbsSnippet);
       PeakVelLocation(Nind,1)=PeakVelLocation(Nind,1)-11; %negative values should mean positive lag 'tween spike&EMG
               
%         [Peak_Vel(Nind,1), PeakVelLocation(Nind,1)] = max(Correlation(zeroInd-10:1:zeroInd));
%         PeakVelLocation(Nind,1)=11-PeakVelLocation(Nind,1); 
%         if PeakVelLocation(Nind,1)==1 || PeakVelLocation(Nind,1)==11 || PeakVelLocation(Nind,1)==10
%             Data=Correlation(zeroInd-10:1:zeroInd); DataInv=max(Data)-Data;
%             [DataInvValue DataInvLocation] = max(DataInv);
%             Peak_Vel(Nind,1)=abs(Data(DataInvLocation));
%             PeakVelLocation(Nind,1)=11-DataInvLocation;
%             if PeakVelLocation(Nind,1)==1 || PeakVelLocation(Nind,1)==11 || PeakVelLocation(Nind,1)==10
%                 Peak_Vel(Nind,1)=NaN; PeakVelLocation(Nind,1)=NaN;
%             end
%         end
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

%  figure
%  plot(rankedEMG,rankedVel,'.','MarkerSize',10)
% hold on; x=0:.01:1; y=x; plot(x,y);
%  xlabel('Ranked EMG neurons');ylabel('Ranked Velocity neurons')
%  title(plotTitle)

figure
subplot(2,1,1)
%title(plotTitle)
hist(PeakVelLocation,20)
xlabel('Velocity peak location')
subplot(2,1,2)
hist(Peak_Vel)
xlabel('PeakValue')

% figure
% subplot(2,1,1)
% %title(plotTitle)
% hist(MaxPeakLocation,20)
% xlabel('EMG peak location')
% subplot(2,1,2)
% hist(MaxPeak_EMG)
% xlabel('PeakValue')

end