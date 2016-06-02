figure;
plot(binnedData.timeframe,AveFR,'k');
hold on;
plot(binnedData.timeframe,FR_S50,'m');
plot(binnedData.timeframe,FR_S100,'b');
plot(binnedData.timeframe,FR_S200,'g');
legend('Raw','S50','S100','S200');
xlim([262 274]); ylim([14 46]);


FR_mod = [0; abs(diff(FR_S100))];
FR_mod = 1-(FR_mod/max(FR_mod));


plot(binnedData.timeframe,FR_mod*10+35,'b');
plot(binnedData.timeframe,FR_mod*10+35,'w');


RC = RC_max * FR_mod.^exp(1);


plot(binnedData.timeframe,RC*50+35,'m');
plot(binnedData.timeframe,RC*50+35,'w');


figure;
x = 0:0.01:1;
y1 = x.^2;
y2 = exp(x);
%sigmoid:
Top = RC_max;
Bottom = 0;
V50 = 0.5;
Slope = 0.1;

y3 = Bottom + (Top-Bottom)./(1+exp((V50-x)/Slope));
figure; plot(x,y3);

plot(x,y1,x,y2,x,y3);
legend('y1','y2','y3');



