%%
use_model = 'muscle';
r2_min = 0.5;

%% look for memory cells
    plot_untuned = false;
    comp_blocks = [1 2 3];
    alpha = 0.05;
    
    all_perms = nchoosek(comp_blocks,2);
    
    is_diff = zeros(num_neurons,size(all_perms,1));
    for j = 1:size(all_perms,1)
        cb = prctile(angleDiff(tc_data(all_perms(j,1)).(use_model).boot_pds,tc_data(all_perms(j,2)).(use_model).boot_pds,true,true),100*[alpha/2,1-alpha/2],2);
        
        for i = 1:size(cb,1)
            if isempty(range_intersection([0 0],cb(i,:)))
                is_diff(i,j) = 1;
            end
        end
    end
    
    cell_classes = zeros(size(is_diff,1),1);
    for i = 1:size(is_diff,1)
        % 2 dynamic: 1 0 1
        % 1 kinematic: 0 0 0
        % 3 memory I: 1 1 0
        % 4 memory II: 0 1 1
        % 5 other: 1 1 1
        if all(is_diff(i,:) == [0 0 0])
            cell_classes(i) = 1;
        elseif all(is_diff(i,:) == [1 0 1]) || all(is_diff(i,:) == [0 0 1])
            cell_classes(i) = 2;
        elseif all(is_diff(i,:) == [1 1 0]) || all(is_diff(i,:) == [1 0 0])
            cell_classes(i) = 3;
        elseif all(is_diff(i,:) == [0 1 1]) || all(is_diff(i,:) == [0 1 0])
            cell_classes(i) = 4;
        elseif all(is_diff(i,:) == [1 1 1])
            cell_classes(i) = 5;
        else
            i
        end
    end
    
    % check tuning quality
    tuned_idx = mean(tc_data(1).(use_model).rs,2) > r2_min;
    is_diff = is_diff(tuned_idx,:);
    if plot_untuned
        cell_classes(~tuned_idx) = 6;
    else
        cell_classes = cell_classes(tuned_idx,:);
    end
    
    
    figure;
    [k,x] = hist(cell_classes,1:6);
    bar(x,100*k/sum(k),1)
    set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',1:6,'XTickLabel',{'Kin','Dyn','MemI','MemII','Other','Untune'},'XLim',[0 7]);
    ylabel('Percent of Cells','FontSize',14);
    title([use_model '-based neurons'],'FontSize',14);
    
    if plot_untuned
        cell_classes = cell_classes(tuned_idx,:);
    end
    
    % get index describing tuning of each cell
    tc = neural_tcs.(use_model);
    tc = tc(tuned_idx,:);
    
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
    
    %     figure;
    %     hold all;
    %     plot(-3,0,'bo','LineWidth',3);
    %     plot(-3,0,'ro','LineWidth',3);
    %     all_counts = zeros(5,length(-1:0.1:1));
    %     for i = 1:5
    %         idx = find(cell_classes == i & tc_index(:,1)==1);
    %         for j = 1:length(idx)
    %             plot(tc_index(idx(j),2),i,'bo');
    %         end
    %         idx = find(cell_classes == i & tc_index(:,1)==2);
    %         for j = 1:length(idx)
    %             plot(tc_index(idx(j),2),i+0.1,'ro');
    %         end
    %     end
    %     imagesc(all_counts');
    %     plot([0 0],[0 6],'k--');
    %     set(gca,'FontSize',14,'Box','off','TickDir','out','Xlim',[-1 1],'XTick',[-0.6 0 0.6],'XTickLabel',{'Elbow','Equal','Shoulder'},'YLim',[0 6],'YTick',1:5,'YTickLabel',{'Kin','Dyn','MemI','MemII','Other'});
    %     ylabel('Weight Index','FontSize',14);
    %     legend({'Flexors','Extensors'},'FontSize',14,'Location','EastOutside');
    %     legend('boxoff');
    
    figure;
    hold all;
    all_counts = zeros(5,length(-1:0.1:1));
    for i = 1:5
        idx = cell_classes == i;
        k = hist(tc_index(idx,2),-1:0.1:1);
        all_counts(i,:) = k/max(k);
    end
    imagesc(-1:0.1:1,1:5,all_counts);
    axis('tight');
    set(gca,'FontSize',14,'Box','off','TickDir','out','Xlim',[-1 1],'XTick',[-0.6 0 0.6],'XTickLabel',{'Elbow','Equal','Shoulder'},'YLim',[0.5 5.5],'YTick',1:5,'YTickLabel',{'Kin','Dyn','MemI','MemII','Other'});
    ylabel('Weight Index','FontSize',14);
    
%% correlate R2 with tuning depth
figure;
hold all;
plot(mean(tc_data(1).(use_model).rs,2),abs(tc_data(1).(use_model).tc(:,2)),'.');
axis('tight');
V = axis;
plot([r2_min r2_min],V(3:4),'r--','LineWidth',3);
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 1]);
xlabel('R-Squared','FontSize',14);
ylabel('Depth of Modulation (Hz)','FontSize',14);

