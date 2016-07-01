% Make FINE_EMGFigure

load('C:\Users\LimbLabSteph\Dropbox\FINEpaper\PAM-Ch2-Median-FF022602-Cnum16-Beg-Recruitment Curve-trial5.mat')
handles.EMGnames
% Load twitches for FDP2
figure; plot(rawtwitch(:,14))
figure; plot(rawtwitch(1.797e04:1.816e04,14));
% pick range you like
signal = rawtwitch(1.797e04:1.816e04,14);
% smooth signal
close all; counter=1;SmoothedSignal=[];jumps=5;
for ind=1:jumps:length(signal)-1
    SmoothedSignal(counter) = mean(signal(ind:ind+jumps));
    counter=counter+1;
end
%rectify
RectifiedSignal = abs(SmoothedSignal);
% plot it all
figure
subplot(2,1,1)
plot(SmoothedSignal);ylim([-2e-4 2e-4]);
subplot(2,1,2)
plot(RectifiedSignal);ylim([-2e-4 2e-4]);

% Load twitches for FCR
close all;
figure; plot(rawtwitch(:,12))
signal2= rawtwitch(2.27e4:2.34e4,12);
figure;plot(signal2);
 counter=1;SmoothedSignal2=[];jumps=2;
for ind=1:jumps:length(signal)-1
    SmoothedSignal2(counter) = mean(signal2(ind:ind+jumps));
    counter=counter+1;
end
figure;plot(SmoothedSignal2);

