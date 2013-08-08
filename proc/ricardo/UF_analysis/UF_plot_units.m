function UF_plot_units(UF_struct,bdf,rw_bdf,save_figs)
figHandles = [];
figTitles = cell(0);
    if isfield(bdf,'units')
        UF_struct.t_axis = UF_struct.trial_range(1); 
        all_chans = reshape([bdf.units.id],2,[])';
        
        if ~isempty(rw_bdf)
            all_chans_rw = reshape([rw_bdf.units.id],2,[])';
            units_rw = unit_list(rw_bdf);
        else
            all_chans_rw = [];
            units_rw = [];
        end
        
        units = unit_list(bdf);        
        dt = round(mean(diff(bdf.pos(:,1)))*10000)/10000;

        bin_size = dt;
        neuron_t_axis = (0:(UF_struct.trial_range(2)-UF_struct.trial_range(1))/bin_size-1)*bin_size+UF_struct.trial_range(1);
    %     bin_width = 0.02;
        fr_tc = 0.02;

        bin_width = 0.01;
        analysis_bin_edges = 0.015:bin_width:0.085;
        analysis_bin_centers = analysis_bin_edges(1:end-1)+bin_width/2;
        short_neuron_t_axis = neuron_t_axis(neuron_t_axis > analysis_bin_edges(1) & neuron_t_axis < analysis_bin_edges(end));
        short_neuron_t_axis = short_neuron_t_axis(1:floor(length(short_neuron_t_axis)/length(analysis_bin_edges))*length(analysis_bin_centers));

        idx_mat = reshape(1:length(short_neuron_t_axis),[],length(analysis_bin_centers));


        varnames = {'Bin','Bump X','Bump Y','Field orientation','Trial number','Bump on'};       

        hist_centers = neuron_t_axis(1):bin_width:neuron_t_axis(end);
        anova_bins = hist_centers > -0.1 & hist_centers < 0.15;      
        all_unit_fr = zeros((size(UF_struct.trial_table,1))*size(units,1),length(neuron_t_axis));
        trial_type_mat = zeros(length(UF_struct.bias_indexes)*length(UF_struct.field_indexes)*length(UF_struct.bump_indexes),3);
        active_PD = zeros(1,0);

        for iUnit = 1:size(units,1)    
            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
            electrode = UF_struct.elec_map(find(UF_struct.elec_map(:,3)==all_chans(unit_idx,1)),4);

            if isfield(UF_struct,'PDs')
                rw_unit_idx = find(UF_struct.PDs(:,1)==units(iUnit,1) & UF_struct.PDs(:,2)==units(iUnit,2));
                PD = UF_struct.PDs(rw_unit_idx,[3 4]);
            end
            ts = bdf.units(unit_idx).ts; %#ok<FNDSB>
            ts_cell = {};    
            max_y = 0;

    %         % anova independent variables
    %         bump_dir_mat = zeros(size(trial_table,1)-1,length(hist_centers));
            bump_x_mat = zeros(size(UF_struct.trial_table,1),length(hist_centers));
            bump_y_mat = zeros(size(UF_struct.trial_table,1),length(hist_centers));
            field_orientation_mat = zeros(size(UF_struct.trial_table,1),length(hist_centers));    
            trial_number_mat = zeros(size(UF_struct.trial_table,1),length(hist_centers));         
            bin_mat = zeros(size(UF_struct.trial_table,1),length(hist_centers)); 
            bump_on_mat = zeros(size(UF_struct.trial_table,1),length(hist_centers));         
            bump_on_mat(:,hist_centers>=0 & hist_centers <= UF_struct.bump_duration) = 1; 
    %         %anova dependent variable
            hist_mat = zeros(size(UF_struct.trial_table,1),length(hist_centers));
    %         fr_mat = zeros(size(trial_table,1),length(neuron_t_axis));

            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));    
            fr = spikes2fr(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc);
            unit_all_trials = zeros(size(UF_struct.trial_table,1),length(neuron_t_axis));
            spikes_vector = [];
            used_spikes_idx = [];
            for iTrial = 1:size(UF_struct.trial_table,1)
                idx = UF_struct.idx_table(iTrial,:);
                unit_all_trials(iTrial,:) = fr(idx);
                all_unit_fr((iUnit-1)*(size(UF_struct.trial_table,1)) + iTrial,:) = fr(idx);
                used_spikes_idx = [used_spikes_idx find(bdf.units(unit_idx).ts>UF_struct.trial_table(iTrial,UF_struct.table_columns.t_bump_onset)+UF_struct.trial_range(1) &...
                    bdf.units(unit_idx).ts < UF_struct.trial_table(iTrial,UF_struct.table_columns.t_bump_onset)+UF_struct.trial_range(2))];
                spikes_temp = bdf.units(unit_idx).ts(bdf.units(unit_idx).ts>UF_struct.trial_table(iTrial,UF_struct.table_columns.t_bump_onset)+UF_struct.trial_range(1) &...
                    bdf.units(unit_idx).ts < UF_struct.trial_table(iTrial,UF_struct.table_columns.t_bump_onset)+UF_struct.trial_range(2));
                spikes_temp = reshape(spikes_temp - UF_struct.trial_table(iTrial,UF_struct.table_columns.t_bump_onset),[],1);
                spikes_vector = [spikes_vector [spikes_temp';repmat(iTrial,1,length(spikes_temp))]];
    %             bump_dir_mat(iTrial,:) = trial_table(iTrial,UF_struct.table_columns.bump_direction);
                bump_x_mat(iTrial,:) = round(1000*cos(UF_struct.trial_table(iTrial,UF_struct.table_columns.bump_direction)))/1000;
                bump_y_mat(iTrial,:) = round(1000*sin(UF_struct.trial_table(iTrial,UF_struct.table_columns.bump_direction)))/1000;
                field_orientation_mat(iTrial,:) = UF_struct.trial_table(iTrial,UF_struct.table_columns.field_orientation);
                trial_number_mat(iTrial,:) = iTrial;
                fr_mat(iTrial,:) = fr(idx);

                ts_temp = ts(ts>UF_struct.trial_table(iTrial,UF_struct.table_columns.t_bump_onset)+neuron_t_axis(1) &...
                    ts<UF_struct.trial_table(iTrial,UF_struct.table_columns.t_bump_onset)+neuron_t_axis(end));
                ts_temp = ts_temp' - UF_struct.trial_table(iTrial,UF_struct.table_columns.t_bump_onset);
                ts_cell{iTrial} = ts_temp;
                hist_mat(iTrial,:) = hist(ts_cell{iTrial},hist_centers);
                bin_mat(iTrial,:) = 1:size(bin_mat,2);
            end
            max_y = .5*iTrial; 
            max_y = 0;

            if length(spikes_vector) > 0
                figHandles(end+1) = figure;
                clf
                set(gcf,'name',['Electrode: ' num2str(electrode) ' - ' num2str(units(iUnit,2)) ' raster'],'numbertitle','off')                
                figTitles{end+1} = [num2str(electrode,'%1.2d') '-' num2str(units(iUnit,2)) '_raster'];                
                hold on

                % Rasters
                trial_type_number = zeros(1,size(UF_struct.trial_table,1));
                trial_type_vector = zeros(1,size(UF_struct.trial_table,1));
                for iBias = 1:length(UF_struct.bias_indexes)
                    for iField = 1:length(UF_struct.field_indexes)
                        for iBump = 1:length(UF_struct.bump_indexes)  
                            subplot(2,length(UF_struct.bump_indexes)/2,iBump)
                            hold on
                            plot(0,-1,'Color',...
                                UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:),'LineWidth',2)
                        end
                    end
                end
                for iBias = 1:length(UF_struct.bias_indexes)
                    for iField = 1:length(UF_struct.field_indexes)
                        for iBump = 1:length(UF_struct.bump_indexes)                        
                            idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
                            idx = intersect(idx,UF_struct.bias_indexes{iBias});
                            max_y = max(max_y,max(mean(unit_all_trials(idx,:),1)));
                            subplot(2,length(UF_struct.bump_indexes)/2,iBump)   
                            hold on
                            spikes_idx = [];
                            trial_type_index = (iBias-1)*(length(UF_struct.field_indexes)*length(UF_struct.bump_indexes)) + (iField-1)*(length(UF_struct.bump_indexes)) + iBump;
                            trial_type_mat(trial_type_index,:) = [iBias iField iBump];
                            for iTrial = 1:length(idx)
                                trial_type_vector(idx) = trial_type_index;                            
                                spikes_idx = [spikes_idx find(spikes_vector(2,:)==idx(iTrial))];
                            end
                            plot(spikes_vector(1,spikes_idx),max_y*spikes_vector(2,spikes_idx)/spikes_vector(2,end),'.','Color',...
                                min([1,1,1],UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:)+.5),'MarkerSize',5)                        
                        end
                    end
                end

                    % Firing rates
                for iBias = 1:length(UF_struct.bias_indexes)
                    for iField = 1:length(UF_struct.field_indexes)
                        for iBump = 1:length(UF_struct.bump_indexes)
                            idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
                            idx = intersect(idx,UF_struct.bias_indexes{iBias});
                            subplot(2,length(UF_struct.bump_indexes)/2,iBump) 
                            plot(neuron_t_axis,mean(unit_all_trials(idx,:),1),'Color',...
                                UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:),'LineWidth',2)
                            errorarea(neuron_t_axis,mean(unit_all_trials(idx,:),1),...
                                1.96*std(unit_all_trials(idx,:))/sqrt(length(idx)),...
                                min([1 1 1],.7+UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:)));
                            title(['B:' num2str(UF_struct.bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
                            ylim([0 size(UF_struct.trial_table,1)/2])
                            ylabel('Firing rate (1/s)')
                            xlabel('t (s)')

                        end
                        legend_str{(iBias-1)*length(UF_struct.field_indexes)+iField} = ['UF: ' num2str(UF_struct.field_orientations(iField)*180/pi) ' deg' ' BF: ' num2str(round(UF_struct.bias_force_directions(iBias)*180/pi)) ' deg'];
                    end
                end

                legend(legend_str,'interpreter','none')
                drawnow 

                for iBump = 1:length(UF_struct.bump_indexes)
                    subplot(2,length(UF_struct.bump_indexes)/2,iBump)
                    ylim([0 1.2*max_y])
                    xlim([-0.1 .15])
                end
        %         [p,table,stats] = anovan(fr_mat(:),{t_mat(:),bump_dir_mat(:),field_orientation_mat(:),...
        %             trial_number_mat(:),bump_on_mat(:)},...
        %             'model','interaction','continuous',[1 4],'varnames',varnames,'display','on');
                hist_mat = hist_mat(:,anova_bins);
        %         bump_dir_mat = bump_dir_mat(:,anova_bins);
                bump_x_mat = bump_x_mat(:,anova_bins);
                bump_y_mat = bump_y_mat(:,anova_bins);
                field_orientation_mat = field_orientation_mat(:,anova_bins);
                bin_mat = bin_mat(:,anova_bins);
                trial_number_mat = trial_number_mat(:,anova_bins);
                bump_on_mat = bump_on_mat(:,anova_bins);

    %             [p,table,stats] = anovan(hist_mat(:),{bin_mat(:),bump_x_mat(:),bump_y_mat(:),field_orientation_mat(:),...
    %                 trial_number_mat(:),bump_on_mat(:)},...
    %                 'model','interaction','continuous',[1 2 3 5],'varnames',varnames,'display','off');
    %             table(find(p<0.05)+1,1)

    %             subplot(2,length(bump_indexes),1)
    %             text(-.05,1.1*max_y,UF_file_prefix,'Interpreter','none')
    %             if ~isempty(PD)
    %                 text(-.05,1.05*max_y,['PD: ' num2str(PD(1)*180/pi,3) ' +/- ' num2str(PD(2)*180/pi,3) ' deg']);        
    %             end
                if isfield(UF_struct,'PDs')
                    rw_unit_idx = find(UF_struct.PDs(:,1)==units(iUnit,1) & UF_struct.PDs(:,2)==units(iUnit,2));
                end
    %             figure(iUnit+50)

                unit_mean_fr = zeros(size(trial_type_mat,1),...
                    sum(neuron_t_axis > analysis_bin_edges(1) & neuron_t_axis < analysis_bin_edges(end)));
                unit_binned_mean_fr = zeros(size(trial_type_mat,1),size(idx_mat,2));
                unit_binned_std_fr = zeros(size(trial_type_mat,1),size(idx_mat,2));

    %             unit_mean_fr = zeros(length(unique(trial_type_vector)),...
    %                 sum(neuron_t_axis > analysis_bin_edges(1) & neuron_t_axis < analysis_bin_edges(end)));
    %             unit_binned_mean_fr = zeros(length(unique(trial_type_vector)),size(idx_mat,2));
    %             unit_binned_std_fr = zeros(length(unique(trial_type_vector)),size(idx_mat,2));
                for iTrialType = 1:length(unique(trial_type_vector))
                    iBias = trial_type_mat(iTrialType,1);
                    iField = trial_type_mat(iTrialType,2);
                    iBump = trial_type_mat(iTrialType,3);        
                    idx = (iUnit-1)*(size(UF_struct.trial_table,1))+find(trial_type_vector==iTrialType);
                    fr_trial_type = all_unit_fr(idx,neuron_t_axis > analysis_bin_edges(1) & neuron_t_axis < analysis_bin_edges(end));
                    if ~isempty(fr_trial_type)
                        unit_mean_fr = mean(fr_trial_type,1);
                        unit_std_fr = std(fr_trial_type,1);
                        
                        unit_binned_mean_fr(iTrialType,:) = mean(unit_mean_fr(idx_mat),1);  
                        unit_binned_std_fr(iTrialType,:) = mean(unit_std_fr(idx_mat));
                        
%                         unit_std_fr = std(fr_trial_type,[],1);        
%                         unit_binned_std_fr(iTrialType,:) = mean(unit_std_fr(idx_mat),1);    
                    end
                end
                [~,max_std_idx] = max(std(unit_binned_mean_fr));
            %     [~,max_std_idx] = min(abs(analysis_bin_centers-0.05));
                max_mod_latency = analysis_bin_centers(max_std_idx);
                [~,max_mean_idx] = max(mean(unit_binned_mean_fr));
                max_act_latency = analysis_bin_centers(max_mean_idx);
                legend_str = {};
                max_radius = max(.1,1.1*max(unit_binned_mean_fr(:,max_std_idx)));

                set(gcf,'NextPlot','add');
                gca = axes;
                h = title({[UF_struct.UF_file_prefix ' ' UF_struct.RW_file_prefix];...
                    ['Elec: ' num2str(electrode) ' (Chan: ' num2str(units(iUnit,1)) ') Unit: ' num2str(units(iUnit,2))];...
                    ['Max modulation latency: ' num2str(max_mod_latency) ' s'];...
                    ['Max activity latency: ' num2str(max_act_latency) ' s']},'Interpreter','none');
                set(gca,'Visible','off');
                set(h,'Visible','on');

                figHandles(end+1) = figure;
                set(gcf,'name',['Electrode: ' num2str(electrode) ' - ' num2str(units(iUnit,2)) ' summary'],'numbertitle','off')
                figTitles{end+1} = [num2str(electrode,'%1.2d') '-' num2str(units(iUnit,2)) '_summary']; 
                subplot(2,2,1)    
                hold on
                for iBias = 1:length(UF_struct.bias_indexes)
                     for iField = 1:length(UF_struct.field_indexes)
                        plot(0,0,'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
                        hold on
                     end
                 end
    %             gca = polar(0,max_radius);
    %             set(gca,'Visible','off')
    %             hold on

                unit_mean_fr_bump_field_bias = zeros(size(trial_type_mat,1),1);   
                unit_sem_fr_bump_field_bias = zeros(size(trial_type_mat,1),1);   

                for iBias = 1:length(UF_struct.bias_indexes)      
    %                 unit_mean_fr_bump_field = zeros(length(field_indexes),length(bump_indexes));        

                    for iField = 1:length(UF_struct.field_indexes)

                        for iBump = 1:length(UF_struct.bump_indexes)
                            trial_type_idx = find(trial_type_mat(:,1)==iBias &...
                                trial_type_mat(:,2)==iField & trial_type_mat(:,3)==iBump);
                            unit_mean_fr_bump_field_bias(trial_type_idx) =...
                                mean(unit_binned_mean_fr(trial_type_idx,max_std_idx));   
%                             unit_mean_fr_bump_field_bias(trial_type_mat(:,1)==iBias &...
%                                 trial_type_mat(:,2)==iField & trial_type_mat(:,3)==iBump) =...
%                                 mean(unit_binned_mean_fr(trial_type_mat(:,1)==iBias &...
%                                 trial_type_mat(:,2)==iField & trial_type_mat(:,3)==iBump,max_std_idx));        
                            unit_sem_fr_bump_field_bias(trial_type_idx) =...
                                unit_binned_std_fr(trial_type_idx,max_std_idx)/sqrt(sum(trial_type_vector==trial_type_idx));     
                        end                    
                        temp_mean = unit_mean_fr_bump_field_bias(trial_type_mat(:,1)==iBias &...
                                trial_type_mat(:,2)==iField,:);
                        temp_sem = unit_sem_fr_bump_field_bias(trial_type_mat(:,1)==iBias &...
                                trial_type_mat(:,2)==iField,:);
                        plot([UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)+2*pi]*180/pi,[temp_mean;temp_mean(1)],...
                            'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:))
                        errorbar([UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)+2*pi]*180/pi,...
                            [temp_mean;temp_mean(1)],...
                            1.96*[temp_sem;temp_sem(1)],...
                            'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
                            
    %                     gca = polar([UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)]',[temp;temp(1)]');
    %                     hold on
    %                     set(gca,'Color',colors_field_bias((iBias-1)*length(field_indexes)+iField,:))
                        legend_str{(iBias-1)*length(UF_struct.field_indexes)+iField} = ['UF: ' num2str(UF_struct.field_orientations(iField)*180/pi) '\circ  BF: ' num2str(round(UF_struct.bias_force_directions(iBias)*180/pi)) '\circ'];
                    end

                end


                % Passive PDs
                mean_fr_bump = zeros(length(UF_struct.bump_indexes),1);
                for iBump = 1:length(UF_struct.bump_indexes)
                    mean_fr_bump(iBump) =  mean(unit_binned_mean_fr(trial_type_mat(:,3)==iBump,max_std_idx));
                end
                % Fit sine
    %             a = mean(mean_fr_bump);
    %             b = (max(mean_fr_bump)-min(mean_fr_bump))/2;
    %             cosine = [num2str(a,10) '+' num2str(b,10) '*cos(x*10/(2*pi) + d)'];
                exp_cosine = 'a + exp(b*cos(x - d))/e';
                s = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0 1 pi 1],'Lower',[0 0 0 0],...
                    'Upper',[100 100 2*pi 100]);
                f = fittype(exp_cosine,'options',s);
                fit_cosine = fit(UF_struct.bump_dir_actual,mean_fr_bump,f);
                
                if isfield(UF_struct,'PDs')
                    active_PD(rw_unit_idx) = fit_cosine.d;
        %             compass(max_radius*cos(active_PD(rw_unit_idx)),max_radius*sin(active_PD(rw_unit_idx)),'r');
                    plot([active_PD(rw_unit_idx) active_PD(rw_unit_idx)]*180/pi,[0 max_radius],'r')

                    PD = UF_struct.PDs(rw_unit_idx,[3 4]);
                    PD_f = UF_struct.PDs(rw_unit_idx,[9 10]);
                    if ~isempty(PD)
                        if PD(2) < pi     
                              plot([PD(1) PD(1)]*180/pi,[0 max_radius],'k')
                              temp = plot([PD(1)+PD(2)/2 PD(1)+PD(2)/2]*180/pi,[0 max_radius],'k');
                              set(temp,'Color',[0.6 0.6 0.6])
                              temp = plot([PD(1)-PD(2)/2 PD(1)-PD(2)/2]*180/pi,[0 max_radius],'k');
                              set(temp,'Color',[0.6 0.6 0.6])
                        end
                    end
                end
                ylim([0 max_radius])
                xlim([0 360])
                xlabel('Bump direction')
                ylabel('Mean fr (Hz)')
    %             if ~isempty(PD_f)
    %                 if PD_f(2) < pi                    
    %                     compass(max_radius*cos(PD_f(1)),max_radius*sin(PD_f(1)),'b');
    %                     temp = compass(max_radius*cos(PD_f(1)-PD_f(2)/2),max_radius*sin(PD_f(1)-PD_f(2)/2),'b');
    %                     set(temp,'Color',[0 0 0.6])
    %                     temp = compass(max_radius*cos(PD_f(1)+PD_f(2)/2),max_radius*sin(PD_f(1)+PD_f(2)/2),'b');
    %                     set(temp,'Color',[0 0 0.6])
    %                 end
    %             end
                hleg = legend(legend_str,'Location','NorthWest');
                set(hleg,'FontSize',8);
            %     title(['BF: ' num2str(round(bias_force_directions(iBias)*180/pi)) ' deg'])

                subplot(2,2,2)
                mean_wf = double(mean(bdf.units(unit_idx).waveforms(used_spikes_idx,:)));
                std_wf = std(double(bdf.units(unit_idx).waveforms(used_spikes_idx,:)));            
    %             ga = area([1:length(mean_wf) length(mean_wf):-1:1],[mean_wf+std_wf mean_wf(end:-1:1)-std_wf(end:-1:1)]);
    %             set(ga,'LineStyle','none','FaceColor',[0.7 0.7 1])            
                hold on
                plot(mean_wf)
                plot(mean_wf+std_wf,'--')
                plot(mean_wf-std_wf,'--')
                plot(max(bdf.units(unit_idx).waveforms(used_spikes_idx,:)),'-.')
                plot(min(bdf.units(unit_idx).waveforms(used_spikes_idx,:)),'-.')

                subplot(2,2,3)
                plot(UF_struct.elec_map(:,1),UF_struct.elec_map(:,2),'ob','MarkerSize',12)
                hold on
                plot(UF_struct.elec_map(UF_struct.elec_map(:,4)==electrode,1),UF_struct.elec_map(UF_struct.elec_map(:,4)==electrode,2),'or','MarkerSize',12)
                text(median(UF_struct.elec_map(:,1)),max(UF_struct.elec_map(:,2))+1,'Anterior')
                text(max(UF_struct.elec_map(:,1)),median(UF_struct.elec_map(:,2))+1,'Lateral')
                axis equal
                axis off

                subplot(2,2,4)
                hist(diff(bdf.units(unit_idx).ts(used_spikes_idx)),[0:0.001:0.1])
    %             h = findobj(gca,'Type','patch');
    %             set(h,'FaceColor','w','EdgeColor','k')

                xlim([0 .09])
                ylabel('Count')
                xlabel('ISI (s)')               


                set(gcf,'NextPlot','add');
                gca = axes;
                h = title({[UF_struct.UF_file_prefix ' ' UF_struct.RW_file_prefix];...
                    ['Elec: ' num2str(electrode) ' (Chan: ' num2str(units(iUnit,1)) ') Unit: ' num2str(units(iUnit,2))];...
                    ['Max modulation latency: ' num2str(max_mod_latency) ' s'];...
                    ['Max activity latency: ' num2str(max_act_latency) ' s']},'Interpreter','none');
                set(gca,'Visible','off');
                set(h,'Visible','on');
    %             pause



            else
                disp('Less than 50 spikes, skipping plotting')
            end
        end
        %% Active vs passive PDs
        % atan2(sin(PDs(:,3)-active_PD),cos(PDs(:,3)-active_PD));
        if isfield(UF_struct,'PDs')
            figHandles(end+1) = figure;
            hist(abs(180*atan2(sin(UF_struct.PDs(:,3)-active_PD'),cos(UF_struct.PDs(:,3)-active_PD'))/pi),30)
            xlabel('|passive - active PD| (deg)')
            ylabel('Count')
        end

    end
    if save_figs
        save_figures(figHandles,UF_struct.UF_file_prefix,UF_struct.datapath,'Units',figTitles)
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