function [figure_list,data_struct]=get_neuron_matching(fpath,input_data)
    %%
    % NOTE: To export the waveform data in offline sorter:
    % File -> Export Per-Unit Data
    %
    % Select *Matlab file*
    %        *All CHannels into one file*
    %
    % Add Channel, Unit Number, and Number of Waveforms to the right-hand column
    % Select *Also Append Template Std Dev Data*

    %% build a cell array 'session'
    figure_list=[];
    foldercontents=dir(fpath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    session_path = dir([fpath 'Output_data' filesep 'session.mat']);
    if ~isempty(session_path)
        warning('quickscript_function_looped:FoundSessionData','Loading session from file. Remove session.mat from the Output_data folder to load individual files')
        disp(['opening: ' fpath,'Output_data',filesep,session_path.name])
        load([fpath,'Output_data',filesep,session_path.name])
        data_struct.session=session;
        clear session
    else
        file_list={};
        data_struct.session={};
        ind=0;
        for i=1:length(foldercontents)
            if (length(fnames{i})>3)
                if exist(strcat(fpath,fnames{i}),'file')~=2
                    continue
                end
                temppath=follow_links(strcat(fpath,fnames{i}));
                [tempfolder,tempname,tempext]=fileparts(temppath);
                if (strcmp(tempext,'.mat') & ~isempty(strfind(tempname,input_data.matchstring)))
                    file_list{end+1}=temppath;
                    ind=ind+1;
                    try
                        %load the bdf from the current file:
                        disp(strcat('Working on: ',temppath))
                        load(temppath);%loads a variable named bdf from the file
                        data_struct.session{ind}.bdf = bdf;
                        clear bdf
                        %get the mean waveshape for every unit and append to
                        %bdf.units
                        for j=1:length(data_struct.session{ind}.bdf.units)
                            data_struct.session{ind}.bdf.units(j).wave=mean(data_struct.session{ind}.bdf.units(j).waveforms);
                            data_struct.session{ind}.bdf.units(j).wave(2,:)=std(double(data_struct.session{ind}.bdf.units(j).waveforms));
                        end
                        %get the spiking distribution
                        data_struct.session{i}.units=spiketrains(data_struct.session{ind}.bdf,1);
                        %put the bdf and the spiking distribution into our
                        %session variable:
                    catch temperr
                        disp(strcat('Failed to process: ', temppath,filesep,tempname))
                        disp(temperr.identifier)
                        disp(temperr.message)
                        for k=1:length(temperr.stack)
                            disp(['in function: ',temperr.stack(k).name])
                            disp(['on line: ',num2str(temperr.stack(k).line)])
                        end
                    end
                end
            end
        end
        
    end
    

    %% Do comparisons
    COMPS = KS_p(data_struct.session,0.0025);  % 'COMPS' might be a bit confusing. Just ask...
    data_struct.COMPS=COMPS;
end