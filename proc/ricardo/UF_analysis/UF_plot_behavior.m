function UF_plot_behavior(UF_struct)

%% Raw positions
figure(1)
clf
for iField = 1:length(UF_struct.field_indexes)
    for iBump = 1:length(UF_struct.bump_indexes)
        idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});       
        subplot(length(UF_struct.field_indexes),length(UF_struct.bump_indexes),(iField-1)*(length(UF_struct.bump_indexes))+iBump)
        plot(UF_struct.x_pos(idx,UF_struct.t_zero_idx),UF_struct.y_pos(idx,UF_struct.t_zero_idx),'k.','MarkerSize',10)
        hold on
        plot(UF_struct.x_pos(idx,UF_struct.t_zero_idx:end)',UF_struct.y_pos(idx,UF_struct.t_zero_idx:end)')
        xlim([-10 10])
        ylim([-10 10])
        axis square
        title(['F: ' num2str(round(UF_struct.field_orientations(iField)*180/pi))...
            'deg  B: ' num2str(round(UF_struct.bump_directions(iBump)*180/pi)) 'deg'])
        xlabel('X pos (cm)')
        ylabel('Y pos (cm)')        
    end
end
%%
% Raw forces
figure(2) 
clf
for iField = 1:length(UF_struct.field_indexes)
    for iBump = 1:length(UF_struct.bump_indexes)
        idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});           
        subplot(length(UF_struct.field_indexes),length(UF_struct.bump_indexes),(iField-1)*(length(UF_struct.bump_indexes))+iBump)
        plot(UF_struct.x_force(idx,UF_struct.t_zero_idx),UF_struct.y_force(idx,UF_struct.t_zero_idx),'k.','MarkerSize',10)
        hold on        
        plot(UF_struct.x_force(idx,UF_struct.t_zero_idx:end)',UF_struct.y_force(idx,UF_struct.t_zero_idx:end)')
        axis square
        xlim([-5 5])
        ylim([-5 5])
        title(['F: ' num2str(round(UF_struct.field_orientations(iField)*180/pi))...
            'deg  B: ' num2str(round(UF_struct.bump_directions(iBump)*180/pi)) 'deg'])
        xlabel('X force (N)')
        ylabel('Y force (N)')
    end
end

%% Aligned positions
figure(3)
clf
for iField = 1:length(UF_struct.field_indexes)
    for iBump = 1:length(UF_struct.bump_indexes)
        idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});       
        figure(3)
        subplot(2,length(UF_struct.bump_indexes),(iField-1)*length(UF_struct.bump_indexes)+iBump)
        plot(UF_struct.x_pos_translated(idx,UF_struct.t_zero_idx:end)',...
            UF_struct.y_pos_translated(idx,UF_struct.t_zero_idx:end)','Color',UF_struct.colors_field(iField,:))
        hold on
        xlim([-10 10])
        ylim([-10 10])
        title(['Bump: ' num2str(round(UF_struct.bump_directions(iBump)*180/pi)) 'deg'])
        xlabel('X pos (cm)')
        ylabel('Y pos (cm)')
        axis square
    end
end 

%% Aligned forces
figure(4)
clf
for iField = 1:length(UF_struct.field_indexes)
    for iBump = 1:length(UF_struct.bump_indexes)
        idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});        
        subplot(2,length(UF_struct.bump_indexes),(iField-1)*length(UF_struct.bump_indexes)+iBump)
        plot(UF_struct.x_force(idx,UF_struct.t_zero_idx:end)'-repmat(UF_struct.x_force(idx,UF_struct.t_zero_idx)',size(UF_struct.x_force(idx,UF_struct.t_zero_idx:end),2),1),...
            UF_struct.y_force(idx,UF_struct.t_zero_idx:end)'-repmat(UF_struct.y_force(idx,UF_struct.t_zero_idx)',size(UF_struct.y_force(idx,UF_struct.t_zero_idx:end),2),1),'Color',UF_struct.colors_field(iField,:))
        hold on
        axis square
        xlim([-5 5])
        ylim([-5 5])
        title(['Bump: ' num2str(round(UF_struct.bump_directions(iBump)*180/pi)) 'deg'])
        xlabel('X force (N)')
        ylabel('Y force (N)')
    end
