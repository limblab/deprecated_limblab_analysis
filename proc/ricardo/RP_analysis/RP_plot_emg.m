function params = RP_plot_emg(data_struct,params)

RP = data_struct.RP;
bdf = data_struct.bdf;

if isempty(RP.emg)
    return
end

emg_idx = find(~cellfun(@isempty,strfind(bdf.emg.emgnames,'TRI')) + ~cellfun(@isempty,strfind(bdf.emg.emgnames,'BRD')));

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
        t_zero = find(RP.t_pert==0);
        for iFreq = 1:length(RP.perturbation_frequencies)
            for iOutcome = 1:1
                idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});
                if iOutcome == 1
                    idx = intersect(idx,RP.reward_trials);
                else
                    idx = intersect(idx,RP.fail_trials);
                end
                emg_temp = RP.emg_pert(idx,:,iEMG);
                idx = setxor(idx,idx(find(mean(emg_temp,2) > 3*std(emg_temp(:)))));
                emg_temp = RP.emg_pert(idx,:,iEMG);
                
                %                 Fs = 1/diff(RP.t_pert(1:2));
                %                 wo = RP.perturbation_frequencies(iFreq)/(Fs/2);
                %                 bw = wo/2;
                %                 [b,a] = iirnotch(wo,bw);
                %                 emg_temp_filt = filtfilt(b,a,emg_temp')';
                
                %                 pos_mean = mean(RP.pos_pert_x(idx,:)-repmat(RP.pos_pert_x(idx,t_zero),1,size(RP.pos_pert_x,2)));
                vel_mean = mean(RP.vel_pert_x(idx,:)-repmat(RP.vel_pert_x(idx,t_zero),1,size(RP.vel_pert_x,2)));
                vel_mean = vel_mean - mean(vel_mean);
                emg_mean = mean(emg_temp);
                emg_mean = emg_mean - mean(emg_mean);
                L = length(vel_mean);
                NFFT = 5000;
                Fs = 1/diff(RP.t_pert(1:2));
                f = Fs/2*linspace(0,1,NFFT/2+1);
                vel_fft = fft(vel_mean,NFFT)/L;
                emg_fft = fft(emg_mean,NFFT)/L;
                [~,f_idx] = min(abs(f-RP.perturbation_frequencies(iFreq)));
                phase_lag(1) = angle(vel_fft(f_idx))-angle(emg_fft(f_idx));
                phase_lag(2) = (angle(emg_fft(f_idx))+pi-angle(vel_fft(f_idx)));
                phase_lag(3) = (angle(emg_fft(f_idx))-pi-angle(vel_fft(f_idx)));
                phase_lag = mod(phase_lag,2*pi);
                phase_lag = min(phase_lag,2*pi-phase_lag);
                time_lag = (phase_lag/(2*pi))*1/RP.perturbation_frequencies(iFreq);
                time_lag = min(time_lag);
                
                %                 [corr,lags] = xcorr(emg_mean,vel_mean);
                %                 [~,max_idx] = max(abs(corr));
                %                 lags(max_idx);
                
                mean_emg(iFreq,:) = mean(emg_temp);
                std_emg(iFreq,:) = std(emg_temp);
                if iOutcome == 1
                    h_plot(end+1) = plot(RP.t_pert,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:));
                    errorarea(RP.t_pert,mean_emg(iFreq,:),...
                        std_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                    legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                        ' Hz. Lag = ' num2str(time_lag) ' s.']}];
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
    std_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert));
    for iFreq = 1:length(RP.perturbation_frequencies)
        for iOutcome = 1:1
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});
            if iOutcome == 1
                idx = intersect(idx,RP.reward_trials);
            else
                idx = intersect(idx,RP.fail_trials);
            end
            %             idx = intersect(idx,RP.reward_trials);
            emg_temp = RP.emg_cocontraction_bi_tri(idx,:);
            mean_emg(iFreq,:) = mean(emg_temp,1);
            std_emg(iFreq,:) = std(emg_temp,[],1);
            %             sem_emg(iFreq,:) = 1.96*std(emg_temp,[],1)/sqrt(size(emg_temp,1));
            
            if iOutcome == 1
                h_plot(end+1) = plot(RP.t_pert,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:));
                errorarea(RP.t_pert,mean_emg(iFreq,:),...
                    std_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
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

%% Movement sum of antagonistic muscles separated by frequency
params.fig_handles(end+1) = figure;
h_sub = [];
max_y = 0;

emg_idx = find(~cellfun(@isempty,strfind(bdf.emg.emgnames,'TRI')) + ~cellfun(@isempty,strfind(bdf.emg.emgnames,'BRD')));

for iDir = 1:length(RP.perturbation_directions)
    h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iDir);
    hold on
    legend_str = {};
    
    h_plot = [];
    mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert));
    std_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert));
    for iFreq = 1:length(RP.perturbation_frequencies)
        for iOutcome = 1:1
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});
            if iOutcome == 1
                idx = intersect(idx,RP.reward_trials);
            else
                idx = intersect(idx,RP.fail_trials);
            end
            %             idx = intersect(idx,RP.reward_trials);
            emg_temp = sum(RP.emg_pert(idx,:,emg_idx),3);
            mean_emg(iFreq,:) = mean(emg_temp,1);
            std_emg(iFreq,:) = std(emg_temp,[],1);
            %             sem_emg(iFreq,:) = 1.96*std(emg_temp,[],1)/sqrt(size(emg_temp,1));
            
            if iOutcome == 1
                h_plot(end+1) = plot(RP.t_pert,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:));
                errorarea(RP.t_pert,mean_emg(iFreq,:),...
                    std_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
            else
                plot(RP.t_pert,mean_emg(iFreq,:),'--','Color',RP.perturbation_frequency_colors(iFreq,:))
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
    mean_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert));
    std_emg = zeros(length(RP.perturbation_frequencies),length(RP.t_pert));
    for iFreq = 1:length(RP.perturbation_frequencies)
        for iOutcome = 1:1
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});
            if iOutcome == 1
                idx = intersect(idx,RP.reward_trials);
            else
                idx = intersect(idx,RP.fail_trials);
                %                 idx = intersect(idx,setxor(1:size(RP.trial_table,1),RP.reward_trials));
            end
            %             idx = intersect(idx,RP.reward_trials);
            %             emg_temp = RP.emg_cocontraction_bmi_bi_tri(idx,:);
            emg_temp = RP.emg_pert(idx,:,emg_idx(1)) - RP.emg_pert(idx,:,emg_idx(2));
            mean_emg(iFreq,:) = mean(emg_temp);
            %             sem_emg(iFreq,:) = 1.96*std(emg_temp)/sqrt(size(emg_temp,1));
            std_emg(iFreq,:) = std(emg_temp);
            
            if iOutcome == 1
                h_plot(end+1) = plot(RP.t_pert,mean_emg(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:));
                errorarea(RP.t_pert,mean_emg(iFreq,:),...
                    std_emg(iFreq,:),RP.perturbation_frequency_colors(iFreq,:),.5);
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                    ' Hz']}];
            else
                plot(RP.t_pert,mean_emg(iFreq,:),'--','Color',RP.perturbation_frequency_colors(iFreq,:))
            end
        end
        plot(RP.t_pert,zeros(size(RP.t_pert)),'-k')
    end
    
    max_y = max(max_y,max(mean_emg(:)));
    min_y = min(min_y,min(mean_emg(:)));
    max_y = max(abs(min_y),max_y);
    xlabel('Time from go cue (s)')
    ylabel('EMG TRI - EMG BRD')
    title(['Difference tri-brd. Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
        '^o.'],'Interpreter','tex')
    set(params.fig_handles(end),'Name',['Difference brd-tri'])
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
                    std_emg(iFreq,:) = std(emg_temp);
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
    ylabel('Mean co-contraction index')
    title(['Mean co-contraction predicted brd-tri. Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
        '^o.'],'Interpreter','tex')
    set(params.fig_handles(end),'Name',['Mean co-contraction predicted bi-tri'])
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
            emg_temp = (RP.emg_pert(idx,:,emg_idx(1)) - RP.emg_pert(idx,:,emg_idx(2)));
            mean_emg = mean(emg_temp(:,RP.t_pert > 0),2);
            sem_emg = 1.96*std(emg_temp(:,RP.t_pert > 0),[],2);
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
    ylabel('Mean EMG difference')
    title(['Mean EMG difference (TRI-BRD). Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
        '^o.'],'Interpreter','tex')
    set(params.fig_handles(end),'Name',['Mean EMG difference (TRI-BRD)'])
    legend(h_plot,legend_str)
    
