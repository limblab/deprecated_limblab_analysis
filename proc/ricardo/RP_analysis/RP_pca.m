function params = RP_pca(data_struct,params)

RP = data_struct.RP;
% bdf = data_struct.bdf;

if isempty(RP.firingrates_pert)
    return
end
%% Movement during no bump trials
binsize = 20;

clear condition_idx

frequencies = 1:length(RP.perturbation_frequencies);
% for iFrequency = 1:length(RP.perturbation_frequencies)
for iFrequency = frequencies
    for iDir = 1:length(RP.perturbation_directions)       
        if (iFrequency == 1 && iDir == 1)
            temp_fr = [];
            temp_x_pos = [];
            temp_y_pos = [];
            temp_x_force = [];
            temp_y_force = [];
            previous_end_idx = 0;
        end
        condition_idx{iFrequency,iDir} = RP.perturbation_frequencies_idx{iFrequency};
        condition_idx{iFrequency,iDir} = intersect(condition_idx{iFrequency,iDir},union(RP.no_bump_trials,RP.late_bump));
        condition_idx{iFrequency,iDir} = intersect(condition_idx{iFrequency,iDir},RP.perturbation_directions_idx{iDir});
        condition_idx{iFrequency,iDir} = intersect(condition_idx{iFrequency,iDir},RP.reward_trials);
        temp_fr = [temp_fr ; RP.firingrates_pert(condition_idx{iFrequency,iDir},:,:)];
        temp_x_pos = [temp_x_pos; RP.pos_pert_x(condition_idx{iFrequency,iDir},:)];
        temp_y_pos = [temp_y_pos; RP.pos_pert_y(condition_idx{iFrequency,iDir},:)];
        temp_x_force = [temp_x_force; RP.force_pert_x(condition_idx{iFrequency,iDir},:)];
        temp_y_force = [temp_y_force; RP.force_pert_y(condition_idx{iFrequency,iDir},:)];
        condition_idx{iFrequency,iDir} = previous_end_idx+(1:length(condition_idx{iFrequency,iDir}));
        previous_end_idx = condition_idx{iFrequency,iDir}(end);
    end
end
x_pos_pert_binned = zeros(size(temp_x_pos,1),floor(size(temp_x_pos,2)/binsize));
y_pos_pert_binned = zeros(size(temp_x_pos,1),floor(size(temp_x_pos,2)/binsize));
x_force_pert_binned = zeros(size(temp_x_force,1),floor(size(temp_x_force,2)/binsize));
y_force_pert_binned = zeros(size(temp_x_force,1),floor(size(temp_x_force,2)/binsize));
firing_rates_pert_binned = zeros(size(temp_fr,1),floor(size(temp_fr,2)/binsize),size(temp_fr,3));
% firing_rates_pert_binned = zeros(size(temp_fr,1),floor(size(temp_fr,2)/binsize),size(temp_fr,3));
for iTime = 1:size(firing_rates_pert_binned,2)
    firing_rates_pert_binned(:,iTime,:) = mean(temp_fr(:,(iTime-1)*binsize+(1:binsize),:),2);
    x_pos_pert_binned(:,iTime,:) = mean(temp_x_pos(:,(iTime-1)*binsize+(1:binsize),:),2);
    y_pos_pert_binned(:,iTime,:) = mean(temp_y_pos(:,(iTime-1)*binsize+(1:binsize),:),2);
    x_force_pert_binned(:,iTime,:) = mean(temp_x_force(:,(iTime-1)*binsize+(1:binsize),:),2);
    y_force_pert_binned(:,iTime,:) = mean(temp_y_force(:,(iTime-1)*binsize+(1:binsize),:),2);    
    t_pert_binned(iTime) = mean(RP.t_pert((iTime-1)*binsize+(1:binsize)));
end

temp = reshape(firing_rates_pert_binned,size(firing_rates_pert_binned,1)*size(firing_rates_pert_binned,2),[]);
[coeff,score,latent,tsquared,explained] = pca(temp);
score = reshape(score,size(firing_rates_pert_binned,1),size(firing_rates_pert_binned,2),[]);

