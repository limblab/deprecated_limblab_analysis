function plotstuff_2(m,a,b,base,title)
%defining some dummy values for variables/remove "%" if needed

%m = [1 10 20 22; 15 20 35 28; 30 42 35 30; 27 22 25 29];
%a = [1 2 3 4];
%b = [29; 30; 45; 30];
%base = [17];




%--------------------------setting figure attributes-----------
scrsz = get(0,'ScreenSize'); %figure orriented on screen size -> determining screen size.
figure('Position',[scrsz(4)/5, scrsz(4)/5, scrsz(4)/2*1.3, scrsz(4)/2]) %setting figure size 

%---------------find max value and axis dimensions-------------
c = [0 max([max(max(m)),max(a),max(b),base])];

%--------------------------plot m------------------------------
axes('position',[0.1 0.1 0.4615 0.6]);
image(m,'CDataMapping','scaled');

ylabel('target');
xlabel('bump');
set(gca, 'YTICK', [1 2 3 4])
set(gca, 'XTICK', [1 2 3 4])
caxis(c)
%--------------------------plot a------------------------------
%   setting pos. and size for image a
axes('position',[0.1 0.8 0.4615 0.13]);
%   drawing image a
image(a,'CDataMapping','scaled');
set(gca, 'YTICK', 1)
set(gca, 'XTICK', [1 2 3 4])
caxis(c)

%--------------------------plot base---------------------------
axes('position',[0.65 0.8 0.113 0.13]);
image(base,'CDataMapping','scaled');
set(gca, 'YTICK', []);
set(gca, 'XTICK', []);
caxis(c);

%--------------------------plot b------------------------------
axes('position',[0.65 0.1 0.2 0.6]);
image(b,'CDataMapping','scaled');
set(gca, 'YTICK', [1 2 3 4]);
set(gca, 'XTICK', 1);








suptitle(title);

colorbar;
caxis(c);

