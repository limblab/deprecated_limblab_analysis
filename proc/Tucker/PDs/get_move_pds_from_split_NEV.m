close all
%% set params
    ts = 50;%binning size
    offset=-0.015; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead

%% load data
    folderpath='E:\processing\PDs\move PD\12092013\'
    fname='Kramer_12092013_RW_tucker_001.nev';
    savename=strcat(fname(1:end-3),'mat');
    


    foldercontents=dir(folderpath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    if isempty(strmatch( savename,fnames))
        disp(strcat('converting: ',fname))
        bdf=load_sorted_NEV_to_bdf(strcat(folderpath,fname));
        save( strcat(folderpath, fname(1:(length(fname)-3)), 'mat'), 'bdf','-v7.3')
    else
        load(strcat(folderpath,savename))
    end
%     disp(strcat('loading: ',fname))
%     load('E:\processing\Kramer_BD_02122013_tucker_no_stim_005-02.mat')

    %identify time vector for binning
    vt = bdf.vel(:,1);
    t = vt(1):ts/1000:vt(end);


%% compute PDs
    disp('computing PDs and plotting results')
    array_map_path='C:\Users\limblab\Desktop\kramer_array_map\6251-0922.cmp';
    [outdata,H_upper,H_lower]=PD_plot(bdf,array_map_path,2,1);
    
%% save data and print PD graphics to file    
    %get the date the files were collected:
    date_vector=get_date_from_filename('Kramer_',fname);
    
    
    save(strcat(folderpath,'PD_moddepth_data_',datestr(date_vector),'.txt'),'outdata','-ascii')
    print('-dpdf',H_upper,strcat(folderpath,'Upper_PD_plot_',datestr(date_vector),'.pdf'))
    print('-dpdf',H_lower,strcat(folderpath,'Lower_PD_plot_',datestr(date_vector),'.pdf'))
    