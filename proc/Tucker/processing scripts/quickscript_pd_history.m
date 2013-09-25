%quickscript_pd_history
%loads a bunch of PD records and plots nicely

close all
folderpath='E:\processing\PDs\';
PDs=get_all_PDS(folderpath,'PD_moddepth_data_');
PDs=(180/3.14159)*PDs;
mask=PDs<0;
mask=mask*360;
PDs=PDs+mask;

H=figure;
%21deg:
plot(PDs(46,:),'r')
hold on
plot(PDs(48,:),'b')
plot(PDs(50,:),'g')
plot(PDs(51,:),'k')
x=[8 8]; y=[0 360];
plot(x,y,'k')
axis([0 length(PDs(1,:)) 0 360]);
title('21deg set')
ylabel('PD(deg)')
print('-dpdf',H,strcat(folderpath,'PD_history_21deg_set.pdf'))

H=figure;
%210deg:
plot(PDs(35,:),'r')
hold on
plot(PDs(44,:),'b')
plot(PDs(66,:),'g')
plot(PDs(87,:),'k')
x=[8 8]; y=[0 360];
plot(x,y,'k')
axis([0 length(PDs(1,:)) 0 360]);
title('210deg set')
ylabel('PD(deg)')
print('-dpdf',H,strcat(folderpath,'PD_history_210deg_set.pdf'))

H=figure;
%270deg:
plot(PDs(3,:),'r')
hold on
plot(PDs(70,:),'b')
plot(PDs(43,:),'g')
plot(PDs(49,:),'k')
x=[8 8]; y=[0 360];
plot(x,y,'k')
axis([0 length(PDs(1,:)) 0 360]);
title('270deg set')
ylabel('PD(deg)')
print('-dpdf',H,strcat(folderpath,'PD_history_270deg_set.pdf'))