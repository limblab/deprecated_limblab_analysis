function [figure_list,data_struct]=compute_generic_stability_metrics(fpath,input_data)

    foldercontents=dir(fpath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    file_list=' ';
    savefolder=strcat(fpath,'\Output_data\');
    data_struct.units=[];
    data_struct.num_units=[];
    data_struct.unit_SNR=[];
    data_struct.num_changed=[];
    units=[];
    all_units=[];
    num_units=[];
    unit_SNR=[];
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
            
            if strcmp(tempext,'.nev') 
                ctr=ctr+1;
                file_list=strcat(file_list, ', ', temppath);
                if isempty(strmatch( strcat( fpath,tempname, '.mat'),fnames))
                    %if we haven't found a .mat file to match the .nev then make
                    %one
                    
                    disp(strcat('Working on: ',temppath, tempname,tempext))
                    try
%                         bdf=get_cerebus_data( temppath,labnum,'verbose','noeye');
                        bdf = get_nev_mat_data(cerebus2NEVNSx(tempfolder,tempname),input_data.labnum,'verbose','noeye');
                                                
                        disp(strcat('Saving: ',strcat(savefolder, tempname, '.mat')))
                        save( strcat(savefolder, tempname, '.mat'), 'bdf','-v7.3')
                        
                        file_list=strcat(file_list,tempname);
                        units{ctr}=unit_list(bdf);
                        all_units{ctr}=unit_list(bdf,1);
                        num_units(ctr)=length(units{ctr});
                        [R,C]=size(units{ctr});
                        unit_SNR{ctr}=-1*ones(R,1);
                        for j=1:num_units(ctr)%for each unit in this bdf
                            %find the index of that unit
                            try
                                for k = 1:length(bdf.units)
                                    if all(bdf.units(k).id == units{ctr}(j,:))
                                        u = k;
                                        break
                                    end
                                end
                            catch
                                error('Specified unit does not exist in bdf.');
                            end
                            amp=max(bdf.units(u).waveforms)-min(bdf.units(u).waveforms);
                            s=var(double(amp));
                            %find noise units on that channel 
                            u2=units(units{ctr}(:,1)==units{ctr}(j,1) & units{ctr}(:,2)==0);
                            amp2=max(bdf.units(u).waveforms)-min(bdf.units(u).waveforms);
                            n=var(double(amp2));
                            unit_SNR{ctr}(j)=s/n;
                        end                        
                        data_struct.units=units;
                        data_struct.num_units=num_units;
                        data_struct.unit_SNR=unit_SNR;
                    catch temperr %catches the error in a MException class object called temperr
                        disp(strcat('Failed to process: ', fpath,tempname))
                        disp(temperr.identifier)
                        disp(temperr.message)
                    end
                else
                    %load the mat file
                end
            end
        
            
        end
    end
    num_changed=zeros(length(unit_SNR),1);
    for i=1:length(unit_SNR)-1
        for j=1:length(units{i})
            %see if unit j exists in the next data set. If we lost that
            %unit, incriment the counter
            if ~find(units{i+1}(:,1)==units{i}(j,1) & units{i+1}(:,2)==units{i}(j,2))
                num_changed(i)=num_changed(i)+1;
            end
            %add how many new units were found
            num_changed(i)=num_changed(i)+length(units{i+1})-(length(units{i})-num_changed(i));
        end
        
    end
    data_struct.num_changed=num_changed;
    data_struct.file_list=file_list;
    
    figure_list=[];
end