function params = RP_plot_emg(data_struct,params)

RP = data_struct.RP;
bdf = data_struct.bdf;

if isempty(RP.emg)
    return
end

%% Movement EMG separated by frequency
for iEMG = 1:size(RP.emg_pert,3)
    params.fig_handles(end+1) = figure;
    h_sub = [];
    max_y = 0;    
    for iDir = 1:length(RP.perturbation_directions)
        h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iDir);
        hold on   
        legend_str = {};
        
        
        h_plot = [];
        mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert));
        sem_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert));        
        for iFreq = 1:length(RP.perturbation_frequencies)            
            for iOutcome = 1:2            
                idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});            
                if iOutcome == 1
                    idx = intersect(idx,RP.reward_trials);
                else
                    idx = intersect(idx,RP.fail_trials);
                end
                emg_temp = RP.emg_pert(idx,:,iEMG);
                idx = setxor(idx,idx(find(mean(emg_temp,2) > 3*std(emg_temp(:)))));
                emg_temp = RP.emg_pert(idx,:,iEMG);
                mean_emg(iFreq,:) = mean(emg_temp);
                sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));    
                if iOutcome == 1
                    h_plot(end+1) = plot(RP.t_pert,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:));
                    errorarea(RP.t_pert,mean_emg(iFreq,:),...
                        sem_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                        ' Hz']}];
                else
                    plot(RP.t_pert,mean_emg(iFreq,:),'--','Color',RP.perturbation_frequency_colors(iFreq,:))
                end
                
            end
        end        
       
        max_y = max(max_y,max(mean_emg(:)));        
        xlabel('Time from go cue (s)')
        ylabel('EMG (au)')
        title(['Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
            '^o. ' strrep(bdf.emg.emgnames{iEMG},'_',' ')],'Interpreter','tex')
        set(params.fig_handles(end),'Name',['EMG movement ' strrep(bdf.emg.emgnames{iEMG},'_',' ')]) 
        legend(h_plot,legend_str)

    end

    set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])
%         h_axes = get(gcf,'Children');
%         set(h_axes,'YLim',[0 max_y]);        

end

%% Movement co-contraction separated by frequency

params.fig_handles(end+1) = figure;
h_sub = [];
max_y = 0;
for iDir = 1:length(RP.perturbation_directions)
    h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iDir);
    hold on
    legend_str = {};
    
    h_plot = [];
    mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert));
    sem_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert));
    for iFreq = 1:length(RP.perturbation_frequencies)
        for iOutcome = 1:2
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});
            if iOutcome == 1
                idx = intersect(idx,RP.reward_trials);
            else
                idx = intersect(idx,RP.fail_trials);
            end
            %             idx = intersect(idx,RP.reward_trials);
            emg_temp = RP.emg_cocontraction_bi_tri(idx,:);
            mean_emg(iFreq,:) = mean(emg_temp);
            sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));
            
            if iOutcome == 1
                h_plot(end+1) = plot(RP.t_pert,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:));
                errorarea(RP.t_pert,mean_emg(iFreq,:),...
                    sem_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
            else
                plot(RP.t_pert,mean_emg(iFreq,:),'--','Color',RP.perturbation_frequency_colors(iFreq,:))
            end
        end
    end
    
    max_y = max(max_y,max(mean_emg(:)));
    xlabel('Time from go cue (s)')
    ylabel('Co-contraction index')
    title(['Co-contraction bi-tri. Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
        '^o.'],'Interpreter','tex')
    set(params.fig_handles(end),'Name',['Co-contraction bi-tri'])
    legend(legend_str)
    
end

set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])


%% Channel correlation coefficients
% correlation = zeros(size(RP.emg,1),size(RP.emg,1));
% for iEMG = 1:size(RP.emg,1)
%     iEMG
%     for jEMG = iEMG:size(RP.emg,1)
%         temp = corrcoef(RP.emg(iEMG,:),RP.emg(jEMG,:));
%         correlation(iEMG,jEMG) = temp(1,2);
%     end
% end

