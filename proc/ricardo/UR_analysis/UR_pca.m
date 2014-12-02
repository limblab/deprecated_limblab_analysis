function params = UR_pca(data_struct,params)

UR = data_struct.UR;
bdf = data_struct.bdf;

if isempty(UR.firingrates_mov)
    return
end
%% Movement during bump trials
binsize = 50;

clear condition_idx

for iStiffness = 1:length(UR.stiffnesses_idx)
    for iBump = 1:length(UR.bump_directions_idx)       
        if (iStiffness == 1 && iBump == 1)
            temp_fr = [];
            temp_x_pos = [];
            temp_y_pos = [];
            previous_end_idx = 0;
        end
        condition_idx{iStiffness,iBump} = UR.stiffnesses_idx{iStiffness};
    %     stiffness_idx{iStiffness} = intersect(stiffness_idx{iStiffness},UR.no_bump_trials);
        condition_idx{iStiffness,iBump} = intersect(condition_idx{iStiffness,iBump},UR.bump_trials);
        condition_idx{iStiffness,iBump} = intersect(condition_idx{iStiffness,iBump},UR.bump_directions_idx{iBump});
        temp_fr = [temp_fr ; UR.firingrates_mov(condition_idx{iStiffness,iBump},:,:)];
        temp_x_pos = [temp_x_pos; UR.pos_mov_x(condition_idx{iStiffness,iBump},:)];
        temp_y_pos = [temp_y_pos; UR.pos_mov_y(condition_idx{iStiffness,iBump},:)];
        condition_idx{iStiffness,iBump} = previous_end_idx+(1:length(condition_idx{iStiffness,iBump}));
        previous_end_idx = condition_idx{iStiffness,iBump}(end);
    end
end
x_pos_mov_binned = zeros(size(temp_x_pos,1),floor(size(temp_x_pos,2)/binsize));
y_pos_mov_binned = zeros(size(temp_x_pos,1),floor(size(temp_x_pos,2)/binsize));
firing_rates_mov_binned = zeros(size(temp_fr,1),floor(size(temp_fr,2)/binsize),size(temp_fr,3));
% firing_rates_mov_binned = zeros(size(temp_fr,1),floor(size(temp_fr,2)/binsize),size(temp_fr,3));
for iTime = 1:size(firing_rates_mov_binned,2)
    firing_rates_mov_binned(:,iTime,:) = mean(temp_fr(:,(iTime-1)*binsize+(1:50),:),2);
    x_pos_mov_binned(:,iTime,:) = mean(temp_x_pos(:,(iTime-1)*binsize+(1:50),:),2);
    y_pos_mov_binned(:,iTime,:) = mean(temp_y_pos(:,(iTime-1)*binsize+(1:50),:),2);
    t_mov_binned(iTime) = mean(UR.t_mov((iTime-1)*binsize+(1:50)));
end

temp = reshape(firing_rates_mov_binned,size(firing_rates_mov_binned,1)*size(firing_rates_mov_binned,2),[]);
[coeff,score,latent,tsaquared,explained] = pca(temp);
score = reshape(score,size(firing_rates_mov_binned,1),size(firing_rates_mov_binned,2),[]);

%
params.fig_handles(end+1) = figure;
h_pca = subplot(121);
hold on
h_mov = subplot(122);
axis equal
hold on
x_limit_pca = [min(min(min(score(:,:,1)))) max(max(max(score(:,:,1))))];
y_limit_pca = [min(min(min(score(:,:,2)))) max(max(max(score(:,:,2))))];
z_limit_pca = [min(min(min(score(:,:,3)))) max(max(max(score(:,:,3))))];
x_limit_pos = [min(min(min(x_pos_mov_binned(:,:)))) max(max(max(x_pos_mov_binned(:,:))))];
y_limit_pos = [min(min(min(y_pos_mov_binned(:,:)))) max(max(max(y_pos_mov_binned(:,:))))];


axis equal
clear h_dots
for iStiffness = 1:length(UR.stiffnesses_idx)  
    for iBump = 1 :length(UR.bump_directions)
%         h_dots{iStiffness} = plot3((score(condition_idx{iStiffness,iBump},1:2,1))',...
%             (score(condition_idx{iStiffness,iBump},1:2,2))',...
%             (score(condition_idx{iStiffness,iBump},1:2,3))','-','Color',UR.stiffness_colors(iStiffness,:),...
%             'Parent',h_pca);
        h_dots_mean{iStiffness,iBump} = plot3(mean(score(condition_idx{iStiffness,iBump},1:2,1))',...
            mean(score(condition_idx{iStiffness,iBump},1:2,2))',...
            mean(score(condition_idx{iStiffness,iBump},1:2,3))','-','Color',UR.stiffness_colors(iStiffness,:),...
            'Parent',h_pca);
