% get the cerebus electrode ID for each electrode on each bank
% cmp_file = 'Z:\lab_folder\Animal-Miscellany\Jaco 8I1\2014-02-04 Left Hemisphere Removal and Reimplant\SN_6250-001275_LH2.cmp';
% elec_map = read_cmp(cmp_file);
bankA_stim_elecs = [1,7,10,11,13,14,17,18,19,20,22,23,24,25,27,28,29,30];
bankC_stim_elecs = [1,2,3,4,6,7,8,9,10,20,21,23,25,28,29,30];

bankA_elec_IDs = 0+bankA_stim_elecs;
bankC_elec_IDs = 64+bankC_stim_elecs;
all_elec_IDs = [bankA_elec_IDs, bankC_elec_IDs];

nm = repmat(struct(),1,2);
stam = repmat(struct(),1,2);
% tuning day 1
load('F:\Jaco\Processed\2016-01-27\M1_tuning\CO_CS_movement_regression_onpeak_2016-01-27.mat');
idx = zeros(size(all_elec_IDs));
for i = 1:length(all_elec_IDs)
    idx(i) = find(tuning.sg(:,1)==all_elec_IDs(i));
end
nm(1).pds = tuning.pds(idx,:);
nm(1).mds = tuning.mds(idx,:);
nm(1).bos = tuning.bos(idx,:);
nm(1).r2 = mean(tuning.r_squared(idx,:),2);

% tuning day 2
load('F:\Jaco\Processed\2016-01-28\M1_tuning\CO_CS_movement_regression_onpeak_2016-01-28.mat');
idx = zeros(size(all_elec_IDs));
for i = 1:length(all_elec_IDs)
    idx(i) = find(tuning.sg(:,1)==all_elec_IDs(i));
end
nm(2).pds = tuning.pds(idx,:);
nm(2).mds = tuning.mds(idx,:);
nm(2).bos = tuning.bos(idx,:);
nm(2).r2 = mean(tuning.r_squared(idx,:),2);

% stim day 1
load('F:\Jaco\ICMS_testing\TTA_data_2016_01_27\Jaco_A_1   7  10  11  13  14  17  18  19  20  22  23  24  25  27  28  29  30_20160127_170019_CO_TTA.mat');
stam_a = calculate_sta_metrics_matt(force,ttap);
load('F:\Jaco\ICMS_testing\TTA_data_2016_01_27\Jaco_A_1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31_20160127_172136_CO_TTA.mat');
stam_c = calculate_sta_metrics_matt(force,ttap);

stam(1).force.mean_detrended_force = cat(3,stam_a.force.mean_detrended_force,stam_c.force.mean_detrended_force(:,:,bankC_stim_elecs));
stam(1).force.std_detrended_force = cat(3,stam_a.force.std_detrended_force,stam_c.force.std_detrended_force(:,:,bankC_stim_elecs));

% stim day 2
load('F:\Jaco\ICMS_testing\TTA_data_2016_01_28\Jaco_A_1   7  10  11  13  14  17  18  19  20  22  23  24  25  27  28  29  30_20160128_122955_CO_TTA.mat')
stam_a = calculate_sta_metrics_matt(force,ttap);
load('F:\Jaco\ICMS_testing\TTA_data_2016_01_28\Jaco_A_1   2   3   4   6   7   8   9  10  20  21  23  25  28  29  30_20160128_125158_CO_TTA.mat')
stam_c = calculate_sta_metrics_matt(force,ttap);
stam(2).force.mean_detrended_force = cat(3,stam_a.force.mean_detrended_force,stam_c.force.mean_detrended_force);
stam(2).force.std_detrended_force = cat(3,stam_a.force.std_detrended_force,stam_c.force.std_detrended_force);

num_elecs = size(stam(1).force.mean_detrended_force,3);

t_force                     = -ttap.t_before:1/force.fs*1000:ttap.t_after;       % in ms

%%
for idx_elec = 1:num_elecs
    
    if ~isnan(nm(1).r2(idx_elec)) && ~isnan(nm(2).r2(idx_elec))
        figure('Position',[100 100 1200 800] );
        
        % day 1
        f = squeeze(stam(1).force.mean_detrended_force(:,:,idx_elec));
        fs = squeeze(stam(1).force.std_detrended_force(:,:,idx_elec));
        
        f_max = max(max(abs(f)+fs,[],1));
        
        for i = 1:2
            subplot(1,3,i);
            hold all;
            plot(t_force, f(:,i),'b','linewidth',2);
            plot(t_force, f(:,i)+fs(:,i),'b--','linewidth',2);
            plot(t_force, f(:,i)-fs(:,i),'b--','linewidth',2);
        end
        
        % don't plot the whole trace in 2D
        t = t_force >= 10  & t_force <= 45;
        
        % make 2d plot
        subplot(1,3,3);
        hold all;
        plot(f(t,1),f(t,2),'b','LineWidth',2);
        % now plot tuning on this
        plot([0 f_max*cos(nm(1).pds(idx_elec))],[0 f_max*sin(nm(1).pds(idx_elec))],'b--','LineWidth',3);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % day 2
        f = squeeze(stam(2).force.mean_detrended_force(:,:,idx_elec));
        fs = squeeze(stam(2).force.std_detrended_force(:,:,idx_elec));
        
        f_max = max([f_max,max(max(abs(f)+fs,[],1))]);
        
        for i = 1:2
            subplot(1,3,i);
            hold all;
            plot([t_force(1),t_force(end)],[0 0],'k--','LineWidth',1);
            plot(t_force, f(:,i),'r','linewidth',2);
            plot(t_force, f(:,i)+fs(:,i),'r--','linewidth',2);
            plot(t_force, f(:,i)-fs(:,i),'r--','linewidth',2);
            ylabel(force.labels{i}(6:end),'FontSize',16);
            axis('tight');
            set(gca,'TickDir','out','Box','off','YLim',[-f_max f_max])
        end
        
        % don't plot the whole trace in 2D
        t = t_force >= 10  & t_force <= 45;
        
        subplot(1,3,3);
        hold all;
        plot(f(t,1),f(t,2),'r','LineWidth',2);
        % now plot tuning on this
        plot([0 f_max*cos(nm(2).pds(idx_elec))],[0 f_max*sin(nm(2).pds(idx_elec))],'r--','LineWidth',2);
        plot([-f_max f_max],[0 0],'k--','LineWidth',1); plot([0 0],[-f_max f_max],'k--','LineWidth',1);
        
        xlabel(force.labels{1}(6:end),'FontSize',16);
        ylabel(force.labels{2}(6:end),'FontSize',16);
        axis('square');
        set(gca,'TickDir','out','Box','off','XLim',[-f_max f_max],'YLim',[-f_max f_max]);
        
        
        saveas(gcf,['F:\Jaco\ICMS_testing\figures\' num2str(idx_elec) '.png']);
        close all;
    end
end