end        

%% Force/position map
figure(5)
clf
x_pos_pre_bump = UF_struct.x_pos(:,UF_struct.t_axis<0);
y_pos_pre_bump = UF_struct.y_pos(:,UF_struct.t_axis<0);
x_force_pre_bump = UF_struct.x_force(:,UF_struct.t_axis<0);
y_force_pre_bump = UF_struct.y_force(:,UF_struct.t_axis<0);

dec_ratio = 10;
for iField = 1:length(UF_struct.field_indexes)    
    idx = UF_struct.field_indexes{iField};        
    figure(5)
    hold on
    quiver(x_pos_pre_bump(idx,1:dec_ratio:end)',y_pos_pre_bump(idx,1:dec_ratio:end)',...
        x_force_pre_bump(idx,1:dec_ratio:end)',y_force_pre_bump(idx,1:dec_ratio:end)','Color',UF_struct.colors_field(iField,:))
    xlim([-2 2])
    ylim([-2 2])
    axis square
end      

%%  Rotated with respect to bump: Position, velocity and acceleration
hf = figure;
clf
plot_range = [-.05 UF_struct.t_lim];
plot_vars = {'UF_struct.x_pos_rot_bump','UF_struct.y_pos_rot_bump',...
    'UF_struct.x_vel_rot_bump','UF_struct.y_vel_rot_bump',...
    'UF_struct.x_acc_rot_bump','UF_struct.y_acc_rot_bump'};
title_list = {'Position parallel to bump','Position perpendicular to bump',...
    'Velocity parallel to bump','Velocity perpendicular to bump',...
    'Acceleration parallel to bump','Acceleration perpendicular to bump'};
ylabel_list = {'Pos (cm)','Pos (cm)','Vel (cm/s)','Vel (cm/s)','Acc (cm/s)','Acc (cm/s)'};

for iPlot = 1:6
    subplot(3,2,iPlot)
    value_matrix = eval(plot_vars{iPlot});
    t_idx = (UF_struct.t_axis>plot_range(1) & UF_struct.t_axis<plot_range(2));
    hold on
    for iBump = 1:length(UF_struct.bump_directions)
        for iField = 1:length(UF_struct.field_orientations)           
            idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
            temp_mean = mean(value_matrix(idx,t_idx),1);
            temp_std = std(value_matrix(idx,t_idx),[],1);
            temp_std = [temp_mean+temp_std,...            
                temp_mean(end:-1:1)-temp_std(end:-1:1)];
            temp_t = UF_struct.t_axis(t_idx);
            temp_t = [temp_t temp_t(end:-1:1)];
            area(temp_t,temp_std,'FaceColor',min(UF_struct.colors_bump(iBump,:)*1,[1 1 1]),'LineStyle','none')   
        end
    end
    for iBump = 1:length(UF_struct.bump_directions)
        for iField = 1:length(UF_struct.field_orientations)           
            idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
            plot(UF_struct.t_axis(t_idx),mean(value_matrix(idx,t_idx)),'Color',UF_struct.colors_bump(iBump,:),'LineStyle',UF_struct.linelist{iField});
        end
    end
    alpha(0.1)
    ylabel(ylabel_list{iPlot})
    xlabel('t (s)')
    title(title_list{iPlot})
    xlim(plot_range)
    ylim([min(min(value_matrix(:,t_idx))) max(max(value_matrix(:,t_idx)))])
end

%% Maximum displacement after "UF_struct.t_lim" time
plot_range = [0 UF_struct.t_lim];
[~,t_end_idx] = min(abs(UF_struct.t_axis-UF_struct.t_lim));
max_x_pos = max(UF_struct.x_pos_rot_bump(:,UF_struct.t_zero_idx:t_end_idx),[],2);
max_x_vel = max(UF_struct.x_vel_rot_bump(:,UF_struct.t_zero_idx:t_end_idx),[],2);
max_x_acc = max(UF_struct.x_acc_rot_bump(:,UF_struct.t_zero_idx:t_end_idx),[],2);