%     h_stars(iStiffness) = plot3(mean(score(:,1,1)),score(:,1,2),score(:,1,3),'.','Color',UR.stiffness_colors(iStiffness,:));
        h_pos_mean{iStiffness,iBump} = plot(mean(x_pos_mov_binned(condition_idx{iStiffness,iBump},1)),...
            mean(y_pos_mov_binned(condition_idx{iStiffness,iBump},1)),'-','Color',UR.stiffness_colors(iStiffness,:),...
            'Parent',h_mov);
    end
end

for iTime = 1:size(score,2)
    for iStiffness = 1:length(UR.stiffnesses_idx)
        for iBump = 1 :length(UR.bump_directions_idx)
            for iTrial = 1:length(condition_idx{iStiffness,iBump})
%                 set(h_dots{iStiffness}(iTrial),...
%                     'XData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,1)',...
%                     'YData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,2)',...
%                     'ZData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,3)');

                set(h_dots_mean{iStiffness,iBump},...
                    'XData',mean(score(condition_idx{iStiffness,iBump},1:iTime,1))',...
                    'YData',mean(score(condition_idx{iStiffness,iBump},1:iTime,2))',...
                    'ZData',mean(score(condition_idx{iStiffness,iBump},1:iTime,3))');
                set(h_pos_mean{iStiffness,iBump},...
                    'XData',mean(x_pos_mov_binned(condition_idx{iStiffness,iBump},1:iTime))',...
                    'YData',mean(y_pos_mov_binned(condition_idx{iStiffness,iBump},1:iTime))');                    
            end
        end
    end
    set(h_pca,'XLim',x_limit_pca,'YLim',y_limit_pca,'ZLim',z_limit_pca);
    set(h_mov,'XLim',x_limit_pos,'YLim',y_limit_pos);
    title(['t = ' num2str(t_mov_binned(iTime)) ' ms'])
    pause(.2)
    
end

%% Individual PCAs
params.fig_handles(end+1) = figure;
for iStiffness = 1:size(condition_idx,1)
    for iBump = 1:size(condition_idx,2)
        subplot(411)
        hold on
        plot(t_mov_binned,mean(score(condition_idx{iStiffness,iBump},:,1)),'Color',UR.stiffness_colors(iStiffness,:))
        title('PC1')

        subplot(412)
        hold on
        plot(t_mov_binned,mean(score(condition_idx{iStiffness,iBump},:,2)),'Color',UR.stiffness_colors(iStiffness,:))
        title('PC2')

        subplot(413)
        hold on
        plot(t_mov_binned,mean(score(condition_idx{iStiffness,iBump},:,3)),'Color',UR.stiffness_colors(iStiffness,:))
        title('PC3')

        subplot(414)
        hold on
        plot(t_mov_binned,mean(score(condition_idx{iStiffness,iBump},:,4)),'Color',UR.stiffness_colors(iStiffness,:))
        title('PC4')
    end
end
xlabel('t (s)')

%% Movement during no bump trials
binsize = 50;
t_range = [-.5 2];

clear condition_idx

t_idx = (UR.t_mov >= t_range(1) & UR.t_mov <= t_range(2));
t_vector = UR.t_mov(t_idx);

for iStiffness = 1:length(UR.stiffnesses_idx)    
    if (iStiffness == 1)
        temp_fr = [];
        temp_x_pos = [];
        temp_y_pos = [];
        previous_end_idx = 0;
    end
    condition_idx{iStiffness} = UR.stiffnesses_idx{iStiffness};    
    condition_idx{iStiffness} = intersect(condition_idx{iStiffness},UR.no_bump_trials);
%     condition_idx{iStiffness} = intersect(condition_idx{iStiffness},find(UR.trial_table(:,UR.table_columns.bump_magnitude)==0));
    
    temp_fr = [temp_fr ; UR.firingrates_mov(condition_idx{iStiffness},t_idx,:)];
    temp_x_pos = [temp_x_pos; UR.pos_mov_x(condition_idx{iStiffness},t_idx)];
    temp_y_pos = [temp_y_pos; UR.pos_mov_y(condition_idx{iStiffness},t_idx)];
    condition_idx{iStiffness} = previous_end_idx+(1:length(condition_idx{iStiffness}));
    previous_end_idx = condition_idx{iStiffness}(end);
end
firing_rates_mov_binned = zeros(size(temp_fr,1),floor(size(temp_fr,2)/binsize),size(temp_fr,3));
x_pos_mov_binned = zeros(size(temp_x_pos,1),floor(size(temp_x_pos,2)/binsize));
y_pos_mov_binned = zeros(size(temp_x_pos,1),floor(size(temp_x_pos,2)/binsize));
t_mov_binned = zeros(1,floor(size(temp_x_pos,2)/binsize));

for iTime = 1:size(firing_rates_mov_binned,2)
    firing_rates_mov_binned(:,iTime,:) = mean(temp_fr(:,(iTime-1)*binsize+(1:binsize),:),2);
    x_pos_mov_binned(:,iTime) = mean(temp_x_pos(:,(iTime-1)*binsize+(1:binsize),:),2);
    y_pos_mov_binned(:,iTime) = mean(temp_y_pos(:,(iTime-1)*binsize+(1:binsize),:),2);
    t_mov_binned(iTime) = mean(t_vector((iTime-1)*binsize+(1:binsize)));
end

temp = reshape(firing_rates_mov_binned,size(firing_rates_mov_binned,1)*size(firing_rates_mov_binned,2),[]);
[coeff,score,latent,tsaquared,explained] = pca(temp);
score = reshape(score,size(firing_rates_mov_binned,1),size(firing_rates_mov_binned,2),[]);

%
params.fig_handles(end+1) = figure;
h_pca = subplot(121);
hold on
h_mov = subplot(122);
axis equal
hold on
x_limit_pca = [min(min(min(score(:,:,1)))) max(max(max(score(:,:,1))))];
y_limit_pca = [min(min(min(score(:,:,2)))) max(max(max(score(:,:,2))))];
z_limit_pca = [min(min(min(score(:,:,3)))) max(max(max(score(:,:,3))))];
x_limit_pos = [min(min(min(x_pos_mov_binned(:,:)))) max(max(max(x_pos_mov_binned(:,:))))];
y_limit_pos = [min(min(min(y_pos_mov_binned(:,:)))) max(max(max(y_pos_mov_binned(:,:))))];


axis equal
clear h_dots
for iStiffness = 1:length(UR.stiffnesses_idx)      
%         h_dots{iStiffness} = plot3((score(condition_idx{iStiffness,iBump},1:2,1))',...
%             (score(condition_idx{iStiffness,iBump},1:2,2))',...
%             (score(condition_idx{iStiffness,iBump},1:2,3))','-','Color',UR.stiffness_colors(iStiffness,:),...
%             'Parent',h_pca);
        h_dots_mean{iStiffness} = plot3(mean(score(condition_idx{iStiffness},1:2,1))',...
            mean(score(condition_idx{iStiffness},1:2,2))',...
            mean(score(condition_idx{iStiffness},1:2,3))','-','Color',UR.stiffness_colors(iStiffness,:),...
            'Parent',h_pca);
%         h_pos_mean{iStiffness} = plot(mean(x_pos_mov_binned(condition_idx{iStiffness},1)),...
%             mean(y_pos_mov_binned(condition_idx{iStiffness},1)),'-','Color',UR.stiffness_colors(iStiffness,:),...
%             'Parent',h_mov);
        h_pos_mean{iStiffness} = plot((x_pos_mov_binned(condition_idx{iStiffness},1:2)'),...
            (y_pos_mov_binned(condition_idx{iStiffness},1:2)'),'-','Color',UR.stiffness_colors(iStiffness,:),...
            'Parent',h_mov);
end

for iTime = 1:size(score,2)
    for iStiffness = 1:length(UR.stiffnesses_idx)        
        for iTrial = 1:length(condition_idx{iStiffness})
%                 set(h_dots{iStiffness}(iTrial),...
%                     'XData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,1)',...
%                     'YData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,2)',...
%                     'ZData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,3)');

            set(h_dots_mean{iStiffness},...
                'XData',mean(score(condition_idx{iStiffness},1:iTime,1))',...
                'YData',mean(score(condition_idx{iStiffness},1:iTime,2))',...
                'ZData',mean(score(condition_idx{iStiffness},1:iTime,3))');
%             set(h_pos_mean{iStiffness},...
%                 'XData',mean(x_pos_mov_binned(condition_idx{iStiffness},1:iTime))',...
%                 'YData',mean(y_pos_mov_binned(condition_idx{iStiffness},1:iTime))');   
            set(h_pos_mean{iStiffness}(iTrial),...
                'XData',(x_pos_mov_binned(condition_idx{iStiffness}(iTrial),1:iTime))',...
                'YData',(y_pos_mov_binned(condition_idx{iStiffness}(iTrial),1:iTime))'); 
        end
    end
    set(h_pca,'XLim',x_limit_pca,'YLim',y_limit_pca,'ZLim',z_limit_pca);
%     set(h_mov,'XLim',x_limit_pos,'YLim',y_limit_pos);
    title(['t = ' num2str(t_mov_binned(iTime)) ' ms'])
    pause(.2)    
end

%% Individual PCAs
params.fig_handles(end+1) = figure;

for iCondition = 1:length(condition_idx)
    subplot(411)
    hold on
    plot(t_mov_binned,mean(score(condition_idx{iCondition},:,1)),'Color',UR.stiffness_colors(iCondition,:))
    title('PC1')
    
    subplot(412)
    hold on
    plot(t_mov_binned,mean(score(condition_idx{iCondition},:,2)),'Color',UR.stiffness_colors(iCondition,:))
    title('PC2')
    
    subplot(413)
    hold on
    plot(t_mov_binned,mean(score(condition_idx{iCondition},:,3)),'Color',UR.stiffness_colors(iCondition,:))
    title('PC3')
    
    subplot(414)
    hold on
    plot(t_mov_binned,mean(score(condition_idx{iCondition},:,4)),'Color',UR.stiffness_colors(iCondition,:))
    title('PC4')
end
xlabel('t (s)')
    
    
