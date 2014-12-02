function params = UR_plot_behavior(data_struct,params)
UR = data_struct.UR;
bdf = data_struct.bdf;

%% Hand position
% params.fig_handles(end+1) = figure;
% hold on
% plot(UR.pos_mov_x(:,1)',...
%     UR.pos_mov_y(:,2)','.r')
% plot(UR.pos_mov_x(:,:)',...
%     UR.pos_mov_y(:,:)','-k')
% 
% xlabel('X position (cm)')
% ylabel('Y position (cm)')
% title('Handle position')
% set(params.fig_handles(end),'Name','Handle position')
% axis equal

%% Hand position separated by stiffness
params.fig_handles(end+1) = figure;
hold on
legend_str = {};
for iStiffness = 1:length(UR.stiffnesses_idx)
    plot(0,0,'Color',UR.stiffness_colors(iStiffness,:))
    legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness)) ' N/cm']}];
end
for iStiffness = 1:length(UR.stiffnesses_idx)
    plot(UR.pos_mov_x(UR.stiffnesses_idx{iStiffness},:)',...
        UR.pos_mov_y(UR.stiffnesses_idx{iStiffness},:)',...
        'Color',UR.stiffness_colors(iStiffness,:))   
end

legend(legend_str)
xlabel('X position (cm)')
ylabel('Y position (cm)')
title('Handle position')
set(params.fig_handles(end),'Name','Handle position')
axis equal

%% Hand position separated by movement direction

for iDir = 1:length(UR.movement_directions)
    params.fig_handles(end+1) = figure;
    legend_str = {};
    hold on
    for iStiffness = 1:length(UR.stiffnesses_idx)
        plot(0,0,'Color',UR.stiffness_colors(iStiffness,:))
        legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness)) ' N/cm']}];
    end
    for iStiffness = 1:length(UR.stiffnesses_idx)
        idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
        plot(UR.pos_mov_x_rot(idx,:)',...
            UR.pos_mov_y_rot(idx,:)',...
            'Color',UR.stiffness_colors(iStiffness,:))        
    end
    xlabel('X position (cm)')
    ylabel('Y position (cm)')
    title(['Handle position. Movement direction: ' num2str(UR.movement_directions(iDir)*180/pi) '^o'])
    set(params.fig_handles(end),'Name','Handle position')
    legend(legend_str)
    axis equal
end

%% Rotated bump force separated by movement direction
% 
% for iDir = 1:length(UR.movement_directions)
%     params.fig_handles(end+1) = figure;
%     legend_str = {};
%     hold on
%     for iStiffness = 1:length(UR.stiffnesses_idx)
%         plot(0,0,'Color',UR.stiffness_colors(iStiffness,:))
%         legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness)) ' N/cm']}];
%     end
%     for iStiffness = 1:length(UR.stiffnesses_idx)        
%         idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
%         idx = intersect(idx,UR.bump_trials);
% %         plot(UR.force_mov_x_rot(idx,:)',...
%     plot(UR.t_mov,...
%             (UR.force_mov_y_rot(idx,:)-repmat(UR.force_mov_y_rot(idx,1),1,length(UR.t_mov)))',...
%             'Color',UR.stiffness_colors(iStiffness,:))        
%     end
%     xlabel('t (s)')
%     ylabel('Y force (N)')
%     title(['Force during movement. Movement direction: ' num2str(UR.movement_directions(iDir)*180/pi) '^o'])
%     set(params.fig_handles(end),'Name','Force')
%     legend(legend_str)
% %     axis equal
% end

%% Movement time separated by movement direction
% 
% for iDir = 1:length(UR.movement_directions)
%     params.fig_handles(end+1) = figure;
%     legend_str = {};
%     hold on
%     for iStiffness = 1:length(UR.stiffnesses_idx)
%        idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
%        t_movement{iDir,iStiffness} = diff(UR.trial_table(idx,[UR.table_columns.t_leave_target UR.table_columns.t_trial_end]),1,2);
%        hist(t_movement{iDir,iStiffness},[0:.05:3]);
%        temp_h = get(gca,'Children');
%        set(temp_h(end-iStiffness+1),'FaceColor',UR.stiffness_colors(iStiffness,:),...
%            'LineStyle','none')
%        legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness)) ' N/cm']}];
%     end
%     xlabel('t (s))')
%     ylabel('count')
%     title(['Movement time. Movement direction: ' num2str(UR.movement_directions(iDir)*180/pi) '^o'])
%     set(params.fig_handles(end),'Name','Handle position')
%     legend(legend_str)
% end

% %% Path length separated by movement direction
% min_path = UR.trial_table(1,UR.table_columns.movement_distance)-2*UR.trial_table(1,UR.table_columns.target_radius);
% for iTrial = 1:size(UR.trial_table,1)
%     idx = UR.trial_table(:,UR.table_columns.t_leave_target);
%     temp = sum(sqrt(sum(diff(bdf.pos(UR.leave_target_idx(iTrial):UR.ot_hold_idx(iTrial),2:3)).^2,2)));
%     path_length_vec(iTrial) = temp/min_path;
% end
%     
% for iDir = 1:length(UR.movement_directions)
%     params.fig_handles(end+1) = figure;
%     legend_str = {};
%     hold on
%     for iStiffness = 1:length(UR.stiffnesses_idx)
%         idx = intersect(UR.stiffnesses_idx{-iStiffness+3},UR.movement_directions_idx{iDir});
%         path_length{iDir,-iStiffness+3} = path_length_vec(idx);
%         hist(path_length{iDir,-iStiffness+3},1:.01:2.5);
%         temp_h = get(gca,'Children');
%         set(temp_h(end-iStiffness+1),'FaceColor',UR.stiffness_colors(-iStiffness+3,:),...
%             'LineStyle','none')
%         legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(-iStiffness+3)) ' N/cm']}];
%     end    
%     xlabel('Path length (norm)')
%     ylabel('count')
%     title(['Path length. Movement direction: ' num2str(UR.movement_directions(iDir)*180/pi) '^o'])
%     set(params.fig_handles(end),'Name','Path length')
%     xlim([1-0.01 2.5])
%     legend(legend_str)
% end

