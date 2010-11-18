% calculate success rate
% filename = 'D:\Data\Ricardo_BC_no_spikes_001';
close all
clear all
boot_iter = 10000;
set(0,'DefaultTextInterpreter','none')
curr_dir = pwd;    
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
load_paths;
cd(curr_dir)

resultpath = 'D:\Ricardo\Miller Lab\Bump choice results\Detection results\';
[datapath filelist] = BC_detection_experiment_list();
tpr = zeros(1,length(filelist));
fpr = zeros(1,length(filelist));

for file_no = 1:length(filelist)
    disp(['File number: ' num2str(file_no) ' of ' num2str(length(filelist))])
    filename = filelist(file_no).name;
    stim_pds = filelist(file_no).pd;
%     if ~exist([resultpath filename '.fig'],'file')
        if ~exist([datapath filename '.mat'],'file')    
            cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
            bdf = get_plexon_data([datapath filename '.plx'],2);
            save([datapath filename],'bdf');
            cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\';
            trial_table = BC_build_trial_table([datapath filename]);    
            save([datapath filename],'trial_table','-append')
        end

        cd(curr_dir)
        load([datapath filename],'trial_table','bdf')
        
        trial_table = trial_table(trial_table(:,5)==0,:); % remove training trials
        
        fit_func = 'm*x+b';
        f_linear = fittype(fit_func,'independent','x');
        
        correct = trial_table(:,3)==32;
        [correct_fit fit_stats] = fit(trial_table(:,1),correct,f_linear);
        percentage_correct = sum(trial_table(:,3)==32)/(sum(trial_table(:,3)==32)+sum(trial_table(:,3)==34))       
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
        
        stim_ids = unique(trial_table(:,8));
        stim_ids = stim_ids(stim_ids>=0);
        response_table = zeros(length(stim_ids),2);
        for i=1:length(stim_ids)
            response_table(i,1) = sum(trial_table(:,8)==stim_ids(i) & trial_table(:,3)==32);
            response_table(i,2) = sum(trial_table(:,8)==stim_ids(i) & trial_table(:,3)==34);
        end
        response_table
        tpr(file_no) = response_table(1,1)/(response_table(1,1)+response_table(2,2));
        fpr(file_no) = response_table(1,2)/(response_table(1,2)+response_table(2,1));
        first_hundred(file_no) = sum(correct(1:100));
        last_hundred(file_no) = sum(correct(end-99:end));
%         fit_slope = zeros(1,boot_iter);
%         tic
%         for i=1:boot_iter
%             correct_fit{i} = fit([1:num_bins]',mean(correct_bootstrapped(:,:,i),2),f_linear,'StartPoint',[0 0]);
%             fit_slope(i) = correct_fit{i}.m;
%         end
%         toc
%         [fit_slope_hist fit_slope_hist_bins] = hist(fit_slope,100);
%         
%         conf_inter = [fit_slope_hist_bins(find(cumsum(fit_slope_hist)>boot_iter*.05,1,'first')),...
%             fit_slope_hist_bins(find(cumsum(fit_slope_hist)>boot_iter*.95,1,'first'))];

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
%     end
end
figure; 
plot(fpr,tpr,'.r')
hold on
plot([0 1],[0 1],'--b')
xlim([0 1])
ylim([0 1])
axis square
xlabel('FPR')
ylabel('TPR')