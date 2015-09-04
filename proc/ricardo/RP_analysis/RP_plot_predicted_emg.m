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
        h_plot = [];
        mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
        std_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));        
        for iFreq = 1:length(RP.perturbation_frequencies)            
            for iOutcome = 1:2            
                idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});            
                if iOutcome == 1
                    idx = intersect(idx,RP.reward_trials);
                else
                    idx = intersect(idx,RP.fail_trials);
%                     idx = intersect(idx,setxor(1:size(RP.trial_table,1),RP.reward_trials));
                end
                emg_temp = RP.emg_pert_bmi(idx,:,iEMG);
%                 idx = setxor(idx,idx(find(mean(emg_temp,2) > 3*std(emg_temp(:)))));
                emg_temp = RP.emg_pert_bmi(idx,:,iEMG);
                mean_emg(iFreq,:) = mean(emg_temp);
%                 sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));    
                std_emg(iFreq,:) = std(emg_temp);    
                if iOutcome == 1
                    h_plot(end+1) = plot(RP.t_pert_bmi,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:));
                    errorarea(RP.t_pert_bmi,mean_emg(iFreq,:),...
                        std_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                        ' Hz']}];
                else
                    plot(RP.t_pert_bmi,mean_emg(iFreq,:),'--','Color',RP.perturbation_frequency_colors(iFreq,:))
                end
                
            end
        end
       
        max_y = max(max_y,max(mean_emg(:)));        
        xlabel('Time from go cue (s)')
        ylabel('EMG (au)')
        title(['Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
            '^o. ' strrep(RP.BMI.emgnames{iEMG},'_',' ')],'Interpreter','tex')
        set(params.fig_handles(end),'Name',['Predicted EMG movement ' strrep(RP.BMI.emgnames{iEMG},'_',' ')]) 
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
    mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
    std_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
    for iFreq = 1:length(RP.perturbation_frequencies)
        for iOutcome = 1:2
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});
            if iOutcome == 1
                idx = intersect(idx,RP.reward_trials);
            else
                idx = intersect(idx,RP.fail_trials);
            end            
            
            cocon_mode = 2;
            if cocon_mode == 1
                emg_temp = RP.emg_cocontraction_bmi_bi_tri(idx,:);
            elseif cocon_mode == 2            
                if RP.BMI.params.arm_params.use_brd
                    cocon_emg_idx = find(~cellfun(@isempty,strfind(RP.BMI.emgnames,'EMG_BRD')));
                else
                    cocon_emg_idx = find(~cellfun(@isempty,strfind(RP.BMI.emgnames,'EMG_BI')));
                end
                cocon_emg_idx(2) = find(~cellfun(@isempty,strfind(RP.BMI.emgnames,'EMG_TRI')));

                emg_temp_1 = RP.emg_pert_bmi(idx,:,cocon_emg_idx(1));
                emg_temp_2 = RP.emg_pert_bmi(idx,:,cocon_emg_idx(2));

                temp = min(emg_temp_1./(emg_temp_2+.00001),emg_temp_2./(emg_temp_1+.00001));
                emg_temp = temp.*(emg_temp_1 + emg_temp_2);
            elseif cocon_mode == 3
                if RP.BMI.params.arm_params.use_brd
                    cocon_emg_idx = find(~cellfun(@isempty,strfind(RP.BMI.emgnames,'EMG_BRD')));
                else
                    cocon_emg_idx = find(~cellfun(@isempty,strfind(RP.BMI.emgnames,'EMG_BI')));
                end
                cocon_emg_idx(2) = find(~cellfun(@isempty,strfind(RP.BMI.emgnames,'EMG_TRI')));

                emg_temp_1 = RP.emg_pert_bmi(idx,:,cocon_emg_idx(1));
                emg_temp_2 = RP.emg_pert_bmi(idx,:,cocon_emg_idx(2));
                emg_temp = emg_temp_1 + emg_temp_2;
            end
            
            mean_emg(iFreq,:) = mean(emg_temp);
%             sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));
            std_emg(iFreq,:) = std(emg_temp);
            
            if iOutcome == 1
                h_plot(end+1) = plot(RP.t_pert_bmi,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:));
                errorarea(RP.t_pert_bmi,mean_emg(iFreq,:),...
                    std_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
            else
                plot(RP.t_pert_bmi,mean_emg(iFreq,:),'--','Color',RP.perturbation_frequency_colors(iFreq,:))
            end
        end
    end
    
    max_y = max(max_y,max(mean_emg(:)));
    xlabel('Time from go cue (s)')
    ylabel('Co-contraction index')
    title(['Co-contraction predicted brd-tri. Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
        '^o.'],'Interpreter','tex')
    set(params.fig_handles(end),'Name',['Co-contraction predicted brd-tri'])
    legend(h_plot,legend_str)
    
end

set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])

