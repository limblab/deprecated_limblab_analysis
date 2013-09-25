%make simple polar plot of PDs for 2013 SFN poster


%establish script variables:
folderpath='E:\processing\PDs\03142013\';
fname=strcat(folderpath,'PD_moddepth_data_14-Mar-2013.txt');
%load PD data
PD_data=load(fname);
%feed to plotting function
h=make_polar_plot_all_PDs(PD_data(:,2));
title('PDs')
h2=make_polar_plot_all_PDs(PD_data(:,2),PD_data(:,3));
title('PDs scaled by normalized modulation depth')

%save figure
print('-dpdf',h,strcat(folderpath,'SFN_2013_all_PDs.pdf'))
print('-dpdf',h2,strcat(folderpath,'SFN_2013_all_PDs_moddepth.pdf'))