%% Position - Bump response separated by movement direction

for iDir = 1:length(UR.movement_directions)
    for iBump = 1:length(UR.bump_directions_idx)
        idx = intersect(UR.bump_directions_idx{iBump},UR.movement_directions_idx{iDir});
        if ~isempty(idx)
            params.fig_handles(end+1) = figure;
            subplot(211)
            legend_str = {};
            hold on
            for iStiffness = 1:length(UR.stiffnesses_idx)
                idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
                idx = intersect(idx,UR.bump_directions_idx{iBump});
                plot(0,0,'Color',UR.stiffness_colors(iStiffness,:))
                legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
                    ' N/cm. n = ' num2str(length(idx))]}];
            end
            for iStiffness = 1:length(UR.stiffnesses_idx)            
                idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
                idx = intersect(idx,UR.bump_directions_idx{iBump});
                if ~isempty(idx)
                    plot(UR.t_bump,...
...%                         UR.pos_bump_y_rot(idx,:)',...
                        mean(UR.pos_bump_y_rot(idx,:)),...
                        'Color',UR.stiffness_colors(iStiffness,:))               
                    h_temp = errorarea(UR.t_bump,mean(UR.pos_bump_y_rot(idx,:),1),...
                        std(UR.pos_bump_y_rot(idx,:),[],1),UR.stiffness_colors(iStiffness,:),0.5);
                    
%                     plot(UR.pos_bump_x_rot(idx,:)',...
%                         UR.pos_bump_y_rot(idx,:)',...
%                         'Color',UR.stiffness_colors(iStiffness,:))             
               end
            end
            ylabel('Y position (cm)')
            title(['Handle position. Movement direction: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
                '. Bump: ' num2str(UR.bump_directions(iBump)*180/pi) '^o'])
            subplot(212)
            hold on
            for iStiffness = 1:length(UR.stiffnesses_idx)            
                idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
                idx = intersect(idx,UR.bump_directions_idx{iBump});
                if ~isempty(idx)
                    plot(UR.t_bump,...
...%                         UR.pos_bump_y_rot(idx,:)',...
                        mean(UR.force_bump_y_rot(idx,:)),...
                        'Color',UR.stiffness_colors(iStiffness,:))               
                    h_temp = errorarea(UR.t_bump,mean(UR.force_bump_y_rot(idx,:),1),...
                        std(UR.force_bump_y_rot(idx,:),[],1),UR.stiffness_colors(iStiffness,:),0.5);
                    
%                     plot(UR.pos_bump_x_rot(idx,:)',...
%                         UR.pos_bump_y_rot(idx,:)',...
%                         'Color',UR.stiffness_colors(iStiffness,:))             
               end
            end
            xlabel('t (s)')
            ylabel('Y force (N)')
            title(['Force. Movement direction: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
                '. Bump: ' num2str(UR.bump_directions(iBump)*180/pi) '^o'])
            set(params.fig_handles(end),'Name','Bump response')            
            legend(legend_str)
        end
    end

end

%% Position - Bump response separated by movement direction

for iDir = 1:length(UR.movement_directions)
    for iBump = 1:length(UR.bump_directions_idx)
        idx = intersect(UR.bump_directions_idx{iBump},UR.movement_directions_idx{iDir});
        if ~isempty(idx)
            params.fig_handles(end+1) = figure;
            subplot(211)
            legend_str = {};
            hold on
            for iStiffness = 1:length(UR.stiffnesses_idx)
                idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
                idx = intersect(idx,UR.bump_directions_idx{iBump});
                plot(0,0,'Color',UR.stiffness_colors(iStiffness,:))
                legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
                    ' N/cm. n = ' num2str(length(idx))]}];
            end
            for iStiffness = 1:length(UR.stiffnesses_idx)            
                idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
                idx = intersect(idx,UR.bump_directions_idx{iBump});
                if ~isempty(idx)
                    plot(UR.t_bump,...
                        UR.pos_bump_y_rot(idx,:)',...
...%                         mean(UR.pos_bump_y_rot(idx,:)),...
                        'Color',UR.stiffness_colors(iStiffness,:))               
                    h_temp = errorarea(UR.t_bump,mean(UR.pos_bump_y_rot(idx,:),1),...
                        std(UR.pos_bump_y_rot(idx,:),[],1),UR.stiffness_colors(iStiffness,:),0.5);
                    
%                     plot(UR.pos_bump_x_rot(idx,:)',...
%                         UR.pos_bump_y_rot(idx,:)',...
%                         'Color',UR.stiffness_colors(iStiffness,:))             
               end
            end
            xlabel('t (s)')
            ylabel('Y position (cm)')
            title(['Handle position. Movement direction: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
                '. Bump: ' num2str(UR.bump_directions(iBump)*180/pi) '^o'])
%             axis equal            
            legend(legend_str)
            
            subplot(212)
            hold on
            for iStiffness = 1:length(UR.stiffnesses_idx)            
                idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
                idx = intersect(idx,UR.bump_directions_idx{iBump});
                if ~isempty(idx)
                    plot(UR.t_bump,...
                        UR.force_bump_y_rot(idx,:)',...
...                         mean(UR.force_bump_y_rot(idx,:)),...
                        'Color',UR.stiffness_colors(iStiffness,:))               
                    h_temp = errorarea(UR.t_bump,mean(UR.force_bump_y_rot(idx,:),1),...
                        std(UR.pos_bump_y_rot(idx,:),[],1),UR.stiffness_colors(iStiffness,:),0.5);
                    