max_y_pos = sign(UF_struct.y_pos_rot_bump(:,t_end_idx)).*max(abs(UF_struct.y_pos_rot_bump(:,UF_struct.t_zero_idx:t_end_idx)),[],2);
max_y_vel = max(abs(UF_struct.y_vel_rot_bump(:,UF_struct.t_zero_idx:t_end_idx)),[],2);
max_y_acc = max(abs(UF_struct.y_acc_rot_bump(:,UF_struct.t_zero_idx:t_end_idx)),[],2);

figure
hold on
xlabel('Maximum displacement parallel to bump (cm)')
ylabel('Maximum displacement perpendicular to bump (cm)')
for iField = 1:length(UF_struct.field_orientations)
    for iBump = 1:length(UF_struct.bump_directions)
        idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
        mean_x = mean(max_x_pos(idx));
        std_x = std(max_x_pos(idx));
        mean_y = mean(max_y_pos(idx));
        std_y = std(max_y_pos(idx));
        plot(mean_x + [-std_x std_x],[mean_y mean_y],'LineWidth',2,'Color',UF_struct.colors_bump(iBump,:),'LineStyle',UF_struct.linelist{iField})
        plot([mean_x mean_x],mean_y +[-std_y std_y],'LineWidth',2,'Color',UF_struct.colors_bump(iBump,:),'LineStyle',UF_struct.linelist{iField})
    end
end
for iField = 1:length(UF_struct.field_orientations)
    for iBump = 1:length(UF_struct.bump_directions)
        idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
        plot(max_x_pos(idx),max_y_pos(idx),'Color',UF_struct.colors_bump(iBump,:),...
            'Marker',UF_struct.markerlist{iField},'LineStyle','none','MarkerSize',10)
%         hold on
    end
end

max_max_x = 1.1*max(max_x_pos);
max_max_y = 1.1*max(max_y_pos);
text(.1*max_max_x,1*max_max_y,'Field orientations','HorizontalAlignment','center')
for iField = 1:length(UF_struct.field_orientations)
    plot(.1*max_max_x+.03*max_max_x*[-cos(UF_struct.field_orientations(iField)) cos(UF_struct.field_orientations(iField))],...
       .85*max_max_y+.03*max_max_x*[-sin(UF_struct.field_orientations(iField)) sin(UF_struct.field_orientations(iField))],... 
       'LineStyle',UF_struct.linelist{iField},'LineWidth',2,'Color','k',...
       'Marker',UF_struct.markerlist{iField},'MarkerSize',10)
end

text(.1*max_max_x,.65*max_max_y,'Bump directions','HorizontalAlignment','center')
for iBump = 1:length(UF_struct.bump_directions)
    plot(.1*max_max_x+.03*max_max_x*[0 cos(UF_struct.bump_directions(iBump))],...
       .5*max_max_y+.03*max_max_x*[0 sin(UF_struct.bump_directions(iBump))],... 
       'LineStyle','-','LineWidth',2,'Color',UF_struct.colors_bump(iBump,:))
end

xlim([0 max_max_x])
ylim([0 1.1*max_max_y])
axis equal

%% Maximum displacement after "UF_struct.t_lim" time
[~, t_end_idx] = min(abs(UF_struct.t_axis-UF_struct.t_lim));

x_temp = UF_struct.x_pos_translated(:,UF_struct.t_zero_idx:t_end_idx);
y_temp = UF_struct.y_pos_translated(:,UF_struct.t_zero_idx:t_end_idx);
max_x_pos = sign(x_temp(:,end)).*max(abs(x_temp),[],2);
max_y_pos = sign(y_temp(:,end)).*max(abs(y_temp),[],2);

