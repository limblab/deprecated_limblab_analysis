%load up a sequence of PD files and parse out the correct electrode info.
%Then put into a polar plot:


%Chips files
folderpath='Z:\Chips_12H1\processed\summary of stim directions';
PDs=[];
mean_pds=[];
%% 79deg PD
fname='79deg_electrode_pd_table_20150602.mat';
elecs=[14 32 61 91];
load([folderpath,filesep,fname])
fhandle=@(x) find(electrode_pd_table.channel==x);
elist=arrayfun(fhandle,elecs);
PDs{end+1}=electrode_pd_table.dir(elist);
mean_pds=[mean_pds,mean(PDs{end})];

%% 48deg PD
fname='48deg_electrode_pd_table_20150514.mat';
elecs=[32 63 81 92];
load([folderpath,filesep,fname])
fhandle=@(x) find(electrode_pd_table.channel==x);
elist=arrayfun(fhandle,elecs);
PDs{end+1}=electrode_pd_table.dir(elist);
mean_pds=[mean_pds,mean(PDs{end})];
%% 216deg PD
fname='216deg_electrode_pd_table_20150527.mat';
elecs=[23 27 54 88];
load([folderpath,filesep,fname])
fhandle=@(x) find(electrode_pd_table.channel==x);
elist=arrayfun(fhandle,elecs);
PDs{end+1}=electrode_pd_table.dir(elist);
mean_pds=[mean_pds,mean(PDs{end})];
%% 66deg PD
fname='66deg_electrode_pd_table_20150608.mat';
elecs=[59 61 82 84];
load([folderpath,filesep,fname])
fhandle=@(x) find(electrode_pd_table.channel==x);
elist=arrayfun(fhandle,elecs);
PDs{end+1}=electrode_pd_table.dir(elist);
mean_pds=[mean_pds,mean(PDs{end})];
%%224deg PD
fname='224deg_electrode_pd_table_20150611.mat';
elecs=[44 77 79 90];
load([folderpath,filesep,fname])
fhandle=@(x) find(electrode_pd_table.channel==x);
elist=arrayfun(fhandle,elecs);
PDs{end+1}=electrode_pd_table.dir(elist);
mean_pds=[mean_pds,mean(PDs{end})];
%316deg PD
fname='316deg_electrode_pd_table_20150615.mat';
elecs=[8 16 25 96];
load([folderpath,filesep,fname])
fhandle=@(x) find(electrode_pd_table.channel==x);
elist=arrayfun(fhandle,elecs);
PDs{end+1}=electrode_pd_table.dir(elist);
mean_pds=[mean_pds,mean(PDs{end})];
%% plot everything
%get colors:

h=figure;

%plot the electrode sets:
plotlist=[];
for i=1:4
    for j=1:length(PDs)
        plotlist=[plotlist,[PDs{j}(i),PDs{j}(i)]'];
    end
    
end
polar(plotlist,[ones(1,size(plotlist,2));zeros(1,size(plotlist,2))]);
hold on
%colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[mean_pds]);
%set(gca,'colororder',colorhsv)
colorjet=jet(length(mean_pds));
set(gca,'colororder',colorjet);
polar(plotlist,[ones(1,size(plotlist,2));zeros(1,size(plotlist,2))]);
%plot the means
h_means=polar([mean_pds;mean_pds],[ones(1,length(mean_pds));zeros(1,length(mean_pds))]);
set(h_means,'linewidth',2);
title('Electrode groups stimulated in monkey C')

fname='Monkey_C_stimulation_groups';%replace spaces in name for saving
print('-dpdf',h,strcat(folderpath,filesep,fname,'.pdf'))
print('-deps',h,strcat(folderpath,filesep,fname,'.eps'))
print('-dpng',h,strcat(folderpath,filesep,fname,'.png'))
saveas(h,strcat(folderpath,filesep,fname,'.fig'),'fig')