%                     plot(UR.pos_bump_x_rot(idx,:)',...
%                         UR.pos_bump_y_rot(idx,:)',...
%                         'Color',UR.stiffness_colors(iStiffness,:))             
               end
            end
            xlabel('t (s)')
            ylabel('Y force (cm)')
            title(['Force. Movement direction: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
                '. Bump: ' num2str(UR.bump_directions(iBump)*180/pi) '^o'])
%             axis equal
            set(params.fig_handles(end),'Name',['Bump response Movement direction ' num2str(UR.movement_directions(iDir)*180/pi) ' deg' ...
                ' Bump ' num2str(UR.bump_directions(iBump)*180/pi) ' deg'])            
        end
    end

end

%% Position - Bump response separated by movement direction colored by trial number
color_low_limits = [1 .8 0; 0 1 1];
color_high_limits = [1 0 0; 0 0 1];

for iDir = 1:length(UR.movement_directions)
    params.fig_handles(end+1) = figure;  
    hold on
    x_limit = [0 0];
    y_limit = [0 0];
    subplot(1,length(UR.bump_directions),1)
    hold on         
    for iBump = 1:length(UR.bump_directions)
        legend_str = {};
        subplot(1,length(UR.bump_directions),iBump)  
        hold on
        for iStiffness = 1:length(UR.stiffnesses_idx)
            idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
            idx = intersect(idx,UR.bump_directions_idx{iBump});
            plot([0 0],[0 0],'Color',UR.stiffness_colors(iStiffness,:))
            legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
                ' N/cm. n = ' num2str(length(idx))]}];
        end
        for iStiffness = 1:length(UR.stiffnesses_idx)            
            idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
            idx = intersect(idx,UR.bump_directions_idx{iBump});
            if ~isempty(idx)
%                 plot(UR.pos_mov_x(idx,:)',...
%                     UR.pos_mov_y(idx,:)',...
%                     'Color',UR.stiffness_colors(iStiffness,:))
                for iIdx = 1:length(idx)
                    color = (iIdx-1)/(length(idx)-1) * (color_high_limits(iStiffness,:) - color_low_limits(iStiffness,:))...
                        + color_low_limits(iStiffness,:);
                    plot((UR.pos_mov_x(idx(iIdx),:)-repmat(UR.pos_mov_x(idx(iIdx),1),1,length(UR.t_mov)))',...
                        (UR.pos_mov_y(idx(iIdx),:)-repmat(UR.pos_mov_y(idx(iIdx),1),1,length(UR.t_mov)))',...
                        'Color',color)
%                     plot((UR.pos_mov_x(idx(iIdx),:))',...
%                         (UR.pos_mov_y(idx(iIdx),:))',...
%                         'Color',color)
                end
                x_limit(1) = min(x_limit(1),min(min((UR.pos_mov_x(idx,:)-repmat(UR.pos_mov_x(idx,1),1,length(UR.t_mov))))));
                x_limit(2) = max(x_limit(2),max(max((UR.pos_mov_x(idx,:)-repmat(UR.pos_mov_x(idx,1),1,length(UR.t_mov))))));
                y_limit(1) = min(y_limit(1),min(min((UR.pos_mov_y(idx,:)-repmat(UR.pos_mov_y(idx,1),1,length(UR.t_mov))))));
                y_limit(2) = max(y_limit(2),max(max((UR.pos_mov_y(idx,:)-repmat(UR.pos_mov_y(idx,1),1,length(UR.t_mov))))));
%                 x_limit(1) = min(x_limit(1),min(min((UR.pos_mov_x(idx,:)))));
%                 x_limit(2) = max(x_limit(2),max(max((UR.pos_mov_x(idx,:)))));
%                 y_limit(1) = min(y_limit(1),min(min((UR.pos_mov_y(idx,:)))));
%                 y_limit(2) = max(y_limit(2),max(max((UR.pos_mov_y(idx,:)))));
            end
            xlabel('t (s)')
            ylabel('Y position (cm)')
            title(['Handle position. Mov: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
                '. Bump: ' num2str(UR.bump_directions(iBump)*180/pi) '^o'],'Interpreter','Tex')
            axis equal
        end
    end
    h_axes = get(gcf,'Children');
    set(h_axes,'YLim',1.1*y_limit,'XLim',1.1*x_limit)
    legend(legend_str)
    set(params.fig_handles(end),'Name','Bump response')    
end

%% Position - No bump trials separated by movement direction colored by trial number
color_low_limits = [1 .8 0; 0 1 1];
color_high_limits = [1 0 0; 0 0 1];
h_legend = [];
for iDir = 1:length(UR.movement_directions)
    params.fig_handles(end+1) = figure;  
    hold on
    x_limit = [0 0];
    y_limit = [0 0];
    hold on         
    legend_str = {};
    
    for iStiffness = 1:length(UR.stiffnesses_idx)
        subplot(1,length(UR.stiffnesses_idx),iStiffness)
        hold on
        idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
        idx = intersect(idx,UR.no_bump_trials);
        plot([0 0],[0 0],'Color',UR.stiffness_colors(iStiffness,:))
        h_legend(end+1) = legend(['K = ' num2str(UR.stiffnesses(iStiffness))...
            ' N/cm. n = ' num2str(length(idx))]);
    end
    for iStiffness = 1:length(UR.stiffnesses_idx)
        subplot(1,length(UR.stiffnesses_idx),iStiffness)
        hold on
        idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
        idx = intersect(idx,UR.no_bump_trials);
        if ~isempty(idx)
            for iIdx = 1:length(idx)
                color = (iIdx-1)/(length(idx)-1) * (color_high_limits(iStiffness,:) - color_low_limits(iStiffness,:))...
                    + color_low_limits(iStiffness,:);
