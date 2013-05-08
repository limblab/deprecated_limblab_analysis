% %quickscript
% 
% %set the mount drive to scan and convert
close all

folderpath_base='E:\processing\210deg_single_electrode_80ua\';
matchstring='Kramer';
% %matchstring2='BC';
disp('converting nev files to bdf format')
autoconvert_nev_to_bdf(folderpath_base,matchstring)
% autoconvert_nev_to_bdf(folderpath,matchstring2)
disp('concatenating bdfs into single structure')
bdf=concatenate_bdfs_from_folder(folderpath_base,matchstring,0,0);
%load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')

make_tdf

%make folder to save into:
ts=datestr(now);
ts(ts==' ')='_';
ts(ts==':')='-';
mkdir(folderpath_base,strcat('Psychometrics_',ts));
folderpath=strcat(folderpath_base,'Psychometrics_',ts,'\');
disp('saving new figures and files to:')
disp(folderpath)

H=catch_trials_all(bdf.tt,bdf.tt_hdr,[0,1,2,3,4],1);
title('Catch trials: reaching rate to secondary target') 
print('-dpdf',H,strcat(folderpath,'Catch_trials_inverted.pdf'))

[H]=error_rate(bdf.tt,bdf.tt_hdr,[0,1,2,3,4]);
title('error rate by stim condition') 
print('-dpdf',H,strcat(folderpath,'error_rate.pdf'))

%new fitting plus inverting the y axis of the sigmoid
[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,0,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(folderpath,'20ua_all_electrodes.txt'),'temp','-ascii')
    figure(H_cartesian)
        subplot(2,1,1),title('Psychometric cartesian 20ua all electrodes')
        subplot(2,1,2),title('Observation counts at each bump angle')
        print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_20ua_all_electrodes.pdf'))

[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,1,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(folderpath,'20ua_electrode_1.txt'),'temp','-ascii')
    figure(H_cartesian)
        subplot(2,1,1),title('Psychometric cartesian 20ua electrode 1')
        subplot(2,1,2),title('Observation counts at each bump angle')
        print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_electrode_1.pdf'))

[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,2,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(folderpath,'20ua_electrode_2.txt'),'temp','-ascii')
    figure(H_cartesian)
        subplot(2,1,1),title('Psychometric cartesian 20ua electrode 2')
        subplot(2,1,2),title('Observation counts at each bump angle')
        print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_electrode_2.pdf'))

[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,3,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(folderpath,'20ua_electrode_3.txt'),'temp','-ascii')
    figure(H_cartesian)
        subplot(2,1,1),title('Psychometric cartesian 20ua electrode 3')
        subplot(2,1,2),title('Observation counts at each bump angle')
        print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_electrode_3.pdf'))

[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,4,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(folderpath,'20ua_electrode_4.txt'),'temp','-ascii')
    figure(H_cartesian)
        subplot(2,1,1),title('Psychometric cartesian 20ua electrode 4')
        subplot(2,1,2),title('Observation counts at each bump angle')
        print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_electrode_4.pdf'))

%new fitting plus inverting the y axis of the sigmoid and folding into a
%single hemispace
[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,0,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(folderpath,'20ua_all_electrodes_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
        subplot(2,1,1),title('Psychometric cartesian 20ua all electrodes compressed')
        subplot(2,1,2),title('Observation counts at each bump angle')
        print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_20ua_all_electrodes_compressed.pdf'))

[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,1,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(folderpath,'20ua_electrode_1_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
        subplot(2,1,1),title('Psychometric cartesian 20ua electrode 1 compressed')
        subplot(2,1,2),title('Observation counts at each bump angle')
        print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_20ua_electrode_1_compressed.pdf'))

[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,2,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(folderpath,'20ua_electrode_2_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
        subplot(2,1,1),title('Psychometric cartesian 20ua electrode 2 compressed')
        subplot(2,1,2),title('Observation counts at each bump angle')
        print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_20ua_electrode_2_compressed.pdf'))
        
[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,3,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(folderpath,'20ua_electrode_3_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
        subplot(2,1,1),title('Psychometric cartesian 20ua electrode 3 compressed')
        subplot(2,1,2),title('Observation counts at each bump angle')
        print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_20ua_electrode_3_compressed.pdf'))
        
[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,4,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(folderpath,'20ua_electrode_4_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
        subplot(2,1,1),title('Psychometric cartesian 20ua electrode 4 compressed')
        subplot(2,1,2),title('Observation counts at each bump angle')
        print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_20ua_electrode_4_compressed.pdf'))

%save the executing script to the same folder as the figures and data

fname=strcat(mfilename,'.m');
[SUCCESS,MESSAGE,MESSAGEID] = copyfile(fname,folderpath);
if SUCCESS
    disp(strcat('successfully copied the running script to the processed data folder'))
else
    disp('script copying failed with the following message')
    disp(MESSAGE)
    disp(MESSAGEID)
end