%     UF_struct.bump_dir_actual = zeros(length(bump_indexes),length(field_indexes));

figure
hold on
xlabel('X position (cm)')
ylabel('Y position (cm)')
for iField = 1:length(UF_struct.field_orientations)
    for iBump = 1:length(UF_struct.bump_directions)
        idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
        mean_x = mean(max_x_pos(idx));
        std_x = std(max_x_pos(idx));
        mean_y = mean(max_y_pos(idx));
        std_y = std(max_y_pos(idx));
        plot(mean_x + [-std_x std_x],[mean_y mean_y],'LineWidth',2,'Color',UF_struct.colors_bump(iBump,:),'LineStyle',UF_struct.linelist{iField})
        plot([mean_x mean_x],mean_y +[-std_y std_y],'LineWidth',2,'Color',UF_struct.colors_bump(iBump,:),'LineStyle',UF_struct.linelist{iField})                
%             UF_struct.bump_dir_actual(iBump,iField) = atan2(mean_y,mean_x);
    end    
end
%     UF_struct.bump_dir_actual(UF_struct.bump_dir_actual<0)=2*pi+UF_struct.bump_dir_actual(UF_struct.bump_dir_actual<0);
%     UF_struct.bump_dir_actual = mean(UF_struct.bump_dir_actual,2);
for iField = 1:length(UF_struct.field_orientations)
    for iBump = 1:length(UF_struct.bump_directions)
        idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
        plot(max_x_pos(idx),max_y_pos(idx),'Color',UF_struct.colors_bump(iBump,:),...
            'Marker',UF_struct.markerlist{iField},'LineStyle','none','MarkerSize',10)
        plot(x_temp(idx,:)',y_temp(idx,:)','Color',UF_struct.colors_bump(iBump,:),'LineStyle',UF_struct.linelist{iField})
    end
end

max_max_x = 1.1*max(max_x_pos);
max_max_y = 1.1*max(max_y_pos);
text(-.7*max_max_x,.8*max_max_y,'Field orientations','HorizontalAlignment','center')
max_max_x = 1.1*max(max_x_pos);
max_max_y = 1.1*max(max_y_pos);
for iField = 1:length(UF_struct.field_orientations)
    plot(-.7*max_max_x+.06*max_max_x*[-cos(UF_struct.field_orientations(iField)) cos(UF_struct.field_orientations(iField))],...
       .65*max_max_y+.06*max_max_x*[-sin(UF_struct.field_orientations(iField)) sin(UF_struct.field_orientations(iField))],... 
       'LineStyle',UF_struct.linelist{iField},'LineWidth',2,'Color','k',...
       'Marker',UF_struct.markerlist{iField},'MarkerSize',10)
end

text(-.7*max_max_x,.4*max_max_y,'Bump directions','HorizontalAlignment','center')
for iBump = 1:length(UF_struct.bump_directions)
    plot(-.7*max_max_x+.06*max_max_x*[0 cos(UF_struct.bump_directions(iBump))],...
       .25*max_max_y+.06*max_max_x*[0 sin(UF_struct.bump_directions(iBump))],... 
       'LineStyle','-','LineWidth',2,'Color',UF_struct.colors_bump(iBump,:))
end

xlim([-max_max_x max_max_x])
ylim([-max_max_y max_max_y])
axis equal

%% Starting position
x_pos_start = UF_struct.x_pos(:,UF_struct.t_zero_idx);
y_pos_start = UF_struct.y_pos(:,UF_struct.t_zero_idx);

figure
hold on
xlabel('Starting X position (cm)')
ylabel('Starting Y position (cm)')
legend_text = {};
for iField = 1:length(UF_struct.field_orientations)    
    idx = UF_struct.field_indexes{iField};
    mean_x = mean(x_pos_start(idx));
    std_x = std(x_pos_start(idx));
    mean_y = mean(y_pos_start(idx));
    std_y = std(y_pos_start(idx));
    plot(mean_x + [-std_x std_x],[mean_y mean_y],'LineWidth',2,'Color',UF_struct.colors_field(iField,:))
    legend_text{iField} = ['Field at ' num2str(180*UF_struct.field_orientations(iField)/pi) '^o'];