%                 plot((UR.pos_mov_x(idx(iIdx),:)-repmat(UR.pos_mov_x(idx(iIdx),1),1,length(UR.t_mov)))',...
%                     (UR.pos_mov_y(idx(iIdx),:)-repmat(UR.pos_mov_y(idx(iIdx),1),1,length(UR.t_mov)))',...
%                     'Color',color)
                plot(UR.pos_mov_x_cell{idx(iIdx)},...
                    UR.pos_mov_y_cell{idx(iIdx)},...
                    'Color',color) 
                x_limit(1) = min(x_limit(1),min(UR.pos_mov_x_cell{idx(iIdx)}));
                x_limit(2) = max(x_limit(2),max(UR.pos_mov_x_cell{idx(iIdx)}));
                y_limit(1) = min(y_limit(1),min(UR.pos_mov_y_cell{idx(iIdx)}));
                y_limit(2) = max(y_limit(2),max(UR.pos_mov_y_cell{idx(iIdx)}));      
            end
        end
        xlabel('t (s)')
        ylabel('Y position (cm)')
        title(['Handle position. Mov: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
            '. Bump: ' num2str(UR.bump_directions(iBump)*180/pi) '^o'],'Interpreter','Tex')
        axis equal
    end
    h_axes = get(gcf,'Children');
    set(setxor(h_axes,h_legend),'YLim',1.1*y_limit,'XLim',1.1*x_limit)
%     legend(legend_str)
    set(params.fig_handles(end),'Name','Bump response')    
end

%% Displacement as a function of session time
params.fig_handles(end+1) = figure;  
displacement = max(abs(UR.pos_bump_y_rot),[],2);
h_legend = [];
for iDir = 1:length(UR.movement_directions) 
    x_limit = [0 0];
    y_limit = [0 0];
    hold on         
    for iBump = 1:length(UR.bump_directions)
        legend_str = {};
        subplot(length(UR.movement_directions),length(UR.bump_directions),(iDir-1)*length(UR.bump_directions)+iBump)  
        hold on
        for iStiffness = 1:length(UR.stiffnesses_idx)   
            idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
            idx = intersect(idx,UR.bump_directions_idx{iBump});
            legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
                ' N/cm. n = ' num2str(length(idx))]}];            
            if ~isempty(idx)
%                 plot(UR.pos_mov_x(idx,:)',...
%                     UR.pos_mov_y(idx,:)',...
%                     'Color',UR.stiffness_colors(iStiffness,:))                
                plot(UR.trial_table(idx,UR.table_columns.t_trial_start),...
                    displacement(idx),...
                    '.','Color',UR.stiffness_colors(iStiffness,:))
                x_limit(1) = min(x_limit(1),min(min(UR.trial_table(idx,UR.table_columns.t_trial_start))));
                x_limit(2) = max(x_limit(2),max(max(UR.trial_table(idx,UR.table_columns.t_trial_start))));
                y_limit(1) = 0;
                y_limit(2) = max(y_limit(2),max(max(displacement(idx))));
            end
            xlabel('t (s)')
            ylabel('Y position (cm)')
            title(['Handle position. Mov: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
                '. Bump: ' num2str(UR.bump_directions(iBump)*180/pi) '^o'],'Interpreter','Tex')
%             axis equal
        end
        h_legend(end+1) = legend(legend_str);
    end
    h_axes = get(gcf,'Children');
    set(setxor(h_axes,h_legend),'YLim',1.1*y_limit,'XLim',1.1*x_limit)
    set(params.fig_handles(end),'Name','Bump displacement vs time')    
end

%% Displacement as a function of session time (all bump conditions)
params.fig_handles(end+1) = figure;  
displacement = max(abs(UR.pos_bump_y_rot),[],2);
for iDir = 1:length(UR.movement_directions) 
    x_limit = [0 0];
    y_limit = [0 0];
    hold on
    
    legend_str = {};
    subplot(length(UR.movement_directions),1,iDir)
    hold on
    for iStiffness = 1:length(UR.stiffnesses_idx)
        idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
        idx = intersect(idx,UR.bump_trials);
        legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
            ' N/cm. n = ' num2str(length(idx))]}];
        if ~isempty(idx)
            %                 plot(UR.pos_mov_x(idx,:)',...
            %                     UR.pos_mov_y(idx,:)',...
            %                     'Color',UR.stiffness_colors(iStiffness,:))
            plot(UR.trial_table(idx,UR.table_columns.t_trial_start),...
                displacement(idx),...
                '.','Color',UR.stiffness_colors(iStiffness,:))
            x_limit(1) = min(x_limit(1),min(min(UR.trial_table(idx,UR.table_columns.t_trial_start))));
            x_limit(2) = max(x_limit(2),max(max(UR.trial_table(idx,UR.table_columns.t_trial_start))));
            y_limit(1) = 0;
            y_limit(2) = max(y_limit(2),max(max(displacement(idx))));
        end
        xlabel('t (s)')
        ylabel('Displacement (cm)')
        title(['Handle displacement. Mov: ' num2str(UR.movement_directions(iDir)*180/pi) '^o'],'Interpreter','Tex')
        %             axis equal
    end
    h_axes = get(gcf,'Children');
    set(h_axes,'YLim',1.1*y_limit,'XLim',1.1*x_limit)
    legend(legend_str)
    set(params.fig_handles(end),'Name','Displacement all bumps vs time')    
end

%% Path length as a function of session time
params.fig_handles(end+1) = figure;  
% pos_x = UR.pos_mov_x - repmat(UR.pos_mov_x(:,1),1,length(UR.t_mov));
% pos_y = UR.pos_mov_y - repmat(UR.pos_mov_y(:,1),1,length(UR.t_mov));
% path_length = sum(diff(sqrt(pos_x.^2+pos_y.^2)));

