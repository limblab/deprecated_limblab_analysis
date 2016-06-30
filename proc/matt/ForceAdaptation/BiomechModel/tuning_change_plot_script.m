
%%
if 0
    use_models = {'muscle'};
    
    
    close all;
    figure;
    hold all;
    use_colors = {'k','b','r','m'};
    for i = 1:length(use_models)
        plot(-1,0,'o','LineWidth',3,'Color',use_colors{i});
    end
    
    cf_dirs = [1 1 1];
    for i = 1:length(use_models)
        % find which cells are tuned in all epochs
        idx = ones(num_neurons,size(blocks,1));
        for j = 1:size(blocks,1)
            idx(:,j) = mean(tc_data(j).(use_models{i}).rs,2) > 0.5;
        end
        
        idx = all(idx,2);
        
        for j = 1:size(blocks,1)
            dpd = angleDiff(tc_data(1).(use_models{i}).tc(:,3),tc_data(j).(use_models{i}).tc(:,3),true,true);
            
            dpd = dpd(idx);
            
            m = cf_dirs(i)*circular_mean(dpd);
            s = circular_confmean(dpd,0.01);%circular_std(dpd);%./sqrt(length(dpd));
            plot(j+0.1*(i-1),m.*(180/pi),'o','LineWidth',3,'Color',use_colors{i});
            plot([j+0.1*(i-1); j+0.1*(i-1)],[m + s; m - s].*(180/pi),'-','LineWidth',2,'Color',use_colors{i});
        end
    end
    
    set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 size(blocks,1)+1]);
    xlabel('Blocks of Trials','FontSize',14);
    ylabel('Population change in PD','FontSize',14);
    legend(use_models,'FontSize',14);
    title(coordinate_frame,'FontSize',14);
    
end

%%

use_model = 'muscle';
reassign_others = false;

alpha = 0.05;
comp_blocks = [1 2 3];
num_neurons = 50;

classColors = {'k','b','r','m','g','c'};

root_dir = 'F:\trial_data_files\biomech_sim_results_poisson_allMuscles\';

filenames = { ...
    'Chewie_CO_FF_2013-10-22', ...
    'Chewie_CO_FF_2013-10-23', ...
    'Chewie_CO_FF_2013-10-31', ...
    'Chewie_CO_FF_2013-11-01', ...
    'Chewie_CO_FF_2013-12-03', ...
    'Chewie_CO_FF_2013-12-04', ...
    'Chewie_CO_FF_2015-06-29', ...
    'Chewie_CO_FF_2015-06-30', ...
    'Chewie_CO_FF_2015-07-01', ...
    'Chewie_CO_FF_2015-07-03', ...
    'Chewie_CO_FF_2015-07-06', ...
    'Chewie_CO_FF_2015-07-07', ...
    'Chewie_CO_FF_2015-07-08', ...
    'Mihili_CO_FF_2014-02-17', ...
    'Mihili_CO_FF_2014-02-18', ...
    'Mihili_CO_FF_2014-03-07', ...
    'Mihili_CO_FF_2015-06-10', ...
    'Mihili_CO_FF_2015-06-11', ...
    'Mihili_CO_FF_2015-06-15', ...
    'Mihili_CO_FF_2015-06-16', ...
    'Mihili_CO_FF_2014-02-03', ...
    'Mihili_CO_FF_2015-06-17'};


