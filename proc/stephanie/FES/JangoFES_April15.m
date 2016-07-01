%JangoApril152016FES

%    12: Target UL X
%    8: Target UL Y
%    9: Target LR X
%    10:Target LR Y

figure;
LineWidth=1.5;
start = 900;
stop=2500;
start = 250;
stop=1650;
xvals = 0:0.05:(stop-start)*.05;
%subplot(3,1,1);hold on;
subplot(4,1,1);hold on;
title('Jango FES April 15, 2016| Median Nerve Block')
ylabel('EMG predictions')

 %subplot(4,1,4);hold on;
 colormap jet

 
 
%      cm=flipud('jet')
% % cm = jet
% % now, try
%      cm=flipud(jet);
%      colormap(cm);
%      colorbar;
 
neuronsubset=JangoMGPGMblock20160415153950spikes(start:stop,2:end)';

 neuronsubset = neuronsubset./320;
%figure; 
imagesc(neuronsubset);
xlim([160 560])

subplot(4,1,2);hold on;
for a=3:5
plot(xvals,cell2mat(JangoMGPGMblock20160415153950emgpreds(start:stop,a)),'LineWidth',LineWidth);
end
plot(xvals, .3*ones(1,length(xvals)));
hold on
xlim([0 (stop-start)*.05])
xlim([8 28])
legend(bmi_fes_stim_params.muscles(2:4));
legend boxoff; MillerFigure

%subplot(3,1,2);hold on;
subplot(4,1,3);hold on;
ylabel('Stimulation PW (us)')
for b=4:6
plot(xvals,cell2mat(JangoMGPGMblock20160415153950stimout(start:stop,b)),'LineWidth',LineWidth);
end
hold on
%plot(xvals,cell2mat(JangoMGPGMblock20160415153950stimout(start:stop,8))*.5,'LineWidth',LineWidth);

xlim([0 (stop-start)*.05])
xlim([8 28])
legend(bmi_fes_stim_params.muscles(2:4));
legend boxoff; 
MillerFigure

multipliedForce = cell2mat(JangoMGPGMblock20160415153950stimout(:,8))*8000-1000;
%subplot(3,1,3);hold on;
subplot(4,1,4);hold on;
ylabel('Force')
xlim([8 28])
%plot(binnedData.forcedatabin(start:stop,2)); hold on
plot(xvals,binnedData.forcedatabin(start+79:stop+79,2),'k','LineWidth',LineWidth)
hold on

%-----------------------------------------------------
%  subplot(4,1,4);hold on;
%  colormap default
%  
% neuronsubset=JangoMGPGMblock20160415153950spikes(start:stop,2:end)';
% 
%  neuronsubset = neuronsubset./320;
% %figure; 
% imagesc(neuronsubset);
% xlim([160 560])

% 
% figure
%  hold on
% for c=1:length(binnedData.trialtable)
%     if binnedData.trialtable(c,12)==82
%         plot([binnedData.trialtable(c,11)+3.95-(start*.05) binnedData.trialtable(c,11)+3.95-(start*.05)], [0 4000],'-k','LineWidth',5)
%     end
% end

xlim([0 (stop-start)*.05])
ylim([-1000 4000])
set(gca,'yticklabel',[]);set(gca,'ytick',[]);  MillerFigure
plot(xvals,multipliedForce(start:stop),'.m')
xlabel('Time (in seconds)')
MillerFigure

% Trial table values
% binnedData.trialtable(:,2) --> hand on touch pad
%  binnedData.trialtable(:,11) --> trial end time
% for c=1:10%length(binnedData.trialtable)
%     rectangle('Position',[binnedData.trialtable(c,2), binnedData.trialtable(c,10), binnedData.trialtable(c,11)-binnedData.trialtable(c,2),4]);
% end
% 


