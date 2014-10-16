function [figure_list,data_struct]=quickscript_function(fpath,input_data)
% %quickscript
% 
% %set the mount drive to scan and convert
close all

folderpath_base=fpath;


disp('converting nev files to bdf format')
file_list=autoconvert_nev_to_bdf(folderpath_base,input_data.matchstring,input_data.labnum);
data_struct.file_list=file_list;
disp('concatenating bdfs into single structure')
bdf=concatenate_bdfs_from_folder(folderpath_base,input_data.matchstring,0,0,0);

bdf=make_tdf_function(bdf);
data_struct.Aggregate_bdf=bdf;

 H=catch_trials_all(bdf.tt,bdf.tt_hdr,[0,1,2,3],1);
    title('Catch trials: reaching rate to secondary target') 
    set(H,'Name','Catch Trials')
    figure_list(1)=H;

[H]=error_rate(bdf.tt,bdf.tt_hdr,[0,1,2,3,4]);
    title('error rate by stim condition') 
    set(H,'Name','error rate by stim condition')
    figure_list(length(figure_list)+1)=H;

[H]=error_rate_aggregate(bdf.tt,bdf.tt_hdr);
    title('error rate Stim vs No-stim') 
    set(H,'Name','error rate Stim vs No-stim')
    figure_list(length(figure_list)+1)=H;

%new fitting plus inverting the y axis of the sigmoid
[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,0,1,0,0);
temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
data_struct.reach_data_5ua=temp;
figure(H_cartesian)
    title('Psychometric cartesian 5uA inverted')
    set(H_cartesian,'Name','Psychometric cartesian 5uA inverted')
    figure_list(length(figure_list)+1)=H_cartesian;
figure(H_polar)
    title('Psychometric polar 5uA inverted')
    set(H_polar,'Name','Psychometric polar 5uA inverted')
    figure_list(length(figure_list)+1)=H_polar;
 
[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,1,1,0,0);
temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
data_struct.reach_data_10ua=temp;
figure(H_cartesian)
    title('Psychometric cartesian 10uA inverted')
    set(H_cartesian,'Name','Psychometric cartesian 10uA inverted')
    figure_list(length(figure_list)+1)=H_cartesian;
figure(H_polar)
    title('Psychometric polar 10uA inverted')
    set(H_polar,'Name','Psychometric polar 10uA inverted')
    figure_list(length(figure_list)+1)=H_polar;
    
[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,2,1,0,0);
temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
data_struct.reach_data_15ua=temp;
figure(H_cartesian)
    title('Psychometric cartesian 15uA inverted')
    set(H_cartesian,'Name','Psychometric cartesian 15uA inverted')
    figure_list(length(figure_list)+1)=H_cartesian;
figure(H_polar)
    title('Psychometric polar 15uA inverted')
    set(H_polar,'Name','Psychometric polar 15uA inverted')
    figure_list(length(figure_list)+1)=H_polar;

[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,3,1,0,0);
temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
data_struct.reach_data_20ua=temp;
figure(H_cartesian)
    title('Psychometric cartesian 20uA inverted')
    set(H_cartesian,'Name','Psychometric cartesian 20uA inverted')
    figure_list(length(figure_list)+1)=H_cartesian;
figure(H_polar)
    title('Psychometric polar 20uA inverted')
    set(H_polar,'Name','Psychometric polar 20uA inverted')
    figure_list(length(figure_list)+1)=H_polar;    
    
    
    
    %new fitting plus inverting the y axis of the sigmoid and folding into a
 %single hemispace
[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,0,1,0,0);
temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
data_struct.reach_data_compressed_5ua=temp;
figure(H_cartesian)
    title('Psychometric cartesian 5uA inverted compressed')
    set(H_cartesian,'Name','Psychometric cartesian 5uA inverted compressed')
    figure_list(length(figure_list)+1)=H_cartesian;
figure(H_polar)
    title('Psychometric polar 5uA inverted compressed')
    set(H_polar,'Name','Psychometric polar 5uA inverted compressed')
    figure_list(length(figure_list)+1)=H_polar;

[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,1,1,0,0);
temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
data_struct.reach_data_compressed_10ua=temp;
figure(H_cartesian)
    title('Psychometric cartesian 10uA inverted compressed')
    set(H_cartesian,'Name','Psychometric cartesian 10uA inverted compressed')
    figure_list(length(figure_list)+1)=H_cartesian;
figure(H_polar)
    title('Psychometric polar 10uA inverted compressed')
    set(H_polar,'Name','Psychometric polar 10uA inverted compressed')
    figure_list(length(figure_list)+1)=H_polar;

[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,2,1,0,0);
temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
data_struct.reach_data_compressed_15ua=temp;
figure(H_cartesian)
    title('Psychometric cartesian 15uA inverted compressed')
    set(H_cartesian,'Name','Psychometric cartesian 15uA inverted compressed')
    figure_list(length(figure_list)+1)=H_cartesian;
figure(H_polar)
    title('Psychometric polar 15uA inverted compressed')
    set(H_polar,'Name','Psychometric polar 15uA inverted compressed')
    figure_list(length(figure_list)+1)=H_polar;
    
    
[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,3,1,0,0);
temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
data_struct.reach_data_compressed_20ua=temp;
figure(H_cartesian)
    title('Psychometric cartesian 20uA inverted compressed')
    set(H_cartesian,'Name','Psychometric cartesian 20uA inverted compressed')
    figure_list(length(figure_list)+1)=H_cartesian;
figure(H_polar)
    title('Psychometric polar 20uA inverted compressed')
    set(H_polar,'Name','Psychometric polar 20uA inverted compressed')
    figure_list(length(figure_list)+1)=H_polar;
    
   
end
