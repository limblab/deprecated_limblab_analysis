%script to process and display impedances
close all
imp=get_all_impedances('E:\processing\impedances\','kramer_impedance');
imp=imp(find(mean(imp,2)~=-1),:);

figure
%21deg:
plot(imp(46,:),'r')
hold on
plot(imp(48,:),'b')
plot(imp(50,:),'g')
plot(imp(51,:),'k')
x=[52 52]; y=[0 2000];
plot(x,y,'k')
axis([0 length(imp(:,1)) 0 2000]);
title('21deg')
ylabel('kOhm')

figure
%210deg:
plot(imp(35,:),'r')
hold on
plot(imp(44,:),'b')
plot(imp(66,:),'g')
plot(imp(87,:),'k')
x=[54 54]; y=[0 2000];
plot(x,y,'k')
axis([0 length(imp(:,1)) 0 2000]);
title('210deg')
ylabel('kOhm')

figure
%270deg:
plot(imp(3,:),'r')
hold on
plot(imp(70,:),'b')
plot(imp(43,:),'g')
plot(imp(49,:),'k')
x=[59 59]; y=[0 2000];
plot(x,y,'k')
axis([0 length(imp(:,1)) 0 2000]);
title('270deg')
ylabel('kOhm')

