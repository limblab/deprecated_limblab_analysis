function BC_psychophysics(filelist)

boot_iter = 1000;

reward_code = 32;
abort_code = 33;
fail_code = 34;
incomplete_code = 35;

for file_no = 1:length(filelist)
    disp(['File number: ' num2str(file_no) ' of ' num2str(length(filelist))])
    filename = filelist(file_no).name;
    stim_pds = filelist(file_no).pd;
    stim_duration = filelist(file_no).period.*filelist(file_no).pulses;
    bump_duration = filelist(file_no).bump_duration/1000;
    serverdatapath = filelist(file_no).serverdatapath;    
        
    load([filelist(file_no).datapath 'Processed\' filename],'trial_table','bdf','table_columns')
    
    trial_table(trial_table(:,table_columns.stim_id)==16,table_columns.stim_id) = -1;

    trial_table = trial_table(trial_table(:,table_columns.bump_time)~=0,:);
    
    trial_table(trial_table(:,table_columns.bump_and_stim)==0 & trial_table(:,table_columns.stim_id) ~= -1,...
        table_columns.bump_magnitude) = 0;
    trial_table(trial_table(:,table_columns.bump_and_stim)==0 & trial_table(:,table_columns.stim_id) ~= -1,...
        table_columns.bump_time) = 0;
    
    %remove training trials
    trial_table = trial_table(trial_table(:,table_columns.training)==0,:);
    
    fit_func = 'm*x+b';
    f_linear = fittype(fit_func,'independent','x');

    response_time = trial_table(:,table_columns.end)-trial_table(:,table_columns.start);

    correct = trial_table(:,table_columns.result)==reward_code;
    [correct_fit fit_stats] = fit(trial_table(:,table_columns.start),correct,f_linear);
    percentage_rewards = sum(trial_table(:,table_columns.result)==reward_code)/length(trial_table) 
    percentage_aborts =  sum(trial_table(:,table_columns.result)==abort_code)/length(trial_table) 
    percentage_incompletes = sum(trial_table(:,table_columns.result)==incomplete_code)/length(trial_table) 
    percentage_fails = sum(trial_table(:,table_columns.result)==fail_code)/length(trial_table) 
    fails = trial_table(:,table_columns.result)==fail_code;
    
    num_outer_targets = max(trial_table(:,table_columns.num_outer_targets));
    
    if length(correct)>=100
        correct_moving_ave = zeros(1,length(correct)-50);
        for i=1:length(correct_moving_ave)
            correct_moving_ave(i) = mean(correct(i:i+50));
        end
        bin_size = 20;
        num_bins = floor(length(correct)/bin_size);
        correct_binned = zeros(num_bins,bin_size);
        correct_bootstrapped = zeros(num_bins,bin_size,boot_iter);
        for i=1:num_bins
            correct_binned_temp = correct((i-1)*bin_size+1:i*bin_size);
            correct_binned(i,:) = correct_binned_temp;
            correct_bootstrapped(i,:,:) = correct_binned_temp(ceil(length(correct_binned_temp)*rand(length(correct_binned_temp),boot_iter)));
        end
        correct_percent_bootstrapped = squeeze(mean(correct_bootstrapped,2));
        correct_binned_fit = fit((1:num_bins)',mean(correct_binned,2),f_linear,'StartPoint',[0 0]);
        fit_binned_conf = confint(correct_binned_fit);
        correct_moving_ave_fit = fit((1:length(correct_moving_ave))',correct_moving_ave',f_linear,'StartPoint',[0 0]);
        fit_moving_conf = confint(correct_moving_ave_fit);

        %%
        figure_behavior = figure; 
        subplot(1,2,1)
        plot(1:length(correct_moving_ave),correct_moving_ave)
        hold on
        plot(correct_moving_ave_fit,'r')
        plot(1:length(correct_moving_ave),(1:length(correct_moving_ave))*fit_moving_conf(1,2)+fit_moving_conf(1,1),'-r');
        plot(1:length(correct_moving_ave),(1:length(correct_moving_ave))*fit_moving_conf(2,2)+fit_moving_conf(2,1),'-r');
        xlim([1 length(correct_moving_ave)])
        ylim([0 1])
        ylabel('Percent correct')
        xlabel('Trial number (moving average)')
        title_temp = filelist(file_no).name;
        title_temp = strrep(title_temp,'_','\_');
        title(title_temp)
        legend off
              
        first_hundred(file_no) = sum(correct(1:100));
        last_hundred(file_no) = sum(correct(end-99:end));

        subplot(1,2,2)
        hold on
        plot(1:num_bins,mean(correct_binned,2))
        plot(correct_binned_fit,'r')
        plot(1:num_bins,(1:num_bins)*fit_binned_conf(1,2)+fit_binned_conf(1,1),'-r');
        plot(1:num_bins,(1:num_bins)*fit_binned_conf(2,2)+fit_binned_conf(2,1),'-r');       
        xlim([1 num_bins])
        ylim([0 1])
        xlabel('Bin number')
        ylabel('Percent correct')
        legend off
    end
        
%% Rewards/incompletes as a function of bump magnitude/stim id

    movement_time = [trial_table(:,table_columns.cursor_on_ct) trial_table(:,table_columns.end)]-...
        repmat(trial_table(:,table_columns.start),1,2);
    bump_magnitudes = unique(trial_table(:,table_columns.bump_magnitude));
    stim_ids = unique(trial_table(:,table_columns.stim_id));
    for iBump = 1:length(bump_magnitudes)
        for iStim = 1:length(stim_ids)
%             trial_indexes{iBump,iStim} = find(trial_table(:,table_columns.stim_id)==stim_ids(iStim) &...
%                 trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(iBump) &...
%                 trial_table(:,table_columns.bump_time)>0);
            trial_indexes{iBump,iStim} = find(trial_table(:,table_columns.stim_id)==stim_ids(iStim) &...
                trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(iBump));
        end
    end
    
    colors = colormap(jet);
    colors = colors(1:round(length(colors)/length(stim_ids)):end,:);
    
     for iBump = 1:length(bump_magnitudes)
        for iStim = 1:length(stim_ids)
            rewards_incompletes(iBump,iStim,:) = [sum(trial_table(trial_indexes{iBump,iStim},table_columns.result)==reward_code) ...
                sum(trial_table(trial_indexes{iBump,iStim},table_columns.result)==incomplete_code)];
            rewards_fails(iBump,iStim,:) = [sum(trial_table(trial_indexes{iBump,iStim},table_columns.result)==reward_code) ...
                sum(trial_table(trial_indexes{iBump,iStim},table_columns.result)==fail_code)];
        end
     end
    if num_outer_targets==1
        rewards_incompletes
    else
        rewards_fails
    end
    
    if length(bump_magnitudes)>1
        figure;
        plot(bump_magnitudes,rewards_incompletes(:,:,1)./sum(rewards_incompletes,3))
        legend(['Stim ' num2str(stim_ids(1))],['Stim ' num2str(stim_ids(2))])
        ylim([0 1])
        xlabel('Bump magnitude (N)')
        ylabel('Rewards/(Rewards+Incompletes)')
        title_temp = filelist(file_no).name;
        title_temp = strrep(title_temp,'_','\_');
        title(title_temp)    
    end
    
%% stim psychophysics plot
    stim_rewards_incompletes = sum(rewards_incompletes,1);
    stim_rewards_incompletes = squeeze(stim_rewards_incompletes)';
    
    stim_rewards_fails = sum(rewards_fails,1);
    stim_rewards_fails = squeeze(stim_rewards_fails)';
    
    file_stim_codes = filelist(file_no).codes;    
    
    stim_details = [filelist(file_no).pd;...
        filelist(file_no).electrodes;...
        filelist(file_no).pulsewidth;...
        filelist(file_no).current;...
        filelist(file_no).period;...
        filelist(file_no).pulses]';
    
    param_list = {'pd','electrodes','pulsewidth','current','period','pulses'};
    
    most_varying_param = std(stim_details)./mean(stim_details);
    [temp most_varying_param] = max(most_varying_param);
    
    plotting_parameter = param_list{most_varying_param};
    
    stim_plot_temp = [filelist(file_no).codes; eval(['filelist(file_no).' plotting_parameter])];
    if intersect(stim_ids,-1)
        stim_plot_temp = [[-1;0] stim_plot_temp];
    end
    
    for iStim = 1:length(stim_ids)
        param_value(iStim) = mean(stim_plot_temp(2,stim_plot_temp(1,:)==stim_ids(iStim)));
    end        
    
%     correct_bootstrapped = zeros(num_bins,bin_size,boot_iter);
%         for i=1:num_bins
%             correct_binned_temp = correct((i-1)*bin_size+1:i*bin_size);
%             correct_binned(i,:) = correct_binned_temp;
%             correct_bootstrapped(i,:,:) = correct_binned_temp(ceil(length(correct_binned_temp)*rand(length(correct_binned_temp),boot_iter)));
%         end
%     correct_percent_bootstrapped = squeeze(mean(correct_bootstrapped,2));
    
    if num_outer_targets==1
        figure;
        plot(param_value,stim_rewards_incompletes(1,:)./sum(stim_rewards_incompletes));
        ylim([0 1])
        xlabel(plotting_parameter)
        ylabel('Rewards/(Incompletes+Rewards)')
        title_temp = filelist(file_no).name;
        title_temp = strrep(title_temp,'_','\_');
        title(title_temp)
    else
        figure;
        plot(param_value,stim_rewards_fails(1,:)./sum(stim_rewards_fails));
        ylim([0 1])
        xlabel(plotting_parameter)
        ylabel('Rewards/(Fails+Rewards)')
        title_temp = filelist(file_no).name;
        title_temp = strrep(title_temp,'_','\_');
        title(title_temp)
    end
    
%% Stim psychophysics comparing electrodes

    for iStim=1:length(stim_ids)
        stim_indexes = filelist(file_no).codes==stim_ids(iStim);
        stims.codes{iStim} = unique(filelist(file_no).codes(stim_indexes));
        stims.electrodes{iStim} = filelist(file_no).electrodes(stim_indexes);
        stims.currents{iStim} = filelist(file_no).current(stim_indexes);
    end
    
    electrode_groups = stims.electrodes;    
    for iElectrodeGroups = 1:length(stims.electrodes)
        for iScanEGroups = iElectrodeGroups+1:length(stims.electrodes)
            if isequal(electrode_groups{iElectrodeGroups},electrode_groups{iScanEGroups})
                electrode_groups{iScanEGroups} = [];
            end
        end
    end                
    electrode_groups(cellfun(@isempty,electrode_groups)) = [];
    
    current_groups = stims.currents;    
    for iCurrentGroups = 1:length(stims.currents)
        for iScanCGroups = iCurrentGroups+1:length(stims.currents)
            if isequal(mean(current_groups{iCurrentGroups}),mean(current_groups{iScanCGroups}))
                current_groups{iScanCGroups} = [];
            end
        end
    end                
    current_groups(cellfun(@isempty,current_groups)) = [];
    
    electrode_current_rewards = zeros(length(electrode_groups),length(current_groups));
    electrode_current_incompletes = zeros(length(electrode_groups),length(current_groups));
    electrode_current_fails = zeros(length(electrode_groups),length(current_groups));
    
    for iElectrodeGroups = 1:length(electrode_groups)
        for iCurrentGroups = 1:length(current_groups)
            for iStimIds = 1:length(stim_ids)
                if isequal(mean(stims.currents{iStimIds}),mean(current_groups{iCurrentGroups}))
                    if isequal(stims.electrodes{iStimIds},electrode_groups{iElectrodeGroups})
                        electrode_current_rewards(iElectrodeGroups,iCurrentGroups) = ...
                            electrode_current_rewards(iElectrodeGroups,iCurrentGroups) +...
                            sum(trial_table(:,table_columns.stim_id)==stims.codes{iStimIds} &...
                            trial_table(:,table_columns.result)==reward_code);
                        electrode_current_incompletes(iElectrodeGroups,iCurrentGroups) = ...
                            electrode_current_incompletes(iElectrodeGroups,iCurrentGroups) +...
                            sum(trial_table(:,table_columns.stim_id)==stims.codes{iStimIds} &...
                            trial_table(:,table_columns.result)==incomplete_code);
                        electrode_current_fails(iElectrodeGroups,iCurrentGroups) = ...
                            electrode_current_fails(iElectrodeGroups,iCurrentGroups) +...
                            sum(trial_table(:,table_columns.stim_id)==stims.codes{iStimIds} &...
                            trial_table(:,table_columns.result)==fail_code);
                    end
                end
            end
        end
    end                
  
    clear legendstrings
    
    for iStrings = 1:length(electrode_groups)
        legendstrings{iStrings} = num2str(electrode_groups{iStrings});
    end
    
    for iCurrentGroups = 1:length(current_groups)
        current_groups{iCurrentGroups} = mean(current_groups{iCurrentGroups});
    end
    
    if num_outer_targets == 1
        error_bars = get_error_bounds(electrode_current_rewards,...
            electrode_current_incompletes,boot_iter,.1);

        figure;
        colors = colormap(jet);
        colors = colors(1:round(length(colors)/size(electrode_current_incompletes,1)):end,:);
        for iPlot = 1:size(electrode_current_rewards,1)
            plot_var = electrode_current_rewards(iPlot,:)./...
                (electrode_current_rewards(iPlot,:)+electrode_current_incompletes(iPlot,:));
            errorbar(cell2mat(current_groups),plot_var,...
                plot_var-error_bars(iPlot,:,1),error_bars(iPlot,:,2)-plot_var,'Color',colors(iPlot,:));
            hold on
        end
        ylim([0 1])
        xlabel(plotting_parameter)
        ylabel('Rewards/(Incompletes+Rewards)')
        legend(legendstrings)
        title_temp = filelist(file_no).name;
        title_temp = strrep(title_temp,'_','\_');
        title(title_temp)
    else
        error_bars = get_error_bounds(electrode_current_rewards,...
            electrode_current_fails,boot_iter,.1);

        figure;
        colors = colormap(jet);
        colors = colors(1:round(length(colors)/size(electrode_current_fails,1)):end,:);
        for iPlot = 1:size(electrode_current_rewards,1)
            plot_var = electrode_current_rewards(iPlot,:)./...
                (electrode_current_rewards(iPlot,:)+electrode_current_fails(iPlot,:));
            errorbar(cell2mat(current_groups),plot_var,...
                plot_var-error_bars(iPlot,:,1),error_bars(iPlot,:,2)-plot_var,'Color',colors(iPlot,:));
            hold on
        end
        ylim([0 1])
        xlabel(plotting_parameter)
        ylabel('Rewards/(Fails+Rewards)')
        legend(legendstrings)
        title_temp = filelist(file_no).name;
        title_temp = strrep(title_temp,'_','\_');
        title(title_temp)
    end
    
%% Timing plot by trial type
    figure;     
    
    movement_time = [trial_table(:,table_columns.cursor_on_ct) trial_table(:,table_columns.end)]-...
    repmat(trial_table(:,table_columns.start),1,2);
    
    stim_trials = find(trial_table(:,table_columns.stim_id)>-1);
    bump_only_trials = find(trial_table(:,table_columns.stim_id)==-1 & trial_table(:,table_columns.result)~=abort_code);
    
    stim_movement_time = [trial_table(stim_trials,table_columns.cursor_on_ct) trial_table(stim_trials,table_columns.end)]-...
        repmat(trial_table(stim_trials,table_columns.start),1,2);
    
    bump_movement_time = [trial_table(bump_only_trials,table_columns.cursor_on_ct) trial_table(bump_only_trials,table_columns.end)]-...
        repmat(trial_table(bump_only_trials,table_columns.start),1,2);
    
    movement_time(stim_trials,:) = stim_movement_time;
    movement_time(bump_only_trials,:) = bump_movement_time;
        
    bump_time = trial_table(:,table_columns.bump_time) -...
        trial_table(:,table_columns.start);
    bump_time = [bump_time bump_time+bump_duration];
    bump_time(bump_time<0) = inf;
    
    stim_time = zeros(length(trial_table),2);    
    
    for iTrials = 1:length(stim_trials)
        stim_time(stim_trials(iTrials),2) = stim_duration(find(stim_ids==trial_table(stim_trials(iTrials),...
            table_columns.stim_id)));
    end        
           
    plot(stim_movement_time',repmat(1:length(stim_movement_time),2,1),'k')
    hold on
    plot(bump_movement_time',repmat(1:length(bump_movement_time),2,1)+length(stim_movement_time),'r')
    plot(stim_time(stim_trials,:),[repmat(1:length(stim_movement_time),2,1)+repmat([-.3 ;.3],1,length(stim_movement_time))]','-b')
    plot(bump_time(~isinf(bump_time(:,1)),:),[repmat(1:sum(~isinf(bump_time(:,1))),2,1)+repmat([-.3 ;.3],1,sum(~isinf(bump_time(:,1))))]','-g')
    
    title_temp = filelist(file_no).name;
    title_temp = strrep(title_temp,'_','\_');
    title(title_temp)   
 
%%
           
    rewards_indices = find(trial_table(:,table_columns.result)==reward_code);
    incomplete_indices = find(trial_table(:,table_columns.result)==incomplete_code);
    
    zero_bump_trials = find(trial_table(:,table_columns.bump_magnitude)==0);
    
    stim_rewards = intersect(rewards_indices, stim_trials);
    bump_rewards = intersect(rewards_indices, bump_only_trials);
  
    stim_incompletes = intersect(incomplete_indices, stim_trials);
    bump_incompletes = intersect(incomplete_indices, bump_only_trials);
        
    zero_bump_stim_indices = intersect(stim_trials,zero_bump_trials);
    zero_bump_no_stim_indices = intersect(bump_only_trials,zero_bump_trials);
    zero_bump_stim_rewards = intersect(zero_bump_stim_indices,rewards_indices);
    zero_bump_stim_incompletes = intersect(zero_bump_stim_indices,incomplete_indices);
    zero_bump_no_stim_rewards = intersect(zero_bump_no_stim_indices,rewards_indices);
    zero_bump_no_stim_incompletes = intersect(zero_bump_no_stim_indices,incomplete_indices);

%%  Zero bump time histograms
    figure
    subplot(2,1,1)
    hold on
    hist(movement_time(zero_bump_stim_rewards,2),0:.1:1.5)
    h_temp = findobj(gca,'Type','patch');
    hist(movement_time(zero_bump_no_stim_rewards,2),0:.1:1.5);
    h = findobj(gca,'Type','patch');
    set(h(h==h_temp), 'FaceColor','b','FaceAlpha',0.5)
    set(h(h~=h_temp), 'FaceColor','r','FaceAlpha',0.5)
    xlabel('Wait time (s)')
    ylabel('Count')
    title_temp = filelist(file_no).name;
    title_temp = strrep(title_temp,'_','\_');
    title({title_temp;' Reward count (No bump)'})
    legend('Stim','No Stim')
    xlim([0 1.5])
    
    subplot(2,1,2)
    hold on
    hist(movement_time(zero_bump_stim_incompletes,2),0:.1:1.5)
    h_temp = findobj(gca,'Type','patch');
    hist(movement_time(zero_bump_no_stim_incompletes,2),0:.1:1.5);
    h = findobj(gca,'Type','patch');
    set(h(h==h_temp), 'FaceColor','b','FaceAlpha',0.5)
    set(h(h~=h_temp), 'FaceColor','r','FaceAlpha',0.5)
    xlabel('Wait time (s)')
    ylabel('Count')
    title('Incompletes count (No bump)')
    legend('Stim','No stim')
    xlim([0 1.5])
 
%%  All bump magnitudes time histograms
    figure; 
    subplot(2,1,1)
    hold on
    hist(movement_time(stim_rewards,2),0:.1:1.5)
    h_temp = findobj(gca,'Type','patch');
    hist(movement_time(bump_rewards,2),0:.1:1.5);
    h = findobj(gca,'Type','patch');
    set(h(h==h_temp), 'FaceColor','b','FaceAlpha',0.5)
    set(h(h~=h_temp), 'FaceColor','r','FaceAlpha',0.5)
    xlabel('Wait time (s)')
    title_temp = filelist(file_no).name;
    title_temp = strrep(title_temp,'_','\_');
    title({title_temp;'Reward count'})
    legend('Stim+Bump','Bump')
    xlim([0 1.5])

    subplot(2,1,2)
    hold on
    hist(movement_time(stim_incompletes,2),0:.1:1.5)
    h_temp = findobj(gca,'Type','patch');
    hist(movement_time(bump_incompletes,2),0:.1:1.5);
    h = findobj(gca,'Type','patch');
    set(h(h==h_temp), 'FaceColor','b','FaceAlpha',0.5)
    set(h(h~=h_temp), 'FaceColor','r','FaceAlpha',0.5)
    xlabel('Wait time (s)')
    title('Incompletes count')
    legend('Stim+Bump','Bump')
    xlim([0 1.5])
    
%%  Zero bump performance figure
    % figure 0N bump performance over time
    figure; 
    plot(trial_table(zero_bump_no_stim_indices,table_columns.start),trial_table(zero_bump_no_stim_indices,table_columns.result)==reward_code,'r.')
    hold on   
    plot(trial_table(zero_bump_stim_indices,table_columns.start),trial_table(zero_bump_stim_indices,table_columns.result)==reward_code,'b.')    
    
    try
        no_stim_fit = fit(trial_table(zero_bump_no_stim_indices,table_columns.start),trial_table(zero_bump_no_stim_indices,table_columns.result)==reward_code,f_linear,'StartPoint',[0 0]);
        no_stim_fit_conf = confint(no_stim_fit);
    catch
        no_stim_fit = [];
        no_stim_fit_conf = [];
    end
    try
        stim_fit = fit(trial_table(zero_bump_stim_indices,table_columns.start),trial_table(zero_bump_stim_indices,table_columns.result)==reward_code,f_linear,'StartPoint',[0 0]);
        stim_fit_conf = confint(stim_fit);
    catch
        stim_fit = [];
        stim_fit_conf = [];
    end
        
    plot(no_stim_fit,'r')       
    plot(stim_fit,'b')
    try
        plot(trial_table(zero_bump_no_stim_indices,table_columns.start),trial_table(zero_bump_no_stim_indices,table_columns.start)*no_stim_fit_conf(1,2)+no_stim_fit_conf(1,1),'r--');
        plot(trial_table(zero_bump_no_stim_indices,table_columns.start),trial_table(zero_bump_no_stim_indices,table_columns.start)*no_stim_fit_conf(2,2)+no_stim_fit_conf(2,1),'r--');
    end
    try
        plot(trial_table(zero_bump_stim_indices,table_columns.start),trial_table(zero_bump_stim_indices,table_columns.start)*stim_fit_conf(1,2)+stim_fit_conf(1,1),'b--');
        plot(trial_table(zero_bump_stim_indices,table_columns.start),trial_table(zero_bump_stim_indices,table_columns.start)*stim_fit_conf(2,2)+stim_fit_conf(2,1),'b--');
    end
    xlabel('Time (s)')
    ylabel('Rewards/Incompletes')
    title_temp = filelist(file_no).name;
    title_temp = strrep(title_temp,'_','\_');
    title({title_temp;'Zero bump performance'})
    legend('No stim','Stim')
    
%% Speed figures
    max_mov_time = trial_table(trial_table(:,table_columns.result)==reward_code,...
                [table_columns.start table_columns.end]);
    max_mov_time = round(max(diff(max_mov_time')')*1000);
    mean_mov_speed = zeros(length(bump_magnitudes),length(stim_ids),max_mov_time+1);
    std_mov_speed = zeros(length(bump_magnitudes),length(stim_ids),max_mov_time+1);
    plot_colors = colormap(hsv);
    plot_colors = plot_colors(round(1:length(plot_colors)/length(stim_ids):end),:);
    for iBump = 1:length(bump_magnitudes)
        figure;
        hold on
        for iColor = 1:length(stim_ids)
            plot(0,0,'Color',plot_colors(iColor,:));
        end
        ylabel('Speed (cm/s)')
        xlabel('t (s)')
        title_temp = filelist(file_no).name;
        title_temp = strrep(title_temp,'_','\_');
        title({title_temp; 'Mean speed'; ['Bump= ' num2str(bump_magnitudes(iBump)) ' N']})
        for iStim = 1:length(stim_ids)
            movement_times = trial_table(trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(iBump) &...
                trial_table(:,table_columns.stim_id)==stim_ids(iStim) & trial_table(:,table_columns.result)==reward_code,...
                [table_columns.start table_columns.end]);
            movement_times = movement_times(diff(movement_times')'>0.5,:);


            temp_mov_speed = zeros(length(movement_times),max_mov_time+1);
            for iMov = 1:size(movement_times,1)
                kin_idx(1) = find(bdf.pos(:,1)>movement_times(iMov,1),1,'first');
    %             kin_idx(2) = find(bdf.pos(:,1)<=movement_times(iMov,2),1,'last');
                kin_idx(2) = kin_idx(1)+max_mov_time;
                mov_speed{iBump,iStim}(iMov) = {sqrt(bdf.vel(kin_idx(1):kin_idx(2),2).^2+...
                    bdf.vel(kin_idx(1):kin_idx(2),3).^2)};
    %             plot(mov_speed{iBump,iStim}{iMov})
                xlim([0 max_mov_time])
                temp_mov_speed(iMov,:) = cell2mat(mov_speed{iBump,iStim}(iMov));
            end
            mean_mov_speed(iBump,iStim,:) = mean(temp_mov_speed);
            std_mov_speed(iBump,iStim,:) = std(temp_mov_speed);
            plot(squeeze(mean_mov_speed(iBump,iStim,:)),'Color',plot_colors(iStim,:))
    %         plot(squeeze(mean_mov_speed(iBump,iStim,:))+squeeze(std_mov_speed(iBump,iStim,:)),'--','Color',plot_colors(iStim,:))
    %         plot(squeeze(mean_mov_speed(iBump,iStim,:))-squeeze(std_mov_speed(iBump,iStim,:)),'--','Color',plot_colors(iStim,:))
        end
        legend(num2str(stim_ids))
    end

%% response time figure
%     figure; 
%     plot(response_time(trial_table(:,table_columns.result)==reward_code));   
% 
%     response_time_bump_mag = zeros(length(bump_magnitudes),1);
%     response_time_bump_mag_std = zeros(length(bump_magnitudes),1);
%     for i=1:length(bump_magnitudes)
%         response_time_temp = response_time(trial_table(:,table_columns.result)==reward_code &...
%             trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(i));
%         response_time_bump_mag(i) = mean(response_time_temp);
%         response_time_bump_mag_std(i) = std(response_time_temp);
%     end
%     figure;
%     errorbar(bump_magnitudes,response_time_bump_mag,response_time_bump_mag_std)
%     xlabel('Bump magnitude [N]')
%     ylabel('Mean response time +/- std (s)')
% 
%     % If using multiple stim ids
%     stim_ids = unique(trial_table(:,table_columns.stim_id));
%     stim_ids = stim_ids(stim_ids~=-1);
%     rewards_stim = zeros(length(stim_ids),1);
%     incompletes_stim = zeros(length(stim_ids),1);
%     response_time_bump_mag_stim = zeros(length(stim_ids),length(bump_magnitudes));
%     response_time_bump_mag_stim_std = zeros(length(stim_ids),length(bump_magnitudes));
%     colors = {'k','b','r'};
% 
%     figure; 
%     for i=1:length(stim_ids)
%         for j=1:length(bump_magnitudes)
%             response_time_temp = response_time(trial_table(:,table_columns.result)==reward_code &...
%                 trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(j) &...
%                 trial_table(:,table_columns.stim_id)==stim_ids(i));
%             response_time_bump_mag_stim(i,j) = mean(response_time_temp);
%             response_time_bump_mag_stim_std(i,j) = std(response_time_temp);    
%         end            
%         errorbar(bump_magnitudes,response_time_bump_mag_stim(i,:),...
%             response_time_bump_mag_stim_std(i,:),'color',colors{i})
%         hold on
%         ylim([0 1])
% %                 plot(response_time(trial_table(:,table_columns.result)==reward_code &...
% %                     trial_table(:,table_columns.stim_id)==stim_ids(i)),'Color',colors{i});   
%     end
% 
%     figure; 
%     for i=1:length(stim_ids)
%         reward_idx = trial_table(:,table_columns.result)==reward_code  &...
%                 trial_table(:,table_columns.stim_id)==stim_ids(i);
%         incomplete_idx = trial_table(:,table_columns.result)==incomplete_code  &...
%                 trial_table(:,table_columns.stim_id)==stim_ids(i);
%         plot(trial_table(reward_idx,table_columns.start), response_time(reward_idx),'.',...
%             'color',colors{i}); 
%         hold on
%         rewards_stim(i) = sum(reward_idx);
%         incompletes_stim(i) = sum(incomplete_idx);
%     end
%     xlabel('t (s)')
%     ylabel('Response time (s)')      
%       
end