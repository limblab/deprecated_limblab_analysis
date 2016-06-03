function PD_history=get_pd_history(folderpath)
    %returns a structure with the PD history for all folders in a specified
    %directory. PD history must be in files with names that include
    %'PD_moddepth_data_' and assumes that file names have the format: 
    %PD_moddepth_data_04-Apr-2013. Also assumes that files have at most 96
    %channels of data
    
    target_file_string='PD_moddepth_data_';
    
    %initialize PD_history
    PD_history.dates=[];
    for k=1:96
        PD_history.channel(k).moddepth=[];
        PD_history.channel(k).PD=[];
        PD_history.channel(k).CI=[];
    end
    
    foldercontents=dir(folderpath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    for i=3:length(fnames)
        %get the the PD data from the current folder
        local_files=dir(strcat(folderpath,'\',fnames{i}));
        local_filenames={local_files.name};
        local_index=strmatch(target_file_string,local_filenames);
        if ~isempty(local_index)
            disp(strcat('Attempting to load: ',folderpath,'\',fnames{i},'\',local_filenames{local_index}))
            data=load(strcat(folderpath,'\',fnames{i},'\',local_filenames{local_index}));
        else
            continue
        end
        %extract the date from the local file name
        local_date_string=local_filenames{local_index}(length(target_file_string)+1:end);
        local_date=datenum(local_date_string);
        %add the date of the current data to the list of dates:
        PD_history.dates=[PD_history.dates,local_date];
        
        %loop through channels and assign elements of the local data to the
        %output struct
        for j=1:96
            ind=find(data(:,1)==j);
            if(isempty(ind))
                %the current channel isn't in the local data
                PD_history.channel(j).moddepth  =[  PD_history.channel(j).moddepth, 0];
                PD_history.channel(j).PD        =[  PD_history.channel(j).PD,       0];
                PD_history.channel(j).CI        =[  PD_history.channel(j).CI,       0];
                
%                 if j==1
%                 disp(strcat('data index: ',num2str(ind)))
%                 disp('should be adding 0 to moddepth vector')
%                 disp(PD_history.channel(j).moddepth)
%                 end
            else
                PD_history.channel(j).moddepth  =[  PD_history.channel(j).moddepth, data(ind,3)];
                PD_history.channel(j).PD        =[  PD_history.channel(j).PD,       data(ind,2)];
                PD_history.channel(j).CI        =[  PD_history.channel(j).CI,       data(ind,4)];
%                 if j==1
%                 disp(strcat('data index: ',num2str(ind)))
%                 disp(strcat('moddepth: ',num2str(data(ind,3))))
%                 disp(PD_history.channel(j).moddepth)
%                 end
            end
            
            
        end
    end
end