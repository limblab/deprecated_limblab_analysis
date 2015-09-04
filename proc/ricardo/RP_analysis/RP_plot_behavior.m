function params = RP_plot_behavior(data_struct,params)
RP = data_struct.RP;
bdf = data_struct.bdf;

if isfield(RP,'t_bump')    
    t_idx_bump = find(RP.t_bump > .1);
else
    t_idx_bump = 1;
end

if ~isfield(RP,'BMI')
    t_pert = RP.t_pert;
    pos_pert_x = RP.pos_pert_x;
    pos_pert_y = RP.pos_pert_y;
    if isfield(RP,'t_bump')
        t_bump = RP.t_bump;
        pos_bump_x = RP.pos_bump_x;
        pos_bump_y = RP.pos_bump_y;
        force_bump_x = RP.force_bump_x;
        force_bump_y = RP.force_bump_y;
    end
    pos_pert_x_rot = RP.pos_pert_x_rot;
else
    t_pert = RP.t_pert_bmi;
    pos_pert_x = RP.pos_pert_x_bmi;
    pos_pert_y = RP.pos_pert_y_bmi;
    if isfield(RP,'t_bump_bmi')
        t_bump = RP.t_bump_bmi;
        pos_bump_x = RP.pos_bump_x_bmi;
        pos_bump_y = RP.pos_bump_y_bmi;
        force_bump_x = RP.force_bump_x_bmi;
        force_bump_y = RP.force_bump_y_bmi;
    end
    pos_pert_x_rot = RP.pos_pert_x_rot_bmi;
    
end

