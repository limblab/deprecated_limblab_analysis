function UF_plot_SSEP(UF_struct,bdf)
if isfield(bdf,'units')
    channels = str2double([bdf.analog.channel]);
    SSEP_range = [0.02 0.05];
    plot_range = [-.05 .1];
    n_bumps = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.field_indexes));
    min_lfp_mean_all = zeros(length(channels),length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes));
    min_lfp_sem_all = zeros(length(channels),length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes));

    lfp_baseline = repmat(mean(UF_struct.lfp_all(:,:,UF_struct.t_axis<0),3),[1 1 size(UF_struct.lfp_all,3)]);
    UF_struct.lfp_all = UF_struct.lfp_all - lfp_baseline;
    
    for iChannel = 1:length(channels)
        electrode = UF_struct.elec_map(UF_struct.elec_map(:,3)==channels(iChannel),4);
        figure
        figure1_idx = gcf;
        figure
        figure2_idx = gcf;
        lfp_idx = iChannel;
        lfp_temp = squeeze(UF_struct.lfp_all(lfp_idx,:,:));
%         lfp_temp = filter_lfp(lfp_temp,UF_struct.t_axis,UF_struct.t_axis>.1);        
        lfp_lim_max = -inf;
        lfp_lim_min = inf;
        mean_lfp = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes));
        sem_lfp = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes));
        min_lfp_mean = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes));
        min_lfp_sem = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes)); 
        sum_lfp_mean = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes)); 
        sum_lfp_sem = zeros(length(UF_struct.bias_indexes),length(UF_struct.field_indexes),length(UF_struct.bump_indexes)); 
        figure(figure1_idx);
        for iBump = 1:length(UF_struct.bump_indexes)           
            subplot(2,length(UF_struct.bump_indexes)/2,iBump) 
            hold on
            for iBias = 1:length(UF_struct.bias_indexes)
                for iField = 1:length(UF_struct.field_indexes)                
                    idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
                    idx = intersect(idx,UF_struct.bias_indexes{iBias});
                    idx = idx(mean(abs(lfp_temp(idx,:))') < 2*mean(std(abs(lfp_temp(:,:))')));
                    n_bumps(iBias,iField,iBump) = length(idx); 
                    errorarea(UF_struct.t_axis,mean(lfp_temp(idx,:),1),1.96*std(lfp_temp(idx,:),1)/sqrt(length(idx)),...
                         min([1 1 1],.7+UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:)));
                    plot(UF_struct.t_axis,mean(lfp_temp(idx,:),1),'Color',...
                        UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:),'LineWidth',2)
                    title(['B:' num2str(UF_struct.bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
                    ylabel('SSEP (mV?)')
                    xlabel('t (s)')
                    xlim(plot_range)
                    lfp_lim_max = max(lfp_lim_max,max(mean(lfp_temp(idx,:),1)));
                    lfp_lim_min = min(lfp_lim_min,min(mean(lfp_temp(idx,:),1)));
                    lfp_temp_2 = lfp_temp(idx,UF_struct.t_axis>SSEP_range(1) & UF_struct.t_axis<SSEP_range(2));                    
                    mean_lfp(iBias,iField,iBump) = mean(lfp_temp_2(:));
                    sem_lfp(iBias,iField,iBump) = std(mean(lfp_temp_2,2))/sqrt(length(idx));
%                     min_lfp_mean(iBias,iField,iBump) = mean(min(lfp_temp_2,[],2));
                    min_lfp_mean(iBias,iField,iBump) = min(mean(lfp_temp_2));
%                     min_lfp_sem(iBias,iField,iBump) = std(min(lfp_temp_2,[],2))/sqrt(length(idx));
                    min_lfp_sem(iBias,iField,iBump) = std(min(lfp_temp_2,[],2))/sqrt(length(idx));
%                     min_lfp_mean_all(iChannel,iBias,iField,iBump) = mean(min(lfp_temp_2,[],2));
                    min_lfp_mean_all(iChannel,iBias,iField,iBump) = min(mean(lfp_temp_2));
%                     min_lfp_sem_all(iChannel,iBias,iField,iBump) = std(min(lfp_temp_2,[],2))/sqrt(length(idx));
                    min_lfp_sem_all(iChannel,iBias,iField,iBump) = std(min(lfp_temp_2,[],2))/sqrt(length(idx));
%                     sum_lfp_mean(iBias,iField,iBump) = mean(sum(lfp_temp_2,2));
%                     sum_lfp_sem(iBias,iField,iBump) = std(sum(lfp_temp_2,2))/sqrt(length(idx));
                    legend_str{(iBias-1)*length(UF_struct.field_indexes)+iField} =...
                        ['UF: ' num2str(UF_struct.field_orientations(iField)*180/pi) ' deg' ' BF: ' num2str(round(UF_struct.bias_force_directions(iBias)*180/pi)) ' deg'];          
                end
             end
        end
        for iBump = 1:length(UF_struct.bump_indexes)
            subplot(2,length(UF_struct.bump_indexes)/2,iBump) 
            ylim([1.1*lfp_lim_min 1.1*lfp_lim_max])
            y_text = lfp_lim_max;
            for iBias = 1:length(UF_struct.bias_indexes)
                for iField = 1:length(UF_struct.field_indexes)
                    y_text = y_text - .05*(lfp_lim_max - lfp_lim_min); 
                    text(0,y_text,num2str(n_bumps(iBias,iField,iBump)),...
                            'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:))
                end
            end
        end
        legend(legend_str)

        clear lfp_temp
        set(gcf,'NextPlot','add');
        gca = axes;
        h = title({[UF_struct.UF_file_prefix];...
            ['Elec: ' num2str(electrode) ' (Chan: ' num2str(channels(iChannel)) ')']},'Interpreter','none');
        set(gca,'Visible','off');
        set(h,'Visible','on');
        
        figure(figure2_idx)
        subplot(221)
        hold on
        for iBias = 1:length(UF_struct.bias_indexes)
            for iField = 1:length(UF_struct.field_indexes)
                errorbar(180/pi*UF_struct.bump_directions',...
                    squeeze(mean_lfp(iBias,iField,:)),...
                    1.96*squeeze(sem_lfp(iBias,iField,:)),...
                    'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
            end
        end
        xlabel('Bump direction (deg)')
        ylabel('Mean SSEP (mV)')
        legend(legend_str)
        
        subplot(222)
        hold on
        for iBias = 1:length(UF_struct.bias_indexes)
            for iField = 1:length(UF_struct.field_indexes)
                plot(cos(UF_struct.bump_dir_actual([1:end 1])).*squeeze(abs(min_lfp_mean(iBias,iField,[1:end 1]))),...
                    sin(UF_struct.bump_dir_actual([1:end 1])).*squeeze(abs(min_lfp_mean(iBias,iField,[1:end 1]))),...
                    'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
%                   plot(cos(UF_struct.bump_directions([1:end 1])).*squeeze(abs(min_lfp_sem(iBias,iField,[1:end 1]))),...
%                     sin(UF_struct.bump_directions([1:end 1])).*squeeze(abs(min_lfp_sem(iBias,iField,[1:end 1]))),...
%                     'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
            end
        end
        plot(cos(0:.1:2*pi)*max(abs(min_lfp_mean(:))),sin(0:.1:2*pi)*max(abs(min_lfp_mean(:))),'-k')

        xlim([-1.1*max(abs(min_lfp_mean(:))) 1.1*max(abs(min_lfp_mean(:)))])
        ylim([-1.1*max(abs(min_lfp_mean(:))) 1.1*max(abs(min_lfp_mean(:)))])
        axis square
        title('max(|LFP|) as a function of displacement direction')
        
        subplot(224)
        hold on
        for iBias = 1:length(UF_struct.bias_indexes)
            for iField = 1:length(UF_struct.field_indexes)
%                 plot(cos(UF_struct.bump_dir_actual([1:end 1])).*squeeze(abs(min_lfp_sem(iBias,iField,[1:end 1]))),...
%                     sin(UF_struct.bump_dir_actual([1:end 1])).*squeeze(abs(min_lfp_sem(iBias,iField,[1:end 1]))),...
%                     'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
                  plot(cos(UF_struct.bump_directions([1:end 1])).*squeeze(abs(min_lfp_mean(iBias,iField,[1:end 1]))),...
                    sin(UF_struct.bump_directions([1:end 1])).*squeeze(abs(min_lfp_mean(iBias,iField,[1:end 1]))),...
                    'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
            end
        end
        plot(cos([0:.1:2*pi 0])*max(abs(min_lfp_mean(:))),sin([0:.1:2*pi 0])*max(abs(min_lfp_mean(:))),'-k')
        
        xlim([-1.1*max(abs(min_lfp_mean(:))) 1.1*max(abs(min_lfp_mean(:)))])
        ylim([-1.1*max(abs(min_lfp_mean(:))) 1.1*max(abs(min_lfp_mean(:)))])
        axis square
        title('max(|LFP|) as a function of commanded force direction')
        
        subplot(223)
        hold on
        for iBias = 1:length(UF_struct.bias_indexes)
            for iField = 1:length(UF_struct.field_indexes)
                errorbar(180/pi*UF_struct.bump_directions',...
                    squeeze(min_lfp_mean(iBias,iField,:)),...
                    1.96*squeeze(min_lfp_sem(iBias,iField,:)),...
                    'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:));
            end
        end
        xlabel('Bump direction (deg)')
        ylabel('Min SSEP (mV)')
        
        set(gcf,'NextPlot','add');
        gca = axes;
        h = title({[UF_struct.UF_file_prefix];...
            ['Elec: ' num2str(electrode) ' (Chan: ' num2str(channels(iChannel)) ')']},'Interpreter','none');
        set(gca,'Visible','off');
        set(h,'Visible','on');
        
    end
end

norm_mat = min(min(squeeze(min(min_lfp_mean_all,[],4)),[],3),[],2);
norm_mat = repmat(norm_mat,[1,length(UF_struct.bias_indexes),length(UF_struct.field_indexes),...
    length(UF_struct.bump_indexes)]);
    
min_lfp_mean_all_norm = min_lfp_mean_all./norm_mat;

% figure
% hold on
% for iBias = 1:length(UF_struct.bias_indexes)
%     for iField = 1:length(UF_struct.field_indexes)
%         for iBump = 1:length(UF_struct.bump_indexes)
% %             if UF_struct.bias_force_directions(iBias)==UF_struct.bump_directions(iBump)
%                 plot3(180/pi*abs(UF_struct.bias_force_directions(iBias)-UF_struct.bump_directions(iBump)),...
%                     180/pi*mod((UF_struct.field_orientations(iField)-UF_struct.bump_directions(iBump)),UF_struct.bump_directions(3)),...
%                     mean(squeeze(min_lfp_mean_all_norm(:,iBias,iField,iBump))),'.')
% %             end
%             
%         end
%     end
% end

figure
hold on
parallel_mean = zeros(size(UF_struct.bias_force_directions));
perpendicular_mean = zeros(size(UF_struct.bias_force_directions));
parallel_sem = zeros(size(UF_struct.bias_force_directions));
perpendicular_mean = zeros(size(UF_struct.bias_force_directions));
perpendicular_sem = zeros(size(UF_struct.bias_force_directions));
for iField = 1:length(UF_struct.field_indexes)
    for iBias = 1:length(UF_struct.bias_force_directions)
        iBump = iBias;
        if (abs(UF_struct.bump_directions(iBump)-UF_struct.field_orientations(iField)) == 0 ||...
            abs(UF_struct.bump_directions(iBump)-UF_struct.field_orientations(iField)) == pi)
            parallel_mean(iBump) = mean(squeeze(min_lfp_mean_all_norm(:,iBias,iField,iBump))); 
            parallel_sem(iBump) = std(squeeze(min_lfp_mean_all_norm(:,iBias,iField,iBump)))/sqrt(size(min_lfp_mean_all_norm,1));
        else
            perpendicular_mean(iBump) = mean(squeeze(min_lfp_mean_all_norm(:,iBias,iField,iBump))); 
            perpendicular_sem(iBump) = std(squeeze(min_lfp_mean_all_norm(:,iBias,iField,iBump)))/sqrt(size(min_lfp_mean_all_norm,1));
        end
    end
end
errorbar(180/pi*UF_struct.bias_force_directions,parallel_mean-perpendicular_mean,1.96*(parallel_sem+perpendicular_sem))
xlabel('Bias force direction (deg)')
ylabel('| LFP_{parallel} - LFP_{perpendicular} |')
title({['Average normalized parallel - perpendicular LFP amplitude (N1) for all electrodes'];...
       ['Bias direction = bump direction'];...
        [UF_struct.UF_file_prefix]},'Interpreter','none');
    
figure
hold on
parallel_mean = zeros(size(UF_struct.bump_directions));
perpendicular_mean = zeros(size(UF_struct.bump_directions));
parallel_sem = zeros(size(UF_struct.bump_directions));
perpendicular_mean = zeros(size(UF_struct.bump_directions));
perpendicular_sem = zeros(size(UF_struct.bump_directions));
for iField = 1:length(UF_struct.field_indexes)
    for iBump = 1:length(UF_struct.bump_directions)
        if (abs(UF_struct.bump_directions(iBump)-UF_struct.field_orientations(iField)) == 0 ||...
            abs(UF_struct.bump_directions(iBump)-UF_struct.field_orientations(iField)) == pi)
            parallel_mean(iBump) = mean(reshape(min_lfp_mean_all_norm(:,:,iField,iBump),[],1)); 
            parallel_sem(iBump) = std(reshape(min_lfp_mean_all_norm(:,:,iField,iBump),[],1))/sqrt(size(min_lfp_mean_all_norm,1));
        else
            perpendicular_mean(iBump) = mean(reshape(min_lfp_mean_all_norm(:,:,iField,iBump),[],1)); 
            perpendicular_sem(iBump) = std(reshape(min_lfp_mean_all_norm(:,:,iField,iBump),[],1))/sqrt(size(min_lfp_mean_all_norm,1));
        end
    end
end
errorbar(180/pi*UF_struct.bump_directions,parallel_mean-perpendicular_mean,1.96*(sqrt(parallel_sem.^2+perpendicular_sem.^2)))
xlabel('Bump direction (deg)')
ylabel('| LFP_{parallel} - LFP_{perpendicular} |')
title({['Average normalized parallel - perpendicular LFP amplitude (N1) for all electrodes'];...
        ['Averaged for all bias force directions'];...
        [UF_struct.UF_file_prefix]},'Interpreter','none');
    
figure
hold on
parallel_mean = zeros(size(UF_struct.bias_force_directions));
parallel_sem = zeros(size(UF_struct.bias_force_directions));
perpendicular_mean = zeros(size(UF_struct.bias_force_directions));
perpendicular_sem = zeros(size(UF_struct.bias_force_directions));
for iField = 1:length(UF_struct.field_indexes)
    for iBias = 1:length(UF_struct.bias_force_directions)
        parallel_mean_temp = zeros(1,length(UF_struct.bump_directions));
        parallel_sem_temp = zeros(1,length(UF_struct.bump_directions));
        perpendicular_mean_temp = zeros(1,length(UF_struct.bump_directions));
        perpendicular_sem_temp = zeros(1,length(UF_struct.bump_directions));
        for iBump = 1:length(UF_struct.bump_directions)
            if (abs(UF_struct.bump_directions(iBump)-UF_struct.field_orientations(iField)) == 0 ||...
                abs(UF_struct.bump_directions(iBump)-UF_struct.field_orientations(iField)) == pi)
                parallel_mean_temp(iBump) = mean(reshape(min_lfp_mean_all_norm(:,iBias,iField,iBump),[],1)); 
                parallel_sem_temp(iBump) = std(reshape(min_lfp_mean_all_norm(:,iBias,iField,iBump),[],1))/sqrt(size(min_lfp_mean_all_norm,1));
            else
                perpendicular_mean_temp(iBump) = mean(reshape(min_lfp_mean_all_norm(:,iBias,iField,iBump),[],1)); 
                perpendicular_sem_temp(iBump) = std(reshape(min_lfp_mean_all_norm(:,iBias,iField,iBump),[],1))/sqrt(size(min_lfp_mean_all_norm,1));
            end
        end
        parallel_mean(iBias) = mean(parallel_mean_temp);
        perpendicular_mean(iBias) = mean(perpendicular_mean_temp);
    end
end
errorbar(180/pi*UF_struct.bias_force_directions,parallel_mean-perpendicular_mean,1.96*(sqrt(parallel_sem.^2+perpendicular_sem.^2)))
xlabel('Bias direction (deg)')
ylabel('| LFP_{parallel} - LFP_{perpendicular} |')
title({['Average normalized parallel - perpendicular LFP amplitude (N1) for all electrodes'];...
        ['Averaged for all bump directions'];...
        [UF_struct.UF_file_prefix]},'Interpreter','none');
    
figure
hold on
bump_dir_lfp_mean = zeros(1,length(UF_struct.bump_directions));
bump_dir_lfp_sem = zeros(1,length(UF_struct.bump_directions));
for iBump = 1:length(UF_struct.bump_directions)
    bump_dir_lfp_mean(iBump) = mean(reshape(min_lfp_mean_all_norm(:,:,:,iBump),[],1)); 
    bump_dir_lfp_sem(iBump) = std(reshape(min_lfp_mean_all_norm(:,:,:,iBump),[],1))/...
        sqrt(numel(min_lfp_mean_all_norm)/length(UF_struct.bump_directions));
end            
            
errorbar(180/pi*UF_struct.bump_directions,bump_dir_lfp_mean,1.96*(bump_dir_lfp_sem))
xlabel('Bump direction (deg)')
ylabel('| LFP |')
title({['Average normalized LFP amplitude (N1) for all electrodes'];...
        ['Averaged for all bias force directions and field orientations'];...
        [UF_struct.UF_file_prefix]},'Interpreter','none');

% parallel_mean-perpendicular_mean



% y = lfp_temp(idx,UF_struct.t_axis<0);
% Fs = UF_struct.fs;                    % Sampling frequency
% T = 1/Fs;                     % Sample time
% L = length(y);                     % Length of signal
% t = (0:L-1)*T;                % Time vector
% 
% NFFT = L; 
% Y = fft(y,NFFT,2);
% f = Fs/2*linspace(0,1,NFFT/2+1);
% 
% figure
% Y_60 = zeros(size(Y));
% Y_60(:,f>55 & f<65) = Y(:,f>55 & f<65);
% Y_filt = Y-Y_60;
% y_filt = ifft(Y_filt,NFFT,2);
% hold on;
% plot(t,mean(y,1),t,mean(y_filt,1))
% figure
% plot(f,mean(2*abs(Y(:,1:NFFT/2+1))),f,mean(2*abs(Y_filt(:,1:NFFT/2+1))))
% 
% figure
% [b,a] = butter(2,[55/(Fs/2) 65/(Fs/2)]);
% y_filt = filtfilt(b,a,mean(y,1));
% plot(t,mean(y,1),t,mean(y,1)-y_filt)
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