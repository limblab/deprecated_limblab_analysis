function UF_plot_EMG(UF_struct,save_figs)
    mean_range = [0.05 0.075];
    figHandles = [];
    plot_idx = 1:size(UF_struct.trial_table,1);
    for iEMG = 1:UF_struct.num_emg
        baseline_idx = find(UF_struct.t_axis>-.05 & UF_struct.t_axis<0);
        temp_emg = squeeze(UF_struct.emg_all(iEMG,:,:));
        max_emg = 0.001;
        emg_mean = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes));
        emg_std = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes));
        emg_sem = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes));        
        min_n = 1000;
        max_n = 0;
        n_bumps = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.field_indexes));
        legend_str = [];
        baseline_mean = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes));
        baseline_sem = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes));
        smooth_n = 10;

        for iBias = 1:length(UF_struct.bias_indexes)
            figHandles(end+1) = figure; 
            for iField = 1:length(UF_struct.field_indexes)
                idx = intersect(UF_struct.field_indexes{iField},UF_struct.bias_indexes{iBias});
                idx = intersect(idx,plot_idx);
                baseline = temp_emg(idx,baseline_idx);
                baseline_mean(iBias,iField) = mean(baseline(:));
                baseline_sem(iBias,iField) = std(mean(baseline,2))/sqrt(length(idx));

                for iBump = 1:length(UF_struct.bump_indexes)
                    idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump}); 
                    idx = intersect(idx,UF_struct.bias_indexes{iBias}); 
                    idx = intersect(idx,plot_idx);
                    idx = idx(~(std(temp_emg(idx,:)') > 3*mean(std(temp_emg(idx,:)'))));
                    subplot(2,length(UF_struct.bump_indexes)/2,iBump)            
                    hold on
                    ha = errorarea(UF_struct.t_axis,smooth(mean(temp_emg(idx,:),1),smooth_n),...
                        1.96*smooth(std(temp_emg(idx,:),0,1),smooth_n)/sqrt(length(idx)),...
                        min([1 1 1],.7+UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:)));
