function plot_raw_StimDAQ(out_struct, EMGchannel)
% load('recruit_train_01');

    %EMGchannel corresponds to analog input number (one-indexed)
    enabled_chans = find(out_struct.emg_enable);

    % find to which data index the EMG channel corresponds to
    data_index = enabled_chans(enabled_chans==EMGchannel);
    index = find(enabled_chans==EMGchannel);
    
    if ((strcmp(out_struct.mode, 'static_pulses') || strcmp(out_struct.mode, 'static_train')) && ~out_struct.is_costim)
        % This is easy, just a static train, so simply show them all.
        num_sample_per_trig = size(out_struct.data,1);
        figh = figure;
        set(figh, 'Units','normalized','Position', [0.15 0.15 0.66 0.66],...
            'Name',sprintf('Raw Data for %s',out_struct.emg_labels{index}));
        plot((1:num_sample_per_trig)*1000/out_struct.sample_rate,...
                out_struct.data(:,data_index), 'Color','r');
        legend(out_struct.emg_labels{data_index});
        
    elseif out_struct.is_costim
        % Plot each co-stim case in its own subplot
        num_mod = size(out_struct.data,1); %number of combinations
        
        % Determine pairs of muscles
        costimComb = nchoosek(find(out_struct.is_active==1),2);

        figh = figure;
        set(figh, 'Units','normalized','Position', [0.15 0.15 0.66 0.66],...
            'Name',sprintf('Raw Data for %s',out_struct.emg_labels{index}));
        colors = get(gca,'ColorOrder');
        subplot_cols = floor(num_mod/5) + 1;
        subplot_rows = ceil(num_mod/subplot_cols);
        stim_chans = find(out_struct.is_active);
        plot_handles = zeros(1,size(out_struct.data,1));
        ylmax = 0; ylmin = 0;           

        %global parameters label:
        glob_label = sprintf('%s  --  Stim\\_ch: [%s], I = [%s] mA', out_struct.emg_labels{index},...
                    num2str(stim_chans(stim_chans==data_index)), num2str(out_struct.base_amp(stim_chans(stim_chans==data_index))));
        annotation('textbox',[0.25 0.95 0.5 0.05],'String',glob_label,...
                    'Linestyle','none','HorizontalAlignment','center');

        %loop for each plot of different stimulation parameters
        for i=1:num_mod
            plot_handles(i) = subplot(subplot_rows,subplot_cols,i);
            num_samples_per_trig = size(out_struct.data{i,1},1);
            hold on;

            %Setup axes with descriptive title
            title(sprintf('[%s] co-stim',num2str(costimComb(i,:))));
            
            % loop for each n stim pulse within a subplot
            for g = 1:size(out_struct.data,2)
                for j=1:out_struct.num_reps
                    plot((1:num_samples_per_trig)*1000/out_struct.sample_rate,...
                        out_struct.data{i,g}(:,index,j), 'Color',colors(mod(g-1,size(colors,1))+1,:));
                end
            end
        
            yl = ylim;
            ylmin = min(yl(1),ylmin);
            ylmax = max(yl(2),ylmax);
            hold off;
        end

        %loop for each plot to replot with same y axis
        for i=1:num_mod
            ylim(plot_handles(i),[ylmin ylmax]);
        end
    else
        % Plot each parameter modulation in its own subplot
        num_mod = size(out_struct.data,1); %number of modulations
        
        figh = figure;
        set(figh, 'Units','normalized','Position', [0.15 0.15 0.66 0.66],...
            'Name',sprintf('Raw Data for %s',out_struct.emg_labels{index}));
        colors = get(gca,'ColorOrder');
        subplot_cols = floor(num_mod/5) + 1;
        subplot_rows = ceil(num_mod/subplot_cols);
        stim_chans = find(out_struct.base_amp & out_struct.base_pw);
        mod_stim_chans= stim_chans(logical(out_struct.is_channel_modulated(stim_chans)));
        plot_handles = zeros(1,size(out_struct.data,1));
        ylmax = 0; ylmin = 0;           

        %global parameters label:
        if strcmp(out_struct.mode,'mod_pw')
            glob_label = sprintf('%s  --  Stim\\_ch: [%s], I = [%s] mA', out_struct.emg_labels{index},...
                    num2str(stim_chans(stim_chans==data_index)), num2str(out_struct.base_amp(stim_chans(stim_chans==data_index))));
        else
            glob_label = sprintf('%s  --  Stim\\_ch: [%s], PW = [%s] us', out_struct.emg_labels{index},...
                    num2str(stim_chans(stim_chans==data_index)), num2str(out_struct.base_pw(stim_chans(stim_chans==data_index))));
        end
           annotation('textbox',[0.25 0.95 0.5 0.05],'String',glob_label,...
                    'Linestyle','none','HorizontalAlignment','center');

        %loop for each plot of different stimulation parameters
        for i=1:num_mod
            plot_handles(i) = subplot(subplot_rows,subplot_cols,i);
            num_samples_per_trig = size(out_struct.data{i,1},1);
            hold on;

            %stim parameters (for labels)
            PW = out_struct.base_pw;
            PW(mod_stim_chans) = out_struct.modulation_channel_multipliers(i)*PW(mod_stim_chans);
            PW = PW(stim_chans==data_index);
            I = out_struct.base_amp;
            I(mod_stim_chans) = out_struct.modulation_channel_multipliers(i)*I(mod_stim_chans);
            I = I(stim_chans==data_index);             

            %Setup axes with descriptive title
            if strcmp(out_struct.mode, 'mod_pw')
                title(sprintf('[%s] us',num2str(nonzeros(PW)')));
            else
                title(sprintf('[%s] mA', num2str(nonzeros(I)')));
            end

            % loop for each n stim pulse within a subplot
            if EMGchannel > length(out_struct.base_amp)
                for g = 1:size(out_struct.data,2)
                    for j=1:out_struct.num_reps
                        plot((1:num_samples_per_trig)*1000/out_struct.sample_rate,...
                            out_struct.data{i,g}(:,index,j), 'Color',colors(mod(g-1,size(colors,1))+1,:));
                    end
                end
            else
                for j=1:out_struct.num_reps
                    plot((1:num_samples_per_trig)*1000/out_struct.sample_rate,...
                        out_struct.data{i,index}(:,index,j), 'Color',colors(mod(j-1,size(colors,1))+1,:));
                end
            end
            
%             for j=1:out_struct.num_reps
%                 plot((1:num_samples_per_trig)*1000/out_struct.sample_rate,...
%                     out_struct.data{i,j}(:,index,j), 'Color',colors(mod(g-1,size(colors,1))+1,:));
%             end
        
            yl = ylim;
            ylmin = min(yl(1),ylmin);
            ylmax = max(yl(2),ylmax);
            hold off;
        end

        %loop for each plot to replot with same y axis
        for i=1:num_mod
            ylim(plot_handles(i),[ylmin ylmax]);
        end
    end
end
