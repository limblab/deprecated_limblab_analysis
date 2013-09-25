%script to reprocess all the move PD's in a directory. Directory structure
%should be a single main folder with a sub-folder for each day of data. The
%function will look in each sub-folder for an .nev file and use that to
%compute the PD's

%set main directory path
    base_folderpath='E:\processing\move_PD\to be processed\';
%%set params
    ts = 50;%binning size
    offset=-0.015; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead
        
    
    %get the list of folders in the current directory
    foldercontents=dir(base_folderpath);
    fnames={foldercontents.name};
    is_dir=cell2mat({foldercontents.isdir});
    
%load data
for i=3:length(fnames)
    if is_dir(i)
        folderpath=strcat(base_folderpath,fnames{i},'\');
        disp(strcat('Working on folder: ',folderpath));
        locallist=dir(folderpath);
        localnames={locallist.name};
        %find .nev files:
        local_datafiles=~cellfun(@isempty,strfind(localnames,'.nev'));
        if sum(local_datafiles)>1
            warning('process_move_PDs:MoreThanOneNev',strcat('Found more than one .nev file in folder. will only operate on the first file in this folder'))
        elseif sum(local_datafiles)==0
            warning('process_move_PDs:NoNevFound',strcat('Found no .nev file. will continue skipping this folder'))
            continue
        end
        local_fild_index=find(local_datafiles,1,'first');
        fname=localnames{local_fild_index};
        savename=strcat(fname(1:end-3),'mat');

        if isempty(strmatch(savename,localnames))
            disp(strcat('converting: '))
            disp(strcat(folderpath,fname))
            bdf=get_cerebus_data(strcat(folderpath,fname),3,'verbose','noeye');
            save(strcat(folderpath,savename),'bdf')
        else
            disp(strcat('loading: '))
            disp(strcat(folderpath,fname))
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
end