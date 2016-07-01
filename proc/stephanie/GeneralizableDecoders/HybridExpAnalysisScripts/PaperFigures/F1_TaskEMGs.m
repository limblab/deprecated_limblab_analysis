function F1_TaskEMGs(IsoBinned,WmBinned,SprBinned)
% use 08-20 from jango
% normalize the binned files

% Get the data for the 4 muscles isolated in variables for each task
binnedData = IsoBinned;
EMGind1 = strmatch('ECR',(binnedData.emgguide)); EMGind1 = EMGind1(1);
EMGind2 = strmatch('ECU',(binnedData.emgguide)); EMGind2 = EMGind2(1);
EMGind3 = strmatch('FCR',(binnedData.emgguide)); EMGind3 = EMGind3(1);
EMGind4 = strmatch('FCU',(binnedData.emgguide)); EMGind4 = EMGind4(1);
emg_vector = [EMGind1 EMGind2 EMGind3 EMGind4];
IsoEMGs = IsoBinned.emgdatabin(:,emg_vector);
WmEMGs = WmBinned.emgdatabin(:,emg_vector);
SprEMGs = SprBinned.emgdatabin(:,emg_vector);

% Normalize
EMGacrossTasks = cat(1,IsoEMGs,WmEMGs,SprEMGs);
SortedEMGacrossTasks = sort(EMGacrossTasks,'descend');
NinetyNinthEMGpercentile = SortedEMGacrossTasks(.0005*length(SortedEMGacrossTasks),:);
for a=1:length(NinetyNinthEMGpercentile)
    IsoEMGsNormed(:,a) = IsoEMGs(:,a)./ NinetyNinthEMGpercentile(a);
    WmEMGsNormed(:,a) = WmEMGs(:,a)./ NinetyNinthEMGpercentile(a);
    SprEMGsNormed(:,a) = SprEMGs(:,a)./ NinetyNinthEMGpercentile(a);
end


% Another way to plot the EMGs
figure; LineWidth=1.5; EMGlist = ['ECR'; 'ECU';'FCR';'FCU'];
for c=1:4
    subplot(4,1,c);hold on;
    title(EMGlist(c,:));
    if c==1
         legend({'Move','Iso','Spr'})
    end
    plot(0:0.05:20,WmEMGsNormed(floor(364.8/.05):floor((364.8+20)/.05),c),'Color',[1 0.5 0],'LineWidth',3); ylim([0 1]);xlim([2 20])%xlim([40 160]) %xlim([0 160])
    plot(0:0.05:20,IsoEMGsNormed(floor(21/.05):floor((21+20)/.05),c),'.-','Color',[0.5 0.5 1],'LineWidth',1.5); ylim([0 1]);xlim([2 20])%xlim([40 160]) %xlim([0 160])
    plot(0:0.05:20,SprEMGsNormed(floor(625.8/.05):floor((625.8+20)/.05),c),'Color',[0 0 0],'LineWidth',2); ylim([0 1]);xlim([2 20])%xlim([0 160])
    MillerFigure
end
xlabel('Time (sec)')
  legend({'Move','Iso','Spr'})
  
%   plot(0:0.05:8,WmEMGsNormed(floor(364.8/.05):floor((364.8+8)/.05),c),'k','LineWidth',3); ylim([0 1]);xlim([2 8])%xlim([40 160]) %xlim([0 160])
%     plot(0:0.05:8,IsoEMGsNormed(floor(21/.05):floor((21+8)/.05),c),'--k','LineWidth',1.5); ylim([0 1]);xlim([2 8])%xlim([40 160]) %xlim([0 160])
%     plot(0:0.05:8,SprEMGsNormed(floor(625.8/.05):floor((625.8+8)/.05),c),'k','LineWidth',2); ylim([0 1]);xlim([2 8])%xlim([0 160])


% 
% startInd=220; endInd=750; LineWidth=1.5;
% figure; EMGlist = ['ECR'; 'ECU';'FCR';'FCU'];
% for d=1:4
%     subplot(3,4,d)
%     plot(WmBinned.timeframe(startInd:endInd),WmEMGsNormed(startInd:endInd,d),'g','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%     xlim([10 35])
%     switch d
%         case 1
%             ylabel('Movement'); title(EMGlist(1,:));
%         case 2
%             title(EMGlist(2,:))
%         case 3
%             title(EMGlist(3,:))
%         case 4
%             title(EMGlist(4,:))
%     end
%     subplot(3,4,d+4)
%     plot(IsoBinned.timeframe(startInd:endInd),IsoEMGsNormed(startInd:endInd,d),'b','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%      xlim([10 35])
%     if d==1
%         ylabel('Isometric')
%     end
%     subplot(3,4,d+8)
%     plot(SprBinned.timeframe(startInd:endInd),SprEMGsNormed(startInd:endInd,d),'m','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%      xlim([10 35])
%     if d ==1
%         ylabel('Spring')
%     end
%     
% end
% 
% 
% startInd=220; endInd=750; LineWidth=1.5;
% figure; EMGlist = ['ECR'; 'ECU';'FCR';'FCU'];
% for d=1:6
%     subplot(3,2,d)
%     xlim([10 35])
%     switch d
%         case 1
%             
%             plot(WmBinned.timeframe(startInd:endInd),WmEMGsNormed(startInd:endInd,1),'c','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;hold on;
%             plot(WmBinned.timeframe(startInd:endInd),WmEMGsNormed(startInd:endInd,2),'b','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%             ylabel('Movement');
%         case 2
%             plot(WmBinned.timeframe(startInd:endInd),WmEMGsNormed(startInd:endInd,3),'c','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;hold on;
%             plot(WmBinned.timeframe(startInd:endInd),WmEMGsNormed(startInd:endInd,4),'b','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%         case 3
%             plot(IsoBinned.timeframe(startInd:endInd),IsoEMGsNormed(startInd:endInd,1),'g','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;hold on;
%             plot(IsoBinned.timeframe(startInd:endInd),IsoEMGsNormed(startInd:endInd,2),'k','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%             ylabel('Isometric');
%         case 4
%             plot(IsoBinned.timeframe(startInd:endInd),IsoEMGsNormed(startInd:endInd,3),'g','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;hold on;
%             plot(IsoBinned.timeframe(startInd:endInd),IsoEMGsNormed(startInd:endInd,4),'k','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%         case 5
%             plot(SprBinned.timeframe(startInd:endInd),SprEMGsNormed(startInd:endInd,1),'m','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;hold on;
%             plot(SprBinned.timeframe(startInd:endInd),SprEMGsNormed(startInd:endInd,2),'r','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%             ylabel('Spring');
%         case 6
%             plot(SprBinned.timeframe(startInd:endInd),SprEMGsNormed(startInd:endInd,3),'m','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;hold on;
%             plot(SprBinned.timeframe(startInd:endInd),SprEMGsNormed(startInd:endInd,4),'r','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%     end
%     
% end

end
