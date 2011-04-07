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
%     trial_table(trial_table(:,table_columns.bump_time)==0,table_columns.bump_magnitude) = 0;

    trial_table = trial_table(trial_table(:,table_columns.bump_time)~=0,:);
    
    trial_table(trial_table(:,table_columns.bump_and_stim)==0 & trial_table(:,table_columns.stim_id) ~= -1,...
        table_columns.bump_magnitude) = 0;
    trial_table(trial_table(:,table_columns.bump_and_stim)==0 & trial_table(:,table_columns.stim_id) ~= -1,...
        table_columns.bump_time) = 0;
    
%     % Temporary hack!
%     trial_table(trial_table(:,table_columns.stim_id)==2,table_columns.stim_id) = 1;

    fit_func = 'm*x+b';
    f_linear = fittype(fit_func,'independent','x');

    response_time = trial_table(:,table_columns.end)-trial_table(:,table_columns.start);

    correct = trial_table(:,table_columns.result)==reward_code;
    [correct_fit fit_stats] = fit(trial_table(:,table_columns.start),correct,f_linear);
    percentage_rewards = sum(trial_table(:,table_columns.result)==reward_code)/length(trial_table) 
    percentage_aborts =  sum(trial_table(:,table_columns.result)==abort_code)/length(trial_table) 
    percentage_incompletes = sum(trial_table(:,table_columns.result)==incomplete_code)/length(trial_table) 
    
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
        title(filelist(file_no).name)
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

%         hgsave(figure_behavior,[resultpath filename]);
%         I = getframe(figure_behavior);
%         imwrite(I.cdata, [resultpath filename '.png']);
    end
        
%% Rewards/incompletes as a function of bump magnitude

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
    figure;

    for iBump = 1:length(bump_magnitudes)
        for iStim = 1:length(stim_ids)
            rewards_incompletes(iBump,iStim,:) = [sum(trial_table(trial_indexes{iBump,iStim},table_columns.result)==reward_code) ...
                sum(trial_table(trial_indexes{iBump,iStim},table_columns.result)==incomplete_code)];
        end
    end
    rewards_incompletes
    
    plot(bump_magnitudes,rewards_incompletes(:,:,1)./sum(rewards_incompletes,3))
    legend(['Stim ' num2str(stim_ids(1))],['Stim ' num2str(stim_ids(2))])
    
%% timing plot
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
    
%     stim_movement_time = [trial_table(stim_trials,table_columns.cursor_on_ct) trial_table(stim_trials,table_columns.end)]-...
%         repmat(trial_table(stim_trials,table_columns.start)+(trial_table(trial_table(:,table_columns.stim_id)~=-1,table_columns.bump_time)-...
%         trial_table(trial_table(:,table_columns.stim_id)~=-1,table_columns.start)),1,2);
%     stim_movement_time = stim_movement_time(trial_table(stim_trials,table_columns.bump_time)~=0,:);
%     bump_movement_time = [trial_table(bump_only_trials,table_columns.cursor_on_ct) trial_table(bump_only_trials,table_columns.end)]-...
%         repmat(trial_table(bump_only_trials,table_columns.start),1,2);
    
%     movement_time(trial_table(:,table_columns.stim_id)~=-1,:) = movement_time(trial_table(:,table_columns.stim_id)~=-1,:)-...
%         repmat((trial_table(trial_table(:,table_columns.stim_id)~=-1,table_columns.bump_time)-...
%         trial_table(trial_table(:,table_columns.stim_id)~=-1,table_columns.start)),1,2);
    
    bump_time = trial_table(:,table_columns.bump_time) -...
        trial_table(:,table_columns.start);
    bump_time = [bump_time bump_time+bump_duration];
    bump_time(bump_time<0) = inf;
    
    stim_time = zeros(length(trial_table),2);
    
    stim_time(stim_trials,2) = ...
        stim_duration(trial_table(stim_trials,table_columns.stim_id)+1)/1000;