%                     alpha(.3)
                    plot(UF_struct.t_axis,smooth(mean(temp_emg(idx,:),1),smooth_n),...
                        'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:))   

    %                 plot(UF_struct.t_axis,smooth(mean(temp_emg(idx,:),1),smooth_n)+...
    %                     smooth(std(temp_emg(idx,:),0,1),smooth_n),...
    %                     'Color',min([1 1 1],.3+UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:)))
    %                 plot(UF_struct.t_axis,smooth(mean(temp_emg(idx,:),1),smooth_n)-...
    %                     smooth(std(temp_emg(idx,:),0,1),smooth_n),...
    %                     'Color',min([1 1 1],.3+UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:)))

                    title([UF_struct.emgnames{iEMG} ' B:' num2str(UF_struct.bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
                    xlabel('t (s)')
                    ylabel('EMG (mV)')
                    xlim([-.05 .15])
                    max_emg = max(max_emg,max(mean(temp_emg(idx,UF_struct.t_axis>-.05 & UF_struct.t_axis<.15))));
                    temp_emg_short = temp_emg(idx,UF_struct.t_axis>mean_range(1) & UF_struct.t_axis<mean_range(2));
                    emg_mean(iBias,iField,iBump) = mean(temp_emg_short(:));
    %                 emg_std(iBias,iField,iBump) = std(mean(temp_emg(idx,UF_struct.t_axis>mean_range(1) & UF_struct.t_axis<mean_range(2))));
                    emg_std(iBias,iField,iBump) = std(mean(temp_emg_short,2));
                    emg_sem(iBias,iField,iBump) = std(mean(temp_emg_short,2))/sqrt(size(temp_emg_short,1));

                    min_n = min(min_n,length(idx));
                    max_n = max(max_n,length(idx));
                    n_bumps(iBias,iField,iBump) = length(idx);
                    hChildren = get(gca,'children');
                    hType = get(hChildren,'Type');
                    set(gca,'children',hChildren([find(strcmp(hType,'line')); find(~strcmp(hType,'line'))]))
                end
                legend_str{(iBias-1)*length(UF_struct.field_indexes)+iField} = ['UF: ' num2str(UF_struct.field_orientations(iField)*180/pi) ' deg' ' BF: ' num2str(round(UF_struct.bias_force_directions(iBias)*180/pi)) ' deg'];                
            end      
            set(gca,'children',hChildren([find(~strcmp(hType,'line')); find(strcmp(hType,'line'))]))
            legend(legend_str{(iBias-1)*length(UF_struct.field_indexes)+[1:length(UF_struct.field_indexes)]})
            set(gca,'children',hChildren([find(strcmp(hType,'line')); find(~strcmp(hType,'line'))]))

            for iBump=1:length(UF_struct.bump_indexes)
                subplot(2,length(UF_struct.bump_indexes)/2,iBump)
                ylim([0 1.1*max_emg])
                y_text = max_emg;
                for iField = 1:length(UF_struct.field_indexes)
                    y_text = y_text - .05*max_emg; 
                    text(-.03,y_text,num2str(n_bumps(iBias,iField,iBump)),...
                        'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:))
                    plot(UF_struct.t_axis(baseline_idx([1 end])),[baseline_mean(iBias,iField) baseline_mean(iBias,iField)],...
                        'Color',min([1 1 1],.3+UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:)),...
                        'LineStyle','-')
                    plot(UF_struct.t_axis(baseline_idx([1 end])),[baseline_mean(iBias,iField) baseline_mean(iBias,iField)]+...
                        1.96*[baseline_sem(iBias,iField) baseline_sem(iBias,iField)],...
                    'Color',min([1 1 1],.5+UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:)),...
                    'LineStyle','--')
                    plot(UF_struct.t_axis(baseline_idx([1 end])),[baseline_mean(iBias,iField) baseline_mean(iBias,iField)]-...
                        1.96*[baseline_sem(iBias,iField) baseline_sem(iBias,iField)],...
                    'Color',min([1 1 1],.5+UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:)),...
                    'LineStyle','--')
                end
            end
            set(gcf,'NextPlot','add');
            gca2 = axes;
            h = title(UF_struct.UF_file_prefix,'Interpreter','none');
            set(gca2,'Visible','off');
            set(h,'Visible','on');            
        end

        figHandles(end+1) = figure; 
        subplot(211)
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
                    ... squeeze(emg_std(iBias,iField,[1:end 1])/2),...
                    squeeze(1.96*emg_sem(iBias,iField,[1:end 1])),...
                    'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
            end
        end
        axis on
        xlim([min(180/pi*[UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)+2*pi])-10, ...
            max(180/pi*[UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)+2*pi])+10])
        xlabel('Bump direction (deg)')
        ylabel('EMG (mV)')
        legend(legend_str,'interpreter','none')
        title({UF_struct.UF_file_prefix;...
            [UF_struct.emgnames{iEMG} '.  Average EMG between ' num2str(mean_range(1)) ' and ' num2str(mean_range(2)) ' s. '...
            num2str(min_n) ' <= n <= ' num2str(max_n)]},...
            'interpreter','none')

        subplot(212)
        hold on
        temp_fields = round(UF_struct.field_orientations*100)/100;
        temp_bumps = round(UF_struct.bump_directions*100)/100;
        temp_pi = round(pi*100)/100;
        temp_pi2= round(pi*100)/100/2;
        log_gain = zeros(length(UF_struct.bias_indexes),length(UF_struct.bump_indexes));
        gain = zeros(length(UF_struct.bias_indexes),length(UF_struct.bump_indexes));
        sem_prop = zeros(length(UF_struct.bias_indexes),length(UF_struct.bump_indexes));
        legend_str = [];

        for iBias = 1:length(UF_struct.bias_indexes)
            for iBump = 1:length(UF_struct.bump_indexes)
                idxParallel = find(temp_fields==temp_bumps(iBump) | (temp_fields+temp_pi)==temp_bumps(iBump));
                idxPerpendicular =  find(abs(temp_fields+temp_pi2-temp_bumps(iBump))<1E-10 | abs((temp_fields-temp_pi2)-temp_bumps(iBump))<1E-10 |...
                    abs(temp_fields+temp_pi2+temp_pi-temp_bumps(iBump))<1E-10 | abs((temp_fields-temp_pi2+temp_pi)-temp_bumps(iBump))<1E-10);
    %             gain(iBias,iBump) = mean(squeeze(emg_mean(iBias,idxParallel,iBump))) ./ ...
    %                 mean(squeeze(emg_mean(iBias,idxPerpendicular,iBump)));
                gain(iBias,iBump) = emg_mean(iBias,idxParallel,iBump) - ...
                    emg_mean(iBias,idxPerpendicular,iBump);
                sem_prop(iBias,iBump) = sqrt(emg_sem(iBias,idxParallel,iBump)^2 + ...
                    emg_sem(iBias,idxPerpendicular,iBump)^2);
                log_gain(iBias,iBump) = log(emg_mean(iBias,idxParallel,iBump)) - ...
                    log(emg_mean(iBias,idxPerpendicular,iBump));            
            end
            legend_str{iBias} = ['BF: ' num2str(round(UF_struct.bias_force_directions(iBias)*180/pi)) ' deg'];    
        end
%         plot(180/pi*[UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)+2*pi],gain(:,[1:end 1])')
            
        for iBias = 1:length(UF_struct.bias_indexes)
            errorbar(180/pi*[UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)+2*pi],...
                gain(iBias,[1:end 1]),1.96*sem_prop(iBias,[1:end 1]),...
                'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+1,:));
        end            
        
        axis on
        xlim([min(180/pi*[UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)+2*pi])-10, ...
            max(180/pi*[UF_struct.bump_dir_actual;UF_struct.bump_dir_actual(1)+2*pi])+10])
        xlabel('Bump direction (deg)')
    %     ylabel('log(UF1)-log(UF2)')
        ylabel('EMG_{parallel} - EMG_{perpenticular} (mV)')
        legend(legend_str,'interpreter','none')
        title({UF_struct.UF_file_prefix;...
            [UF_struct.emgnames{iEMG} '.  Average EMG between ' num2str(mean_range(1)) ' and ' num2str(mean_range(2)) ' s. '...
            num2str(min_n) ' <= n <= ' num2str(max_n)]},...
            'interpreter','none')
        plot([-10 500],[0 0],'k--')

    end
    if save_figs
        save_figures(figHandles,UF_struct.UF_file_prefix,UF_struct.datapath,'EMG')
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