%
params.fig_handles(end+1) = figure;
set(params.fig_handles(end),'Name','PCA Movement animation')            
h_pca = subplot(121);
hold on
h_pert = subplot(122);
axis equal
hold on
x_limit_pca = [min(min(min(score(:,:,1)))) max(max(max(score(:,:,1))))];
y_limit_pca = [min(min(min(score(:,:,2)))) max(max(max(score(:,:,2))))];
z_limit_pca = [min(min(min(score(:,:,3)))) max(max(max(score(:,:,3))))];
x_limit_pos = [min(min(min(x_pos_pert_binned(:,:)))) max(max(max(x_pos_pert_binned(:,:))))];
y_limit_pos = [min(min(min(y_pos_pert_binned(:,:)))) max(max(max(y_pos_pert_binned(:,:))))];


axis equal
clear h_dots
% for iFrequency = 1:length(RP.perturbation_frequencies_idx) 
for iFrequency = frequencies
    for iDir = 1:length(RP.perturbation_directions_idx)
        h_dots_mean{iFrequency,iDir} = plot3(mean(score(condition_idx{iFrequency,iDir},1:2,1))',...
            mean(score(condition_idx{iFrequency,iDir},1:2,2))',...
            mean(score(condition_idx{iFrequency,iDir},1:2,3))','-','Color',RP.perturbation_frequency_colors(iFrequency,:),...
            'Parent',h_pca);
%     h_stars(iStiffness) = plot3(mean(score(:,1,1)),score(:,1,2),score(:,1,3),'.','Color',RP.stiffness_colors(iStiffness,:));
        h_pos_mean{iFrequency,iDir} = plot(mean(x_pos_pert_binned(condition_idx{iFrequency,iDir},1)),...
            mean(y_pos_pert_binned(condition_idx{iFrequency,iDir},1)),'-','Color',RP.perturbation_frequency_colors(iFrequency,:),...
            'Parent',h_pert);
    end
end

for iTime = 1:size(score,2)
%     for iFrequency = 2
%     for iFrequency = 1:length(RP.perturbation_frequencies_idx)
    for iFrequency = frequencies    
        for iDir = 1:length(RP.perturbation_directions_idx)
%         for iDir = 1:1
            for iTrial = 1:length(condition_idx{iFrequency,iDir})
