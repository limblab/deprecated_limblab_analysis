function altplot(m,a,b,base,title)
%defining some dummy values for variables/remove "%" if needed

%m = [1 10 20 22; 
  %  15 20 35 28; 
%   30 42 35 30;
 %   27 22 25 29];
%a = [1 2 3 4];
%b = [29; 30; 45; 30];
%base = [17];

x = [0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 m(1,1) 0 0 0 0 0 0;
     0 0 0 0 0 m(1,4) b(1) m(1,2) 0 0 0 0 0;
     0 0 0 0 0 0 m(1,3) 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 m(4,1) 0 0 0 a(1) 0 0 0 m(2,1) 0 0;
     0 m(4,4) b(4) m(4,2) 0 a(4) base a(2) 0 m(2,4) b(2) m(2,2) 0;
     0 0 m(4,3) 0 0 0 a(3) 0 0 0 m(2,3) 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 m(3,1) 0 0 0 0 0 0;
     0 0 0 0 0 m(3,4) b(3) m(3,2) 0 0 0 0 0;
     0 0 0 0 0 0 m(3,3) 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0;];
 
 alfa = [0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 1 0 0 0 0 0 0;
     0 0 0 0 0 1 1 1 0 0 0 0 0;
     0 0 0 0 0 0 1 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 1 0 0 0 1 0 0 0 1 0 0;
     0 1 1 1 0 1 1 1 0 1 1 1 0;
     0 0 1 0 0 0 1 0 0 0 1 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 1 0 0 0 0 0 0;
     0 0 0 0 0 1 1 1 0 0 0 0 0;
     0 0 0 0 0 0 1 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0;];

c = [    1.0000    1.0000    1.0000
         0         0    0.6875
         0         0    0.7396
         0         0    0.7917
         0         0    0.8438
         0         0    0.8958
         0         0    0.9479
         0         0    1.0000
         0    0.0625    1.0000
         0    0.1250    1.0000
         0    0.1875    1.0000
         0    0.2500    1.0000
         0    0.3125    1.0000
         0    0.3750    1.0000
         0    0.4375    1.0000
         0    0.5000    1.0000
         0    0.5625    1.0000
         0    0.6250    1.0000
         0    0.6875    1.0000
         0    0.7500    1.0000
         0    0.8125    1.0000
         0    0.8750    1.0000
         0    0.9375    1.0000
         0    1.0000    1.0000
    0.0625    1.0000    0.9375
    0.1250    1.0000    0.8750
    0.1875    1.0000    0.8125
    0.2500    1.0000    0.7500
    0.3125    1.0000    0.6875
    0.3750    1.0000    0.6250
    0.4375    1.0000    0.5625
    0.5000    1.0000    0.5000
    0.5625    1.0000    0.4375
    0.6250    1.0000    0.3750
    0.6875    1.0000    0.3125
    0.7500    1.0000    0.2500
    0.8125    1.0000    0.1875
    0.8750    1.0000    0.1250
    0.9375    1.0000    0.0625
    1.0000    1.0000         0
    1.0000    0.9375         0
    1.0000    0.8750         0
    1.0000    0.8125         0
    1.0000    0.7500         0
    1.0000    0.6875         0
    1.0000    0.6250         0
    1.0000    0.5625         0
    1.0000    0.5000         0
    1.0000    0.4375         0
    1.0000    0.3750         0
    1.0000    0.3125         0
    1.0000    0.2500         0
    1.0000    0.1875         0
    1.0000    0.1250         0
    1.0000    0.0625         0
    1.0000         0         0
    0.9375         0         0
    0.8750         0         0
    0.8125         0         0
    0.7500         0         0
    0.6875         0         0
    0.6250         0         0
    0.5625         0         0
    0.5000         0         0];



%suptitle(title);

%--------------------------setting figure attributes-----------
scrsz = get(0,'ScreenSize'); %figure orriented on screen size -> determining screen size.
figure('Position',[scrsz(4)/5, scrsz(4)/5, scrsz(4)/2*1.3, scrsz(4)/2]) %setting figure size 

%---------------find max value and axis dimensions-------------
r = [0 max([max(max(m)),max(a),max(b),base])];

%--------------------------plot the thing---------------------------
%axes('position',[0.1 0.1 0.6666 0.8333]);
h = image(x,'CDataMapping','scaled');
set(gca, 'YTICK', []);
set(gca, 'XTICK', []);
suptitle(title);
colorbar;
caxis(r);
set (h,'AlphaData', alfa)




