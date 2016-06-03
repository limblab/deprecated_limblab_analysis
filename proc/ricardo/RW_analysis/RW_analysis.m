
file_prefix = 'Kevin_2013-04-12_RW-s_001';
datapath = 'D:\Data\Kevin_12A2\Data\';

NEVNSx = concatenate_NEVs(datapath,file_prefix);
bdf = get_nev_mat_data(NEVNSx,3);  
PDs = PD_table(bdf,0);