end
set(h_sub,'YLim',[min(cellfun(@min,get(h_sub,'YLim'))) max(cellfun(@max,get(h_sub,'YLim')))])

%% Co-contraction and difference summary
params.fig_handles(end+1) = figure;
h_sub = [];
max_y = 0;
for iDir = 1:length(RP.perturbation_directions)  

    for iFreq = 1:length(RP.perturbation_frequencies)        
        idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});
        idx = intersect(idx,RP.reward_trials);
        
        h_sub(end+1) = subplot(2,3,((iDir-1)*3)+1);
        hold on
        emg_sum(iFreq,:) = mean((RP.emg_pert(idx,:,emg_idx(1)) + RP.emg_pert(idx,:,emg_idx(2))));
        emg_sum_mean = mean(emg_sum(iFreq,RP.t_pert > 1));
        emg_sum_std = std(emg_sum(iFreq,RP.t_pert > 1));
        emg_sum_sem = 1.96*emg_sum_std/sqrt(sum(RP.t_pert > 1));
        bar(iFreq,emg_sum_mean,'FaceColor',RP.perturbation_frequency_colors(iFreq,:))
        plot([iFreq iFreq],[emg_sum_mean emg_sum_mean+emg_sum_std],'-k')
        if iFreq == 2
            [h,p] = ttest2(emg_sum(1,:),emg_sum(2,:));
            if iDir == 1
                title({'EMG sum';'';['p = ' num2str(p)]})
                set(gca,'XTickLabel',[])
            else
                title(['p = ' num2str(p)])
                set(gca,'XTick',0:3)
                set(gca,'XTickLabel',{'','Slow','Fast',''})
            end
        end      
        
        h_sub(end+1) = subplot(2,3,((iDir-1)*3)+2);
        hold on
        cocon_temp(iFreq,:) = mean(RP.emg_cocontraction_bi_tri(idx,:));        
        cocon_mean = mean(cocon_temp(iFreq,RP.t_pert > 1));
        cocon_std = std(cocon_temp(iFreq,RP.t_pert > 1));
        cocon_sem = 1.96*cocon_std/sqrt(sum(RP.t_pert > 1));
        bar(iFreq,cocon_mean,'FaceColor',RP.perturbation_frequency_colors(iFreq,:))
        plot([iFreq iFreq],[cocon_mean cocon_mean+cocon_std],'-k')
        if iFreq == 2
            [h,p] = ttest2(cocon_temp(1,:),cocon_temp(2,:));        
            if iDir == 1
                title({'Co-contraction';'index';['p = ' num2str(p)]})
                set(gca,'XTickLabel',[])
            else
                title(['p = ' num2str(p)])
                set(gca,'XTick',0:3)
                set(gca,'XTickLabel',{'','Slow','Fast',''})
            end
        end
        
        h_sub(end+1) = subplot(2,3,((iDir-1)*3)+3);
        hold on
        emg_diff(iFreq,:) = mean((RP.emg_pert(idx,:,emg_idx(1)) - RP.emg_pert(idx,:,emg_idx(2))));
        emg_diff_mean = mean(emg_diff(iFreq,RP.t_pert > 1));
        emg_diff_std = std(emg_diff(iFreq,RP.t_pert > 1));
        emg_diff_sem = 1.96*emg_diff_std/sqrt(sum(RP.t_pert > 1));
        bar(iFreq,emg_diff_mean,'FaceColor',RP.perturbation_frequency_colors(iFreq,:)) 
        plot([iFreq iFreq],[emg_diff_mean emg_diff_mean+emg_diff_std],'-k')
        if iFreq == 2
            [h,p] = ttest2(emg_diff(1,:),emg_diff(2,:));
            if iDir == 1
                title({'EMG diff';'';['p = ' num2str(p)]})
                set(gca,'XTickLabel',[])
            else
                title(['p = ' num2str(p)])
                set(gca,'XTick',0:3)
                set(gca,'XTickLabel',{'','Slow','Fast',''})
            end
        end
    end    
  
end
set(h_sub,'XLim',[0 3])
set(h_sub([1 7]),'YLim',[0 max(max(cell2mat(get(h_sub([1 7]),'YLim'))))])
set(h_sub([2 8]),'YLim',[0 max(max(cell2mat(get(h_sub([2 8]),'YLim'))))])
temp = max(max(abs(cell2mat(get(h_sub([3 9]),'YLim')))));
set(h_sub([3 9]),'YLim',[-temp temp])