%% Hand position
params.fig_handles(end+1) = figure;
hold on
plot(pos_pert_x(:,1)',...
    pos_pert_y(:,2)','.r')
plot(pos_pert_x(:,:)',...
    pos_pert_y(:,:)','-k')

xlabel('X position (cm)')
ylabel('Y position (cm)')
title('Handle position')
set(params.fig_handles(end),'Name','Handle position raw')
axis equal

%% Hand position - bump
if exist('t_bump')
    params.fig_handles(end+1) = figure;
    hold on
    t_zero = find(t_bump==0);
    % plot((RP.pos_bump_x(:,1)-RP.pos_bump_x(t_zero,1))',...
    %     (RP.pos_bump_y(:,2)-RP.pos_bump_x(t_zero,2))','.r')
    for iFreq = 1:length(RP.perturbation_frequencies)
        idx = intersect(RP.bump_trials,RP.perturbation_frequencies_idx{iFreq});
        plot((pos_bump_x(idx,:)-repmat(pos_bump_x(idx,t_zero),1,size(pos_bump_x(idx,:),2)))',...
            (pos_bump_y(idx,:)-repmat(pos_bump_y(idx,t_zero),1,size(pos_bump_y(idx,:),2)))',...
            'Color',RP.perturbation_frequency_colors(iFreq,:))
    end

    xlabel('X position (cm)')
    ylabel('Y position (cm)')
    title('Handle position - Bump')
    set(params.fig_handles(end),'Name','Handle position - Bump')
    axis equal
end

%% Hand position during perturbation separated by frequency, direction
params.fig_handles(end+1) = figure;
hold on
for iDir = 1:length(RP.perturbation_directions_idx)   
    subplot(length(RP.perturbation_directions_idx),1,iDir)
    hold on
    for iResult = 1:2
        for iFreq = 1:length(RP.perturbation_frequencies_idx)
            idx = RP.perturbation_directions_idx{iDir};
            idx = intersect(idx,RP.perturbation_frequencies_idx{iFreq});
            idx = intersect(idx,union(RP.no_bump_trials,RP.late_bump));        
            if iResult==1
                idx = intersect(idx,RP.reward_trials);
                if ~isempty(idx)
                    plot(t_pert,...
                        mean(pos_pert_x_rot(idx,:)),...
                        'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(t_pert,mean(pos_pert_x_rot(idx,:)),std(pos_pert_x_rot(idx,:)),RP.perturbation_frequency_colors(iFreq,:),.5);
                end
            else
                idx = intersect(idx,RP.fail_trials);
                plot(t_pert,...
                        mean(pos_pert_x_rot(idx,:)),...
                        '--','Color',RP.perturbation_frequency_colors(iFreq,:))
            end
        end
    end
    title(['Cursor position. Perturbation at ' num2str(RP.perturbation_directions(iDir)*180/pi) '^o'],...
        'Interpreter','tex')    
    xlabel('t (s)')
    ylabel('X pos (cm)')
end

set(params.fig_handles(end),'Name','Cursor position during perturbation')

%% Hand force during perturbation separated by frequency, direction
params.fig_handles(end+1) = figure;
hold on
for iDir = 1:length(RP.perturbation_directions_idx)   
    subplot(length(RP.perturbation_directions_idx),1,iDir)
    hold on
    for iResult = 1:2
        for iFreq = 1:length(RP.perturbation_frequencies_idx)
            idx = RP.perturbation_directions_idx{iDir};
            idx = intersect(idx,RP.perturbation_frequencies_idx{iFreq});
            idx = intersect(idx,union(RP.no_bump_trials,RP.late_bump));
            if iResult == 1
                idx = intersect(idx,RP.reward_trials);
                if ~isempty(idx)
                    plot(RP.t_pert,...
                        mean((RP.force_pert_x_rot(idx,:))),...
                        'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(RP.t_pert,mean(RP.force_pert_x_rot(idx,:)),std(RP.force_pert_x_rot(idx,:)),RP.perturbation_frequency_colors(iFreq,:),.5);
                end
            else
                idx = intersect(idx,RP.fail_trials);
                if ~isempty(idx)
                    plot(RP.t_pert,...
                        mean((RP.force_pert_x_rot(idx,:))),...
                        '--','Color',RP.perturbation_frequency_colors(iFreq,:))
                end
            end
        end
    end
    title(['Handle force. Perturbation at ' num2str(RP.perturbation_directions(iDir)*180/pi) '^o'],...
        'Interpreter','tex')    
    xlabel('t (s)')
    ylabel('X force (N)')
end

set(params.fig_handles(end),'Name','Handle force during perturbation')

%% Simulation force during perturbation separated by frequency, direction
if isfield(RP,'BMI')
    params.fig_handles(end+1) = figure;
    hold on
    for iDir = 1:length(RP.perturbation_directions_idx)   
        subplot(length(RP.perturbation_directions_idx),1,iDir)
        hold on
        for iFreq = 1:length(RP.perturbation_frequencies_idx)
            idx = RP.perturbation_directions_idx{iDir};
            idx = intersect(idx,RP.perturbation_frequencies_idx{iFreq});
            idx = intersect(idx,union(RP.no_bump_trials,RP.late_bump));
            idx = intersect(idx,RP.reward_trials);
            if ~isempty(idx)
                plot(RP.t_pert_bmi,...
                    ((RP.force_pert_x_rot_bmi(idx,:))'),...
                    'Color',RP.perturbation_frequency_colors(iFreq,:))
            end
        end
        title(['BMI force. Perturbation at ' num2str(RP.perturbation_directions(iDir)*180/pi) '^o'],...
            'Interpreter','tex')    
        xlabel('t (s)')
        ylabel('X force (N)')
    end

    set(params.fig_handles(end),'Name','BMI force during perturbation')
end

%% Stiffness vs time during perturbation
if ~isfield(RP,'BMI')
    if isfield(RP,'bump_directions_idx')
        h_sub = [];        
        params.fig_handles(end+1) = figure;    

        for iDir = 1:length(RP.perturbation_directions_idx)
            h_sub(end+1) = subplot(length(RP.perturbation_directions_idx),1,iDir);
            legend_str = {};

            hold on       
            for iFreq = 1:length(RP.perturbation_frequencies_idx)  
                idx = intersect(RP.perturbation_frequencies_idx{iFreq},RP.perturbation_directions_idx{iDir});
                idx = intersect(idx,union(RP.late_bump,RP.no_bump_trials));
                plot(RP.t_pert,mean(RP.stiffness_magnitude_pert(idx,:)),...
                           'Color',RP.perturbation_frequency_colors(iFreq,:))
                errorarea(RP.t_pert,mean(RP.stiffness_magnitude_pert(idx,:)),...
                    1.96/length(idx)*std(RP.stiffness_magnitude_pert(idx,:)),RP.perturbation_frequency_colors(iFreq,:),.5);
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                ' Hz']}];
            end
            title({['Stiffness.'];['Movement: ' num2str(180/pi*RP.perturbation_directions(iDir)) '^o']},...
                'Interpreter','tex')        
            xlabel('t (s)')
            ylabel('K (N/cm)')

            legend(legend_str);
        end
        set(h_sub,'YLim',[0 10])
        set(h_sub,'XLim',RP.t_pert([1 end]))
        set(params.fig_handles(end),'Name','Stiffness during perturbation')

    end
end

%% Hand force during bump separated by frequency, direction
if exist('t_bump')
    params.fig_handles(end+1) = figure;
    hold on
    for iDir = 1:length(RP.bump_directions_idx)   
        subplot(length(RP.bump_directions_idx),2,iDir*2-1)
        hold on
        idx = RP.bump_directions_idx{iDir};
        idx = intersect(idx,RP.early_bump);
        length(idx)
        if ~isempty(idx)
            plot(t_bump,...
                ((force_bump_x(1,:))'),...
                'Color','r')
            plot(t_bump,...
                ((force_bump_y(1,:))'),...
                'Color','b')
            plot(t_bump,...
                ((force_bump_x(idx,:))'),...
                'Color','r')
            plot(t_bump,...
                ((force_bump_y(idx,:))'),...
                'Color','b')
        end
        title(['Handle force (early bump). Bump at ' num2str(RP.bump_directions(iDir)*180/pi) '^o'],...
            'Interpreter','tex')    
        xlabel('t (s)')
        ylabel('force (N)')

        subplot(length(RP.bump_directions_idx),2,iDir*2)
        hold on
        idx = RP.bump_directions_idx{iDir};
        idx = intersect(idx,RP.late_bump);
        length(idx)
        if ~isempty(idx)
            plot(t_bump,...
                ((force_bump_x(1,:))'),...
                'Color','r')
            plot(t_bump,...
                ((force_bump_y(1,:))'),...
                'Color','b')
            plot(t_bump,...
                ((force_bump_x(idx,:))'),...
                'Color','r')
            plot(t_bump,...
                ((force_bump_y(idx,:))'),...
                'Color','b')
        end
        title(['Handle force (late bump). Bump at ' num2str(RP.bump_directions(iDir)*180/pi) '^o'],...
            'Interpreter','tex')    
        xlabel('t (s)')
        ylabel('force (N)')

        legend('X force', 'Y force')
    end

    set(params.fig_handles(end),'Name','Handle force during bump')
end
 %% Hand force separated by frequency, direction - Used for testing motors
% for iAmp = 1:length(RP.perturbation_amplitudes_idx)
%     params.fig_handles(end+1) = figure;
%     hold on
%     for iDir = 1:length(RP.perturbation_directions_idx)   
%         subplot(length(RP.perturbation_directions_idx),1,iDir)
%         hold on
%         for iFreq = 1:length(RP.perturbation_frequencies_idx)
%             idx = RP.perturbation_directions_idx{iDir};
%             idx = intersect(idx,RP.perturbation_frequencies_idx{iFreq});
%             idx = intersect(idx,RP.perturbation_amplitudes_idx{iAmp});
%             if ~isempty(idx)
%                 plot(RP.t_pert,...
%                     ((RP.force_pert_x_rot(idx,:))'),...
%                     'Color',RP.perturbation_frequency_colors(iFreq,:))
%             end
%         end
%         xlim([0 5])
%         title(['Handle force. Perturbation at ' num2str(RP.perturbation_directions(iDir)*180/pi) '^o'],...
%             'Interpreter','tex')    
%         xlabel('t (s)')
%         ylabel('X force (N)')
%     end
% end
% 
% set(params.fig_handles(end),'Name','Handle force')

% %% Stiffness - Bump response separated by perturbation direction
% if isfield(RP,'bump_directions_idx')
%     params.fig_handles(end+1) = figure;
%     t_zero = find(RP.t_bump==0);
%     max_stiffness = 0;
%     for iDir = 1:length(RP.perturbation_directions)
%         legend_str = {};
%         subplot(2,ceil(length(RP.perturbation_directions_idx)/2),iDir)
%         hold on
%         displacement = zeros(length(RP.perturbation_frequencies_idx),length(RP.bump_directions_idx));
%         force = zeros(length(RP.perturbation_frequencies_idx),length(RP.bump_directions_idx));
%         stiffness = zeros(length(RP.perturbation_frequencies_idx),length(RP.bump_directions_idx));
%         for iFreq = 1:length(RP.perturbation_frequencies_idx)
%             for iBump = 1:length(RP.bump_directions_idx)
%                 idx = intersect(RP.bump_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});
%                 idx = intersect(idx,RP.perturbation_directions_idx{iDir});
%                 if ~isempty(idx)
%                    x_pos = RP.pos_bump_x(idx,end)-RP.pos_bump_x(idx,t_zero);
%                    y_pos = RP.pos_bump_y(idx,end)-RP.pos_bump_y(idx,t_zero);
%                    displacement(iFreq,iBump) = mean(sqrt(x_pos.^2+y_pos.^2));
%                    x_force = max(abs(RP.force_bump_x(idx)));
%                    y_force = max(abs(RP.force_bump_y(idx)));
%                    force(iFreq,iBump) = mean(sqrt(x_force.^2+y_force.^2));
% %                    force(iFreq,iBump) = RP.trial_table(idx(1),RP.table_columns.bump_magnitude);
% %                    stiffness(iFreq,iBump) = 100*force(iFreq,iBump)/displacement(iFreq,iBump);
%                    temp = RP.force_bump_magnitude(idx,end-50:end)./...
%                        RP.bump_displacement(idx,end-50:end);
%                    temp(isnan(temp)) = [];
%                    temp(isinf(temp)) = [];
%                    stiffness(iFreq,iBump) = 100*mean(mean(temp));
%                    max_stiffness = max(max_stiffness,max(stiffness(:)));
%                 end                
%             end
%             plot(10*(iFreq-1)+stiffness(iFreq,[1:end 1]).*cos(RP.bump_directions([1:end 1])'),...
%                        10*(iFreq-1)+stiffness(iFreq,[1:end 1]).*sin(RP.bump_directions([1:end 1])'),...
%                        'Color',RP.perturbation_frequency_colors(iFreq,:))
% 
%             legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
%             ' Hz']}];
%         end
%         title(['Stiffness. Perturbation at ' num2str(RP.perturbation_directions(iDir)*180/pi) '^o'],...
%             'Interpreter','tex')        
%         xlabel('K (N/m)')
%         ylabel('K (N/m)')
%         axis square
%     end
%     legend(legend_str)
%     for iDir = 1:length(RP.perturbation_directions)
%         subplot(2,ceil(length(RP.perturbation_directions_idx)/2),iDir)
%         plot(max_stiffness*cos([0:.01:2*pi 0]),max_stiffness*sin([0:.01:2*pi 0]),'--k')
% %         xlim([-max_stiffness max_stiffness])
% %         ylim([-max_stiffness max_stiffness])
%     end
%     set(params.fig_handles(end),'Name','Stiffness')
% end

%% Stiffness - Bump response 
if exist('t_bump')
    if ~isfield(RP,'BMI') && isfield(RP,'bump_directions_idx')
        params.fig_handles(end+1) = figure;
        t_zero = find(t_bump==0);

        subplot(121)
        max_stiffness = 0;   
        legend_str = {};

        hold on       
        stiffness = zeros(length(RP.perturbation_frequencies_idx),length(RP.bump_directions_idx));
        for iFreq = 1:length(RP.perturbation_frequencies_idx)
            for iBump = 1:length(RP.bump_directions_idx)
                idx = intersect(RP.bump_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});                
                idx = intersect(idx,RP.early_bump);
                if ~isempty(idx)
    %                x_pos = pos_bump_x(idx,end)-pos_bump_x(idx,t_zero);
    %                y_pos = pos_bump_y(idx,end)-pos_bump_y(idx,t_zero);
    %                displacement(iFreq,iBump) = mean(sqrt(x_pos.^2+y_pos.^2));
    %                x_force = max(abs(RP.force_bump_x(idx)));
    %                y_force = max(abs(RP.force_bump_y(idx)));
    %                    force(iFreq,iBump) = mean(sqrt(x_force.^2+y_force.^2));
    %                    force(iFreq,iBump) = RP.trial_table(idx(1),RP.table_columns.bump_magnitude);
    %                    stiffness(iFreq,iBump) = 100*force(iFreq,iBump)/displacement(iFreq,iBump);
                   temp = RP.force_bump_magnitude(idx,end-50:end)./...
                       RP.bump_displacement(idx,end-50:end); 

                   stiffness(iFreq,iBump) = 100*mean(mean(temp));
                   max_stiffness = max(max_stiffness,max(stiffness(:)));
                end                
            end
    %         plot(5*(iFreq-1)+stiffness(iFreq,[1:end 1]).*cos(RP.bump_directions([1:end 1])'),...
    %                    0*(iFreq-1)+stiffness(iFreq,[1:end 1]).*sin(RP.bump_directions([1:end 1])'),...
    %                    'Color',RP.perturbation_frequency_colors(iFreq,:))
            plot(180/pi*RP.bump_directions,stiffness(iFreq,:),...
                       'Color',RP.perturbation_frequency_colors(iFreq,:))

            legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
            ' Hz']}];
        end
        title(['Stiffness (early bump)'],...
            'Interpreter','tex')        
        xlabel('Bump direction (deg)')
        ylabel('K (N/m)')
        axis square

        legend(legend_str)    

        subplot(122) 
        legend_str = {};

        hold on       
        stiffness = zeros(length(RP.perturbation_frequencies_idx),length(RP.bump_directions_idx));
        for iFreq = 1:length(RP.perturbation_frequencies_idx)
            for iBump = 1:length(RP.bump_directions_idx)
                idx = intersect(RP.bump_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});                
                idx = intersect(idx,RP.late_bump);
                if ~isempty(idx)
    %                x_pos = pos_bump_x(idx,end)-pos_bump_x(idx,t_zero);
    %                y_pos = pos_bump_y(idx,end)-pos_bump_y(idx,t_zero);
    %                displacement(iFreq,iBump) = mean(sqrt(x_pos.^2+y_pos.^2));
    %                x_force = max(abs(RP.force_bump_x(idx)));
    %                y_force = max(abs(RP.force_bump_y(idx)));
    %                    force(iFreq,iBump) = mean(sqrt(x_force.^2+y_force.^2));
    %                    force(iFreq,iBump) = RP.trial_table(idx(1),RP.table_columns.bump_magnitude);
    %                    stiffness(iFreq,iBump) = 100*force(iFreq,iBump)/displacement(iFreq,iBump);
                   temp = RP.force_bump_magnitude(idx,end-50:end)./...
                       RP.bump_displacement(idx,end-50:end);

                   stiffness(iFreq,iBump) = 100*mean(mean(temp));
                   max_stiffness = max(max_stiffness,max(stiffness(:)));
                end                
            end
            plot(180/pi*RP.bump_directions,stiffness(iFreq,:),...
                       'Color',RP.perturbation_frequency_colors(iFreq,:))

            legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
            ' Hz']}];
        end
        title(['Stiffness (late bump)'],...
            'Interpreter','tex')        
        xlabel('Bump direction (deg)')
        ylabel('K (N/m)')
        axis square

        legend(legend_str)
    %     plot(max_stiffness*cos([0:.01:2*pi 0]),max_stiffness*sin([0:.01:2*pi 0]),'--k')
    %     subplot(121)
    %     plot(max_stiffness*cos([0:.01:2*pi 0]),max_stiffness*sin([0:.01:2*pi 0]),'--k')

        set(params.fig_handles(end),'Name','Stiffness summary')
    end
end

%% Stiffness vs time - Bump response 
if exist('t_bump')
    if ~isfield(RP,'BMI') && isfield(RP,'bump_directions_idx')
        h_sub = [];

        for iBump = 1:length(RP.bump_directions_idx)
            params.fig_handles(end+1) = figure;    

            for iDir = 1:length(RP.perturbation_directions_idx)
                h_sub(end+1) = subplot(length(RP.perturbation_directions_idx),2,iDir*2-1);
                legend_str = {};

                hold on       
                for iFreq = 1:length(RP.perturbation_frequencies_idx)               
                    idx = intersect(RP.bump_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});                
                    idx = intersect(idx,RP.perturbation_directions_idx{iDir});
                    idx = intersect(idx,RP.early_bump);
                    plot(RP.t_bump(t_idx_bump),mean(RP.stiffness_magnitude_bump(idx,t_idx_bump),1),...
                               'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(RP.t_bump(t_idx_bump),mean(RP.stiffness_magnitude_bump(idx,t_idx_bump),1),...
                        1.96/length(idx)*std(RP.stiffness_magnitude_bump(idx,t_idx_bump),[],1),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
                end
                title({['Stiffness (early bump).'];['Bump: ' num2str(180/pi*RP.bump_directions(iBump)) '^o. '...
                    'Movement: ' num2str(mod(180+180/pi*RP.perturbation_directions(iDir),360)) '^o']},...
                    'Interpreter','tex')        
                xlabel('t (s)')
                ylabel('K (N/cm)')
                axis square

                legend(legend_str);

                h_sub(end+1) = subplot(length(RP.perturbation_directions_idx),2,iDir*2);               
                legend_str = {};

                hold on                  
                for iFreq = 1:length(RP.perturbation_frequencies_idx)               
                    idx = intersect(RP.bump_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});                
                    idx = intersect(idx,RP.perturbation_directions_idx{iDir});
                    idx = intersect(idx,RP.late_bump);
                    plot(RP.t_bump(t_idx_bump),mean(RP.stiffness_magnitude_bump(idx,t_idx_bump),1),...
                               'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(RP.t_bump(t_idx_bump),mean(RP.stiffness_magnitude_bump(idx,t_idx_bump),1),...
                        1.96/length(idx)*std(RP.stiffness_magnitude_bump(idx,t_idx_bump),[],1),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
                end
                title({['Stiffness (late bump).'];['Bump: ' num2str(180/pi*RP.bump_directions(iBump)) '^o. '...
                    'Movement: ' num2str(mod(180+180/pi*RP.perturbation_directions(iDir),360)) '^o']},...
                    'Interpreter','tex')        
                xlabel('t (s)')
                ylabel('K (N/cm)')
                axis square            

                legend(legend_str);
            end
            set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])
            set(h_sub,'XLim',[RP.t_bump(t_idx_bump(1)) RP.t_bump(t_idx_bump(end))])
            set(params.fig_handles(end),'Name',['Stiffness Bump ' num2str(180/pi*RP.bump_directions(iBump))])
        end
    end
end

%% Displacement vs time - Bump response 
if exist('t_bump')
    if ~isfield(RP,'BMI') && isfield(RP,'bump_directions_idx')
        h_sub = [];

        for iBump = 1:length(RP.bump_directions_idx)
            params.fig_handles(end+1) = figure;    

            for iDir = 1:length(RP.perturbation_directions_idx)
                h_sub(end+1) = subplot(length(RP.perturbation_directions_idx),2,iDir*2-1);
                legend_str = {};

                hold on       
                for iFreq = 1:length(RP.perturbation_frequencies_idx)               
                    idx = intersect(RP.bump_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});                
                    idx = intersect(idx,RP.perturbation_directions_idx{iDir});
                    idx = intersect(idx,RP.early_bump);
                    plot(RP.t_bump(t_idx_bump),mean(RP.bump_displacement(idx,t_idx_bump),1),...
                               'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(RP.t_bump(t_idx_bump),mean(RP.bump_displacement(idx,t_idx_bump),1),...
                        1.96/length(idx)*std(RP.bump_displacement(idx,t_idx_bump),[],1),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
                end
                title({['Displacement (early bump).'];['Bump: ' num2str(180/pi*RP.bump_directions(iBump)) '^o. '...
                    'Movement: ' num2str(mod(180+180/pi*RP.perturbation_directions(iDir),360)) '^o']},...
                    'Interpreter','tex')        
                xlabel('t (s)')
                ylabel('displacement (cm)')
                axis square

                legend(legend_str);

                h_sub(end+1) = subplot(length(RP.perturbation_directions_idx),2,iDir*2);               
                legend_str = {};

                hold on                  
                for iFreq = 1:length(RP.perturbation_frequencies_idx)               
                    idx = intersect(RP.bump_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});                
                    idx = intersect(idx,RP.perturbation_directions_idx{iDir});
                    idx = intersect(idx,RP.late_bump);
                    plot(RP.t_bump(t_idx_bump),mean(RP.bump_displacement(idx,t_idx_bump),1),...
                               'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(RP.t_bump(t_idx_bump),mean(RP.bump_displacement(idx,t_idx_bump),1),...
                        1.96/length(idx)*std(RP.bump_displacement(idx,t_idx_bump),[],1),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
                end
                title({['Displacement (late bump).'];['Bump: ' num2str(180/pi*RP.bump_directions(iBump)) '^o. '...
                    'Movement: ' num2str(mod(180+180/pi*RP.perturbation_directions(iDir),360)) '^o']},...
                    'Interpreter','tex')        
                xlabel('t (s)')
                ylabel('displacement (cm)')
                axis square            

                legend(legend_str);
            end
            set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])
            set(h_sub,'XLim',[RP.t_bump(t_idx_bump(1)) RP.t_bump(t_idx_bump(end))])
            set(params.fig_handles(end),'Name',['Displacement Bump ' num2str(180/pi*RP.bump_directions(iBump))])
        end
    end
