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
    full_session_path = dir([fpath 'Output_data' filesep 'full_session.mat']);
    
    if ~isempty(session_path)
        warning('quickscript_function_looped:FoundSessionData','Loading session from file. Remove session.mat from the Output_data folder to load individual files')
        disp(['opening: ' fpath,'Output_data',filesep,session_path.name])
        load([fpath,'Output_data',filesep,session_path.name])
        data_struct.session=session;
        load([fpath,'Output_data',filesep,full_session_path.name])
        data_struct.full_session=full_session;
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
                if ((strcmp(tempext,'.mat') | strcmp(tempext,'.nev')| strcmp(tempext,'.plx')) & ~isempty(strfind(tempname,input_data.matchstring)))
                    file_list{end+1}=temppath;
                    ind=ind+1;
                    try
                        %load the bdf from the current file:
                        disp(strcat('Working on: ',temppath))
                        if (strcmp(tempext,'.mat'))
                            load(temppath);%loads a variable named bdf from the file
                        elseif strcmp(tempext,'.nev')
                            bdf=get_nev_mat_data(cerebus2NEVNSx(tempfolder,tempname),input_data.labnum,'verbose','noeye');
                        elseif strcmp(tempext,'.plx')
                            bdf=get_plexon_data(temppath,input_data.labnum,'verbose','noeye');
                        else
                            disp('how did we get here? this should be impossible')
                            error('get_neuron_matching:somethingsWrong','Something is Wrong')
                        end
                        bdf.raw=[];     
                        data_struct.full_session{ind}.bdf = bdf;
                        bdf.pos=[];
                        bdf.vel=[];
                        bdf.acc=[];                   
                        bdf.force=[];
                        bdf.words=[];
                        data_struct.session{ind}.bdf = bdf;
                        clear bdf
                        %get the mean waveshape for every unit and append to
                        %bdf.units
                        for j=1:length(data_struct.session{ind}.bdf.units)
                            data_struct.full_session{ind}.bdf.units(j).wave=mean(data_struct.full_session{ind}.bdf.units(j).waveforms);
                            data_struct.full_session{ind}.bdf.units(j).wave(2,:)=std(double(data_struct.full_session{ind}.bdf.units(j).waveforms));
                            data_struct.session{ind}.bdf.units(j).wave=mean(data_struct.session{ind}.bdf.units(j).waveforms);
                            data_struct.session{ind}.bdf.units(j).wave(2,:)=std(double(data_struct.session{ind}.bdf.units(j).waveforms));
                        end
                        %get the spiking distribution
                        data_struct.full_session{ind}.units=spiketrains(data_struct.session{ind}.bdf,1);
                        data_struct.session{ind}.units=spiketrains(data_struct.session{ind}.bdf,1);
                        %put the bdf and the spiking distribution into our
                        %session variable:
                    catch temperr
                        disp(strcat('Failed to process: ', temppath))
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
    opts.use_shape=1;
    opts.use_ISI=0;
    data_struct.COMPS = KS_p(data_struct.session,0.0025,opts);  % 'COMPS' might be a bit confusing. Just ask...

    %% get list of units that are present on all days. Will have a different list for each day since the unit number may change across days
    for i=1:length(data_struct.session)
        data_struct.session{i}.StableUnitIds=squeeze(data_struct.COMPS{1}.chan((3==sum((0<data_struct.COMPS{1,1}.inds(:,:)),2)),i,:));
        data_struct.full_session{i}.StableUnitIds= data_struct.session{i}.StableUnitIds;
    end
    
    for i=1:length(data_struct.session)
        data_struct.session{i}.StableUnits=zeros(size(data_struct.session{i}.StableUnitIds,1),1);
        data_struct.full_session{i}.StableUnits=zeros(size(data_struct.session{i}.StableUnitIds,1),1);
        for k=1:size(data_struct.session{i}.StableUnitIds,1)
            j=find_unit(data_struct.session{i}.bdf,data_struct.session{i}.StableUnitIds(k,:));
            data_struct.session{i}.StableUnits(k)=j;
            data_struct.full_session{i}.StableUnits(k)=j;
        end
    end
    %% tag all stable units in bdf.unis with a tracking index so we know which ones match across the different days in each session
    for j=1:length(data_struct.session)
        for i=1:length(data_struct.session{j}.StableUnits)
            data_struct.session{j}.bdf.units(data_struct.session{j}.StableUnits(i)).tracking_index=i;
            data_struct.full_session{j}.bdf.units(data_struct.session{j}.StableUnits(i)).tracking_index=i;
        end
    end
    %% build session where each bdf only includes data for the stable units
    data_struct.stable_session=data_struct.full_session;
    for i=1:length(data_struct.stable_session)
        data_struct.stable_session{i}.bdf.units=data_struct.stable_session{i}.bdf.units(data_struct.stable_session{i}.StableUnits);
    end
end