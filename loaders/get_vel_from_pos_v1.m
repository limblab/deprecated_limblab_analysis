d1=(diff(analog(1).waveform));
d2=(diff(analog(2).waveform));
av_d1 = (d1(1:length(d1)-1) + d1(2:length(d1)))/2;
av_d2 = (d2(1:length(d2)-1) + d2(2:length(d2)))/2;

dvX = zeros(length(d1)+1, 1);
dvY = zeros(length(d2)+1, 1);

dvX(2:end-1) = av_d1;
dvY(2:end-1) = av_d2;

analog(2)
analog(3)
analog(4)


analog(3).waveform = dvX;
analog(4).waveform = dvY;

analog(3)
analog(4)
figure
plot(analog(3).waveform); hold on ; plot(analog(4).waveform, 'r')

clear d1 d2 av_d1 av_d2 dvX dvY