end
%% Force vs time - Bump response 
if exist('t_bump')
    if ~isfield(RP,'BMI') && isfield(RP,'bump_directions_idx')
        h_sub = [];

        for iBump = 1:length(RP.bump_directions_idx)
            params.fig_handles(end+1) = figure;    

            for iDir = 1:length(RP.perturbation_directions_idx)
                h_sub(end+1) = subplot(length(RP.perturbation_directions_idx),2,iDir*2-1);
                legend_str = {};

                hold on       
                for iFreq = 1:length(RP.perturbation_frequencies_idx)               
                    idx = intersect(RP.bump_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});                
                    idx = intersect(idx,RP.perturbation_directions_idx{iDir});
                    idx = intersect(idx,RP.early_bump);
                    plot(RP.t_bump(t_idx_bump),mean(RP.force_bump_magnitude(idx,t_idx_bump),1),...
                               'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(RP.t_bump(t_idx_bump),mean(RP.force_bump_magnitude(idx,t_idx_bump),1),...
                        1.96/length(idx)*std(RP.force_bump_magnitude(idx,t_idx_bump),[],1),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
                end
                title({['Force (early bump).'];['Bump: ' num2str(180/pi*RP.bump_directions(iBump)) '^o. '...
                    'Movement: ' num2str(mod(180+180/pi*RP.perturbation_directions(iDir),360)) '^o']},...
                    'Interpreter','tex')        
                xlabel('t (s)')
                ylabel('force (N)')
                axis square

                legend(legend_str);

                h_sub(end+1) = subplot(length(RP.perturbation_directions_idx),2,iDir*2);               
                legend_str = {};

                hold on                  
                for iFreq = 1:length(RP.perturbation_frequencies_idx)               
                    idx = intersect(RP.bump_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});                
                    idx = intersect(idx,RP.perturbation_directions_idx{iDir});
                    idx = intersect(idx,RP.late_bump);
                    plot(RP.t_bump(t_idx_bump),mean(RP.force_bump_magnitude(idx,t_idx_bump),1),...
                               'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(RP.t_bump(t_idx_bump),mean(RP.force_bump_magnitude(idx,t_idx_bump),1),...
                        1.96/length(idx)*std(RP.force_bump_magnitude(idx,t_idx_bump),[],1),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
                end
                title({['Force (late bump).'];['Bump: ' num2str(180/pi*RP.bump_directions(iBump)) '^o. '...
                    'Movement: ' num2str(mod(180+180/pi*RP.perturbation_directions(iDir),360)) '^o']},...
                    'Interpreter','tex')        
                xlabel('t (s)')
                ylabel('force (N)')
                axis square            

                legend(legend_str);
            end
            set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])
            set(h_sub,'XLim',[RP.t_bump(t_idx_bump(1)) RP.t_bump(t_idx_bump(end))])
            set(params.fig_handles(end),'Name',['Force Bump ' num2str(180/pi*RP.bump_directions(iBump))])
        end
    end
end

 %% Synchronization debugging stuff
% clear first_idx
% for iTrial = 1:size(RP.force_pert_x_rot_bmi,1)
%     temp = find(RP.force_pert_x_rot_bmi(iTrial,:)~=0,1,'first');
%     if ~isempty(temp)  
%         first_idx(iTrial) = temp;
%     else
%         first_idx(iTrial) = nan;
%     end
% end
%    
% figure
% plot(RP.trial_table(~isnan(first_idx),RP.table_columns.t_start_perturbation),RP.t_pert_bmi(first_idx(~isnan(first_idx))),'.')