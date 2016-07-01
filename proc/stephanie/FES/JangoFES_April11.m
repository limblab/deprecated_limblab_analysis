%JangoApril112016FES

% ch 1,2,8 are bad
%JangoWFMUblock20160411155418stimout (import as cell)
%JangoWFMUblock20160411155418emg (import as cell)
figure;
LineWidth=1.5;
start = 900;
stop=2500;
start = 2800;
stop=4200;
xvals = 0:0.05:(stop-start)*.05;
subplot(3,1,1);hold on;
title('Jango FES April 11, 2016| Median Nerve Block')
ylabel('EMG predictions')
for a=2:5
plot(xvals,cell2mat(JangoWFMUblock20160411155418emgpreds(start:stop,a)),'LineWidth',LineWidth);
end
xlim([0 (stop-start)*.05])
legend(bmi_fes_stim_params.muscles(1:4));
legend boxoff; MillerFigure

subplot(3,1,2);hold on;
ylabel('Stimulation PW (us)')
for b=3:6
plot(xvals,cell2mat(JangoWFMUblock20160411155418stimout(start:stop,b)),'LineWidth',LineWidth);
end
xlim([0 (stop-start)*.05])
legend(bmi_fes_stim_params.muscles(1:4));
legend boxoff; MillerFigure

load('Z:\data\Jango_12a1\CerebusData\Samplefes\20160411\Processed\Jango_WF_MUblock__20160411_155418_Binned.mat')
subplot(3,1,3);hold on;
ylabel('Force')
%plot(binnedData.forcedatabin(start:stop,2))
plot(xvals,binnedData.forcedatabin(start+74:stop+74,2),'g','LineWidth',LineWidth)
xlim([0 (stop-start)*.05])
set(gca,'yticklabel',[]);set(gca,'ytick',[]);  MillerFigure
xlabel('Time (in seconds)')
%for c=1:length(binnedData.trialtable)
%plot(binnedData.forcedatabin(start-74:stop,2),'r')

%for c=1:length(binnedData.trialtable)
%rectangle


%w.Catch = hex2dec('32');


