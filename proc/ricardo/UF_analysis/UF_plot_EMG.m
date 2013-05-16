function UF_plot_EMG(UF_struct)
for iEMG = 1:UF_struct.num_emg
    figure
    temp_emg = squeeze(UF_struct.emg_all(iEMG,:,:));
    max_emg = 0.001;
    emg_mean = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes));
    emg_std = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes));
    mean_range = [0.05 0.1];
    min_n = 1000;
    max_n = 0;
    for iBias = 1:length(UF_struct.bias_indexes)
        for iField = 1:length(UF_struct.field_indexes)
            for iBump = 1:length(UF_struct.bump_indexes)
                idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump}); 
                idx = intersect(idx,UF_struct.bias_indexes{iBias}); 
                idx = idx(~(std(temp_emg(idx,:)') > 3*mean(std(temp_emg(idx,:)'))));
                subplot(2,length(UF_struct.bump_indexes)/2,iBump)            
                hold on
                plot(UF_struct.t_axis,smooth(mean(temp_emg(idx,:),1),10),...
                    'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:))
                title([UF_struct.emgnames{iEMG} ' B:' num2str(UF_struct.bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
                xlabel('t (s)')
                ylabel('EMG (mV)')
                xlim([-.05 .15])
                max_emg = max(max_emg,max(mean(temp_emg(idx,UF_struct.t_axis>-.05 & UF_struct.t_axis<.15))));
                emg_mean(iBias,iField,iBump) = mean(mean(temp_emg(idx,UF_struct.t_axis>mean_range(1) & UF_struct.t_axis<mean_range(2))));
                emg_std(iBias,iField,iBump) = std(mean(temp_emg(idx,UF_struct.t_axis>mean_range(1) & UF_struct.t_axis<mean_range(2))));
                min_n = min(min_n,length(idx));
                max_n = max(max_n,length(idx));
            end
            legend_str{(iBias-1)*length(UF_struct.field_indexes)+iField} = ['UF: ' num2str(UF_struct.field_orientations(iField)*180/pi) ' deg' ' BF: ' num2str(round(UF_struct.bias_force_directions(iBias)*180/pi)) ' deg'];
        end      
    end
    legend(legend_str,'interpreter','none')
    for iBump=1:length(UF_struct.bump_indexes)
        subplot(2,length(UF_struct.bump_indexes)/2,iBump)
        ylim([0 1.1*max_emg])
    end
    set(gcf,'NextPlot','add');
    gca = axes;
    h = title(UF_struct.UF_file_prefix,'Interpreter','none');
    set(gca,'Visible','off');
    set(h,'Visible','on');

    figure
    temp_axes = axes;
    hold on
    for iBias = 1:length(UF_struct.bias_indexes)
        for iField = 1:length(UF_struct.field_indexes)
            plot(180/pi*[UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)+2*pi],squeeze(emg_mean(iBias,iField,[1:end 1])),...
                'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
        end
    end
    for iBias = 1:length(UF_struct.bias_indexes)
        for iField = 1:length(UF_struct.field_indexes)
            errorbar(180/pi*[UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)+2*pi],squeeze(emg_mean(iBias,iField,[1:end 1])),...
                squeeze(emg_std(iBias,iField,[1:end 1])/2),...
                'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
        end
    end
    axis on
    xlim([0 360])
    xlabel('Bump direction (deg)')
    ylabel('EMG (mV)')
    legend(legend_str,'interpreter','none')
    title({UF_struct.UF_file_prefix;...
        [UF_struct.emgnames{iEMG} '.  Average EMG between ' num2str(mean_range(1)) ' and ' num2str(mean_range(2)) ' s. '...
        num2str(min_n) ' <= n <= ' num2str(max_n)]},...
        'interpreter','none')

end