[dpd_ad, dpd_wo, dpd_adwo, cell_classes, bl_avg, bl_dom, bl_r2, bl_cb,tuned_cells,cell_tuning_idx] = deal([]);
for iFile = 1:length(filenames)
    load([root_dir filenames{iFile} '_results.mat'],'tc_data','neural_tcs','params');
    
    
    % get index describing tuning of each cell
    % NOTE: DOESN'T WORK WITH KIN YET
    tc = neural_tcs.(use_model);
    tc_index = zeros(size(tc,1),2);
    for i = 1:size(tc,1)
        if tc(i,2) + tc(i,4) ~= 0 && tc(i,3) + tc(i,5) == 0 % it's a flexor cell
            % 0 means equal weight to both joints
            % positive means more shoulder
            % negative means more elbow
            tc_index(i,1) = 1;
            tc_index(i,2) = (abs(tc(i,2)) - abs(tc(i,4)))/(abs(tc(i,2)) + abs(tc(i,4)));
        elseif tc(i,3) + tc(i,5) ~= 0 && tc(i,2) + tc(i,4) == 0 % it's an extensor cell
            tc_index(i,1) = 2;
            tc_index(i,2) = (abs(tc(i,3)) - abs(tc(i,5)))/(abs(tc(i,3)) + abs(tc(i,5)));
        else % we didn't do synergies
            % 0 means equal weight to flexion and extension
            % negative means more flexion
            % positive means more extension
            tc_index(i,1) = 3;
            tc_index(i,2) = ((abs(tc(i,2))+abs(tc(i,4))) - (abs(tc(i,3))+abs(tc(i,5))))/((abs(tc(i,2))+abs(tc(i,4))) + (abs(tc(i,3))+abs(tc(i,5))));
        end
    end
    
    
%     mean(tc_data(1).(use_model).rs,2) > 0.5 & ...
    is_tuned = all(prctile(tc_data(1).(use_model).rs,[2.5 97.5],2) > 0.5,2) & ...
        all(prctile(tc_data(2).(use_model).rs,[2.5 97.5],2) > 0.5,2) & ...
        all(prctile(tc_data(3).(use_model).rs,[2.5 97.5],2) > 0.5,2) & ...
        angleDiff(tc_data(1).(use_model).cb{3}(:,1),tc_data(1).(use_model).cb{3}(:,2),true,false) < 40*pi/180 & ...
        angleDiff(tc_data(2).(use_model).cb{3}(:,1),tc_data(2).(use_model).cb{3}(:,2),true,false) < 40*pi/180 & ...
         angleDiff(tc_data(3).(use_model).cb{3}(:,1),tc_data(3).(use_model).cb{3}(:,2),true,false) < 40*pi/180;
    
    % get some facts about the tuned cells
    bl_avg = [bl_avg; tc_data(1).(use_model).tc(:,1)]; % mean
    bl_dom = [bl_dom; tc_data(1).(use_model).tc(:,2)]; % modulation depth
    bl_r2 = [bl_r2; mean(tc_data(1).(use_model).rs,2)]; % r-squared
    bl_cb = [bl_cb; angleDiff(tc_data(1).(use_model).cb{3}(:,1),tc_data(1).(use_model).cb{3}(:,2),true,false)];
    
    % get PDs
    bl = tc_data(1).(use_model).tc(:,3);
    ad = tc_data(2).(use_model).tc(:,3);
    wo = tc_data(3).(use_model).tc(:,3);
    
    temp = angleDiff(bl,ad,true,true);
    
    if mean(temp) < 0
        temp = -temp;
    end
    
    dpd_ad = [dpd_ad; temp];
    dpd_wo = [dpd_wo; angleDiff(bl,wo,true,true)];
    dpd_adwo = [dpd_adwo; angleDiff(ad,wo,true,true)];
    
    
    % classify
    all_perms = nchoosek(comp_blocks,2);
    
    is_diff = zeros(num_neurons,size(all_perms,1));
    for j = 1:size(all_perms,1)
        for i = 1:size(tc_data(1).(use_model).boot_pds,1)
            cb = prctile(angleDiff(tc_data(all_perms(j,1)).(use_model).boot_pds(i,:),tc_data(all_perms(j,2)).(use_model).boot_pds(i,:),true,true),100*[alpha/2,1-alpha/2],2);
            if isempty(range_intersection([0 0],cb))
                is_diff(i,j) = 1;
            end
        end
    end
    
    cc = zeros(size(is_diff,1),1);
    for i = 1:size(is_diff,1)
        % 2 dynamic: 1 0 1
        % 1 kinematic: 0 0 0
        % 3 memory I: 1 1 0
        % 4 memory II: 0 1 1
        % 5 other: 1 1 1
        if all(is_diff(i,:) == [0 0 0])
            cc(i) = 1;
        elseif all(is_diff(i,:) == [1 0 1]) || all(is_diff(i,:) == [0 0 1])
            cc(i) = 2;
        elseif all(is_diff(i,:) == [1 1 0]) || all(is_diff(i,:) == [1 0 0])
            cc(i) = 3;
        elseif all(is_diff(i,:) == [0 1 1]) || all(is_diff(i,:) == [0 1 0])
            cc(i) = 4;
        elseif all(is_diff(i,:) == [1 1 1])
            cc(i) = 5;
        else
            cc(i) = 6;
        end
    end
    
    cell_classes = [cell_classes; cc];
    tuned_cells = [tuned_cells; is_tuned];
    cell_tuning_idx = [cell_tuning_idx; tc_index];
