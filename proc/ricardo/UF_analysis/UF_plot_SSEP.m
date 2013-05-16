function UF_plot_SSEP(UF_struct,bdf)
if isfield(bdf,'units')
    all_chans = reshape([bdf.units.id],2,[])';
    units = unit_list(bdf);
    dt = round(mean(diff(bdf.pos(:,1)))*10000)/10000;
    bin_size = dt;
    neuron_t_axis = (0:(UF_struct.trial_range(2)-UF_struct.trial_range(1))/bin_size-1)*bin_size+UF_struct.trial_range(1);

    for iUnit = 1:size(units,1)    
        unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));

        electrode = UF_struct.elec_map(find(UF_struct.elec_map(:,3)==all_chans(unit_idx,1)),4);
        figure(iUnit+250)
        lfp_idx = find(str2double([bdf.analog.channel])==electrode);
        lfp_temp = squeeze(UF_struct.lfp_all(lfp_idx,:,:));
        for iBias = 1:length(UF_struct.bias_indexes)
            for iField = 1:length(UF_struct.field_indexes)
                for iBump = 1:length(UF_struct.bump_indexes)
                    idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
                    idx = intersect(idx,UF_struct.bias_indexes{iBias});
                    subplot(2,length(UF_struct.bump_indexes)/2,iBump) 
                    hold on
                    plot(neuron_t_axis,mean(lfp_temp(idx,:),1),'Color',...
                        UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:),'LineWidth',2)
                    title(['B:' num2str(UF_struct.bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
                    ylabel('SSEP (mV?)')
                    xlabel('t (s)')
                    xlim([-.02 .15])
                end
                legend_str{(iBias-1)*length(UF_struct.field_indexes)+iField} = ['UF: ' num2str(UF_struct.field_orientations(iField)*180/pi) ' deg' ' BF: ' num2str(round(UF_struct.bias_force_directions(iBias)*180/pi)) ' deg'];
            end
        end
        clear lfp_temp
        set(gcf,'NextPlot','add');
        gca = axes;
        h = title({[UF_struct.UF_file_prefix];...
            ['Elec: ' num2str(electrode) ' (Chan: ' num2str(units(iUnit,1)) ')']},'Interpreter','none');
        set(gca,'Visible','off');
        set(h,'Visible','on');
    end
end