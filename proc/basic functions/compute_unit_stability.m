function [figure_list,data_struct]=compute_unit_stability(fpath,input_data)
    %required fields in the input_data struct:
    %num_channels   the number of channels in the array. This is a
    %               workaround till I can implement something that actually
    %               looks at the data to see how many channels are in the
    %               files loaded
    %min_moddepth   the minimum modulation depth to consider a unit when
    %               computing the number of units and change in number of
    %               units
    foldercontents=dir(fpath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    file_list=' ';
    savefolder=strcat(fpath,'\Output_data\');
    data_struct.num_units=[];
    data_struct.num_changed=[];
    ctr=0;
    for i=1:length(foldercontents)
        if (length(fnames{i})>3)
        
            %skip things that aren't files
            if exist(strcat(fpath,fnames{i}),'file')~=2
                continue
            end
            %generate a new path to the source file of shortcuts
            temppath=follow_links(strcat(fpath,fnames{i}));
            [tempfolder,tempname,tempext]=fileparts(temppath);
            
            if strcmp(tempext,'.mat') 
                disp(strcat('Working on: ',temppath))
                ctr=ctr+1;
                file_list=strcat(file_list, ', ', temppath);
                try
                    disp('loading pd dataset from from file')
                    temp=load(temppath);
                    if length(fieldnames(temp))==1
                        fields=fieldnames(temp);    
                        pd_table=temp.(fields{1});
                    elseif isempty(fieldnames(temp))
                        error(['compute_generic_stability_metrics:NoVariableInFile'],['Tried to load' temppath 'but found no variables in the file'])
                    else
                        error(['compute_generic_stability_metrics:MultipleVariableInFile'],['Tried to load' temppath 'but found multiple variables in the file'])
                    end
                    data_struct.all_pds{ctr}=pd_table;
                    file_list=strcat(file_list,tempname);
                catch temperr
                    disp(strcat('Failed to process: ', fpath,tempname))
                    disp(temperr.identifier)
                    disp(temperr.message)
                end

            end
        end
    end
    
    %now that we have loaded all the files, find the number of units on
    %each channel each day:
    data_struct.num_units=zeros(input_data.num_channels,length(data_struct.all_pds));
    for i=1:length(data_struct.all_pds)
        for j=1:input_data.num_channels
            data_struct.num_units(j,i)=length(find(data_struct.all_pds{i}.channel==j & data_struct.all_pds{i}.moddepth>input_data.min_moddepth ));
        end
    end

    %compute the change on each
    %channel:
    data_struct.num_changed=diff(data_struct.num_units')';

    data_struct.file_list=file_list;
    
    figure_list=[];
end