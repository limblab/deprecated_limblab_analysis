function params = RP_plot_predicted_emg(data_struct,params)

RP = data_struct.RP;
bdf = data_struct.bdf;

if isempty(RP.emg)
    return
end

%% Movement EMG separated by frequency
for iEMG = 1:length(RP.BMI.emgnames)
    params.fig_handles(end+1) = figure;
    h_sub = [];
    max_y = 0;    
    for iDir = 1:length(RP.perturbation_directions)
        h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iDir);
        hold on   
        legend_str = {};
        mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
        sem_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));        
        for iFreq = 1:length(RP.perturbation_frequencies)  
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});            
            emg_temp = RP.emg_pert_bmi(idx,:,iEMG);
            mean_emg(iFreq,:) = mean(emg_temp);
            sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));                    
            plot(RP.t_pert_bmi,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:))
            errorarea(RP.t_pert_bmi,mean_emg(iFreq,:),...
                sem_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
            legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
            ' Hz']}];
        end
       
        max_y = max(max_y,max(mean_emg(:)));        
        xlabel('Time from go cue (s)')
        ylabel('EMG (au)')
        title(['Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
            '^o. ' strrep(RP.BMI.emgnames{iEMG},'_',' ')],'Interpreter','tex')
        set(params.fig_handles(end),'Name',['EMG movement ' strrep(RP.BMI.emgnames{iEMG},'_',' ')]) 
        legend(legend_str)

    end

    set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])
%         h_axes = get(gcf,'Children');
%         set(h_axes,'YLim',[0 max_y]);        

end

%% Movement co-contraction separated by frequency
% for iEMG = 1:size(RP.emg_pert,3)
    params.fig_handles(end+1) = figure;
    h_sub = [];
    max_y = 0;    
    for iDir = 1:length(RP.perturbation_directions)
        h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iDir);
        hold on   
        legend_str = {};
        mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
        sem_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));        
        for iFreq = 1:length(RP.perturbation_frequencies)  
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});            
            emg_temp = RP.emg_pert_bmi(idx,:,iEMG);
            emg_temp = RP.emg_cocontraction_bmi_bi_tri(idx,:);
            mean_emg(iFreq,:) = mean(emg_temp);
            sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));           
           
            plot(RP.t_pert_bmi,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:))
            errorarea(RP.t_pert_bmi,mean_emg(iFreq,:),...
                sem_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
            legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
            ' Hz.']}];
        end
       
        max_y = max(max_y,max(mean_emg(:)));        
        xlabel('Time from go cue (s)')
        ylabel('Co-contraction index')
        title(['Co-contraction predicted bi-tri. Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
            '^o.'],'Interpreter','tex')
        set(params.fig_handles(end),'Name',['Co-contraction predicted bi-tri']) 
        legend(legend_str)

    end

    set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])
%         h_axes = get(gcf,'Children');
%         set(h_axes,'YLim',[0 max_y]);        

% end

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
                mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_bump_bmi));
                sem_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_bump_bmi));
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
                    emg_temp = RP.emg_bump_bmi(idx,:,iEMG);
                    mean_emg(iFreq,:) = mean(emg_temp);
                    sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));
                    plot(RP.t_bump_bmi,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(RP.t_bump_bmi,mean_emg(iFreq,:),...
                        sem_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz.']}];
                    emg_all(iDir,iEMG,iFreq,:) = mean(RP.emg_bump(idx,:,iEMG),1);  
                end
                xlabel('Time from go cue (s)')
                ylabel('EMG (au)')
                title({[strrep(RP.BMI.emgnames{iEMG},'_',' ') '. Bump: ' num2str(RP.bump_directions(iBump)*180/pi) '^o. '...
                    'Movement: ' num2str(mod(180+round(RP.perturbation_directions(iDir)*180/pi),360))...
                    '^o.'];[bump_str '. ' ]},'Interpreter','tex');
                set(params.fig_handles(end),'Name',['EMG bump ' strrep(RP.BMI.emgnames{iEMG},'_',' ') ' Bump '...
                    num2str(round(RP.bump_directions(iBump)*180/pi))]) 
                legend(legend_str)
            end
        end        
        set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])       

    end
end