end
for iField = 1:length(UF_struct.field_orientations)    
    idx = UF_struct.field_indexes{iField};
    mean_x = mean(x_pos_start(idx));
    std_x = std(x_pos_start(idx));
    mean_y = mean(y_pos_start(idx));
    std_y = std(y_pos_start(idx));   
    plot([mean_x mean_x],mean_y +[-std_y std_y],'LineWidth',2,'Color',UF_struct.colors_field(iField,:))
end
for iField = 1:length(UF_struct.field_orientations)
    idx = UF_struct.field_indexes{iField};
    plot(x_pos_start(idx),y_pos_start(idx),'Color',UF_struct.colors_field(iField,:),...
        'Marker',UF_struct.markerlist{iField},'LineStyle','none','MarkerSize',10)
end
legend(legend_text)
axis equal   

%% End position as a function of time
figure
field_transitions = find(diff(UF_struct.trial_table(:,UF_struct.table_columns.field_orientation))~=0);
t_field_transitions = UF_struct.trial_table(field_transitions,UF_struct.table_columns.t_trial_start);
for iField = 1:length(UF_struct.field_indexes)
    for iBump = 1:length(UF_struct.bump_indexes)
        idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});      
        [a t_idx] = min(abs(UF_struct.t_axis-UF_struct.t_lim));
        subplot(1,length(UF_struct.bump_indexes),iBump)
        plot(UF_struct.trial_table(idx,UF_struct.table_columns.t_trial_start),UF_struct.x_pos_rot_bump(idx,t_idx),'.','Color',UF_struct.colors_field(iField,:))
        hold on
        plot([t_field_transitions t_field_transitions]',[zeros(size(field_transitions)),10*ones(size(field_transitions))]','k-');
        xlim([0 UF_struct.trial_table(end,UF_struct.table_columns.t_trial_start)])
        ylim([min(UF_struct.x_pos_rot_bump(:,t_idx))-1 1+max(UF_struct.x_pos_rot_bump(:,t_idx))])
        xlabel('t (s)')
        ylabel('Final position parallel to bump (cm)')
        title(['Bump at ' num2str(180/pi*UF_struct.bump_directions(iBump)) '^o'])
    end
end        


%% Forces
figure
values_matrix = UF_struct.x_force_rot_bump;
[~,t_end_idx] = min(abs(UF_struct.t_axis-UF_struct.t_lim));
y_limit = [min(min(values_matrix(:,UF_struct.t_zero_idx:t_end_idx))) max(max(values_matrix(:,UF_struct.t_zero_idx:t_end_idx)))];
x_limit = plot_range;
for iField = 1:length(UF_struct.field_orientations)
    for iBump = 1:length(UF_struct.bump_directions)
        idx = intersect(UF_struct.bump_indexes{iBump},UF_struct.field_indexes{iField});
        subplot(2,length(UF_struct.bump_directions)/2,iBump)
        hold on
        temp_std = [mean(values_matrix(idx,:),1)+std(values_matrix(idx,:),[],1),...            
            mean(values_matrix(idx,end:-1:1),1)-std(values_matrix(idx,end:-1:1),[],1)];
        temp_t = [UF_struct.t_axis UF_struct.t_axis(end:-1:1)];
        area(temp_t,temp_std,'FaceColor',min(UF_struct.colors_field(iField,:)*1,[1 1 1]),'LineStyle','none') 
        plot(UF_struct.t_axis,mean(values_matrix(idx,:)),'Color',UF_struct.colors_field(iField,:))
%         plot(t_axis,values_matrix(idx,:));
        xlim(x_limit)
        ylim(y_limit)
        alpha(.1)
        ylabel('Force (N)')
        xlabel('t (s)')
        title(['Force parallel to bump at ' num2str(180*UF_struct.bump_directions(iBump)/pi) '^o'])
    end

end