m = [1 10 20 30; 40 50 35 28; 40 60 35 30; 27 22 25 29];
a = [1 2 3 4];
b = [29; 30; 45; 30];

%setting figure attributes
scrsz = get(0,'ScreenSize'); %figure orriented on screen size -> determining screen size.
figure('Position',[scrsz(4)/5, scrsz(4)/5, scrsz(4)/2*1.3, scrsz(4)/2]) %setting figure size 
%rect = [scrsz(4)/4, scrsz(4)/4, width, height]


axes('position',[0.1 0.1 0.4615 0.6])
image (m);

ylabel('target');
xlabel('bump');
set(gca, 'YTICK', [1 2 3 4])
set(gca, 'XTICK', [1 2 3 4])
%title(sprintf('%d - %d', chan,unit));


%setting pos. and size for image a
axes('position',[0.1 0.8 0.4615 0.13]);
%drawing image a
image (a);
set(gca, 'YTICK', [1])
set(gca, 'XTICK', [1 2 3 4])


axes('position',[0.65 0.1 0.2 0.6]);
image (b);
set(gca, 'YTICK', [1 2 3 4])
set(gca, 'XTICK', [1])

colorbar;


%x = 0:pi/100:2*pi
%y1 = sin(x)
%y2 = sin(x+.25)
%y3 = sin(x+.5)
%%subplot(2,2,3)
%%image (m)
%plot(x,y1,x,y2,x,y3)
%axis tight
%w1 = cos(x)
%w2 = cos(x+.25)
%w3 = cos(x+.5)
%%subplot(2,2,1)
%axes('position',[0.1 0.1 0.6 0.6])
%image (m)
%plot(x,w1,x,w2,x,w3)
%axis tight