leave_target = UR.trial_table(:,UR.table_columns.t_leave_target);
reach_target = UR.trial_table(:,UR.table_columns.t_trial_end);
idx_vector = round(bdf.pos(:,1)*1000);
[~,leave_target_idx,~] = intersect(idx_vector,round(1000*leave_target));
[~,reach_target_idx,~] = intersect(idx_vector,round(1000*reach_target));
for iTrial = 1:size(UR.trial_table,1)    
    pos_x = bdf.pos(leave_target_idx(iTrial):reach_target_idx(iTrial),2);
    pos_y = bdf.pos(leave_target_idx(iTrial):reach_target_idx(iTrial),3);
    path_length(iTrial) = sum(abs(diff(sqrt(pos_x.^2+pos_y.^2))));
end
legend_str = {};
for iDir = 1:length(UR.movement_directions) 
    x_limit = [-.01 .01];
    y_limit = [-.01 .01];
    hold on 
    if any(UR.bump_directions == UR.movement_directions(iDir))
        legend_str = {};
        subplot(length(UR.movement_directions),1,iDir)  
        hold on
        for iStiffness = 1:length(UR.stiffnesses_idx)   
            idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
            idx = intersect(idx,UR.bump_directions_idx{UR.bump_directions == UR.movement_directions(iDir)});

            idx_2 = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
            idx_2 = intersect(idx_2,UR.stiffnesses_idx{UR.stiffnesses==0});
            idx = unique([idx;idx_2]);
            plot(UR.trial_table(idx,UR.table_columns.t_trial_start),...
                    UR.path_length(idx),...
                    '.','Color',UR.stiffness_colors(iStiffness,:))
        end
        for iStiffness = 1:length(UR.stiffnesses_idx)   
            idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
            idx = intersect(idx,UR.bump_directions_idx{UR.bump_directions == UR.movement_directions(iDir)});

            idx_2 = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
            idx_2 = intersect(idx_2,UR.stiffnesses_idx{UR.stiffnesses==0});
            idx = sort([idx;idx_2]);
            legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
                ' N/cm. n = ' num2str(length(idx))]}];            
            if ~isempty(idx)
    %                 plot(UR.pos_mov_x(idx,:)',...
    %                     UR.pos_mov_y(idx,:)',...
    %                     'Color',UR.stiffness_colors(iStiffness,:))                
                plot(UR.trial_table(idx,UR.table_columns.t_trial_start),...
                    UR.path_length(idx),...
                    '.','Color',UR.stiffness_colors(iStiffness,:))     
                plot([0 UR.trial_table(end,UR.table_columns.t_trial_end)],...
                    [mean(UR.path_length(idx)) mean(UR.path_length(idx))],'-','Color',UR.stiffness_colors(iStiffness,:))
                x_limit(1) = min(x_limit(1),min(min(UR.trial_table(idx,UR.table_columns.t_trial_start))));
                x_limit(2) = max(x_limit(2),max(max(UR.trial_table(idx,UR.table_columns.t_trial_start))));
                y_limit(1) = 0;
                y_limit(2) = max(y_limit(2),max(max(path_length(idx))));
            end
            xlabel('t (s)')
            ylabel('Path length (cm)')
            title(['Path length. Mov: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
                '. No bump.'],'Interpreter','Tex')
    %             axis equal
        end
    end
    if ~isempty(legend_str)
        h_legend = legend(legend_str);

        h_axes = get(gcf,'Children');
%         set(setxor(h_axes,h_legend),'YLim',1.1*y_limit,'XLim',1.1*x_limit)
        set(params.fig_handles(end),'Name',['Path length Mov ' num2str(UR.movement_directions(iDir)*180/pi)])    
    else
        close(params.fig_handles(end))
        params.fig_handles(end) = [];
    end
end

%% Signed error as a function of session time - no bump
params.fig_handles(end+1) = figure;  

% pos_x = UR.pos_mov_x_rot - repmat(UR.pos_mov_x_rot(:,1),1,length(UR.t_mov));
% pos_y = UR.pos_mov_y_rot - repmat(UR.pos_mov_y_rot(:,1),1,length(UR.t_mov));
% signed_error = sum(pos_y,2);
signed_error = UR.signed_error;
for iDir = 1:length(UR.movement_directions) 
    x_limit = [0 0];
    y_limit = [0 0];
    hold on 
    
    legend_str = {};
    if any(UR.bump_directions == UR.movement_directions(iDir))
        subplot(length(UR.movement_directions),1,iDir)  
        hold on
        for iStiffness = 1:length(UR.stiffnesses_idx)
            idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
            idx = intersect(idx,UR.bump_directions_idx{UR.bump_directions == UR.movement_directions(iDir)});
            
            idx_2 = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
            idx_2 = intersect(idx_2,UR.stiffnesses_idx{UR.stiffnesses==0});
            idx = unique([idx;idx_2]);
            plot(UR.trial_table(idx,UR.table_columns.t_trial_start),...
                signed_error(idx),...
                '.','Color',UR.stiffness_colors(iStiffness,:))
        end
        for iStiffness = 1:length(UR.stiffnesses_idx)   
            idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
            idx = intersect(idx,UR.bump_directions_idx{UR.bump_directions == UR.movement_directions(iDir)});

            idx_2 = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
            idx_2 = intersect(idx_2,UR.stiffnesses_idx{UR.stiffnesses==0});
            idx = sort([idx;idx_2]);
            legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
                ' N/cm. n = ' num2str(length(idx))]}];            
            if ~isempty(idx)
    %                 plot(UR.pos_mov_x(idx,:)',...
    %                     UR.pos_mov_y(idx,:)',...
    %                     'Color',UR.stiffness_colors(iStiffness,:))                
                plot(UR.trial_table(idx,UR.table_columns.t_trial_start),...
                    signed_error(idx),...
                    '.','Color',UR.stiffness_colors(iStiffness,:))   
                plot([0 UR.trial_table(end,UR.table_columns.t_trial_end)],...
                    [mean(signed_error(idx)) mean(signed_error(idx))],'-','Color',UR.stiffness_colors(iStiffness,:))                
                x_limit(1) = min(x_limit(1),min(min(UR.trial_table(idx,UR.table_columns.t_trial_start))));
                x_limit(2) = max(x_limit(2),max(max(UR.trial_table(idx,UR.table_columns.t_trial_start))));
                y_limit(1) = min(y_limit(2),min(min(signed_error(idx))));
                y_limit(2) = max(y_limit(2),max(max(signed_error(idx))));
            end
            xlabel('t (s)')
            ylabel('Signed error (cm^2)','Interpreter','Tex')
            title(['Signed error. Mov: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
                '. No bump.'],'Interpreter','Tex')
    %             axis equal
        end
    end
    if ~isempty(legend_str)
        h_legend = legend(legend_str);

        h_axes = get(gcf,'Children');
        set(setxor(h_axes,h_legend),'YLim',1.1*y_limit,'XLim',1.1*x_limit)
        set(params.fig_handles(end),'Name',['Signed error Mov ' num2str(UR.movement_directions(iDir)*180/pi)])    
    else
        close(params.fig_handles(end))
        params.fig_handles(end) = [];
    end
        
