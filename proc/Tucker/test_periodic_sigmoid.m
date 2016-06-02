ang=[0:180]*pi/180;

params=[0 1 0 2];

h=figure;
data=sigmoid_periodic(params,ang);
h2=plot(data,'Color',[1 .9 .9],'LineWidth',2);
pause(.1)
format_for_lee(h2)