%% Movement sum of antagonistic muscles separated by frequency
params.fig_handles(end+1) = figure;
h_sub = [];
max_y = 0;
if RP.BMI.params.arm_params.use_brd
    emg_idx = find(~cellfun(@isempty,strfind(RP.BMI.emgnames,'TRI')) + ~cellfun(@isempty,strfind(RP.BMI.emgnames,'BRD')));
else
    emg_idx = find(~cellfun(@isempty,strfind(RP.BMI.emgnames,'TRI')) + ~cellfun(@isempty,strfind(RP.BMI.emgnames,'BI')));
end
for iDir = 1:length(RP.perturbation_directions)
    h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iDir);
    hold on
    legend_str = {};
    
    h_plot = [];
    mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
    std_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
    for iFreq = 1:length(RP.perturbation_frequencies)
        for iOutcome = 1:2
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});
            if iOutcome == 1
                idx = intersect(idx,RP.reward_trials);
            else
                idx = intersect(idx,RP.fail_trials);
            end
            %             idx = intersect(idx,RP.reward_trials);            
            emg_temp = sum(RP.emg_pert_bmi(idx,:,emg_idx),3);
%             emg_temp = RP.emg_pert_bmi(idx,:,emg_idx(1)) + RP.emg_pert_bmi(idx,:,emg_idx(2));
            mean_emg(iFreq,:) = mean(emg_temp,1);
            std_emg(iFreq,:) = std(emg_temp,[],1);
%             sem_emg(iFreq,:) = 1.96*std(emg_temp,[],1)/sqrt(size(emg_temp,1));
            
            if iOutcome == 1
                h_plot(end+1) = plot(RP.t_pert_bmi,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:));
                errorarea(RP.t_pert_bmi,mean_emg(iFreq,:),...
                    std_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
            else
                plot(RP.t_pert_bmi,mean_emg(iFreq,:),'--','Color',RP.perturbation_frequency_colors(iFreq,:))
            end
        end
    end
    
    max_y = max(max_y,max(mean_emg(:)));
    xlabel('Time from go cue (s)')
    ylabel('EMG sum (Tri + Brd)')
    title(['EMG sum. Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
        '^o.'],'Interpreter','tex')
    set(params.fig_handles(end),'Name',['EMG sum'])
    legend(legend_str)    
end
set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])

%% Movement EMG difference separated by frequency

params.fig_handles(end+1) = figure;
h_sub = [];
max_y = 0;
min_y = 0;
for iDir = 1:length(RP.perturbation_directions)
    h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iDir);
    hold on
    legend_str = {};
    h_plot = [];
    mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
    std_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert_bmi));
    for iFreq = 1:length(RP.perturbation_frequencies)
        for iOutcome = 1:2
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});
            if iOutcome == 1
                idx = intersect(idx,RP.reward_trials);
            else
                idx = intersect(idx,RP.fail_trials);
%                 idx = intersect(idx,setxor(1:size(RP.trial_table,1),RP.reward_trials));
            end
            %             idx = intersect(idx,RP.reward_trials);
%             emg_temp = RP.emg_cocontraction_bmi_bi_tri(idx,:);
            emg_temp = RP.emg_pert_bmi(idx,:,2) - RP.emg_pert_bmi(idx,:,3);
            mean_emg(iFreq,:) = mean(emg_temp);
%             sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));
            std_emg(iFreq,:) = std(emg_temp);
            
            if iOutcome == 1
                h_plot(end+1) = plot(RP.t_pert_bmi,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:));
                errorarea(RP.t_pert_bmi,mean_emg(iFreq,:),...
                    std_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
            else
                plot(RP.t_pert_bmi,mean_emg(iFreq,:),'--','Color',RP.perturbation_frequency_colors(iFreq,:))
            end
        end
        plot(RP.t_pert_bmi,zeros(size(RP.t_pert_bmi)),'-k')
    end
    
    max_y = max(max_y,max(mean_emg(:)));
    min_y = min(min_y,min(mean_emg(:)));
    max_y = max(abs(min_y),max_y);
    xlabel('Time from go cue (s)')
    ylabel('EMG TRI - EMG BRD')
    title(['Difference predicted tri-brd. Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
        '^o.'],'Interpreter','tex')
    set(params.fig_handles(end),'Name',['Difference predicted brd-tri'])
    legend(h_plot,legend_str)
    
end

set(h_sub,'YLim',[min(cellfun(@min,get(h_sub,'YLim'))) max(cellfun(@max,get(h_sub,'YLim')))])
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
                std_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_bump_bmi));
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
%                     sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));
                    std_emg(iFreq,:) = std(emg_temp);
                    plot(RP.t_bump_bmi,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:))
                    errorarea(RP.t_bump_bmi,mean_emg(iFreq,:),...
                        std_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz.']}];
                    emg_all(iDir,iEMG,iFreq,:) = mean(RP.emg_bump(idx,:,iEMG),1);  
                end
                xlabel('Time from go cue (s)')
                ylabel('EMG (au)')
                title({[strrep(RP.BMI.emgnames{iEMG},'_',' ') '. Bump: ' num2str(RP.bump_directions(iBump)*180/pi) '^o. '...
                    'Movement: ' num2str(mod(180+round(RP.perturbation_directions(iDir)*180/pi),360))...
                    '^o.'];[bump_str '. ' ]},'Interpreter','tex');
                set(params.fig_handles(end),'Name',['Predicted EMG bump ' strrep(RP.BMI.emgnames{iEMG},'_',' ') ' Bump '...
                    num2str(round(RP.bump_directions(iBump)*180/pi))]) 
                legend(legend_str)
            end
        end        
        set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])       

    end