%% Bump EMG separated by bump direction, frequency, movement direction and early/late bump
for iEMG = 1:size(RP.emg_bump,3)
    for iBump = 1:length(RP.bump_directions)
        clear emg_all        
        params.fig_handles(end+1) = figure;
        h_sub = [];
        
        max_y = 0;    
        for iBumpTime = 1:2
            for iDir = 1:length(RP.perturbation_directions)
                h_sub(end+1) = subplot(length(RP.perturbation_directions),2,iDir*2-1+iBumpTime-1);
                hold on   
                legend_str = {};
                mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_bump));
                sem_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_bump));
                for iFreq = 1:length(RP.perturbation_frequencies)  
                    idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});            
                    idx = intersect(idx,RP.bump_directions_idx{iBump});
                    if (iBumpTime == 1)
                        idx = intersect(idx,RP.early_bump);
                        bump_str = 'Early bump';
                    else
                        idx = intersect(idx,RP.late_bump);
                        bump_str = 'Late bump';
                    end
                    emg_temp = RP.emg_bump(idx,:,iEMG);
                    mean_emg(iFreq,:) = mean(emg_temp);
                    sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));
                    plot(RP.t_bump,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(RP.t_bump,mean_emg(iFreq,:),...
                        sem_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz.']}];
                    emg_all(iDir,iEMG,iFreq,:) = mean(RP.emg_bump(idx,:,iEMG),1);  
                end
                xlabel('Time from go cue (s)')
                ylabel('EMG (au)')
                title({[strrep(bdf.emg.emgnames{iEMG},'_',' ') '. Bump: ' num2str(RP.bump_directions(iBump)*180/pi) '^o. '...
                    'Movement: ' num2str(mod(180+round(RP.perturbation_directions(iDir)*180/pi),360))...
                    '^o.'];[bump_str '. ' ]},'Interpreter','tex');
                set(params.fig_handles(end),'Name',['EMG bump ' strrep(bdf.emg.emgnames{iEMG},'_',' ') ' Bump '...
                    num2str(round(RP.bump_directions(iBump)*180/pi))]) 
                legend(legend_str)
            end
        end        
        set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])       

    end
end

%% Cocontraction as a function of session time
params.fig_handles(end+1) = figure;
h_sub = [];
max_y = 0;
for iDir = 1:length(RP.perturbation_directions)
    h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iDir);
    hold on
    legend_str = {};
    h_plot = [];
%     mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
%     sem_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
    for iFreq = 1:length(RP.perturbation_frequencies)
        for iOutcome = 1:2
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});
            if iOutcome == 1
                idx = intersect(idx,RP.reward_trials);
            else
                idx = intersect(idx,RP.fail_trials);
            end
            %             idx = intersect(idx,RP.reward_trials);
            emg_temp = RP.emg_cocontraction_bi_tri(idx,:);
            mean_emg = mean(emg_temp(:,RP.t_pert > 0),2);
            sem_emg = 1.96*std(emg_temp(:,RP.t_pert > 0),[],2);
            t_trials = RP.trial_table(idx,RP.table_columns.t_trial_start);
            
            if iOutcome == 1
                if ~isempty(t_trials)
                    h_plot(end+1) = plot(t_trials,mean_emg,'.','Color',RP.perturbation_frequency_colors(iFreq,:));
                    plot(t_trials([1 end]),[mean(mean_emg(:)) mean(mean_emg(:))],'-','Color',RP.perturbation_frequency_colors(iFreq,:));
                end
%                 errorarea(t_trials,mean_emg,...
%                     sem_emg,RP.perturbation_frequency_colors(iFreq,:),.5);
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
            else
                if ~isempty(t_trials)
                    plot(t_trials,mean_emg,'.','Color',min(1,[RP.perturbation_frequency_colors(iFreq,:)+.7]))
                    plot(t_trials([1 end]),[mean(mean_emg(:)) mean(mean_emg(:))],'-','Color',min(1,[RP.perturbation_frequency_colors(iFreq,:)+.7]));
                end
            end
        end
    end
    
%     max_y = max(max_y,max(mean_emg(:)));
    xlabel('Time in session (s)')
    ylabel('Mean co-contraction index')
    title(['Mean co-contraction predicted bi-tri. Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
        '^o.'],'Interpreter','tex')
    set(params.fig_handles(end),'Name',['Mean co-contraction predicted bi-tri'])
    legend(h_plot,legend_str)
    
end

set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])
