close all
clear all
clc
set(0,'DefaultTextInterpreter','none')
curr_dir = pwd;    
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
load_paths;
cd(curr_dir)
boot_iter = 1000;

resultpath = 'D:\Ricardo\Miller Lab\Bump choice results\DetectionC results\';
[datapath filelist] = BC_detectionD_experiment_list();
reward_code = 32;
abort_code = 33;
fail_code = 34;
incomplete_code = 35;

for file_no = 4:length(filelist)
    disp(['File number: ' num2str(file_no) ' of ' num2str(length(filelist))])
    filename = filelist(file_no).name;
    stim_pds = filelist(file_no).pd;
    stim_duration = filelist(file_no).period.*filelist(file_no).pulses;
    bump_duration = filelist(file_no).bump_duration;
    serverdatapath = filelist(file_no).serverdatapath;
        if ~exist([datapath filename '.mat'],'file')  
            if ~exist([datapath filename '.plx'],'file')
                disp('Waiting for file to be copied to server')
                while ~exist([serverdatapath '\' filename '.plx'],'file')                
                    pause(30) 
                    why
                end
                disp('Done')
                copied=0;
                while copied==0
                    try
                        copyfile([serverdatapath '\' filename '.plx'],datapath);
                        copied=1;
                    end
                end
            end
            cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
            bdf = get_plexon_data([datapath filename '.plx'],2);
            save([datapath filename],'bdf');
            cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\';
            [trial_table table_columns]= BC_detectionD_trial_table([datapath filename]);    
            save([datapath filename],'trial_table','table_columns','-append')
        end

        cd(curr_dir)
        load([datapath filename],'trial_table','bdf','table_columns')
                
        fit_func = 'm*x+b';
        f_linear = fittype(fit_func,'independent','x');
        
        response_time = trial_table(:,table_columns.end)-trial_table(:,table_columns.start);
        
        correct = trial_table(:,table_columns.result)==reward_code;
        [correct_fit fit_stats] = fit(trial_table(:,table_columns.start),correct,f_linear);
        percentage_rewards = sum(trial_table(:,table_columns.result)==reward_code)/length(trial_table) 
        percentage_aborts =  sum(trial_table(:,table_columns.result)==abort_code)/length(trial_table) 
        percentage_incompletes = sum(trial_table(:,table_columns.result)==incomplete_code)/length(trial_table) 
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

        hgsave(figure_behavior,[resultpath filename]);
        I = getframe(figure_behavior);
        imwrite(I.cdata, [resultpath filename '.png']);
%         
        % timing plot
        movement_time = [trial_table(:,table_columns.cursor_on_ct) trial_table(:,table_columns.end)]-...
            repmat(trial_table(:,table_columns.start),1,2);
        bump_time = trial_table(:,table_columns.bump_time) -...
            trial_table(:,table_columns.start);
        bump_time = [bump_time bump_time+bump_duration];
        bump_time(bump_time<0) = inf;
        stim_time = zeros(length(movement_time),2);
        stim_time(trial_table(:,table_columns.stim_id)~=-1,2) = ...
            stim_duration(trial_table(trial_table(:,table_columns.stim_id)~=-1,table_columns.stim_id)+1)/1000;
        
        [temp sort_idx] = sort(movement_time);
        movement_time_sorted = movement_time(sort_idx(:,1),:);
        bump_time_sorted = bump_time(sort_idx(:,1),:);
        stim_time_sorted = stim_time(sort_idx(:,1),:);
        trial_table_sorted = trial_table(sort_idx(:,1),:);       
%%
        figure;        
        plot(movement_time_sorted(trial_table_sorted(:,table_columns.result)==reward_code,:)',...
            [sort_idx(trial_table_sorted(:,table_columns.result)==reward_code) sort_idx(trial_table_sorted(:,table_columns.result)==reward_code)]','b')
        hold on;
        plot(movement_time_sorted(trial_table_sorted(:,table_columns.result)==abort_code,:)',...
            [sort_idx(trial_table_sorted(:,table_columns.result)==abort_code) sort_idx(trial_table_sorted(:,table_columns.result)==abort_code)]','r')
        plot(movement_time_sorted(trial_table_sorted(:,table_columns.result)==incomplete_code,:)',...
            [sort_idx(trial_table_sorted(:,table_columns.result)==incomplete_code) sort_idx(trial_table_sorted(:,table_columns.result)==incomplete_code)]','k')
        plot([bump_time_sorted(:,1) bump_time_sorted(:,1)]',[sort_idx(:,1)-.3 sort_idx(:,1)+.3]','g')
        plot([bump_time_sorted(:,2) bump_time_sorted(:,2)]',[sort_idx(:,1)-.5 sort_idx(:,1)+.5]','g')
        plot([stim_time_sorted(:,1) stim_time_sorted(:,1)]',[sort_idx(:,1)-.5 sort_idx(:,1)+.5]','k')
        plot([stim_time_sorted(:,2) stim_time_sorted(:,2)]',[sort_idx(:,1)-.15 sort_idx(:,1)+.15]','k')

%%                
        figure; hist(-movement_time_sorted(trial_table_sorted(:,table_columns.result)==reward_code,1),0:.1:5)
        xlabel('Wait time (s)')
        title('Reward count')
        xlim([0 5])

        figure; hist(-movement_time_sorted(trial_table_sorted(:,table_columns.result)==incomplete_code,1),0:.1:5)
        xlabel('Wait time (s)')
        title('Incomplete count')
        xlim([0 5])
        
        figure; hist(-movement_time_sorted(trial_table_sorted(:,table_columns.result)==abort_code,1),0:.1:5)
        xlabel('Wait time (s)')
        title('Abort count')
        xlim([0 5])
        
        % figure correct as a function of bump mag
        bump_magnitudes = unique(trial_table(:,table_columns.bump_magnitude));
        rewards_bump = zeros(1,length(bump_magnitudes));
        incomplete_bump = zeros(1,length(bump_magnitudes));
        fail_bump = zeros(1,length(bump_magnitudes));
        for i=1:length(bump_magnitudes)
            rewards_bump(i) = sum(trial_table(trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(i),table_columns.result)==reward_code);
            incomplete_bump(i) = sum(trial_table(trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(i),table_columns.result)==incomplete_code);
        end
        rewards_incomplete_bump = rewards_bump./( rewards_bump+incomplete_bump);        
        figure; 
        plot(bump_magnitudes,rewards_incomplete_bump);
        legend('Rewards/(Rewards+Incomplete)','Location','Southeast');
        xlabel('Bump magnitude [N]')
        
        % figure 0N bump performance over time
        zero_bump_subtable = trial_table(trial_table(:,table_columns.bump_magnitude)==0,:);
        figure; 
        plot(zero_bump_subtable(:,table_columns.start),zero_bump_subtable(:,table_columns.result)==reward_code,'.')
        zero_bump_reward_ratio(file_no) = sum(zero_bump_subtable(:,table_columns.result)==reward_code)/...
            length(zero_bump_subtable(:,table_columns.result)==reward_code);
        
        % response time figure
        figure; 
        plot(response_time(trial_table(:,table_columns.result)==reward_code));   
        
        response_time_bump_mag = zeros(length(bump_magnitudes),1);
        response_time_bump_mag_std = zeros(length(bump_magnitudes),1);
        for i=1:length(bump_magnitudes)
            response_time_temp = response_time(trial_table(:,table_columns.result)==reward_code &...
                trial_table(:,table_columns.bump_magnitude)==bump_magnitudes(i));
            response_time_bump_mag(i) = mean(response_time_temp);
            response_time_bump_mag_std(i) = std(response_time_temp);
        end
        figure;
        errorbar(bump_magnitudes,response_time_bump_mag,response_time_bump_mag_std)
        xlabel('Bump magnitude [N]')
        ylabel('Mean response time +/- std (s)')
end
