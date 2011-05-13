function BC_newsome(filenames)
    reward_code = 32;
    abort_code = 33;
    fail_code = 34;
    incomplete_code = 35;
    
    fit_func = 'a+b/(1+exp(x*c+d))';
    f_sigmoid = fittype(fit_func,'independent','x');

    trial_table_concat = [];
    for iFile = 1:length(filenames)
        load([filenames(iFile).datapath 'Processed\' filenames(iFile).name],'bdf','trial_table','table_columns')
        bdf_all(iFile) = bdf;
        table_columns_all{iFile} = table_columns;
        end_time(iFile) = bdf.pos(end,1);
        if iFile>1
            trial_table(:,[table_columns.cursor_on_ct table_columns.start...
                table_columns.bump_time table_columns.end]) = ...
                trial_table(:,[table_columns.cursor_on_ct table_columns.start...
                table_columns.bump_time table_columns.end]) + sum(end_time(1:iFile-1));
            bdf_concat.pos = [bdf_concat.pos ; [bdf.pos(:,1)+sum(end_time(1:iFile-1)) bdf.pos(:,2:3)]];
            bdf_concat.vel = [bdf_concat.vel ; [bdf.vel(:,1)+sum(end_time(1:iFile-1)) bdf.vel(:,2:3)]];
        else
            bdf_concat.pos = bdf.pos;
            bdf_concat.vel = bdf.vel;
        end
        trial_table_concat = [trial_table_concat; trial_table];
    end
    % concatenate datafiles
%     for i=1:length(bdf.units)
%         bdf_concat.units(i).id = bdf(1).units(i).id;
%         bdf_concat.units(i).ts = bdf(1).units(i).ts;
%         for iFile = 2:length(filenames)
%             bdf_concat.units(i).ts = [bdf_concat.units(i).ts; bdf_all(iFile).units(i).ts + sum(end_time(1:iFile-1))];
%         end
%     end
%     trial_table = trial_table_concat;
%     bdf.units = bdf_concat.units;
    
    trial_table = trial_table(trial_table(:,table_columns.result)~=abort_code,:);
    trial_table = trial_table(trial_table(:,table_columns.training)==0,:);
    
    bump_magnitudes = unique(trial_table(:,table_columns.bump_magnitude));
    stim_ids = unique(trial_table(:,table_columns.stim_id));
    bump_directions = unique(trial_table(:,table_columns.bump_direction));
    reward_table = zeros(length(bump_directions),length(bump_magnitudes),length(stim_ids));
    fail_table = reward_table;
    codes_pds_electrodes = [filenames(1).codes; filenames(1).pd; filenames(1).electrodes];
    [tempa tempb] = sort(codes_pds_electrodes(3,:));
    codes_pds_electrodes = codes_pds_electrodes(:,tempb);
    
    stim_electrodes = unique(codes_pds_electrodes(3,:));
    !CHECK STIM ELECTRODE ORDER!!!!
    for iElectrodes = 1:length(stim_electrodes)
        stim_groups{iElectrodes} = codes_pds_electrodes(1,codes_pds_electrodes(3,:)==stim_electrodes(iElectrodes));
    end
    for iDir = 1:length(bump_directions)
        for iBumpMag = 1:length(bump_magnitudes)
            for iStim = 1:length(stim_ids)
    %             trial_indexes{iBumpMag,iStim} = find(trial_table(:,table_columns.stim_id)==stim_ids(iStim) &...
    %                 trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(iBumpMag) &...
    %                 trial_table(:,table_columns.bump_time)>0);
                trial_indexes_temp = find(trial_table(:,table_columns.stim_id)==stim_ids(iStim) &...
                    trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(iBumpMag) &...
                    trial_table(:,table_columns.bump_direction)==bump_directions(iDir));
                trial_indexes{iDir,iBumpMag,iStim} = trial_indexes_temp;
                reward_table(iDir,iBumpMag,iStim) = sum(trial_table(trial_indexes_temp,table_columns.result)==reward_code);
                fail_table(iDir,iBumpMag,iStim) = sum(trial_table(trial_indexes_temp,table_columns.result)==fail_code);
            end
        end
    end
    
    for iElectrodes = 1:length(stim_electrodes)
        reward_table_temp(:,:,iElectrodes) = sum(reward_table(:,:,stim_groups{iElectrodes}),3);
        fail_table_temp(:,:,iElectrodes) = sum(fail_table(:,:,stim_groups{iElectrodes}),3);
    end
    reward_table = reward_table_temp;
    fail_table = fail_table_temp;
    
%     %arbitrarily remove largest bump
%     reward_table = reward_table(:,1:end-1,:);
%     fail_table = fail_table(:,1:end-1,:);
%     bump_magnitudes = bump_magnitudes(1:end-1);
    
    if length(bump_directions)==2
        bump_dir1_move_target1 = squeeze(fail_table(1,:,:))';
        bump_dir2_move_target1 = squeeze(reward_table(2,:,:))';
        bump_dir1_move_target2 = squeeze(reward_table(1,:,:))';
        bump_dir2_move_target2 = squeeze(fail_table(2,:,:))';
        
        moved_target1 = [bump_dir1_move_target1(:,end:-1:1) bump_dir2_move_target1]; 
        temp = moved_target1(:,end/2) + moved_target1(:,end/2+1);
        moved_target1 = [moved_target1(:,[1:end/2-1]) ...
            temp moved_target1(:,[end/2+2:end])];
        
        moved_target2 = [bump_dir1_move_target2(:,end:-1:1) bump_dir2_move_target2]; 
        temp = moved_target2(:,end/2) + moved_target2(:,end/2+1);
        moved_target2 = [moved_target2(:,[1:end/2-1]) ...
            temp moved_target2(:,[end/2+2:end])];
        
        percent_moved_target1 = moved_target1./(moved_target1+moved_target2);
       
        bumps_reordered = [-bump_magnitudes(end:-1:2); bump_magnitudes];

%         bump_magnitudes_rearranged = 
        colors = jet;
        figure;
        hold on
        
        for iStim=1:length(stim_electrodes)
            plot(bumps_reordered',percent_moved_target1(iStim,:),'Color',colors(round(iStim*64/length(stim_ids)),:),'LineStyle','.');
           
        end
        
        for iStim=1:length(stim_electrodes)
            sigmoid_fit = fit(bumps_reordered,percent_moved_target1(iStim,:)',f_sigmoid);
            h_temp = plot(sigmoid_fit);
            set(h_temp,'LineWidth',2,'Color',colors(round(iStim*64/length(stim_ids)),:))
        end
            
        legend(num2str(stim_electrodes'))
        xlabel('Bump magnitude [N]')
        ylabel('Move to target 1')
        ylim([0 1])
    end
    
end
    
    