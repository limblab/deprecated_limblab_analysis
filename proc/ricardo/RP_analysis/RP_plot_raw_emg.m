function params = RP_plot_raw_emg(data_struct,params)

bdf = data_struct.bdf;
RP = data_struct.RP;

%% Movement EMG separated by frequency
for iEMG = 1:size(RP.emg_pert,3)
    params.fig_handles(end+1) = figure;
    h_sub = [];
    y_limits = [-1 1];    
    for iBump = 1:length(RP.perturbation_directions)
        h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iBump);
        hold on   
        legend_str = {};          
        for iFreq = 1:length(RP.perturbation_frequencies)  
            idx = intersect(RP.perturbation_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});            
            emg_temp = RP.emg_pert_raw(idx(1),:,iEMG) - 40*(iFreq) + 20*length(RP.perturbation_frequencies) + 20; 
           
            plot(RP.t_pert,emg_temp,'Color',RP.perturbation_frequency_colors(iFreq,:))           
            legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
            ' Hz']}];
             y_limits = [min(y_limits(1),min(emg_temp)) max(y_limits(2),max(emg_temp))]; 
        end
        ylim(y_limits)
        xlabel('Time from go cue (s)')
        ylabel('EMG (au)')
        title(['Perturbation direction: ' num2str(round(RP.perturbation_directions(iBump)*180/pi))...
            '^o. ' strrep(bdf.emg.emgnames{iEMG},'_',' ')],'Interpreter','tex')
        set(params.fig_handles(end),'Name',[RP.RP_file_prefix ' EMG movement raw ' strrep(bdf.emg.emgnames{iEMG},'_',' ')]) 
        legend(legend_str)

    end
    set(h_sub,'YLim',[min(cellfun(@min,get(h_sub,'YLim'))) max(cellfun(@max,get(h_sub,'YLim')))])
end

%% Bump EMG separated by frequency
for iEMG = 1:size(RP.emg_pert,3)
    params.fig_handles(end+1) = figure;
    h_sub = [];
    y_limits = [-1 1];    
    for iBump = 1:length(RP.bump_directions)
        h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iBump);
        hold on   
        legend_str = {};          
        for iFreq = 1:length(RP.perturbation_frequencies)  
            idx = intersect(RP.bump_directions_idx{iBump},RP.perturbation_frequencies_idx{iFreq});            
            emg_temp = RP.emg_bump_raw(idx(2),:,iEMG) - 40*(iFreq) + 20*length(RP.perturbation_frequencies) + 20;           
           
            plot(RP.t_bump,emg_temp,'Color',RP.perturbation_frequency_colors(iFreq,:))           
            legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
            ' Hz']}];
             y_limits = [min(y_limits(1),min(emg_temp)) max(y_limits(2),max(emg_temp))];
        end
        
        ylim(y_limits)
        xlabel('Time from go cue (s)')
        ylabel('EMG (au)')
        title(['Bump direction: ' num2str(round(RP.bump_directions(iBump)*180/pi))...
            '^o. ' strrep(bdf.emg.emgnames{iEMG},'_',' ')],'Interpreter','tex')
        set(params.fig_handles(end),'Name',[RP.RP_file_prefix ' EMG bump raw ' strrep(bdf.emg.emgnames{iEMG},'_',' ')]) 
        legend(legend_str)

    end
    set(h_sub,'YLim',[min(cellfun(@min,get(h_sub,'YLim'))) max(cellfun(@max,get(h_sub,'YLim')))])
end