end

if reassign_others
    mem_ind = abs(dpd_wo) ./ min( abs(dpd_ad) , abs(dpd_adwo) );
    idx = cell_classes == 5 & mem_ind >= 1;
    cell_classes(idx) = 3;
    idx = cell_classes == 5 & mem_ind < 1;
    cell_classes(idx) = 2;
end

tuned_cells = logical(tuned_cells);

bl_avg = bl_avg(tuned_cells);
bl_dom = bl_dom(tuned_cells);
bl_r2 = bl_r2(tuned_cells);
bl_cb = bl_cb(tuned_cells);
dpd_ad = dpd_ad(tuned_cells);
dpd_wo = dpd_wo(tuned_cells);
dpd_adwo = dpd_adwo(tuned_cells);
cell_classes = cell_classes(tuned_cells);

cell_tuning_joint = cell_tuning_idx(tuned_cells,1);
cell_tuning_idx = cell_tuning_idx(tuned_cells,2);

binsize = 5;
figure('Position',[300 50 950 950]);
subplot1(2,2,'Gap',[0 0]);
subplot1(3);
hold all;
% plot(dpd_ad.*(180/pi),dpd_wo.*(180/pi),'d','LineWidth',2);
for i  = 1:length(dpd_ad)
    plot(dpd_ad(i).*(180/pi),dpd_wo(i).*(180/pi),'d','LineWidth',2,'Color',classColors{cell_classes(i)});
end
plot([-180,180],[0 0],'k--','LineWidth',1);
plot([0 0],[-180,180],'k--','LineWidth',1);
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[-180,180],'YLim',[-180,180]);

xlabel('dPD Base to Force','FontSize',14);
ylabel('dPD Base to Wash','FontSize',14);

subplot1(1);
hold all;
hist(dpd_ad.*180/pi,-180:binsize:180);
axis('tight');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[-180,180],'XTick',[],'YTick',[]);

subplot1(4);
hold all;
hist(dpd_wo.*180/pi,-180:binsize:180);
axis('tight');
set(gca,'CameraUpVector',[1,0,0],'Xdir','reverse');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[-180,180],'XTick',[],'YTick',[]);

subplot1(2);
set(gca,'Box','off','Visible','off');

figure;
[k,x] = hist(cell_classes,1:5);
bar(x,100*k/sum(k),1)
set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',1:5,'XTickLabel',{'Kin','Dyn','MemI','MemII','Other'},'XLim',[0 6]);
ylabel('Percent of Cells','FontSize',14);
title([use_model '-based neurons'],'FontSize',14);


figure;
hold all;
for i = 1:5
    m = mean(bl_cb(cell_classes==i));
    s = std(bl_cb(cell_classes==i))/sqrt(sum(cell_classes==i));
    
    plot(i,m,'ko','LineWidth',3);
    plot([i,i],[m-s,m+s],'k-','LineWidth',2);
end

%%
close all;

figure;
subplot(2,6,1);
hist(bl_avg(cell_classes==2 | cell_classes== 3 | cell_classes== 5),0:1:35);
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight'); title('avg');

ylabel('Dynamic cells');
subplot(2,6,2);
hist(bl_dom(cell_classes==2 | cell_classes== 3 | cell_classes== 5),0:1:35);
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight'); title('dom');
subplot(2,6,3);
hist(bl_r2(cell_classes==2 | cell_classes== 3 | cell_classes== 5),0.5:0.01:1);
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight'); title('r2');
subplot(2,6,4);
hist(180/pi*bl_cb(cell_classes==2 | cell_classes== 3 | cell_classes== 5), 180/pi*(0:pi/180:40*pi/180));
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight'); title('cb');
subplot(2,6,5);
hist(180/pi*dpd_ad(cell_classes==2 | cell_classes== 3 | cell_classes== 5),180/pi*(-180*pi/180:5*pi/180:180*pi/180));
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight'); title('dpd');
subplot(2,6,6);
hist(cell_tuning_idx(cell_classes==2 | cell_classes== 3 | cell_classes== 5),-1:0.05:1);
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight');