end

%%
if isfield(RP.table_columns,'cocontraction_target') && any(RP.trial_table(:,RP.table_columns.cocontraction_target))
    params.fig_handles(end+1) = figure;
    hold on

    cocontraction_idx = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'cocontraction')));    
    cocontraction = RP.BMI.data(:,cocontraction_idx);
    t_idx = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'t_bin_start')));
    plot(RP.BMI.data(:,t_idx),cocontraction)

    for iTrial = 1:size(RP.trial_table,1)
    %     rectangle('Position',[RP.trial_table(iTrial,RP.table_columns.t_trial_start)...
    %         RP.trial_table(iTrial,RP.table_columns.cocontraction_level)-0.5*RP.trial_table(iTrial,RP.table_columns.cocontraction_window),...
    %         diff(RP.trial_table(iTrial,[RP.table_columns.t_trial_start RP.table_columns.t_trial_end])),...
    %         RP.trial_table(iTrial,RP.table_columns.cocontraction_window)])
        rectangle('Position',[RP.trial_table(iTrial,RP.table_columns.t_ct_hold_on)...
            RP.trial_table(iTrial,RP.table_columns.cocontraction_level)-0.5*RP.trial_table(iTrial,RP.table_columns.cocontraction_window),...
            diff(RP.trial_table(iTrial,[RP.table_columns.t_ct_hold_on RP.table_columns.t_trial_end])),...
            RP.trial_table(iTrial,RP.table_columns.cocontraction_window)])
        plot(RP.trial_table(iTrial,[RP.table_columns.t_trial_start RP.table_columns.t_trial_end]),...
            RP.trial_table(iTrial,[RP.table_columns.cocontraction_level RP.table_columns.cocontraction_level]),...
            'r')
    end
end

%% 
params.fig_handles(end+1) = figure;
hold on
if strcmp(bdf.meta.filename,'Chewie_2015-05-12_RP_n2e_hu_001')   
    cocontraction_idx = 74;
    t_idx = 1;
else
    cocontraction_idx = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'cocontraction')));
    t_idx = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'t_bin_start')));
end

cocontraction = RP.BMI.data(:,cocontraction_idx);


frequency_changes = [1;find(diff(RP.trial_table(:,RP.table_columns.perturbation_frequency))~=0)];

for iFreq = 1:length(frequency_changes)-1
    temp = cellfun(@(x) x==frequency_changes(iFreq),RP.perturbation_frequencies_idx,'UniformOutput',false);
    freq_idx = find(cellfun(@sum,temp));
    rectangle('Position',[RP.trial_table(frequency_changes(iFreq),RP.table_columns.t_trial_start) ...
        0 RP.trial_table(frequency_changes(iFreq+1),RP.table_columns.t_trial_end) - RP.trial_table(frequency_changes(iFreq),RP.table_columns.t_trial_start) ...
        max(cocontraction(:))],'FaceColor',min(.5+RP.perturbation_frequency_colors(freq_idx,:),1),'LineStyle','none');
end
temp = cellfun(@(x) x==frequency_changes(end),RP.perturbation_frequencies_idx,'UniformOutput',false);
freq_idx = find(cellfun(@sum,temp));
rectangle('Position',[RP.trial_table(frequency_changes(end),RP.table_columns.t_trial_start) ...
    0 RP.trial_table(end,RP.table_columns.t_trial_end) - RP.trial_table(frequency_changes(end),RP.table_columns.t_trial_start) ...
    max(cocontraction(:))],'FaceColor',min(.5+RP.perturbation_frequency_colors(freq_idx,:),1),'LineStyle','none');    

plot(RP.BMI.data(:,t_idx),cocontraction,'k')
title('Co-contraction')
ylabel('Co-contraction')
xlabel('t (s)')
xlim([0 RP.trial_table(end,RP.table_columns.t_trial_end)])
ylim([0 max(cocontraction(:))])

