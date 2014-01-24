%gets the PSE for each of the directions in the analysis and plots them as
%a single bar chart. this is lazy copy paste code. A loop would be more
%readable
    close all
    clear all
%save summary data for all sets while we are at it:
mkdir('E:\processing\bump_task\Summary\',strcat('summary_data_',date));
savepath=strcat('E:\processing\bump_task\Summary\','summary_data_',date,'\');


%20deg dir
    folderpath='E:\processing\bump_task\20degstim\';

    matchstring='Kramer';
    % %matchstring2='BC';
    disp('converting nev files to bdf format')
    file_list=autoconvert_nev_to_bdf(folderpath,matchstring);
    fid=fopen(strcat(savepath,'file_list_20deg.txt'),'w+');
    fprintf(fid,'%s',file_list);
    fclose(fid);
    % autoconvert_nev_to_bdf(folderpath,matchstring2)
    disp('concatenating bdfs into single structure')
    bdf=concatenate_bdfs_from_folder(folderpath,matchstring,0,0,0);
    %load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')
    make_tdf
    [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar,g_stim_20,g_no_stim_20] = bc_psychometric_curve_stim5_compressed(bdf.tt,bdf.tt_hdr,3,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(savepath,'20deg_stim_20ua_inverted_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
    title('Psychometric cartesian 20deg_stim_20uA inverted compressed')
    print('-dpdf',H_cartesian,strcat(savepath,'Psychometric_cartesian_20deg_20ua_inverted_compressed.pdf'))
    
    [H,probs_20,catch_e_lower_20,catch_e_upper_20]=catch_trials_all2(bdf.tt,bdf.tt_hdr,[0,1,2,3],1);
    title('20deg Catch trials: reaching rate to secondary target') 
    print('-dpdf',H,strcat(savepath,'20deg_Catch_trials_inverted.pdf'))
    save(strcat(savepath,'20deg_stim_20ua_catch_rates.txt'),'probs_20','-ascii')
    save(strcat(savepath,'20deg_stim_20ua_catch_errors_upper.txt'),'catch_e_upper_20','-ascii')
    save(strcat(savepath,'20deg_stim_20ua_catch_errors_lower.txt'),'catch_e_lower_20','-ascii')
    
    
    [H,error_rate_20,e_lower_20,e_upper_20]=error_rate2(bdf.tt,bdf.tt_hdr,[0,1,2,3]);
    title('20deg error rate by stim condition') 
    print('-dpdf',H,strcat(savepath,'20deg_error_rate.pdf'))
    save(strcat(savepath,'20deg_stim_20ua_error_rates.txt'),'error_rate_20','-ascii')
    save(strcat(savepath,'20deg_stim_20ua_error_errors_upper.txt'),'e_upper_20','-ascii')
    save(strcat(savepath,'20deg_stim_20ua_error_errors_lower.txt'),'e_lower_20','-ascii')
    close all
    
%70deg dir
    folderpath='E:\processing\bump_task\70degstim\';
    matchstring='Kramer';
    % %matchstring2='BC';
    disp('converting nev files to bdf format')
    file_list=autoconvert_nev_to_bdf(folderpath,matchstring);
    fid=fopen(strcat(savepath,'file_list_70deg.txt'),'w+');
    fprintf(fid,'%s',file_list);
    fclose(fid);
    % autoconvert_nev_to_bdf(folderpath,matchstring2)
    disp('concatenating bdfs into single structure')
    bdf=concatenate_bdfs_from_folder(folderpath,matchstring,0,0,0);
    %load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')
    make_tdf
    [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar,g_stim_70,g_no_stim_70] = bc_psychometric_curve_stim5_compressed(bdf.tt,bdf.tt_hdr,3,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(savepath,'70deg_stim_20ua_inverted_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
    title('Psychometric cartesian 70deg_stim_20uA inverted compressed')
    print('-dpdf',H_cartesian,strcat(savepath,'Psychometric_cartesian_70deg_20ua_inverted_compressed.pdf'))
    
    [H,probs_70,catch_e_lower_70,catch_e_upper_70]=catch_trials_all2(bdf.tt,bdf.tt_hdr,[0,1,2,3],1);
    title('70deg Catch trials: reaching rate to secondary target') 
    print('-dpdf',H,strcat(savepath,'70deg_Catch_trials_inverted.pdf'))
    save(strcat(savepath,'70deg_stim_20ua_catch_rates.txt'),'probs_70','-ascii')
    save(strcat(savepath,'70deg_stim_20ua_catch_errors_upper.txt'),'catch_e_upper_70','-ascii')
    save(strcat(savepath,'70deg_stim_20ua_catch_errors_lower.txt'),'catch_e_lower_70','-ascii')

    [H,error_rate_70,e_lower_70,e_upper_70]=error_rate2(bdf.tt,bdf.tt_hdr,[0,1,2,3]);
    title('70deg error rate by stim condition') 
    print('-dpdf',H,strcat(savepath,'70deg_error_rate.pdf'))
    save(strcat(savepath,'70deg_stim_20ua_error_rates.txt'),'error_rate_70','-ascii')
    save(strcat(savepath,'70deg_stim_20ua_error_errors_upper.txt'),'e_upper_70','-ascii')
    save(strcat(savepath,'70deg_stim_20ua_error_errors_lower.txt'),'e_lower_70','-ascii')
    close all


%140deg dir
    folderpath='E:\processing\bump_task\140deg stim\';
    matchstring='Kramer';
    % %matchstring2='BC';
    disp('converting nev files to bdf format')
    file_list=autoconvert_nev_to_bdf(folderpath,matchstring);
    fid=fopen(strcat(savepath,'file_list_140deg.txt'),'w+');
    fprintf(fid,'%s',file_list);
    fclose(fid);
    % autoconvert_nev_to_bdf(folderpath,matchstring2)
    disp('concatenating bdfs into single structure')
    bdf=concatenate_bdfs_from_folder(folderpath,matchstring,0,0,0);
    %load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')
    make_tdf
    [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar,g_stim_140,g_no_stim_140] = bc_psychometric_curve_stim5_compressed(bdf.tt,bdf.tt_hdr,3,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(savepath,'140deg_stim_20ua_inverted_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
    title('Psychometric cartesian 140deg_stim_200uA inverted compressed')
    print('-dpdf',H_cartesian,strcat(savepath,'Psychometric_cartesian_140deg_20ua_inverted_compressed.pdf'))
    
    [H,probs_140,catch_e_lower_140,catch_e_upper_140]=catch_trials_all2(bdf.tt,bdf.tt_hdr,[0,1,2,3],1);
    title('140deg Catch trials: reaching rate to secondary target') 
    print('-dpdf',H,strcat(savepath,'140deg_Catch_trials_inverted.pdf'))
    save(strcat(savepath,'140deg_stim_20ua_catch_rates.txt'),'probs_140','-ascii')
    save(strcat(savepath,'140deg_stim_20ua_catch_errors_upper.txt'),'catch_e_upper_140','-ascii')
    save(strcat(savepath,'140deg_stim_20ua_catch_errors_lower.txt'),'catch_e_lower_140','-ascii')

    [H,error_rate_140,e_lower_140,e_upper_140]=error_rate2(bdf.tt,bdf.tt_hdr,[0,1,2,3]);
    title('140deg error rate by stim condition') 
    print('-dpdf',H,strcat(savepath,'140deg_error_rate.pdf'))
    save(strcat(savepath,'140deg_stim_20ua_error_rates.txt'),'error_rate_140','-ascii')
    save(strcat(savepath,'140deg_stim_20ua_error_errors_upper.txt'),'e_upper_140','-ascii')
    save(strcat(savepath,'140deg_stim_20ua_error_errors_lower.txt'),'e_lower_140','-ascii')
    close all


%210deg dir
    folderpath='E:\processing\bump_task\210degstim\';
    matchstring='Kramer';
    % %matchstring2='BC';
    disp('converting nev files to bdf format')
    file_list=autoconvert_nev_to_bdf(folderpath,matchstring);
    fid=fopen(strcat(savepath,'file_list_210deg.txt'),'w+');
    fprintf(fid,'%s',file_list);
    fclose(fid);
    % autoconvert_nev_to_bdf(folderpath,matchstring2)
    disp('concatenating bdfs into single structure')
    bdf=concatenate_bdfs_from_folder(folderpath,matchstring,0,0,0);
    %load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')
    make_tdf
    [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar,g_stim_210,g_no_stim_210] = bc_psychometric_curve_stim5_compressed(bdf.tt,bdf.tt_hdr,3,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(savepath,'210deg_stim_20ua_inverted_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
    title('Psychometric cartesian 210deg_stim_20uA inverted compressed')
    print('-dpdf',H_cartesian,strcat(savepath,'Psychometric_cartesian_210deg_20ua_inverted_compressed.pdf'))
    
    [H,probs_210,catch_e_lower_210,catch_e_upper_210]=catch_trials_all2(bdf.tt,bdf.tt_hdr,[0,1,2,3],1);
    title('210deg Catch trials: reaching rate to secondary target') 
    print('-dpdf',H,strcat(savepath,'Catch_trials_inverted.pdf'))
    save(strcat(savepath,'210deg_stim_20ua_catch_rates.txt'),'probs_210','-ascii')
    save(strcat(savepath,'210deg_stim_20ua_catch_errors_upper.txt'),'catch_e_upper_210','-ascii')
    save(strcat(savepath,'210deg_stim_20ua_catch_errors_lower.txt'),'catch_e_lower_210','-ascii')

    [H,error_rate_210,e_lower_210,e_upper_210]=error_rate2(bdf.tt,bdf.tt_hdr,[0,1,2,3]);
    title('210deg error rate by stim condition') 
    print('-dpdf',H,strcat(savepath,'error_rate.pdf'))
    save(strcat(savepath,'210deg_stim_20ua_error_rates.txt'),'error_rate_210','-ascii')
    save(strcat(savepath,'210deg_stim_20ua_error_errors_upper.txt'),'e_upper_210','-ascii')
    save(strcat(savepath,'210deg_stim_20ua_error_errors_lower.txt'),'e_lower_210','-ascii')
    close all

%211deg dir
    folderpath='E:\processing\bump_task\211degstim\';
    matchstring='Kramer';
    % %matchstring2='BC';
    disp('converting nev files to bdf format')
    file_list=autoconvert_nev_to_bdf(folderpath,matchstring);
    fid=fopen(strcat(savepath,'file_list_211deg.txt'),'w+');
    fprintf(fid,'%s',file_list);
    fclose(fid);
    % autoconvert_nev_to_bdf(folderpath,matchstring2)
    disp('concatenating bdfs into single structure')
    bdf=concatenate_bdfs_from_folder(folderpath,matchstring,0,0,0);
    %load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')
    make_tdf
    [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar,g_stim_211,g_no_stim_211] = bc_psychometric_curve_stim5_compressed(bdf.tt,bdf.tt_hdr,3,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(savepath,'211deg_stim_20ua_inverted_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
    title('Psychometric cartesian 211deg_stim_20uA inverted compressed')
    print('-dpdf',H_cartesian,strcat(savepath,'Psychometric_cartesian_211deg_20ua_inverted_compressed.pdf'))
    
    [H,probs_211,catch_e_lower_211,catch_e_upper_211]=catch_trials_all2(bdf.tt,bdf.tt_hdr,[0,1,2,3],1);
    title('211deg Catch trials: reaching rate to secondary target') 
    print('-dpdf',H,strcat(savepath,'Catch_trials_inverted.pdf'))
    save(strcat(savepath,'211deg_stim_20ua_catch_rates.txt'),'probs_211','-ascii')
    save(strcat(savepath,'211deg_stim_20ua_catch_errors_upper.txt'),'catch_e_upper_211','-ascii')
    save(strcat(savepath,'211deg_stim_20ua_catch_errors_lower.txt'),'catch_e_lower_211','-ascii')

    [H,error_rate_211,e_lower_211,e_upper_211]=error_rate2(bdf.tt,bdf.tt_hdr,[0,1,2,3]);
    title('211deg error rate by stim condition') 
    print('-dpdf',H,strcat(savepath,'error_rate.pdf'))
    save(strcat(savepath,'211deg_stim_20ua_error_rates.txt'),'error_rate_211','-ascii')
    save(strcat(savepath,'211deg_stim_20ua_error_errors_upper.txt'),'e_upper_211','-ascii')
    save(strcat(savepath,'211deg_stim_20ua_error_errors_lower.txt'),'e_lower_211','-ascii')
    close all
    
%270deg dir
    folderpath='E:\processing\bump_task\270degstim\';
    matchstring='Kramer';
    % %matchstring2='BC';
    disp('converting nev files to bdf format')
    file_list=autoconvert_nev_to_bdf(folderpath,matchstring);
    fid=fopen(strcat(savepath,'file_list_270deg.txt'),'w+');
    fprintf(fid,'%s',file_list);
    fclose(fid);
    % autoconvert_nev_to_bdf(folderpath,matchstring2)
    disp('concatenating bdfs into single structure')
    bdf=concatenate_bdfs_from_folder(folderpath,matchstring,0,0,0);
    %load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')
    make_tdf
    [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar,g_stim_270,g_no_stim_270] = bc_psychometric_curve_stim5_compressed(bdf.tt,bdf.tt_hdr,3,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(savepath,'270deg_stim_20ua_inverted_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
    title('Psychometric cartesian 270deg_stim_20uA inverted compressed')
    print('-dpdf',H_cartesian,strcat(savepath,'Psychometric_cartesian_270deg_20ua_inverted_compressed.pdf'))
    
    [H,probs_270,catch_e_lower_270,catch_e_upper_270]=catch_trials_all2(bdf.tt,bdf.tt_hdr,[0,1,2,3],1);
    title('270deg Catch trials: reaching rate to secondary target') 
    print('-dpdf',H,strcat(savepath,'Catch_trials_inverted.pdf'))
    save(strcat(savepath,'270deg_stim_20ua_catch_rates.txt'),'probs_270','-ascii')
    save(strcat(savepath,'270deg_stim_20ua_catch_errors_upper.txt'),'catch_e_upper_270','-ascii')
    save(strcat(savepath,'270deg_stim_20ua_catch_errors_lower.txt'),'catch_e_lower_270','-ascii')

    [H,error_rate_270,e_lower_270,e_upper_270]=error_rate2(bdf.tt,bdf.tt_hdr,[0,1,2,3]);
    title('270deg error rate by stim condition') 
    print('-dpdf',H,strcat(savepath,'error_rate.pdf'))
    save(strcat(savepath,'270deg_stim_20ua_error_rates.txt'),'error_rate_270','-ascii')
    save(strcat(savepath,'270deg_stim_20ua_error_errors_upper.txt'),'e_upper_270','-ascii')
    save(strcat(savepath,'270deg_stim_20ua_error_errors_lower.txt'),'e_lower_270','-ascii')
    close all

%352deg dir
    folderpath='E:\processing\bump_task\352degstim\';
    matchstring='Kramer';
    % %matchstring2='BC';
    disp('converting nev files to bdf format')
    file_list=autoconvert_nev_to_bdf(folderpath,matchstring);
    fid=fopen(strcat(savepath,'file_list_352deg.txt'),'w+');
    fprintf(fid,'%s',file_list);
    fclose(fid);
    % autoconvert_nev_to_bdf(folderpath,matchstring2)
    disp('concatenating bdfs into single structure')
    bdf=concatenate_bdfs_from_folder(folderpath,matchstring,0,0,0);
    %load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')
    make_tdf
    [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar,g_stim_352,g_no_stim_352] = bc_psychometric_curve_stim5_compressed(bdf.tt,bdf.tt_hdr,3,1,0,0);
    temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
    save(strcat(savepath,'352deg_stim_20ua_inverted_compressed.txt'),'temp','-ascii')
    figure(H_cartesian)
    title('Psychometric cartesian 352deg_stim_20uA inverted compressed')
    print('-dpdf',H_cartesian,strcat(savepath,'Psychometric_cartesian_352deg_20ua_inverted_compressed.pdf'))
    
    [H,probs_352,catch_e_lower_352,catch_e_upper_352]=catch_trials_all2(bdf.tt,bdf.tt_hdr,[0,1,2,3],1);
    title('352deg Catch trials: reaching rate to secondary target') 
    print('-dpdf',H,strcat(savepath,'Catch_trials_inverted.pdf'))
    save(strcat(savepath,'352deg_stim_20ua_catch_rates.txt'),'probs_352','-ascii')
    save(strcat(savepath,'352deg_stim_20ua_catch_errors_upper.txt'),'catch_e_upper_352','-ascii')
    save(strcat(savepath,'352deg_stim_20ua_catch_errors_lower.txt'),'catch_e_lower_352','-ascii')

    [H,error_rate_352,e_lower_352,e_upper_352]=error_rate2(bdf.tt,bdf.tt_hdr,[0,1,2,3]);
    title('352deg error rate by stim condition') 
    print('-dpdf',H,strcat(savepath,'error_rate.pdf'))
    save(strcat(savepath,'352deg_stim_20ua_error_rates.txt'),'error_rate_352','-ascii')
    save(strcat(savepath,'352deg_stim_20ua_error_errors_upper.txt'),'e_upper_352','-ascii')
    save(strcat(savepath,'352deg_stim_20ua_error_errors_lower.txt'),'e_lower_352','-ascii')
    close all

%plot the PSEs
    %PSE=ctr-log((max-min)/(.5-min)-1)/steepness
    %g(1)=min
    %g(2)=max
    %g(3)=ctr
    %g(4)=steepness
    y=[getPSE(g_no_stim_20),getPSE(g_stim_20);...
        getPSE(g_no_stim_70),getPSE(g_stim_70);...
        getPSE(g_no_stim_140),getPSE(g_stim_140);...
        getPSE(g_no_stim_210),getPSE(g_stim_210);...
        getPSE(g_no_stim_211),getPSE(g_stim_211);...
        getPSE(g_no_stim_270),getPSE(g_stim_270);...
        getPSE(g_no_stim_352),getPSE(g_stim_352);...
        ];

    save(strcat(savepath,'all_sigmoid_PSEs.txt'),'y','-ascii')
    H=figure;
    h=bar(y,1.4);
    set(h(1),'FaceColor','b')
    set(h(2),'FaceColor','r')
    title('PSE for no stim and 20uA stim for each electrode set')
    print('-dpdf',H,strcat(savepath,'all_PSEs.pdf'))
    
    
    %plot summary catch @ 20ua
    y=[ probs_20(1),probs_20(5);...
        probs_70(1),probs_70(5);...
        probs_140(1),probs_140(5);...
        probs_210(1),probs_210(5);...
        probs_211(1),probs_211(5);...
        probs_270(1),probs_270(5);...
        probs_352(1),probs_352(5);...
        ];
    errs_l=[ catch_e_lower_20(1),catch_e_lower_20(5);...
        catch_e_lower_70(1),catch_e_lower_70(5);...
        catch_e_lower_140(1),catch_e_lower_140(5);...
        catch_e_lower_210(1),catch_e_lower_210(5);...
        catch_e_lower_211(1),catch_e_lower_211(5);...
        catch_e_lower_270(1),catch_e_lower_270(5);...
        catch_e_lower_352(1),catch_e_lower_352(5);...
        ];
    errs_u=[ catch_e_upper_20(1),catch_e_upper_20(5);...
        catch_e_upper_70(1),catch_e_upper_70(5);...
        catch_e_upper_140(1),catch_e_upper_140(5);...
        catch_e_upper_210(1),catch_e_upper_210(5);...
        catch_e_upper_211(1),catch_e_upper_211(5);...
        catch_e_upper_270(1),catch_e_upper_270(5);...
        catch_e_upper_352(1),catch_e_upper_352(5);...
        ];
    errs(:,:,1)=errs_l;
    errs(:,:,2)=errs_u;
    H=figure;
    h=barwitherr(errs,y,1.4);
    set(h(1),'FaceColor','b')
    set(h(2),'FaceColor','r')
    title('catch choice rate for no stim and 20uA stim for each electrode set')
    print('-dpdf',H,strcat(savepath,'all_catch_ratess.pdf'))
    %plot summary error rate @ 20 ua
    y=[ error_rate_20(1),error_rate_20(5);...
        error_rate_70(1),error_rate_70(5);...
        error_rate_140(1),error_rate_140(5);...
        error_rate_210(1),error_rate_210(5);...
        error_rate_211(1),error_rate_211(5);...
        error_rate_270(1),error_rate_270(5);...
        error_rate_352(1),error_rate_352(5);...
        ];
    errs_l=[ e_lower_20(1),e_lower_20(5);...
        e_lower_70(1),e_lower_70(5);...
        e_lower_140(1),e_lower_140(5);...
        e_lower_210(1),e_lower_210(5);...
        e_lower_211(1),e_lower_211(5);...
        e_lower_270(1),e_lower_270(5);...
        e_lower_352(1),e_lower_352(5);...
        ];
    errs_u=[ catch_e_upper_20(1),e_upper_20(5);...
        e_upper_70(1),e_upper_70(5);...
        e_upper_140(1),e_upper_140(5);...
        e_upper_210(1),e_upper_210(5);...
        e_upper_211(1),e_upper_211(5);...
        e_upper_270(1),e_upper_270(5);...
        e_upper_352(1),e_upper_352(5);...
        ];
    errs(:,:,1)=errs_l;
    errs(:,:,2)=errs_u;
    H=figure;
    set(H,'Position',[100 100 800 800])
    h=barwitherr(errs,y,1.4);
    set(h(1),'FaceColor','b')
    set(h(2),'FaceColor','r')
    title('error for no stim and 20uA stim for each electrode set')
    print('-dpdf',H,strcat(savepath,'all_error_rates.pdf'))
    
    close all
     %save the executing script to the same folder as the figures and data

fname=strcat(mfilename('fullpath'),'.m');
[SUCCESS,MESSAGE,MESSAGEID] = copyfile(fname,folderpath);
if SUCCESS
    disp(strcat('successfully copied the running script to the processed data folder'))
else
    disp('script copying failed with the following message')
    disp(MESSAGE)
    disp(MESSAGEID)
end