function results = BC_newsome(filenames)
    results.sigmoid_fit_data = {};
    results.xthr = [];
    results.xthr_conf = [];
    results.thr_level = [];
    results.bumps_ordered = [];
    results.currents = [];
    results.electrodes = [];
    
    reward_code = 32;
    abort_code = 33;
    fail_code = 34;
    incomplete_code = 35;
    
    num_iter = 10;
    fit_func = 'a+b/(1+exp(x*c+d))';
    f_sigmoid = fittype(fit_func,'independent','x');
    f_opts = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1 -1 1 0]);

    trial_table_concat = [];
    for iFile = 1:length(filenames)
        load([filenames(iFile).datapath 'Processed\' filenames(iFile).name],'bdf','trial_table','table_columns')
        try
            bdf = rmfield(bdf,'units');
        end
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
    trial_table = trial_table_concat;
%     bdf.units = bdf_concat.units;
    
    trial_table = trial_table(trial_table(:,table_columns.result)~=abort_code,:);
    trial_table = trial_table(trial_table(:,table_columns.training)==0,:);
    
    % Stats sanity check!  Uncomment the following line to randomize the stim_ids
%     trial_table(:,table_columns.stim_id)  = trial_table(randperm(size(trial_table,1)),table_columns.stim_id);
    
    bump_magnitudes = unique(trial_table(:,table_columns.bump_magnitude));
    stim_ids = unique(trial_table(:,table_columns.stim_id));
    bump_directions = unique(trial_table(:,table_columns.bump_direction));
    reward_table = zeros(length(bump_directions),length(bump_magnitudes),length(stim_ids));
    fail_table = reward_table;
    codes_pds_electrodes = [filenames(1).codes; filenames(1).pd; filenames(1).electrodes];
    [tempa tempb] = sort(codes_pds_electrodes(3,:));
    codes_pds_electrodes = codes_pds_electrodes(:,tempb);
    
    stim_electrodes = unique(codes_pds_electrodes(3,:));
%     !CHECK STIM ELECTRODE ORDER!!!!
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
    num_sigmoids = length(stim_ids);
    if length(stim_electrodes)>1
        for iElectrodes = 1:length(stim_electrodes)
            reward_table_temp(:,:,iElectrodes) = sum(reward_table(:,:,stim_groups{iElectrodes}),3);
            fail_table_temp(:,:,iElectrodes) = sum(fail_table(:,:,stim_groups{iElectrodes}),3);
        end
        reward_table = reward_table_temp;
        fail_table = fail_table_temp;
        num_sigmoids = length(stim_electrodes);
        legend_text = stim_electrodes;
    else
        currents = unique(filenames(1).current);
        for iCurrent = 1:length(currents)
            current_groups{iCurrent} = filenames(1).codes(filenames(1).current == currents(iCurrent));
            reward_table_temp(:,:,iCurrent) = sum(reward_table(:,:,current_groups{iCurrent}),3);
            fail_table_temp(:,:,iCurrent) = sum(fail_table(:,:,current_groups{iCurrent}),3);
        end

        reward_table = reward_table_temp;
        fail_table = fail_table_temp;
        num_sigmoids = length(currents);
        legend_text = currents;
        
    end

    
%     %arbitrarily remove largest bump
%     reward_table = reward_table(:,1:end-1,:);
%     fail_table = fail_table(:,1:end-1,:);
%     bump_magnitudes = bump_magnitudes(1:end-1);
    
    if length(bump_directions)==2
        bump_dir1_move_target1 = reshape(fail_table(1,:,:),length(bump_magnitudes),num_sigmoids)';
        bump_dir2_move_target1 = reshape(reward_table(2,:,:),length(bump_magnitudes),num_sigmoids)';
        bump_dir1_move_target2 = reshape(reward_table(1,:,:),length(bump_magnitudes),num_sigmoids)';
        bump_dir2_move_target2 = reshape(fail_table(2,:,:),length(bump_magnitudes),num_sigmoids)';
        
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
%         figure;
%         hold on
%         
%         for iStim=1:length(stim_electrodes)
%             plot(bumps_reordered',percent_moved_target1(iStim,:),'Color',colors(round(iStim*64/length(stim_ids)),:),'LineStyle','.');
%            
%         end
%         
% 
%         for iStim=1:length(stim_electrodes)
%             sigmoid_fit = fit(bumps_reordered,percent_moved_target1(iStim,:)',f_sigmoid,f_opts);
%             h_temp = plot(sigmoid_fit);
%             set(h_temp,'LineWidth',2,'Color',colors(round(iStim*64/length(stim_ids)),:))
%         end

%         stim_electrodes
%         percent_moved_target1
%         moved_target1
%         moved_target2
        
        results = sigmoid_fit_bootstrap(moved_target1,moved_target2,bumps_reordered,num_iter);
        if exist('currents','var')
            results.currents = currents;
        else
            results.currents = [];
        end
        results.electrodes = stim_electrodes;
            
        legend([num2str(legend_text');'al'])
        xlabel('Bump magnitude [N]')
        ylabel('Move to target 1')
        ylim([0 1])
        title(strrep(filenames(1).name(1:end-4),'_',' '))
        text(bumps_reordered(2),0.9,{['Total trials: ' num2str(size(trial_table,1))];...
            ['Stimulated electrodes: ' num2str(unique(filenames(1).electrodes))];...
            ['Target 1 at ' num2str(180*bump_directions(1)/pi,3) '^o (' num2str(bump_directions(1),3) ' rad)']});
    end
        
end
    
    