%                 set(h_dots{iStiffness}(iTrial),...
%                     'XData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,1)',...
%                     'YData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,2)',...
%                     'ZData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,3)');

                set(h_dots_mean{iFrequency,iDir},...
                    'XData',mean(score(condition_idx{iFrequency,iDir},1:iTime,1))',...
                    'YData',mean(score(condition_idx{iFrequency,iDir},1:iTime,2))',...
                    'ZData',mean(score(condition_idx{iFrequency,iDir},1:iTime,3))');
                set(h_pos_mean{iFrequency,iDir},...
                    'XData',mean(x_pos_pert_binned(condition_idx{iFrequency,iDir},1:iTime))',...
                    'YData',mean(y_pos_pert_binned(condition_idx{iFrequency,iDir},1:iTime))');                    
            end
        end
    end
    set(h_pca,'XLim',x_limit_pca,'YLim',y_limit_pca,'ZLim',z_limit_pca);
    set(h_pert,'XLim',x_limit_pos,'YLim',y_limit_pos);
    title(['t = ' num2str(t_pert_binned(iTime)) ' s'])
    pause(.05)
    
end

%% Individual PCAs
params.fig_handles(end+1) = figure;
set(params.fig_handles(end),'Name','PCA Movement')            
for iFrequency = 1:size(condition_idx,1)
    for iDir = 1:size(condition_idx,2)
        subplot(411)
        hold on
        plot(t_pert_binned,mean(score(condition_idx{iFrequency,iDir},:,1)),'Color',RP.perturbation_frequency_colors(iFrequency,:))
        title('PC1')

        subplot(412)
        hold on
        plot(t_pert_binned,mean(score(condition_idx{iFrequency,iDir},:,2)),'Color',RP.perturbation_frequency_colors(iFrequency,:))
        title('PC2')

        subplot(413)
        hold on
        plot(t_pert_binned,mean(score(condition_idx{iFrequency,iDir},:,3)),'Color',RP.perturbation_frequency_colors(iFrequency,:))
        title('PC3')

        subplot(414)
        hold on
        plot(t_pert_binned,mean(score(condition_idx{iFrequency,iDir},:,4)),'Color',RP.perturbation_frequency_colors(iFrequency,:))
        title('PC4')
    end
end
xlabel('t (s)')


%% Bump during late trials
if ~isempty(RP.bump_trials)
    binsize = 10;

    clear condition_idx

    for iFrequency = 1:length(RP.perturbation_frequencies)
        for iDir = 1:length(RP.perturbation_directions)       
            if (iFrequency == 1 && iDir == 1)
                temp_fr = [];
                temp_x_pos = [];
                temp_y_pos = [];
                temp_x_force = [];
                temp_y_force = [];
                previous_end_idx = 0;
            end
            condition_idx{iFrequency,iDir} = RP.perturbation_frequencies_idx{iFrequency};
            condition_idx{iFrequency,iDir} = intersect(condition_idx{iFrequency,iDir},RP.late_bump);
            condition_idx{iFrequency,iDir} = intersect(condition_idx{iFrequency,iDir},RP.perturbation_directions_idx{iDir});
            condition_idx{iFrequency,iDir} = intersect(condition_idx{iFrequency,iDir},RP.bump_directions_idx{RP.bump_directions ~= RP.perturbation_directions(iDir)});

            temp_fr = [temp_fr ; RP.firingrates_bump(condition_idx{iFrequency,iDir},:,:)];
            temp_x_pos = [temp_x_pos; RP.pos_bump_x(condition_idx{iFrequency,iDir},:)];
            temp_y_pos = [temp_y_pos; RP.pos_bump_y(condition_idx{iFrequency,iDir},:)];
            temp_x_force = [temp_x_force; RP.force_bump_x(condition_idx{iFrequency,iDir},:)];
            temp_y_force = [temp_y_force; RP.force_bump_y(condition_idx{iFrequency,iDir},:)];
            condition_idx{iFrequency,iDir} = previous_end_idx+(1:length(condition_idx{iFrequency,iDir}));
            previous_end_idx = condition_idx{iFrequency,iDir}(end);
        end
    end
    x_pos_bump_binned = zeros(size(temp_x_pos,1),floor(size(temp_x_pos,2)/binsize));
    y_pos_bump_binned = zeros(size(temp_x_pos,1),floor(size(temp_x_pos,2)/binsize));
    x_force_bump_binned = zeros(size(temp_x_force,1),floor(size(temp_x_force,2)/binsize));
    y_force_bump_binned = zeros(size(temp_x_force,1),floor(size(temp_x_force,2)/binsize));
    firing_rates_bump_binned = zeros(size(temp_fr,1),floor(size(temp_fr,2)/binsize),size(temp_fr,3));
    % firing_rates_bump_binned = zeros(size(temp_fr,1),floor(size(temp_fr,2)/binsize),size(temp_fr,3));
    for iTime = 1:size(firing_rates_bump_binned,2)
        firing_rates_bump_binned(:,iTime,:) = mean(temp_fr(:,(iTime-1)*binsize+(1:binsize),:),2);
        x_pos_bump_binned(:,iTime,:) = mean(temp_x_pos(:,(iTime-1)*binsize+(1:binsize),:),2);
        y_pos_bump_binned(:,iTime,:) = mean(temp_y_pos(:,(iTime-1)*binsize+(1:binsize),:),2);
        x_force_bump_binned(:,iTime,:) = mean(temp_x_force(:,(iTime-1)*binsize+(1:binsize),:),2);
        y_force_bump_binned(:,iTime,:) = mean(temp_y_force(:,(iTime-1)*binsize+(1:binsize),:),2);    
        t_bump_binned(iTime) = mean(RP.t_bump((iTime-1)*binsize+(1:binsize)));
    end

    temp = reshape(firing_rates_bump_binned,size(firing_rates_bump_binned,1)*size(firing_rates_bump_binned,2),[]);
    [coeff,score,latent,tsaquared,explained] = pca(temp);
    score = reshape(score,size(firing_rates_bump_binned,1),size(firing_rates_bump_binned,2),[]);

    %
    params.fig_handles(end+1) = figure;
    set(params.fig_handles(end),'Name','PCA Bump animation')            
    h_pca = subplot(121);
    hold on
    h_bump = subplot(122);
    axis equal
    hold on
    x_limit_pca = [min(min(min(score(:,:,1)))) max(max(max(score(:,:,1))))];
    y_limit_pca = [min(min(min(score(:,:,2)))) max(max(max(score(:,:,2))))];
    z_limit_pca = [min(min(min(score(:,:,3)))) max(max(max(score(:,:,3))))];
    x_limit_pos = [min(min(min(x_pos_bump_binned(:,:)))) max(max(max(x_pos_bump_binned(:,:))))];
    y_limit_pos = [min(min(min(y_pos_bump_binned(:,:)))) max(max(max(y_pos_bump_binned(:,:))))];


    axis equal
    clear h_dots
    for iFrequency = 1:length(RP.perturbation_frequencies_idx)  
        for iDir = 1:length(RP.perturbation_directions_idx)
            h_dots_mean{iFrequency,iDir} = plot3(mean(score(condition_idx{iFrequency,iDir},1:2,1))',...
                mean(score(condition_idx{iFrequency,iDir},1:2,2))',...
                mean(score(condition_idx{iFrequency,iDir},1:2,3))','-','Color',RP.perturbation_frequency_colors(iFrequency,:),...
                'Parent',h_pca);
    %     h_stars(iStiffness) = plot3(mean(score(:,1,1)),score(:,1,2),score(:,1,3),'.','Color',RP.stiffness_colors(iStiffness,:));
            h_pos_mean{iFrequency,iDir} = plot(mean(x_pos_bump_binned(condition_idx{iFrequency,iDir},1)),...
                mean(y_pos_bump_binned(condition_idx{iFrequency,iDir},1)),'-','Color',RP.perturbation_frequency_colors(iFrequency,:),...
                'Parent',h_bump);
        end
    end

    for iTime = 1:size(score,2)
    %     for iFrequency = 2
        for iFrequency = 1:length(RP.perturbation_frequencies_idx)
            for iDir = 1:length(RP.perturbation_directions_idx)
    %         for iDir = 1:1
                for iTrial = 1:length(condition_idx{iFrequency,iDir})
    %                 set(h_dots{iStiffness}(iTrial),...
    %                     'XData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,1)',...
    %                     'YData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,2)',...
    %                     'ZData',score(condition_idx{iStiffness,iBump}(iTrial),1:iTime,3)');

                    set(h_dots_mean{iFrequency,iDir},...
                        'XData',mean(score(condition_idx{iFrequency,iDir},1:iTime,1))',...
                        'YData',mean(score(condition_idx{iFrequency,iDir},1:iTime,2))',...
                        'ZData',mean(score(condition_idx{iFrequency,iDir},1:iTime,3))');
                    set(h_pos_mean{iFrequency,iDir},...
                        'XData',mean(x_pos_bump_binned(condition_idx{iFrequency,iDir},1:iTime))',...
                        'YData',mean(y_pos_bump_binned(condition_idx{iFrequency,iDir},1:iTime))');                    
                end
            end
        end
        set(h_pca,'XLim',x_limit_pca,'YLim',y_limit_pca,'ZLim',z_limit_pca);
        set(h_bump,'XLim',x_limit_pos,'YLim',y_limit_pos);
        title(['t = ' num2str(t_bump_binned(iTime)) ' s'])
        pause(.2)

    end
end

%% Individual PCAs
if ~isempty(RP.bump_trials)
    params.fig_handles(end+1) = figure;
    set(params.fig_handles(end),'Name','PCA Bump')  
    for iFrequency = 1:size(condition_idx,1)
        for iDir = 1:size(condition_idx,2)
            subplot(411)
            hold on
            plot(t_bump_binned,mean(score(condition_idx{iFrequency,iDir},:,1)),'Color',RP.perturbation_frequency_colors(iFrequency,:))
            title('PC1')

            subplot(412)
            hold on
            plot(t_bump_binned,mean(score(condition_idx{iFrequency,iDir},:,2)),'Color',RP.perturbation_frequency_colors(iFrequency,:))
            title('PC2')

            subplot(413)
            hold on
            plot(t_bump_binned,mean(score(condition_idx{iFrequency,iDir},:,3)),'Color',RP.perturbation_frequency_colors(iFrequency,:))
            title('PC3')

            subplot(414)
            hold on
            plot(t_bump_binned,mean(score(condition_idx{iFrequency,iDir},:,4)),'Color',RP.perturbation_frequency_colors(iFrequency,:))
            title('PC4')
        end
    end
    xlabel('t (s)')
end