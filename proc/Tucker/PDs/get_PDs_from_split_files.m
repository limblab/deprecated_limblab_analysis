%script to load neural data cleaned in offline sorter and merge with
%digital data from the original file. looks for the key text '_NODIGITAL'
%in the file name and uses the preceding text to find the original file
%name. i.e. if the file name is 'FILENAME_NODIGITAL_01.nev' the script will
%look for 'FILENAME.nev' to find the kinematic data

folderpath='E:\processing\PDs\10242013\';
fname='Kramer_RW_10242013_tucker_001_NODIGITAL-01.nev';
array_map_path='C:\Users\limblab\Desktop\kramer_array_map\6251-0922.cmp';

foldercontents=dir(folderpath);
fnames={foldercontents.name};%extracts just the names from the foldercontents

%find the original file:
endloc=strfind(fname,'_NODIGITAL')-1;
fname_original=[fname(1:endloc),'.nev'];
if isempty(strmatch( fname_original,fnames))
    disp(strcat('file: ',fname_original,' not found'))
    disp('Script exiting without loading any data')
else
    NEVNSx=load_NEVNSX_object([folderpath,fname_original]);
    NEV_nodigital=openNEV('read', [folderpath, fname],'nosave','nomat','report');
    NEVNSx.NEV.Data.Spikes=NEV_nodigital.Data.Spikes;
    clear NEV_nodigital
    bdf=get_nev_mat_data(NEVNSx);
    savename=[folderpath, fname_original(1:end-3), 'mat'];
    save(savename,'bdf','-v7.3')
    [outdata,H_upper,H_lower]=PD_plot(bdf,array_map_path,2,1);
    %re-size our two main figures
    ss=get(0,'ScreenSize');
    ss(4)=1000;
    figure(H_upper);
    set(H_upper,'OuterPosition',ss) 
    figure(H_lower);
    set(H_lower,'OuterPosition',ss) 

    %get the date the files were collected:
    date_vector=get_date_from_filename('Kramer_',fname);

    save(strcat(folderpath,'PD_moddepth_data_',datestr(date_vector),'.txt'),'outdata','-ascii')
    print('-dpdf',H_upper,strcat(folderpath,'Upper_PD_plot_',datestr(date_vector),'.pdf'))
    print('-dpdf',H_lower,strcat(folderpath,'Lower_PD_plot_',datestr(date_vector),'.pdf'))
    close all

end