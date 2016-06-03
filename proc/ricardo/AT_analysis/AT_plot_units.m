function AT_plot_units(AT_struct,bdf,rw_bdf,save_figs)
    figHandles = [];
    figTitles = cell(0);
    x_limits = [-.05 .1];
    firing_rate_method = 'moving'; % 'moving', 'hist','gaussian'
    fr_tc = 0.02;


    %% Units!
    % Read cerebus to electrode map
    if isfield(bdf,'units')
        all_chans = reshape([bdf.units.id],2,[])';
        units = unit_list(bdf);        
        dt = round(mean(diff(bdf.pos(:,1)))*10000)/10000;  
        bin_size = dt;
        neuron_t_axis = (0:(AT_struct.trial_range(2)-AT_struct.trial_range(1))/bin_size-1)*bin_size+AT_struct.trial_range(1);

        all_unit_fr = zeros((size(AT_struct.trial_table,1))*size(units,1),length(neuron_t_axis));

        kernel_width = 0.005;   
    %     fr_cell = cell(size(unit_idx));
        electrode = [];    
    %     red_area = [1 .9 .9];
    %     blue_area = [.9 .9 1];
        red_area = [1 0 0];
        blue_area = [0 0 1];
        fr_cell = cell(size(units,1),1);
        figure
        for iUnit = 1:size(units,1) 
            fr_cell{iUnit} = zeros(size(AT_struct.trial_table,1),length(neuron_t_axis));
            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
            try
                electrode = AT_struct.elec_map(find(AT_struct.elec_map(:,3)==all_chans(unit_idx,1)),4);
            catch
                temp = reshape([AT_struct.elec_map{:}]',4,[])';
                temp = [temp{:,3}]';
                temp = find(temp==all_chans(unit_idx,1));
                electrode = AT_struct.elec_map{temp}{4};
            end                    

            if isfield(AT_struct,'PDs')
                rw_unit_idx = find(AT_struct.PDs(:,1)==units(iUnit,1) & AT_struct.PDs(:,2)==units(iUnit,2));
                PD = AT_struct.PDs(rw_unit_idx,[3 4]);
            end
            ts = bdf.units(unit_idx).ts; %#ok<FNDSB>
            ts_cell = {};    
            max_y = 0;

            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));    

            if strcmp(firing_rate_method,'gaussian')
                fr = spikes2fr(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc); 
            else
                fr = spikes2FrMovAve(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc); 
            end
            unit_all_trials = zeros(size(AT_struct.trial_table,1),length(neuron_t_axis));
            spikes_vector = [];
            used_spikes_idx = [];
            ts_cell = {}; 

            for iTrial = 1:size(AT_struct.trial_table,1)
                idx = AT_struct.idx_table(iTrial,:);
                unit_all_trials(iTrial,:) = fr(idx);
    %             all_unit_fr((iUnit-1)*(size(AT_struct.trial_table,1)) + iTrial,:) = fr(idx);
                fr_cell{iUnit}(iTrial,:) = fr(idx);
                trial_spikes = bdf.units(unit_idx).ts>AT_struct.trial_table(iTrial,AT_struct.table_columns.t_stimuli_onset)+AT_struct.trial_range(1) &...
                    bdf.units(unit_idx).ts < AT_struct.trial_table(iTrial,AT_struct.table_columns.t_stimuli_onset)+AT_struct.trial_range(2);
                used_spikes_idx = [used_spikes_idx; find(trial_spikes)];
                spikes_temp = bdf.units(unit_idx).ts(trial_spikes);
                spikes_temp = reshape(spikes_temp - AT_struct.trial_table(iTrial,AT_struct.table_columns.t_stimuli_onset),[],1);
                spikes_vector = [spikes_vector [spikes_temp';repmat(iTrial,1,length(spikes_temp))]];
    %             bump_dir_mat(iTrial,:) = trial_table(iTrial,AT_struct.table_columns.bump_direction);

                ts_temp = ts(ts>AT_struct.trial_table(iTrial,AT_struct.table_columns.t_stimuli_onset)+neuron_t_axis(1) &...
                    ts<AT_struct.trial_table(iTrial,AT_struct.table_columns.t_stimuli_onset)+neuron_t_axis(end));
                ts_temp = ts_temp' - AT_struct.trial_table(iTrial,AT_struct.table_columns.t_stimuli_onset);
                ts_cell{iTrial} = ts_temp;
    %                 hist_mat(iTrial,:) = hist(ts_cell{iTrial},hist_centers);
            end
            max_y = .5*iTrial; 
            max_y = 0;

            if length([ts_cell{:}])>20
                figHandles(end+1) = figure;
                clf
                if ~isstr(electrode)
                    set(gcf,'name',['Electrode: ' num2str(electrode) ' - ' num2str(units(iUnit,2)) ' raster'],'numbertitle','off')   
                    figTitles{end+1} = [num2str(electrode,'%1.2d') '-' num2str(units(iUnit,2)) '_raster'];   
                else
                    set(gcf,'name',['Electrode: ' electrode ' - ' num2str(units(iUnit,2)) ' raster'],'numbertitle','off')       
                    figTitles{end+1} = [electrode '-' num2str(units(iUnit,2)) '_raster'];   
                end
                
                max_y = 0;
                for iBump = 1:size(AT_struct.proprio_idx)
                    subplot(2,length(AT_struct.bump_indexes)/2,iBump)  
                    hold on
    %                 error_y_proprio = std(fr_cell{iUnit}(AT_struct.proprio_idx{iBump},:),[],1);                
    %                 error_y_visual = std(fr_cell{iUnit}(AT_struct.visual_idx{iBump},:),[],1);
    %                 error_y_proprio = std(fr_cell{iUnit}(AT_struct.proprio_idx{iBump},:),[],1)/sqrt(size(fr_cell{iUnit}(AT_struct.proprio_idx{iBump},:),1));
    %                 error_y_visual = std(fr_cell{iUnit}(AT_struct.visual_idx{iBump},:),[],1)/sqrt(size(fr_cell{iUnit}(AT_struct.visual_idx{iBump},:),1));
                    errorarea(AT_struct.t_axis,mean(fr_cell{iUnit}(AT_struct.proprio_idx{iBump},:),1),...
                        1.96*std(fr_cell{iUnit}(AT_struct.proprio_idx{iBump},:),[],1)/sqrt(length(AT_struct.proprio_idx{iBump})),...
                        min([1 1 1],.7+AT_struct.colors_trial_type(2,:)));
                    errorarea(AT_struct.t_axis,mean(fr_cell{iUnit}(AT_struct.visual_idx{iBump},:),1),...
                        1.96*std(fr_cell{iUnit}(AT_struct.visual_idx{iBump},:),[],1)/sqrt(length(AT_struct.visual_idx{iBump})),...
                        min([1 1 1],.7+AT_struct.colors_trial_type(1,:)));            

    %                 area([AT_struct.t_axis AT_struct.t_axis(end:-1:1)], [mean(fr_cell{iUnit}(AT_struct.proprio_idx{iBump},:),1) mean(fr_cell{iUnit}(AT_struct.proprio_idx{iBump},end:-1:1),1)]+...
    %                     [error_y_proprio -error_y_proprio(end:-1:1)],...
    %                     'FaceColor',red_area,'LineStyle','none')
    %                 area([AT_struct.t_axis AT_struct.t_axis(end:-1:1)], [mean(fr_cell{iUnit}(AT_struct.visual_idx{iBump},:),1) mean(fr_cell{iUnit}(AT_struct.visual_idx{iBump},end:-1:1),1)]+...
    %                     [error_y_visual -error_y_visual(end:-1:1)],...
    %                     'FaceColor',blue_area,'LineStyle','none')
    %                 alpha(0.2)

                    plot(AT_struct.t_axis,mean(fr_cell{iUnit}(AT_struct.proprio_idx{iBump},:)),'r')            
                    plot(AT_struct.t_axis,mean(fr_cell{iUnit}(AT_struct.visual_idx{iBump},:)),'b')

                    if iBump == 1
                        title(['Electrode: ' num2str(electrode) '   Bump: ' num2str(AT_struct.unique_bump_directions(iBump)*180/pi) ' deg'])
                        legend('Proprio','Visual')
                    else
                        title(['Bump: ' num2str(AT_struct.unique_bump_directions(iBump)*180/pi) ' deg'])
                    end
                    max_y = max(max_y,max(mean(fr_cell{iUnit}(AT_struct.proprio_idx{iBump},:),1)+...
                        1.96*std(fr_cell{iUnit}(AT_struct.proprio_idx{iBump},:),[],1)/sqrt(length(AT_struct.proprio_idx{iBump}))));
                    max_y = max(max_y,max(mean(fr_cell{iUnit}(AT_struct.visual_idx{iBump},:),1)+...
                        1.96*std(fr_cell{iUnit}(AT_struct.visual_idx{iBump},:),[],1)/sqrt(length(AT_struct.visual_idx{iBump}))));
                    xlabel('t (s)')
                    ylabel('fr (Hz?)')

                end
                for iBump = 1:size(AT_struct.proprio_idx)
                    subplot(2,length(AT_struct.bump_indexes)/2,iBump)  
                    xlim([x_limits])
                    ylim([0 max_y+5])
    %                 plot(AT_struct.t_axis(1:end-1),.9*(max_y+5)+.1*(max_y+5)*diff(AT_struct.averaged_x_projection_proprio(iBump,:))/max(diff(AT_struct.averaged_x_projection_proprio(iBump,:))),'r')
    %                 plot(AT_struct.t_axis(1:end-1),.9*(max_y+5)+.1*(max_y+5)*diff(AT_struct.averaged_x_projection_visual(iBump,:))/max(diff(AT_struct.averaged_x_projection_visual(iBump,:))),'b')
                    text(AT_struct.t_axis(100),max_y*0.8+3,['n = ' num2str(length(AT_struct.proprio_idx{iBump}))],'Color','r')
                    text(AT_struct.t_axis(100),max_y*0.75+2,['n = ' num2str(length(AT_struct.visual_idx{iBump}))],'Color','b')
                end
                
                set(gcf,'NextPlot','add');
                gca_temp = axes;                
                if ~isstr(electrode)
                     h = title({[AT_struct.AT_file_prefix ' ' AT_struct.RW_file_prefix];...
                    ['Elec: ' num2str(electrode) ' (Chan: ' num2str(units(iUnit,1)) ') Unit: ' num2str(units(iUnit,2))]},...
                    'Interpreter','none');                      
                else
                    h = title({[AT_struct.AT_file_prefix ' ' AT_struct.RW_file_prefix];...
                    ['Elec: ' electrode ' (Chan: ' num2str(units(iUnit,1)) ') Unit: ' num2str(units(iUnit,2))]},...
                    'Interpreter','none');  
                end      
                set(gca_temp,'Visible','off');
                set(h,'Visible','on');
                
                figHandles(end+1) = figure;
                clf
                if ~isstr(electrode)
                    set(gcf,'name',['Electrode: ' num2str(electrode) ' - ' num2str(units(iUnit,2)) ' visual raster'],'numbertitle','off')   
                    figTitles{end+1} = [num2str(electrode,'%1.2d') '-' num2str(units(iUnit,2)) '_visual_raster'];   
                else
                    set(gcf,'name',['Electrode: ' electrode ' - ' num2str(units(iUnit,2)) ' visual raster'],'numbertitle','off')       
                    figTitles{end+1} = [electrode '-' num2str(units(iUnit,2)) '_visual_raster'];   
                end
                max_y = 0;
                for iBump = 1:size(AT_struct.proprio_idx)
                    subplot(2,length(AT_struct.bump_indexes)/2,iBump)  
                    hold on
                    errorarea(AT_struct.t_axis,mean(fr_cell{iUnit}(AT_struct.visual_difficult_correct_trials{iBump},:),1),...
                        1.96*std(fr_cell{iUnit}(AT_struct.visual_difficult_correct_trials{iBump},:),[],1)/...
                        sqrt(length(AT_struct.visual_difficult_correct_trials{iBump})),...
                        min([1 1 1],.7+AT_struct.colors_response(1,:)));
                    errorarea(AT_struct.t_axis,mean(fr_cell{iUnit}(AT_struct.visual_difficult_fail_trials{iBump},:),1),...
                        1.96*std(fr_cell{iUnit}(AT_struct.visual_difficult_fail_trials{iBump},:),[],1)/...
                        sqrt(length(AT_struct.visual_difficult_fail_trials{iBump})),...
                        min([1 1 1],.7+AT_struct.colors_response(2,:)));            

                    plot(AT_struct.t_axis,mean(fr_cell{iUnit}(AT_struct.visual_difficult_correct_trials{iBump},:)),'Color',AT_struct.colors_response(1,:))            
                    plot(AT_struct.t_axis,mean(fr_cell{iUnit}(AT_struct.visual_difficult_fail_trials{iBump},:)),'Color',AT_struct.colors_response(2,:))

                    if iBump == 1
                        title(['Electrode: ' num2str(electrode) '   Bump: ' num2str(AT_struct.unique_bump_directions(iBump)*180/pi) ' deg'])
                        legend(AT_struct.response_str)
                    else
                        title(['Bump: ' num2str(AT_struct.unique_bump_directions(iBump)*180/pi) ' deg'])
                    end
                    max_y = max(max_y,max(mean(fr_cell{iUnit}(AT_struct.visual_difficult_correct_trials{iBump},:),1)+...
                        1.96*std(fr_cell{iUnit}(AT_struct.visual_difficult_correct_trials{iBump},:),[],1)/sqrt(length(AT_struct.visual_difficult_correct_trials{iBump}))));
                    max_y = max(max_y,max(mean(fr_cell{iUnit}(AT_struct.visual_difficult_fail_trials{iBump},:),1)+...
                        1.96*std(fr_cell{iUnit}(AT_struct.visual_difficult_fail_trials{iBump},:),[],1)/sqrt(length(AT_struct.visual_difficult_fail_trials{iBump}))));
                    xlabel('t (s)')
                    ylabel('fr (Hz?)')

                end
                for iBump = 1:size(AT_struct.proprio_idx)
                    subplot(2,length(AT_struct.bump_indexes)/2,iBump)  
                    xlim([x_limits])
                    ylim([0 max_y+5])
    %                 plot(AT_struct.t_axis(1:end-1),.9*(max_y+5)+.1*(max_y+5)*diff(AT_struct.averaged_x_projection_proprio(iBump,:))/max(diff(AT_struct.averaged_x_projection_proprio(iBump,:))),'r')
    %                 plot(AT_struct.t_axis(1:end-1),.9*(max_y+5)+.1*(max_y+5)*diff(AT_struct.averaged_x_projection_visual(iBump,:))/max(diff(AT_struct.averaged_x_projection_visual(iBump,:))),'b')
                    text(AT_struct.t_axis(100),max_y*0.8+3,['n = ' num2str(length(AT_struct.visual_difficult_correct_trials{iBump}))],'Color','r')
                    text(AT_struct.t_axis(100),max_y*0.75+2,['n = ' num2str(length(AT_struct.visual_difficult_fail_trials{iBump}))],'Color','b')
                end
                
                set(gcf,'NextPlot','add');
                gca_temp = axes;                
                if ~isstr(electrode)
                     h = title({[AT_struct.AT_file_prefix ' ' AT_struct.RW_file_prefix];...
                    ['Elec: ' num2str(electrode) ' (Chan: ' num2str(units(iUnit,1)) ') Unit: ' num2str(units(iUnit,2))]},...
                    'Interpreter','none');                      
                else
                    h = title({[AT_struct.AT_file_prefix ' ' AT_struct.RW_file_prefix];...
                    ['Elec: ' electrode ' (Chan: ' num2str(units(iUnit,1)) ') Unit: ' num2str(units(iUnit,2))]},...
                    'Interpreter','none');  
                end      
                set(gca_temp,'Visible','off');
                set(h,'Visible','on');
    %             pause
            end

        end
    end
    if save_figs
        save_figures(figHandles,AT_struct.AT_file_prefix,AT_struct.datapath,'Units',figTitles)
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