end

%% Signed error as a function of session time - no field
params.fig_handles(end+1) = figure;  
% pos_y = UR.pos_mov_y_rot - repmat(UR.pos_mov_y_rot(:,1),1,length(UR.t_mov));
pos_y = UR.pos_mov_y_rot;
signed_error = sum((pos_y),2);
h_legend = [];
for iDir = 1:length(UR.movement_directions) 
    x_limit = [0 0];
    y_limit = [0 0];
    hold on         
    for iBump = 1:length(UR.bump_directions)
        legend_str = {};
        subplot(length(UR.movement_directions),length(UR.bump_directions),(iDir-1)*length(UR.bump_directions)+iBump)  
        hold on
        for iStiffness = 1:length(UR.stiffnesses_idx)   
            idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
            idx = intersect(idx,UR.bump_directions_idx{iBump});
            legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
                ' N/cm. n = ' num2str(length(idx))]}];            
            if ~isempty(idx)
%                 plot(UR.pos_mov_x(idx,:)',...
%                     UR.pos_mov_y(idx,:)',...
%                     'Color',UR.stiffness_colors(iStiffness,:))                
                plot(UR.trial_table(idx,UR.table_columns.t_trial_start),...
                    signed_error(idx),...
                    '.','Color',UR.stiffness_colors(iStiffness,:))
                x_limit(1) = 0;
                x_limit(2) = UR.trial_table(end,UR.table_columns.t_trial_start);
                y_limit(1) = min(y_limit(1),min(min(signed_error(idx))));
                y_limit(2) = max(y_limit(2),max(max(signed_error(idx))));
            end                       
%             axis equal
        end
        xlabel('t (s)')
        ylabel('Signed error (cm^2)','Interpreter','Tex')
        title(['Signed error. Mov: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
            '. Bump: ' num2str(UR.bump_directions(iBump)*180/pi) '^o'],'Interpreter','Tex')
        plot([0 UR.trial_table(end,UR.table_columns.t_trial_start)],...
            [0 0],'-k')
        h_legend(end+1) = legend(legend_str);
    end
    y_limit = max(abs(y_limit)) * [-1 1];
    h_axes = get(gcf,'Children');
    set(setxor(h_axes,h_legend),'YLim',1.1*y_limit,'XLim',x_limit)
    set(params.fig_handles(end),'Name','Bump response')    
end

%% Stiffness - Bump response separated by movement direction
% 
% for iDir = 1:length(UR.movement_directions)
%     for iBump = 1:length(UR.bump_directions_idx)
%         idx = intersect(UR.bump_directions_idx{iBump},UR.movement_directions_idx{iDir});
%         if ~isempty(idx)
%             params.fig_handles(end+1) = figure;
%             subplot(211)
%             legend_str = {};
%             hold on
%             for iStiffness = 1:length(UR.stiffnesses_idx)
%                 idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
%                 idx = intersect(idx,UR.bump_directions_idx{iBump});
%                 plot(0,0,'Color',UR.stiffness_colors(iStiffness,:))
%                 legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
%                     ' N/cm. n = ' num2str(length(idx))]}];
%             end
%             for iStiffness = 1:length(UR.stiffnesses_idx)            
%                 idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
%                 idx = intersect(idx,UR.bump_directions_idx{iBump});
%                 if ~isempty(idx)
%                     plot(UR.t_bump,...
%                         UR.stiffness(idx,:)',...
% ...%                         mean(UR.pos_bump_y_rot(idx,:)),...
%                         'Color',UR.stiffness_colors(iStiffness,:))               
%                     h_temp = errorarea(UR.t_bump,mean(UR.stiffness(idx,:),1),...
%                         std(UR.stiffness(idx,:),[],1),UR.stiffness_colors(iStiffness,:),0.5);
%                     
% %                     plot(UR.pos_bump_x_rot(idx,:)',...
% %                         UR.pos_bump_y_rot(idx,:)',...
% %                         'Color',UR.stiffness_colors(iStiffness,:))             
%                end
%             end
%             xlabel('t (s)')
%             ylabel('Y position (cm)')
%             title(['Handle position. Movement direction: ' num2str(UR.movement_directions(iDir)*180/pi) '^o' ...
%                 '. Bump: ' num2str(UR.bump_directions(iBump)*180/pi) '^o'])
% %             axis equal            
%             legend(legend_str)
%             set(params.fig_handles(end),'Name','Bump response')            
%         end
%     end
% 
% end

