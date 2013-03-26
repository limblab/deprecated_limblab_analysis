function bdf_all = concatenate_bdfs(datapath,filenames)
    
for iFile = 1:length(filenames)   
    disp(['Concatenating BDFs, file: ' num2str(iFile) ' of ' num2str(length(filenames))])
    filename_no_ext = filenames(iFile).name(1:end-4);
    if ~exist([datapath '\' filename_no_ext '.mat'])
        bdf = get_cerebus_data([datapath '\' filenames(iFile).name],3);    
        save([datapath '\' filename_no_ext],'bdf');        
    else
        load([datapath '\' filename_no_ext],'bdf');        
    end
    bdf_temp = bdf;    

    if iFile == 1
        bdf_all = bdf;        
    else        
        old_end_time = bdf_all.pos(end,1);       
       
        bdf_temp.words(:,1) = bdf_temp.words(:,1) + old_end_time;
        bdf_all.words = [bdf_all.words ; bdf_temp.words];
        bdf_temp.pos(:,1) = bdf_temp.pos(:,1) + old_end_time;
        bdf_all.pos = [bdf_all.pos ; bdf_temp.pos];
        bdf_temp.vel(:,1) = bdf_temp.vel(:,1) + old_end_time;
        bdf_all.vel = [bdf_all.vel ; bdf_temp.vel];
        bdf_temp.acc(:,1) = bdf_temp.acc(:,1) + old_end_time;
        bdf_all.acc = [bdf_all.acc ; bdf_temp.acc];
        bdf_temp.force(:,1) = bdf_temp.force(:,1) + old_end_time;
        bdf_all.force = [bdf_all.force ; bdf_temp.force];
        for iTrial = 1:size(bdf_temp.databursts,1)
            bdf_temp.databursts{iTrial,1} = bdf_temp.databursts{iTrial,1} + old_end_time;
        end
        bdf_all.databursts = [bdf_all.databursts; bdf_temp.databursts];
        for iUnit = 1:size(bdf_all.units,2)
            unit_id = bdf_all.units(iUnit).id;
            temp_units = reshape([bdf_temp.units.id],2,[])';
            [~,~,unit_idx] = intersect(unit_id,temp_units,'rows');
            if ~isempty(unit_idx)
                bdf_all.units(iUnit).ts = [bdf_all.units(iUnit).ts ; bdf_temp.units(unit_idx).ts + old_end_time];
            else
                warning('Neuron dropped from recording') %#ok<WNTAG>
            end
        end
        
        bdf_temp.emg.data(:,1) = bdf_temp.emg.data(:,1) + old_end_time;
        bdf_all.emg.data = [bdf_all.emg.data ; bdf_temp.emg.data]; 
    end    
end