subplot(2,6,7);
hist(bl_avg(cell_classes==1 | cell_classes== 4),0:1:35);
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight');
ylabel('Kinematic Cells');
subplot(2,6,8);
hist(bl_dom(cell_classes==1 | cell_classes== 4),0:1:35);
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight');
subplot(2,6,9);
hist(bl_r2(cell_classes==1 | cell_classes== 4),0.5:0.01:1);
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight');
subplot(2,6,10);
hist(180/pi*bl_cb(cell_classes==1 | cell_classes== 4),180/pi*(0:pi/180:40*pi/180));
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight');
subplot(2,6,11);
hist(180/pi*dpd_ad(cell_classes==1 | cell_classes== 4),180/pi*(-180*pi/180:5*pi/180:180*pi/180));
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight');
subplot(2,6,12);
hist(cell_tuning_idx(cell_classes==1 | cell_classes== 4),-1:0.05:1);
set(gca,'Box','off','TickDir','out','FontSize',14); axis('tight');


%%
if 0
    comp_blocks = [1 2 3];
    bin_size = 15;
    figure;
    for i = 1:length(use_models)
        dpd1 = cf_dirs(i)*angleDiff(tc_data(comp_blocks(1)).(use_models{i}).tc(:,3),tc_data(comp_blocks(2)).(use_models{i}).tc(:,3),true,true).*(180/pi);
        dpd2 = angleDiff(tc_data(comp_blocks(1)).(use_models{i}).tc(:,3),tc_data(comp_blocks(3)).(use_models{i}).tc(:,3),true,true).*(180/pi);
        
        % find which cells are tuned in all epochs
        idx = ones(num_neurons,size(blocks,1));
        for j = 1:size(blocks,1)
            idx(:,j) = mean(tc_data(j).(use_models{i}).rs,2) > 0.5;
        end
        
        idx = all(idx,2);
        
        subplot(length(use_models),2,2*(i-1)+1)
        hist(dpd1(idx),-180:bin_size:180);
        axis('tight');
        set(gca,'Box','off','TickDir','out','FontSize',14,'Xlim',[-180 180]);
        title([use_models{i} ': Curl Field'],'FontSize',14);
        xlabel('Change in PD (Deg)','FontSize',14);
        
        subplot(length(use_models),2,2*(i-1)+2)
        hist(dpd2(idx),-180:bin_size:180);
        axis('tight');
        set(gca,'Box','off','TickDir','out','FontSize',14,'Xlim',[-180 180]);
        title([use_models{i} ': Washout'],'FontSize',14);
        xlabel('Change in PD (Deg)','FontSize',14);
    end
end