%% look for memory cells
    figure;
    
    % first plot memory cells as function of confidence level
    subplot(1,2,2);
    hold all;
    
    comp_blocks = [1 3];
    alpha = 0:0.001:0.25;
    filenames = {'test_100muscleneurons_03-29-16.mat', ...
        'test_100muscleneurons_nopoiss_03-29-16.mat', ...
        'test_100muscleneurons_duplicatebl_03-29-16.mat', ...
        'test_100muscleneurons_duplicateblnopoiss_03-29-16.mat'};
    plot_colors = {'k','b','r','m'};
    plot_names = {'Full','NoPoiss','CopyBL','Both'};
    
    for j = 1:length(filenames)
        plot(-1,-1,'o','LineWidth',3,'Color',plot_colors{j});
    end
    
    for j = 1:length(filenames)
        load(filenames{j},'tc_data');
        for k = 1:length(alpha)
            is_diff = zeros(num_neurons,1);
            cb = prctile(angleDiff(tc_data(comp_blocks(1)).(use_model).boot_pds,tc_data(comp_blocks(2)).(use_model).boot_pds,true,true),100*[alpha(k)/2,1-alpha(k)/2],2);
            
            for i = 1:size(cb,1)
                if isempty(range_intersection([0 0],cb(i,:)))
                    is_diff(i) = 1;
                end
            end
            
            % check tuning quality
            is_diff = is_diff(mean(tc_data(comp_blocks(1)).muscle.rs,2) > r2_min,:);
            
            plot(100*alpha(k),100*sum(is_diff)/num_neurons,'o','Color',plot_colors{j});
        end
    end
    legend(plot_names,'FontSize',14);
    legend('boxoff');
    axis('tight');
    set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',100*alpha([1,end]));
    xlabel('Confidence Level (%)','FontSize',14);
    ylabel('Percent of "Memory"-like cells','FontSize',14);
    
    V = axis;
    
    
    
    % now pick 5% level and compare
    alpha = 0.05;
    subplot(1,2,1);
    hold all;
    for j = 1:length(filenames)
        load(filenames{j},'tc_data');
        is_diff = zeros(num_neurons,1);
        cb = prctile(angleDiff(tc_data(comp_blocks(1)).(use_model).boot_pds,tc_data(comp_blocks(2)).(use_model).boot_pds,true,true),100*[alpha/2,1-alpha/2],2);
        
        for i = 1:size(cb,1)
            if isempty(range_intersection([0 0],cb(i,:)))
                is_diff(i) = 1;
            end
        end
        
        % check tuning quality
        is_diff = is_diff(mean(tc_data(comp_blocks(1)).muscle.rs,2) > r2_min);
        
        bar(j,100*sum(is_diff)/num_neurons,plot_colors{j});
    end
    h = findobj(gca,'Type','patch');
    set(h,'EdgeColor','w');
    
    axis('tight');
    set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',1:length(filenames),'XTickLabel',plot_names,'YLim',V(3:4));
    xlabel('at 5% confidence','FontSize',14);
    ylabel('Percent of "Memory"-like cells','FontSize',14);