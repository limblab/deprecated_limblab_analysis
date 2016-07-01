TaskEMGsFigure(IsoBinned,WmBinned,SprBinned)
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


% Plot
figure
startInd=220; endInd=350; LineWidth=2;
startInd=220; endInd=575; LineWidth=2;
subplot(3,1,1)
plot(WmBinned.timeframe(startInd:endInd,:),WmEMGsNormed(startInd:endInd,:),'LineWidth',LineWidth); ylim([0 1.1]);xlim([11 28])
MillerFigure
legend(WmBinned.emgguide(2:5))
subplot(3,1,2)
plot(IsoBinned.timeframe(startInd:endInd,:),IsoEMGsNormed(startInd:endInd,:),'LineWidth',LineWidth); ylim([0 1.1]);xlim([11 28])
MillerFigure
subplot(3,1,3)
plot(SprBinned.timeframe(startInd:endInd,:),SprEMGsNormed(startInd:endInd,:),'LineWidth',LineWidth); ylim([0 1.1]);xlim([11 28])
MillerFigure
xlabel('Time (in seconds)')

% figure
% LineWidth=2;
% subplot(3,1,1)
% plot(WmEMGsNormed(floor(364.8/.05):floor((364.8+8)/.05),:),'LineWidth',LineWidth); ylim([0 1.2])
% title('Movement')
% subplot(3,1,2)
% plot(IsoEMGsNormed(floor(21/.05):floor((21+8)/.05),:),'LineWidth',LineWidth); ylim([0 1.2])
% title('Isometric')
% subplot(3,1,3)
% plot(SprEMGsNormed(floor(625.8/.05):floor((625.8+8)/.05),:),'LineWidth',LineWidth); ylim([0 1.2])
% title('Spring')
% legend({'ECR','ECU','FCR','FCU'})
% 
% 
% 
% % Another way to plot the EMGs
% figure; LineWidth=1.5; EMGlist = ['ECR'; 'ECU';'FCR';'FCU'];
% for c=1:4
%     subplot(4,1,c);hold on;
%     title(EMGlist(c,:));
%     if c==1
%          legend({'Move','Iso','Spr'})
%     end
%     plot(0:0.05:8,WmEMGsNormed(floor(364.8/.05):floor((364.8+8)/.05),c),'k','LineWidth',3); ylim([0 1]);xlim([2 8])%xlim([40 160]) %xlim([0 160])
%     plot(0:0.05:8,IsoEMGsNormed(floor(21/.05):floor((21+8)/.05),c),'--k','LineWidth',1.5); ylim([0 1]);xlim([2 8])%xlim([40 160]) %xlim([0 160])
%     plot(0:0.05:8,SprEMGsNormed(floor(625.8/.05):floor((625.8+8)/.05),c),'k','LineWidth',2); ylim([0 1]);xlim([2 8])%xlim([0 160])
% end
% xlabel('Time (sec)')
%   legend({'Move','Iso','Spr'})
% 
%  
%  % Just plot without regard for time axis
%  startInd=220; endInd=750; LineWidth=1.5;
% figure; EMGlist = ['ECR'; 'ECU';'FCR';'FCU'];
% for c=1:4
%     subplot(4,1,c);hold on;
%     title(EMGlist(c,:));
%     plot(WmEMGsNormed(startInd:endInd,c),'g','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%     plot(IsoEMGsNormed(startInd:endInd,c),'b','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%     plot(SprEMGsNormed(startInd:endInd,c),'m','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
% end
%  %legend({'Move','Iso','Spr'})
%  
%   % Just plot without regard for time axis but separate out the EMGs
%   startInd=220; endInd=750; LineWidth=1.5;
%   figure; EMGlist = ['ECR'; 'ECU';'FCR';'FCU'];
%   for d=1:4
%       subplot(3,4,d)
%       plot(WmBinned.timeframe(startInd:endInd),WmEMGsNormed(startInd:endInd,d),'g','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%       switch d
%           case 1 
%               ylabel('Movement'); title(EMGlist(1,:));
%           case 2
%               title(EMGlist(2,:))
%           case 3
%               title(EMGlist(3,:))
%           case 4
%               title(EMGlist(4,:))
%       end
%       subplot(3,4,d+4)
%       plot(IsoBinned.timeframe(startInd:endInd),IsoEMGsNormed(startInd:endInd,d),'b','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%       if d==1
%           ylabel('Isometric')
%       end
%       subplot(3,4,d+8)
%       plot(SprBinned.timeframe(startInd:endInd),SprEMGsNormed(startInd:endInd,d),'m','LineWidth',LineWidth); ylim([0 1.2]);MillerFigure;
%       if d ==1
%           ylabel('Spring')
%       end
%       
%   end
% 
% 
%  
%  
%  
% 
% % Plot the cursor position traces
% figure
% startInd=220; endInd=350; LineWidth=2;
% subplot(3,1,1)
% plot(WmBinned.cursorposbin(floor(364.8/.05):floor((364.8+8)/.05),1),'LineWidth',LineWidth);ylim([-15 15])
% subplot(3,1,2)
% plot(IsoBinned.cursorposbin(floor(21/.05):floor((21+8)/.05),1),'LineWidth',LineWidth);ylim([-15 15])
% subplot(3,1,3)
% plot(SprBinned.cursorposbin(floor(625.8/.05):floor((625.8+8)/.05),1),'LineWidth',LineWidth);ylim([-15 15])
% 
% 
% 
% 
% 