%% Cocontraction as a function of session time
params.fig_handles(end+1) = figure;
h_sub = [];
max_y = 0;
hist_result = [];
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
%                 idx = intersect(idx,setxor(1:size(RP.trial_table,1),RP.reward_trials));
            end
            %             idx = intersect(idx,RP.reward_trials);
            emg_temp = RP.emg_cocontraction_bmi_bi_tri(idx,:);
            mean_emg = mean(emg_temp(:,RP.t_pert_bmi > 1),2);            
%             sem_emg = 1.96*std(emg_temp(:,RP.t_pert_bmi > 0),[],2);
            std_emg = std(emg_temp(:,RP.t_pert_bmi > 1),[],2);
            t_trials = RP.trial_table(idx,RP.table_columns.t_trial_start);
            
            if iOutcome == 1
                if (~isempty(t_trials) && length(t_trials)>1)
                    lin_fit = polyfit(t_trials,mean_emg,1);
                    h_plot(end+1) = plot(t_trials,mean_emg,'.','Color',RP.perturbation_frequency_colors(iFreq,:));
%                     plot(t_trials([1 end]),[mean(mean_emg(:)) mean(mean_emg(:))],'-','Color',RP.perturbation_frequency_colors(iFreq,:));
                    plot(t_trials([1 end]),polyval(lin_fit,t_trials([1 end])),'-','Color',RP.perturbation_frequency_colors(iFreq,:));
                end
%                 errorarea(t_trials,mean_emg,...
%                     sem_emg,RP.perturbation_frequency_colors(iFreq,:),.5);
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
                hist_result(end+1,:) = hist(mean_emg,[0:.05:.5]);
            else
                if (~isempty(t_trials) && length(t_trials)>1)
                    lin_fit = polyfit(t_trials,mean_emg,1);
                    plot(t_trials,mean_emg,'.','Color',min(1,[RP.perturbation_frequency_colors(iFreq,:)+.7]))
                    plot(t_trials([1 end]),polyval(lin_fit,t_trials([1 end])),'-','Color',min(1,[RP.perturbation_frequency_colors(iFreq,:)+.7]));
                end
            end
        end
    end
    
%     max_y = max(max_y,max(mean_emg(:)));
    xlabel('Time in session (s)')
    ylabel('Mean co-contraction index')
    title(['Mean co-contraction predicted brd-tri. Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
        '^o.'],'Interpreter','tex')
    set(params.fig_handles(end),'Name',['Mean co-contraction predicted brd-tri'])
    legend(h_plot,legend_str)
    
end

set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])

%% EMG diff as a function of session time
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
            emg_temp = abs(RP.emg_pert_bmi(idx,:,2) - RP.emg_pert_bmi(idx,:,3));
            mean_emg = mean(emg_temp(:,RP.t_pert_bmi > 0),2);
            sem_emg = 1.96*std(emg_temp(:,RP.t_pert_bmi > 0),[],2);
            t_trials = RP.trial_table(idx,RP.table_columns.t_trial_start);
            
            if iOutcome == 1
                if (~isempty(t_trials) && length(t_trials)>1)
                    lin_fit = polyfit(t_trials,mean_emg,1);
                    h_plot(end+1) = plot(t_trials,mean_emg,'.','Color',RP.perturbation_frequency_colors(iFreq,:));
%                     plot(t_trials([1 end]),[mean(mean_emg(:)) mean(mean_emg(:))],'-','Color',RP.perturbation_frequency_colors(iFreq,:));
                    plot(t_trials([1 end]),polyval(lin_fit,t_trials([1 end])),'-','Color',RP.perturbation_frequency_colors(iFreq,:));
                end
%                 errorarea(t_trials,mean_emg,...
%                     sem_emg,RP.perturbation_frequency_colors(iFreq,:),.5);
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
            else
                if ~isempty(t_trials)
                    lin_fit = polyfit(t_trials,mean_emg,1);
                    plot(t_trials,mean_emg,'.','Color',min(1,[RP.perturbation_frequency_colors(iFreq,:)+.7]))
%                     plot(t_trials([1 end]),[mean(mean_emg(:)) mean(mean_emg(:))],'-','Color',min(1,[RP.perturbation_frequency_colors(iFreq,:)+.7]));
                    plot(t_trials([1 end]),polyval(lin_fit,t_trials([1 end])),'-','Color',min(1,[RP.perturbation_frequency_colors(iFreq,:)+.7]));
                end
            end
        end
    end
    
%     max_y = max(max_y,max(mean_emg(:)));
    xlabel('Time in session (s)')
    ylabel('Mean pred EMG difference')
    title(['Mean pred EMG difference (TRI-BRD). Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
        '^o.'],'Interpreter','tex')
    set(params.fig_handles(end),'Name',['Mean pred EMG difference (TRI-BRD)'])
    legend(h_plot,legend_str)
    
end

set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])