%     [temp sort_idx] = sort(movement_time);
%     movement_time_sorted = movement_time(sort_idx(:,1),:);
%     bump_time_sorted = bump_time(sort_idx(:,1),:);
%     stim_time_sorted = stim_time(sort_idx(:,1),:);
%     trial_table_sorted = trial_table(sort_idx(:,1),:);       
%%
%     figure;        
%     plot(movement_time_sorted(trial_table_sorted(:,table_columns.result)==reward_code,:)',...
%         [sort_idx(trial_table_sorted(:,table_columns.result)==reward_code) sort_idx(trial_table_sorted(:,table_columns.result)==reward_code)]','b')
%     hold on;
%     plot(movement_time_sorted(trial_table_sorted(:,table_columns.result)==abort_code,:)',...
%         [sort_idx(trial_table_sorted(:,table_columns.result)==abort_code) sort_idx(trial_table_sorted(:,table_columns.result)==abort_code)]','r')
%     plot(movement_time_sorted(trial_table_sorted(:,table_columns.result)==incomplete_code,:)',...
%         [sort_idx(trial_table_sorted(:,table_columns.result)==incomplete_code) sort_idx(trial_table_sorted(:,table_columns.result)==incomplete_code)]','k')
%     plot([bump_time_sorted(:,1) bump_time_sorted(:,1)]',[sort_idx(:,1)-.3 sort_idx(:,1)+.3]','g')
%     plot([bump_time_sorted(:,2) bump_time_sorted(:,2)]',[sort_idx(:,1)-.5 sort_idx(:,1)+.5]','g')
%     plot([stim_time_sorted(:,1) stim_time_sorted(:,1)]',[sort_idx(:,1)-.5 sort_idx(:,1)+.5]','k')
%     plot([stim_time_sorted(:,2) stim_time_sorted(:,2)]',[sort_idx(:,1)-.15 sort_idx(:,1)+.15]','k')

%% Timing plot by trial type
    figure;     
    plot(stim_movement_time',repmat(1:length(stim_movement_time),2,1),'k')
    hold on
    plot(bump_movement_time',repmat(1:length(bump_movement_time),2,1)+length(stim_movement_time),'r')
    plot(stim_time(stim_trials,:),[repmat(1:length(stim_movement_time),2,1)+repmat([-.3 ;.3],1,length(stim_movement_time))]','-b')
    plot(bump_time(~isinf(bump_time(:,1)),:),[repmat(1:sum(~isinf(bump_time(:,1))),2,1)+repmat([-.3 ;.3],1,sum(~isinf(bump_time(:,1))))]','-g')
%     plot(movement_time_sorted(trial_table_sorted(:,table_columns.result)==reward_code,:)',...
%         [sort_idx(trial_table_sorted(:,table_columns.result)==reward_code) sort_idx(trial_table_sorted(:,table_columns.result)==reward_code)]','b')
%     hold on;
%     plot(movement_time_sorted(trial_table_sorted(:,table_columns.result)==abort_code,:)',...
%         [sort_idx(trial_table_sorted(:,table_columns.result)==abort_code) sort_idx(trial_table_sorted(:,table_columns.result)==abort_code)]','r')
%     plot(movement_time_sorted(trial_table_sorted(:,table_columns.result)==incomplete_code,:)',...
%         [sort_idx(trial_table_sorted(:,table_columns.result)==incomplete_code) sort_idx(trial_table_sorted(:,table_columns.result)==incomplete_code)]','k')
%     plot([bump_time_sorted(:,1) bump_time_sorted(:,1)]',[sort_idx(:,1)-.3 sort_idx(:,1)+.3]','g')
%     plot([bump_time_sorted(:,2) bump_time_sorted(:,2)]',[sort_idx(:,1)-.5 sort_idx(:,1)+.5]','g')
%     plot([stim_time_sorted(:,1) stim_time_sorted(:,1)]',[sort_idx(:,1)-.5 sort_idx(:,1)+.5]','k')
%     plot([stim_time_sorted(:,2) stim_time_sorted(:,2)]',[sort_idx(:,1)-.15 sort_idx(:,1)+.15]','k')

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
 
%%
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
    title('Reward count (No bump)')
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
 
%%
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
    title('Reward count')
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
    
%     subplot(3,1,3)
%     hist(-movement_time_sorted(trial_table_sorted(:,table_columns.result)==abort_code,1),0:.1:5)
%     xlabel('Wait time (s)')
%     title('Abort count')
%     xlim([0 5])

%%
%     % figure correct as a function of bump mag
%     bump_magnitudes = unique(trial_table(:,table_columns.bump_magnitude));
%     rewards_bump = zeros(1,length(bump_magnitudes));
%     incomplete_bump = zeros(1,length(bump_magnitudes));
%     fail_bump = zeros(1,length(bump_magnitudes));
%     for i=1:length(bump_magnitudes)
%         rewards_bump(i) = sum(trial_table(trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(i),table_columns.result)==reward_code);
%         incomplete_bump(i) = sum(trial_table(trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(i),table_columns.result)==incomplete_code);
%     end
%     rewards_incomplete_bump = rewards_bump./( rewards_bump+incomplete_bump);        
%     figure; 
%     plot(bump_magnitudes,rewards_incomplete_bump);
%     legend('Rewards/(Rewards+Incomplete)','Location','Southeast');
%     xlabel('Bump magnitude [N]')
% 
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
    title('Zero bump performance')
    legend('No stim','Stim')
    
%% Movement onset figure
max_mov_time = trial_table(trial_table(:,table_columns.result)==reward_code,...
            [table_columns.start table_columns.end]);
max_mov_time = round(max(diff(max_mov_time')')*1000);
mean_mov_speed = zeros(length(bump_magnitudes),length(stim_ids),max_mov_time+1);
std_mov_speed = zeros(length(bump_magnitudes),length(stim_ids),max_mov_time+1);
plot_colors = {'b','r','k','g'};
for iBump = 1:length(bump_magnitudes)
    figure;
    hold on
    plot(0,0,plot_colors{1});
    plot(0,0,plot_colors{2});
    plot(0,0,plot_colors{3});
    plot(0,0,plot_colors{4});
    title(['Bump: ' num2str(bump_magnitudes(iBump))])
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
        plot(squeeze(mean_mov_speed(iBump,iStim,:)),plot_colors{iStim})
        plot(squeeze(mean_mov_speed(iBump,iStim,:))+squeeze(std_mov_speed(iBump,iStim,:)),'--','Color',plot_colors{iStim})
        plot(squeeze(mean_mov_speed(iBump,iStim,:))-squeeze(std_mov_speed(iBump,iStim,:)),'--','Color',plot_colors{iStim})
    end
    legend(num2str(stim_ids))
end
iMov;

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