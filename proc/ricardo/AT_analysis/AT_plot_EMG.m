function AT_plot_EMG(AT_struct,save_figs)
    mean_range = [0.04 0.075];
    figHandles = [];    
    figTitles = cell(0);
    plot_idx = 1:size(AT_struct.trial_table,1);
    for iEMG = 1:AT_struct.num_emg
        baseline_idx = find(AT_struct.t_axis>-.05 & AT_struct.t_axis<0);
        temp_emg = squeeze(AT_struct.emg_all(iEMG,:,:));
        max_emg = 0.001;
        emg_mean = zeros(3,length(AT_struct.unique_bump_directions));
        emg_std = zeros(3,length(AT_struct.unique_bump_directions));
        emg_sem = zeros(3,length(AT_struct.unique_bump_directions));
        min_n = 1000;
        max_n = 0;
        n_bumps = zeros(3,length(AT_struct.unique_bump_directions));
        legend_str = [];
        baseline_mean = zeros(3,1);
        baseline_sem = zeros(3,1);
        smooth_n = 10;
        
        figHandles(end+1) = figure; 
        figTitles{end+1} = AT_struct.emgnames{iEMG};
        set(gcf,'name',AT_struct.emgnames{iEMG},'numbertitle','off')
        for iTrialType = 1:length(AT_struct.trial_type_indexes)
            idx = AT_struct.trial_type_indexes{iTrialType};
            idx = intersect(idx,plot_idx);
            baseline = temp_emg(idx,baseline_idx);
            baseline_mean(iTrialType) = mean(baseline(:));
            baseline_sem(iTrialType) = std(mean(baseline,2))/sqrt(length(idx));

            for iBump = 1:length(AT_struct.unique_bump_directions)
                idx = intersect(AT_struct.trial_type_indexes{iTrialType},AT_struct.bump_indexes{iBump}); 
                idx = intersect(idx,plot_idx);
                idx = idx(~(std(temp_emg(idx,:)') > 3*mean(std(temp_emg(idx,:)'))));
                subplot(2,length(AT_struct.bump_indexes)/2,iBump)            
                hold on
                ha = errorarea(AT_struct.t_axis,smooth(mean(temp_emg(idx,:),1),smooth_n),...
                    1.96*smooth(std(temp_emg(idx,:),0,1),smooth_n)/sqrt(length(idx)),...
                    min([1 1 1],.7+AT_struct.colors_trial_type(iTrialType,:)));
                plot(AT_struct.t_axis,smooth(mean(temp_emg(idx,:),1),smooth_n),...
                    'Color',AT_struct.colors_trial_type(iTrialType,:))   

                title([AT_struct.emgnames{iEMG} ' B:' num2str(AT_struct.unique_bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
                xlabel('t (s)')
                ylabel('EMG (mV)')
                xlim([-.05 .15])
                max_emg = max(max_emg,max(mean(temp_emg(idx,AT_struct.t_axis>-.05 & AT_struct.t_axis<.15))));
                temp_emg_short = temp_emg(idx,AT_struct.t_axis>mean_range(1) & AT_struct.t_axis<mean_range(2));
                emg_mean(iTrialType,iBump) = mean(temp_emg_short(:));
                emg_std(iTrialType,iBump) = std(mean(temp_emg_short,2));
                emg_sem(iTrialType,iBump) = std(mean(temp_emg_short,2))/sqrt(size(temp_emg_short,1));

                min_n = min(min_n,length(idx));
                max_n = max(max_n,length(idx));
                n_bumps(iTrialType,iBump) = length(idx);
                hChildren = get(gca,'children');
                hType = get(hChildren,'Type');
                set(gca,'children',hChildren([find(strcmp(hType,'line')); find(~strcmp(hType,'line'))]))
            end
            legend_str{iTrialType} = AT_struct.trial_types{iTrialType};
        end      
        set(gca,'children',hChildren([find(~strcmp(hType,'line')); find(strcmp(hType,'line'))]))
        set(gca,'children',hChildren([find(strcmp(hType,'line')); find(~strcmp(hType,'line'))]))

        for iBump=1:length(AT_struct.bump_indexes)
            subplot(2,length(AT_struct.bump_indexes)/2,iBump)
            ylim([0 1.1*max_emg])
            y_text = max_emg;
            hAxes = gca;
            for iTrialType = 1:length(AT_struct.trial_type_indexes)
                y_text = y_text - .05*max_emg; 
                text(.03,y_text,num2str(n_bumps(iTrialType,iBump)),...
                    'Color',AT_struct.colors_trial_type(iTrialType,:))
                plot(AT_struct.t_axis(baseline_idx([1 end])),[baseline_mean(iTrialType) baseline_mean(iTrialType)],...
                    'Color',min([1 1 1],.3+AT_struct.colors_trial_type(iTrialType,:)),...
                    'LineStyle','-')
                plot(AT_struct.t_axis(baseline_idx([1 end])),[baseline_mean(iTrialType) baseline_mean(iTrialType)]+...
                    1.96*[baseline_sem(iTrialType) baseline_sem(iTrialType)],...
                'Color',min([1 1 1],.5+AT_struct.colors_trial_type(iTrialType,:)),...
                'LineStyle','--')
                plot(AT_struct.t_axis(baseline_idx([1 end])),[baseline_mean(iTrialType) baseline_mean(iTrialType)]-...
                    1.96*[baseline_sem(iTrialType) baseline_sem(iTrialType)],...
                'Color',min([1 1 1],.5+AT_struct.colors_trial_type(iTrialType,:)),...
                'LineStyle','--')                    
                set(hAxes,'Visible','on')
            end 
        end

        set(gcf,'NextPlot','add');
        gca2 = axes;
        h = title(AT_struct.AT_file_prefix,'Interpreter','none');
        set(gca2,'Visible','off');
        set(h,'Visible','on');            
        
        figHandles(end+1) = figure; 
        figTitles{end+1} = [AT_struct.emgnames{iEMG} ' summary'];
        set(gcf,'name',[AT_struct.emgnames{iEMG} ' summary'],'numbertitle','off')

        subplot(211)
        hold on        
        for iTrialType = 1:length(AT_struct.trial_type_indexes)
            plot(180/pi*[AT_struct.unique_bump_directions;AT_struct.unique_bump_directions(1)+2*pi],squeeze(emg_mean(iTrialType,[1:end 1])),...
                'Color',AT_struct.colors_trial_type(iTrialType,:));
        end

        for iTrialType = 1:length(AT_struct.trial_type_indexes)
            errorbar(180/pi*[AT_struct.unique_bump_directions;AT_struct.unique_bump_directions(1)+2*pi],squeeze(emg_mean(iTrialType,[1:end 1])),...
                ... squeeze(emg_std(iBias,iTrialType,[1:end 1])/2),...
                squeeze(1.96*emg_sem(iTrialType,[1:end 1])),...
                'Color',AT_struct.colors_trial_type(iTrialType,:));
        end
        
        axis on
        xlim([min(180/pi*[AT_struct.unique_bump_directions;AT_struct.unique_bump_directions(1)+2*pi])-10, ...
            max(180/pi*[AT_struct.unique_bump_directions;AT_struct.unique_bump_directions(1)+2*pi])+10])
        xlabel('Bump direction (deg)')
        ylabel('EMG (mV)')
        legend(legend_str,'interpreter','none')
        title({AT_struct.AT_file_prefix;...
            [AT_struct.emgnames{iEMG} '.  Average EMG between ' num2str(mean_range(1)) ' and ' num2str(mean_range(2)) ' s. '...
            num2str(min_n) ' <= n <= ' num2str(max_n)]},...
            'interpreter','none')

        figHandles(end+1) = figure; 
        figTitles{end+1} = [AT_struct.emgnames{iEMG} ' Visual rewards vs visual fail'];
        set(gcf,'name',[AT_struct.emgnames{iEMG} ' Visual rewards vs visual fail'],'numbertitle','off')
        temp_result = {AT_struct.reward_trials AT_struct.fail_trials};        
        for iResult = 1:2            
            idx = temp_result{iResult};
            temp = cell2mat(AT_struct.visual_idx);
            idx = intersect(idx,temp);
            idx = intersect(idx,plot_idx);
            baseline = temp_emg(idx,baseline_idx);
            baseline_mean(iResult) = mean(baseline(:));
            baseline_sem(iResult) = std(mean(baseline,2))/sqrt(length(idx));

            for iBump = 1:length(AT_struct.unique_bump_directions)
                idx = intersect(temp_result{iResult},AT_struct.bump_indexes{iBump}); 
                idx = intersect(idx,temp);
                idx = intersect(idx,plot_idx);
%                 idx = idx(~(std(temp_emg(idx,:)') > 3*mean(std(temp_emg(idx,:)'))));
                subplot(2,length(AT_struct.bump_indexes)/2,iBump)            
                hold on
                ha = errorarea(AT_struct.t_axis,smooth(mean(temp_emg(idx,:),1),smooth_n),...
                    1.96*smooth(std(temp_emg(idx,:),0,1),smooth_n)/sqrt(length(idx)),...
                    min([1 1 1],.7+AT_struct.colors_response(iResult,:)));
                plot(AT_struct.t_axis,smooth(mean(temp_emg(idx,:),1),smooth_n),...
                    'Color',AT_struct.colors_response(iResult,:))   

                title([AT_struct.emgnames{iEMG} ' B:' num2str(AT_struct.unique_bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
                xlabel('t (s)')
                ylabel('EMG (mV)')
                xlim([-.05 .15])
                max_emg = max(max_emg,max(mean(temp_emg(idx,AT_struct.t_axis>-.05 & AT_struct.t_axis<.15))));
                temp_emg_short = temp_emg(idx,AT_struct.t_axis>mean_range(1) & AT_struct.t_axis<mean_range(2));
                emg_mean(iResult,iBump) = mean(temp_emg_short(:));
                emg_std(iResult,iBump) = std(mean(temp_emg_short,2));
                emg_sem(iResult,iBump) = std(mean(temp_emg_short,2))/sqrt(size(temp_emg_short,1));

                min_n = min(min_n,length(idx));
                max_n = max(max_n,length(idx));
                n_bumps(iResult,iBump) = length(idx);
                hChildren = get(gca,'children');
                hType = get(hChildren,'Type');
                set(gca,'children',hChildren([find(strcmp(hType,'line')); find(~strcmp(hType,'line'))]))
            end
        end      
        set(gca,'children',hChildren([find(~strcmp(hType,'line')); find(strcmp(hType,'line'))]))
        set(gca,'children',hChildren([find(strcmp(hType,'line')); find(~strcmp(hType,'line'))]))

        for iBump=1:length(AT_struct.bump_indexes)
            subplot(2,length(AT_struct.bump_indexes)/2,iBump)
            ylim([0 1.1*max_emg])
            y_text = max_emg;
            hAxes = gca;
            for iResult = 1:2
                y_text = y_text - .05*max_emg; 
                text(.03,y_text,num2str(n_bumps(iResult,iBump)),...
                    'Color',AT_struct.colors_response(iResult,:))
                plot(AT_struct.t_axis(baseline_idx([1 end])),[baseline_mean(iResult) baseline_mean(iResult)],...
                    'Color',min([1 1 1],.3+AT_struct.colors_response(iResult,:)),...
                    'LineStyle','-')
                plot(AT_struct.t_axis(baseline_idx([1 end])),[baseline_mean(iResult) baseline_mean(iResult)]+...
                    1.96*[baseline_sem(iResult) baseline_sem(iResult)],...
                'Color',min([1 1 1],.5+AT_struct.colors_response(iResult,:)),...
                'LineStyle','--')
                plot(AT_struct.t_axis(baseline_idx([1 end])),[baseline_mean(iResult) baseline_mean(iResult)]-...
                    1.96*[baseline_sem(iResult) baseline_sem(iResult)],...
                'Color',min([1 1 1],.5+AT_struct.colors_response(iResult,:)),...
                'LineStyle','--')                    
                set(hAxes,'Visible','on')
            end 
        end

        set(gcf,'NextPlot','add');
        gca2 = axes;
        h = title(AT_struct.AT_file_prefix,'Interpreter','none');
        set(gca2,'Visible','off');
        set(h,'Visible','on');      
    end
    if save_figs
        save_figures(figHandles,AT_struct.UF_file_prefix,AT_struct.datapath,'',figTitles)
    end
end

function h = errorarea(x,ymean,yerror,c)
    x = reshape(x,1,[]);
    ymean = reshape(ymean,size(x,1),size(x,2));
    yerror = reshape(yerror,size(x,1),size(x,2));
    h = area(x([1:end end:-1:1]),[ymean(1:end)+yerror(1:end) ymean(end:-1:1)-yerror(end:-1:1)],...
        'FaceColor',c,'LineStyle','none');
    hChildren = get(gca,'children');
    hType = get(hChildren,'Type');
    set(gca,'children',hChildren([find(strcmp(hType,'line')); find(~strcmp(hType,'line'))]))
end