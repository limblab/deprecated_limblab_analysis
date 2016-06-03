clc;clear;
pathnamesorted='\\165.124.111.234\data\Miller\Pedro_4C2\S1 Array\Sorted\';
pathname='\\165.124.111.234\data\Miller\Pedro_4C2\S1 Array\Processed\';
pathnameout='\\165.124.111.234\limblab\user_folders\Boubker\Labbooks\';

allroots={'Pedro_2011-04-28_RW_001'};
figout='4_15_2011_PDs';
stimulated=[41,57];
totalcurrent=[80,80];


data=get_cerebus_data([pathnamesorted,char(allroots),'-s.nev']);
save([pathname,char(allroots)], 'data');
PDfromspikesFtic_cell_count_multi
cellcounttolabbook