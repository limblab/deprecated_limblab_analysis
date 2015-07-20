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
    aggregate_bdf = dir([fpath 'Output_data' filesep 'aggregate_bdf.mat']);
    if ~isempty(aggregate_bdf)
        warning('quickscript_function_looped:FoundAggregateBDF','Loading aggregate bdf. Remove aggregate_bdf.mat from the folder to load individual files')
        disp(['opening: ' fpath,'Output_data',filesep,aggregate_bdf.name])
        load([fpath,'Output_data',filesep,aggregate_bdf.name])
        bdf=aggregate_bdf;
        clear aggregate_bdf;
    else
        file_list={};
        bdf_list={};
        for i=1:length(foldercontents)
            if (length(fnames{i})>3)
                if exist(strcat(fpath,fnames{i}),'file')~=2
                    continue
                end
                temppath=follow_links(strcat(fpath,fnames{i}));
                [tempfolder,tempname,tempext]=fileparts(temppath);
                if (strcmp(tempext,'.mat') & ~isempty(strfind(tempname,input_data.matchstring)))
                    file_list{end+1}=temppath;
                    try
                        %load the bdf from the current file:
                        disp(strcat('Working on: ',temppath))
                        load(temppath);%loads a variable named bdf from the file
                        session{ind}.bdf = bdf;
                        clear bdf
                        %get the mean waveshape for every unit and append to
                        %bdf.units
                        for j=1:length(bdf.units)
                            session{ind}.bdf.units(j).wave=mean(bdf.units(j));
                            session{ind}.bdf.units(j).wave(2,:)=stdev(bdf.units(j));
                        end
                        %get the spiking distribution
                        session{i}.units=spiketrains(bdf,1);
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
        if length(bdf_list)==1
            bdf=bdf_list{1};
            clear bdf_list
        else
            for i=1:length(bdf_list)
                if i==1
                    %initialize the aggregate bdf
                    bdf=bdf_list{i};
                else
                    %if our new bdf already has something in it, append to
                    %the end of the new bdf
                    bdf=concatenate_bdfs(  bdf,   bdf_list{i},    30,     0,   0, 0);%concatenate bdfs with no kinematics, no units and no force
                end
            end
        end
        bdf.meta.task='BC';
    end
    if ~isfield(bdf,'TT')
        [bdf.TT,bdf.TT_hdr]=bc_trial_table4(bdf);
    end
    data_struct.session=session;

    %% Do comparisons
    COMPS = KS_p(session,0.0025);  % 'COMPS' might be a bit confusing. Just ask...
    data_struct.COMPS=COMPS;
end