%% Position
position = UR.pos_mov_x_rot;
params.fig_handles(end+1) = figure;
hold on
legend_str = {};
for iStiffness = 1:length(UR.stiffnesses)
    idx = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
    plot(UR.t_mov,mean(position(idx,:)),'Color',UR.stiffness_colors(iStiffness,:));
    legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
        ' N/cm']}];
end

xlabel('t (s)')
ylabel('position (cm)')
title('Position')
legend(legend_str)
set(params.fig_handles(end),'Name','Position') 

%% Speed
speed = sqrt(UR.vel_mov_x.^2 + UR.vel_mov_y.^2);
params.fig_handles(end+1) = figure;
subplot(211)
hold on
legend_str = {};
for iStiffness = 1:length(UR.stiffnesses)
    idx = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
    plot(UR.t_mov,mean(speed(idx,:)),'Color',UR.stiffness_colors(iStiffness,:));
    legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
        ' N/cm']}];
end

xlabel('t (s)')
ylabel('speed (cm/s)')
title('Speed')
legend(legend_str)
subplot(212)
hold on
plot(UR.t_mov,mean(speed(UR.stiffnesses_idx{1},:))./mean(speed(UR.stiffnesses_idx{2},:)))
plot(UR.t_mov,ones(size(UR.t_mov)),'--k')
xlabel('t (s)')
ylabel('speed ratio (negative/positive)')
ylim([0.8 1.5])
set(params.fig_handles(end),'Name','Speed') 

%% Force
force = sqrt(UR.force_mov_x.^2 + UR.force_mov_y.^2);
params.fig_handles(end+1) = figure;
subplot(211)
hold on
legend_str = {};
for iStiffness = 1:length(UR.stiffnesses)
    idx = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
    plot(UR.t_mov,mean(force(idx,:)),'Color',UR.stiffness_colors(iStiffness,:));
    legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
        ' N/cm']}];
end

xlabel('t (s)')
ylabel('force (N)')
title('Force')
legend(legend_str)
subplot(212)
hold on
plot(UR.t_mov,mean(force(UR.stiffnesses_idx{1},:))./mean(force(UR.stiffnesses_idx{2},:)))
plot(UR.t_mov,ones(size(UR.t_mov)),'--k')
xlabel('t (s)')
ylabel('force ratio (negative/positive)')
% ylim([0.8 1.5])
set(params.fig_handles(end),'Name','Force') 

%% Force separated by components
force_x = abs(UR.force_mov_x_rot);
force_y = abs(UR.force_mov_y_rot);
max_y = 0;
params.fig_handles(end+1) = figure;
subplot(221)
hold on
legend_str = {};
for iStiffness = 1:length(UR.stiffnesses)
    idx = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
    max_y = max(max_y,mean(force_x(idx,:)));
    plot(UR.t_mov,mean(force_x(idx,:)),'Color',UR.stiffness_colors(iStiffness,:));
    legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
        ' N/cm']}];
end
xlabel('t (s)')
ylabel('force (N)')
title('Force parallel to movement')
legend(legend_str)

subplot(222)
hold on
legend_str = {};
for iStiffness = 1:length(UR.stiffnesses)
    idx = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
    max_y = max(max_y,mean(force_y(idx,:)));
    plot(UR.t_mov,mean(force_y(idx,:)),'Color',UR.stiffness_colors(iStiffness,:));
    legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
        ' N/cm']}];
end
xlabel('t (s)')
ylabel('force (N)')
title('Force perpendicular to movement')
legend(legend_str)
temp_h = get(gcf,'Children');
set(temp_h,'YLim',[0 1.1*max(max_y)])
set(temp_h,'XLim',[UR.t_mov(1) UR.t_mov(end)])

subplot(223)
hold on
plot(UR.t_mov,mean(force_x(UR.stiffnesses_idx{1},:))./mean(force_x(UR.stiffnesses_idx{2},:)))
plot(UR.t_mov,ones(size(UR.t_mov)),'--k')
xlabel('t (s)')
ylabel('force ratio (negative/positive)')
y_max = max(mean(force_x(UR.stiffnesses_idx{1},:))./mean(force_x(UR.stiffnesses_idx{2},:)));
y_max = max(y_max,max(mean(force_y(UR.stiffnesses_idx{1},:))./mean(force_y(UR.stiffnesses_idx{2},:))));
ylim([0.8 1.1*y_max])
set(params.fig_handles(end),'Name','Force') 

subplot(224)
hold on
plot(UR.t_mov,mean(force_y(UR.stiffnesses_idx{1},:))./mean(force_y(UR.stiffnesses_idx{2},:)))
plot(UR.t_mov,ones(size(UR.t_mov)),'--k')
xlabel('t (s)')
ylabel('force ratio (negative/positive)')
ylim([0.8 1.1*y_max])
set(params.fig_handles(end),'Name','Force') 

%% Derivative of force separated by components
force_x_smooth = smooth(bdf.force(:,2),100);
force_y_smooth = smooth(bdf.force(:,3),100);

force_x_smooth_mat = reshape(force_x_smooth(UR.mov_idx_table),[],size(UR.mov_idx_table,2));
force_y_smooth_mat = reshape(force_y_smooth(UR.mov_idx_table),[],size(UR.mov_idx_table,2));    

force_x_smooth_mat_rot = zeros(size(UR.force_mov_x));
force_y_smooth_mat_rot = zeros(size(UR.force_mov_y));
    