%% plot sliding window thing
if 1
    root_dir = 'F:\trial_data_files\biomech_sim_results_poisson_allMuscles\';
    use_model = 'muscle';
    doMD = false;
    
    figure;
    subplot1(1,2);
    
    filenames = { ...
                'Chewie_CO_FF_2013-10-22', ...
                'Chewie_CO_FF_2013-10-23', ...
                'Chewie_CO_FF_2013-10-31', ...
                'Chewie_CO_FF_2013-11-01', ...
                'Chewie_CO_FF_2013-12-03', ...
                'Chewie_CO_FF_2013-12-04', ...
                'Chewie_CO_FF_2015-06-29', ...
        'Chewie_CO_FF_2015-06-30', ...
        'Chewie_CO_FF_2015-07-01', ...
        'Chewie_CO_FF_2015-07-03', ...
        'Chewie_CO_FF_2015-07-06', ...
        'Chewie_CO_FF_2015-07-07', ...
        'Chewie_CO_FF_2015-07-08'};
    %     'Mihili_CO_FF_2014-02-17', ...
    %     'Mihili_CO_FF_2014-02-18', ...
    %     'Mihili_CO_FF_2014-03-07', ...
    %     'Mihili_CO_FF_2015-06-10', ...
    %     'Mihili_CO_FF_2015-06-11', ...
    %     'Mihili_CO_FF_2015-06-15', ...
    %     'Mihili_CO_FF_2015-06-16'};
    
    
    for iFile = 1:length(filenames)
        load([root_dir filenames{iFile} '_results.mat'],'sw_data','tc_data');
        
        tuned_cells = mean(tc_data(1).(use_model).rs,2) > 0.5;
        
        if iFile == 1
            day_dpd = zeros(length(filenames),length(sw_data));
            all_dpd = cell(1,length(sw_data));
            all_f = zeros(length(filenames),length(sw_data));
        end
        
        for iBlock = 1:length(sw_data)
            if doMD
                bl = sw_data(iBlock).tc_data(1).(use_model).tc(tuned_cells,2);
                ad = sw_data(iBlock).tc_data(2).(use_model).tc(tuned_cells,2);
                dpd = abs(ad - bl);
                day_dpd(iFile,iBlock) = mean(dpd);
            else
                bl = sw_data(iBlock).tc_data(1).(use_model).tc(tuned_cells,3);
                ad = sw_data(iBlock).tc_data(2).(use_model).tc(tuned_cells,3);
                dpd = angleDiff(bl,ad,true,false);
                day_dpd(iFile,iBlock) = circular_mean(dpd);
            end
            
            df = abs(mean(sw_data(iBlock).data(2).f) - mean(sw_data(iBlock).data(1).f));
            
            all_dpd{iBlock} = [all_dpd{iBlock}; dpd];
            
            all_f(iFile,iBlock) = mean(df);
        end
    end
    
    all_dpd = cell2mat(all_dpd);
    
    subplot1(1);
    ax1 = gca;
    hold all;
    
    for i = 1:size(all_dpd,2)
        if doMD
            m(i) = mean(all_dpd(:,i));
            s(i) = std(all_dpd(:,i))./sqrt(length(all_dpd));
        else
        m(i) = circular_mean(all_dpd(:,i));
        s(i) = circular_std(all_dpd(:,i))./sqrt(length(all_dpd));
        end
    end
    
    plot(1:length(all_f),m.*(180/pi),'b','LineWidth',2);
    plot([1:length(all_f);1:length(all_f)],[m-s; m+s].*(180/pi),'b','LineWidth',2);
    set(ax1,'XLim',[0 length(all_f)+1],'Box','off','TickDir','out','FontSize',14,'XTickLabel',[],'YLim',[50 110]);
    ylabel('mean dPD','FontSize',14);
    xlabel('Windows over movement','FontSize',14);
    
    ax1_pos = get(ax1,'Position'); % store position of first axes
    ax2 = axes('Position',ax1_pos,...
        'YAxisLocation','right',...
        'Color','none', ...
        'TickDir','out');
    hold all;
    
    m = mean(all_f,1);
    s = std(all_f,1)./sqrt(size(all_f,1));
    plot(1:length(all_f),m,'k','LineWidth',2);
    plot([1:length(all_f);1:length(all_f)],[m-s; m+s],'k','LineWidth',2);
    set(ax2,'XLim',[0 length(all_f)+1],'Box','off','XTick',[],'FontSize',14,'YLim',[0 2.5],'YTick',[]);
    % ylabel('mean dForce','FontSize',14);
    
    title('Chewie','FontSize',14);
    
    % figure;
    % plot(reshape(all_f,1,size(all_f,2)*size(all_f,1)),reshape(day_dpd,1,size(day_dpd,2)*size(day_dpd,1)).*(180/pi),'bo','LineWidth',2);
    % set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 2.5],'YLim',[20 120]);
    % xlabel('Change in Force','FontSize',14);
    % ylabel('dPD','FontSize',14);
    
    
    
    filenames = { ...
        'Mihili_CO_FF_2014-02-17', ...
        'Mihili_CO_FF_2014-02-18', ...
        'Mihili_CO_FF_2014-03-07', ...
        'Mihili_CO_FF_2015-06-10', ...
        'Mihili_CO_FF_2015-06-11', ...
        'Mihili_CO_FF_2015-06-15', ...
        'Mihili_CO_FF_2015-06-16', ...
        'Mihili_CO_FF_2014-02-03', ...
        'Mihili_CO_FF_2015-06-17'};
    
    
    for iFile = 1:length(filenames)
        load([root_dir filenames{iFile} '_results.mat'],'sw_data','tc_data');
        
        tuned_cells = mean(tc_data(1).(use_model).rs,2) > 0.5;
        
        if iFile == 1
            day_dpd = zeros(length(filenames),length(sw_data));
            all_dpd = cell(1,length(sw_data));
            all_f = zeros(length(filenames),length(sw_data));
        end
        
        for iBlock = 1:length(sw_data)
            if doMD
                bl = sw_data(iBlock).tc_data(1).(use_model).tc(tuned_cells,2);
                ad = sw_data(iBlock).tc_data(2).(use_model).tc(tuned_cells,2);
                dpd = abs(ad - bl);
                day_dpd(iFile,iBlock) = mean(dpd);
            else
                bl = sw_data(iBlock).tc_data(1).(use_model).tc(tuned_cells,3);
                ad = sw_data(iBlock).tc_data(2).(use_model).tc(tuned_cells,3);
                dpd = angleDiff(bl,ad,true,false);
                day_dpd(iFile,iBlock) = circular_mean(dpd);
            end
            
            df = abs(mean(sw_data(iBlock).data(2).f) - mean(sw_data(iBlock).data(1).f));
            
            all_dpd{iBlock} = [all_dpd{iBlock}; dpd];
            
            all_f(iFile,iBlock) = mean(df);
        end
    end
    
    all_dpd = cell2mat(all_dpd);
    
    subplot1(2);
    ax1 = gca;
    hold all;
    
    for i = 1:size(all_dpd,2)
        if doMD
            m(i) = mean(all_dpd(:,i));
            s(i) = std(all_dpd(:,i))./sqrt(length(all_dpd));
        else
        m(i) = circular_mean(all_dpd(:,i));
        s(i) = circular_std(all_dpd(:,i))./sqrt(length(all_dpd));
        end
    end
    
    plot(1:length(all_f),m.*(180/pi),'b','LineWidth',2);
    plot([1:length(all_f);1:length(all_f)],[m-s; m+s].*(180/pi),'b','LineWidth',2);
    set(ax1,'XLim',[0 length(all_f)+1],'Box','off','TickDir','out','FontSize',14,'XTickLabel',[],'YTick',[],'YLim',[50 110]);
    xlabel('Windows over movement','FontSize',14);
    
    ax1_pos = get(ax1,'Position'); % store position of first axes
    ax2 = axes('Position',ax1_pos,...
        'YAxisLocation','right',...
        'Color','none', ...
        'TickDir','out');
    hold all;
    
    m = mean(all_f,1);
    s = std(all_f,1)./sqrt(size(all_f,1));
    plot(1:length(all_f),m,'k','LineWidth',2);
    plot([1:length(all_f);1:length(all_f)],[m-s; m+s],'k','LineWidth',2);
    set(ax2,'XLim',[0 length(all_f)+1],'Box','off','XTick',[],'FontSize',14,'YLim',[0 2.5]);
    ylabel('mean dForce','FontSize',14);
    
    title('Mihili','FontSize',14);
    
end

%%
%         for unit = 1:num_neurons
%             figure;
%             hold all;
%             idx = strcmpi({trial_data.epoch},'BL');
%             plot(theta(idx & ~bad_trials),fr(idx & ~bad_trials,unit),'o')
%             idx = find(strcmpi({trial_data.epoch},'AD') & ~bad_trials);
%             idx = idx(floor(0.33*length(idx))+1:floor(1*length(idx)));
%             plot(theta(idx),fr(idx,unit),'o')
%             idx = strcmpi({trial_data.epoch},'WO');
%             plot(theta(idx & ~bad_trials),fr(idx & ~bad_trials,unit),'o')
%             pause;
%             close all;
%         end
