
%%
if 1
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
        
        alpha = 0.05;
        comp_blocks = [1 2 3];
        
root_dir = 'F:\trial_data_files\';

filenames = { ...
% %         'Chewie_CO_FF_2013-10-22', ...
% %         'Chewie_CO_FF_2013-10-23', ...
% %         'Chewie_CO_FF_2013-10-31', ...
% %         'Chewie_CO_FF_2013-11-01', ...
% %         'Chewie_CO_FF_2013-12-03', ...
% %         'Chewie_CO_FF_2013-12-04', ...
% %         'Chewie_CO_FF_2015-06-29', ...
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
    'Mihili_CO_FF_2015-06-16'};


dpd_ad = [];
dpd_wo = [];
cell_classes = [];
for iFile = 1:length(filenames)
    load([root_dir filenames{iFile} '_results.mat'],'sw_data','tc_data');
    
    tuned_cells = mean(tc_data(1).muscle.rs,2) > 0.5;
   
    
        bl = tc_data(1).muscle.tc(tuned_cells,3);
        ad = tc_data(2).muscle.tc(tuned_cells,3);
        wo = tc_data(3).muscle.tc(tuned_cells,3);
        
        temp = angleDiff(bl,ad,true,true);
        
        if mean(temp) < 0
            temp = -temp;
        end
        
        dpd_ad = [dpd_ad; temp];
        dpd_wo = [dpd_wo; angleDiff(bl,wo,true,true)];
        

        
        all_perms = nchoosek(comp_blocks,2);
        
        is_diff = zeros(num_neurons,size(all_perms,1));
        for j = 1:size(all_perms,1)
            cb = prctile(angleDiff(tc_data(all_perms(j,1)).muscle.boot_pds,tc_data(all_perms(j,2)).muscle.boot_pds,true,true),100*[alpha/2,1-alpha/2],2);
            
            for i = 1:size(cb,1)
                if isempty(range_intersection([0 0],cb(i,:)))
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
                i
            end
        end
        
        cell_classes = [cell_classes; cc(tuned_cells)];
end

binsize = 2;
figure;
subplot1(2,2,'Gap',[0 0]);
subplot1(3);
hold all;
plot(dpd_ad.*(180/pi),dpd_wo.*(180/pi),'d','LineWidth',2);
plot([-180,180],[0 0],'k--','LineWidth',1);
plot([0 0],[-180,180],'k--','LineWidth',1);
set(gca,'TickDir','out','FontSize',14,'XLim',[-180,180],'YLim',[-180,180]);

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
title(['Muscle-based neurons'],'FontSize',14);

figure;
boxplot(dpd_ad,cell_classes)
    
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