for iDir = 1:length(UR.movement_directions)
    theta = UR.movement_directions(iDir);
    rot_mat = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    idx = UR.trial_table(:,UR.table_columns.movement_direction) == theta;

    temp_x = force_x_smooth_mat(idx,:);
    temp_y = force_y_smooth_mat(idx,:);
    temp = [temp_x(:) temp_y(:)];
    temp = temp*rot_mat;
    temp_x = reshape(temp(:,1),size(UR.pos_mov_x(idx,:)));
    temp_y = reshape(temp(:,2),size(UR.pos_mov_x(idx,:)));
    force_x_smooth_mat_rot(idx,:) = temp_x;
    force_y_smooth_mat_rot(idx,:) = temp_y;
end

d_force_x = diff(abs(force_x_smooth_mat_rot),1,2)/UR.dt;
d_force_x = [d_force_x d_force_x(:,end)];
d_force_y = diff(abs(force_y_smooth_mat_rot),1,2)/UR.dt;
d_force_y = [d_force_y d_force_y(:,end)];

min_y = 0;
max_y = 0;
params.fig_handles(end+1) = figure;
subplot(221)
hold on
legend_str = {};
for iStiffness = 1:length(UR.stiffnesses)
    idx = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
    min_y = min(min_y,min(mean(d_force_x(idx,:))));
    max_y = max(max_y,max(mean(d_force_x(idx,:))));
    plot(UR.t_mov,mean(d_force_x(idx,:)),'Color',UR.stiffness_colors(iStiffness,:));
    legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
        ' N/cm']}];
end
xlabel('t (s)')
ylabel('dforce (N/s)')
title('Change in force parallel to movement')
legend(legend_str)

subplot(222)
hold on
legend_str = {};
for iStiffness = 1:length(UR.stiffnesses)
    idx = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
    min_y = min(min_y,min(mean(d_force_y(idx,:))));
    max_y = max(max_y,max(mean(d_force_y(idx,:))));
    plot(UR.t_mov,mean(d_force_y(idx,:)),'Color',UR.stiffness_colors(iStiffness,:));
    legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
        ' N/cm']}];
end
xlabel('t (s)')
ylabel('dforce (N/s)')
title('Change in force perpendicular to movement')
legend(legend_str)
temp_h = get(gcf,'Children');
set(temp_h,'YLim',[min_y 1.1*max(max_y)])
set(temp_h,'XLim',[UR.t_mov(1) UR.t_mov(end)])

% subplot(223)
% hold on
% plot(UR.t_mov,mean(d_force_x(UR.stiffnesses_idx{1},:))./mean(d_force_x(UR.stiffnesses_idx{2},:)))
% plot(UR.t_mov,ones(size(UR.t_mov)),'--k')
% xlabel('t (s)')
% ylabel('force ratio (negative/positive)')
% y_max = max(mean(d_force_x(UR.stiffnesses_idx{1},:))./mean(d_force_x(UR.stiffnesses_idx{2},:)));
% y_max = max(y_max,max(mean(d_force_y(UR.stiffnesses_idx{1},:))./mean(d_force_y(UR.stiffnesses_idx{2},:))));
% ylim([0.8 1.1*y_max])
% set(params.fig_handles(end),'Name','Force') 
% 
% subplot(224)
% hold on
% plot(UR.t_mov,mean(d_force_y(UR.stiffnesses_idx{1},:))./mean(d_force_y(UR.stiffnesses_idx{2},:)))
% plot(UR.t_mov,ones(size(UR.t_mov)),'--k')
% xlabel('t (s)')
% ylabel('force ratio (negative/positive)')
% ylim([0.8 1.1*y_max])
% set(params.fig_handles(end),'Name','Force') 


%% Position error
% displacement = UR.pos_mov_y_rot;
params.fig_handles(end+1) = figure;
subplot(211)
hold on
legend_str = {};
for iStiffness = 1:length(UR.stiffnesses)
    idx = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
    plot(UR.t_mov,mean(abs(UR.pos_mov_y_rot(idx,:))),'Color',UR.stiffness_colors(iStiffness,:));
    legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
        ' N/cm']}];
end

xlabel('t (s)')
ylabel('Absolute distance from null line (cm)')
title('Distance from null line')
legend(legend_str)
subplot(212)
hold on
plot(UR.t_mov,mean(abs(UR.pos_mov_y_rot(UR.stiffnesses_idx{1},:)))./...
    mean(abs(UR.pos_mov_y_rot(UR.stiffnesses_idx{2},:))))
plot(UR.t_mov,ones(size(UR.t_mov)),'--k')
xlabel('t (s)')
ylabel('distance ratio (negative/positive)')
% ylim([0.8 1.5])
set(params.fig_handles(end),'Name','Distance from null') 

%% Acceleration
% params.fig_handles(end+1) = figure;
% acceleration = sqrt(diff(UR.pos_mov_x_rot,2,2).^2 + diff(UR.pos_mov_y_rot,2,2).^2)/(UR.dt^2);
% % acceleration = diff(UR.pos_mov_y_rot,2,2)/(UR.dt^2);
% acceleration = [acceleration acceleration(:,end) acceleration(:,end)];
% subplot(211)
% hold on
% legend_str = {};
% for iStiffness = 1:length(UR.stiffnesses)
%     idx = intersect(UR.stiffnesses_idx{iStiffness},UR.no_bump_trials);
%     plot(UR.t_mov,mean((acceleration(idx,:))),'Color',UR.stiffness_colors(iStiffness,:));
%     legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
%         ' N/cm']}];
% end
% 
% xlabel('t (s)')
% ylabel('Acceleration (cm/s^2)')
% title('Acceleration')
% legend(legend_str)
% subplot(212)
% hold on
% plot(UR.t_mov,mean((acceleration(UR.stiffnesses_idx{1},:)))./...
%     mean((acceleration(UR.stiffnesses_idx{2},:))))
% plot(UR.t_mov,ones(size(UR.t_mov)),'--k')
% xlabel('t (s)')
% ylabel('acceleration ratio (negative/positive)')
% % ylim([0.8 1.5])
% set(params.fig_handles(end),'Name','Acceleration') 