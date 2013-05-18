%%set params
    ts = 50;%binning size
    offset=-0.015; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead

%load data
    folderpath='E:\processing\move_PD\05012013\'
    fname='Kramer_RW_05012013_tucker_002-01.nev';
    savename=strcat(fname(1:end-3),'mat');
    
    foldercontents=dir(folderpath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    if isempty(strmatch( savename,fnames))
        disp(strcat('converting: ',fname))
        bdf=get_cerebus_data(strcat(folderpath,fname),3,'verbose','noeye');
        save(strcat(folderpath,savename),'bdf')
    else
        load(strcat(folderpath,savename))
    end
%     disp(strcat('loading: ',fname))
%     load('E:\processing\Kramer_BD_02122013_tucker_no_stim_005-02.mat')

    %identify time vector for binning
    vt = bdf.vel(:,1);
    t = vt(1):ts/1000:vt(end);



    disp('computing PDs and plotting results')
    array_map_path='C:\Users\limblab\Desktop\kramer_array_map\6251-0922.cmp';
    [outdata,H_upper,H_lower]=PD_plot(bdf,array_map_path,2,1);
    
    save(strcat(folderpath,'PD_moddepth_data.txt',outdata,'-ascii'))
    print('-dpdf',H_upper,strcat(folderpath,'Upper_PD_plot.pdf'))
    print('-dpdf',H_lower,strcat(folderpath,'Lower_PD_plot.pdf'))
    