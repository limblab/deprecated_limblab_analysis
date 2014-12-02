function params = RP_plot_firing_rates(data_struct,params)

RP = data_struct.RP;
bdf = data_struct.bdf;

if isempty(RP.firingrates_pert)
    return
end

%% Movement firing rates separated by frequency
for iUnit = 1:size(RP.firingrates_pert,3)
    if params.plot_each_neuron
        params.fig_handles(end+1) = figure;
        h_sub = [];
    end
    max_y = 0;    
    for iDir = 1:length(RP.perturbation_directions)
        if params.plot_each_neuron
            h_sub(end+1) = subplot(2,ceil(length(RP.perturbation_directions)/2),iDir);
            hold on   
            legend_str = {};
        end
        mean_fr = zeros(length(RP.perturbation_frequencies),length(RP.t_pert));
        for iFreq = 1:length(RP.perturbation_frequencies)  
            idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});            
            fr_temp = RP.firingrates_pert(idx,:,iUnit);
            mean_fr(iFreq,:) = mean(fr_temp);
            force_temp = RP.force_pert_x_rot(idx,:);
            correlation = corrcoef(fr_temp,force_temp);
            if params.plot_each_neuron
                plot(RP.t_pert,mean_fr(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:))
                legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
                ' Hz. R^2= ' num2str(correlation(1,2),2)]}];
            end
            fr_all(iDir,iUnit,iFreq,:) = mean(RP.firingrates_pert(idx,:,iUnit));  
        end
        temp = mean_fr(1,:)./mean_fr(2,:);
        fr_ratio_all(iUnit,iFreq,:) = temp;        
        temp(isnan(temp)) = [];
        temp(isinf(temp)) = [];
        fr_ratio(iUnit,iFreq) = mean(temp);
        max_y = max(max_y,max(mean_fr(:)));
        if params.plot_each_neuron
            xlabel('Time from go cue (s)')
            ylabel('Firing rate (Hz)')
            title(['Perturbation direction: ' num2str(round(RP.perturbation_directions(iDir)*180/pi))...
                '^o. Unit ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2))],'Interpreter','tex')
            set(params.fig_handles(end),'Name',['Firing rates ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2)) ' Movement']) 
            legend(legend_str)
        end
    end
    if params.plot_each_neuron
        set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])
%         h_axes = get(gcf,'Children');
%         set(h_axes,'YLim',[0 max_y]);        
    end
end

%% Average firing rate ratio
fr_ratio_all(isnan(fr_ratio_all)) = 1;
fr_ratio_all(isinf(fr_ratio_all)) = 1;
mean_fr_ratio_all = mean(mean(fr_ratio_all,1),2);
mean_fr_ratio_all = reshape(mean_fr_ratio_all,1,[]);

for iDir = 1:size(fr_all,1)
    for iUnit = 1:size(fr_all,2)
        temp = fr_all(:,iUnit,:,:);
        temp = max(temp(:));
        fr_all_norm(iDir,iUnit,:,:) = fr_all(iDir,iUnit,:,:)/temp;
    end
end

params.fig_handles(end+1) = figure;

for iDir = 1:length(RP.perturbation_directions)
    subplot(2,ceil(length(RP.perturbation_directions)/2),iDir)
    hold on
    legend_str = {};
    for iFreq = 1:length(RP.perturbation_frequencies)    
        temp = fr_all_norm(iDir,:,iFreq,:);
        temp = squeeze(mean(mean(temp,2),3));
        plot(RP.t_pert,temp,'Color',RP.perturbation_frequency_colors(iFreq,:));
        legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
            ' Hz']}];
    end
    xlim([RP.t_pert(1) RP.t_pert(end)])
end
legend(legend_str)
xlabel('t (s)')
ylabel('normalized firing rate')
title('Normalized firing rate')


% subplot(212)
% hold on
% plot(RP.t_pert,mean_fr_ratio_all)
% plot(RP.t_pert,ones(size(RP.t_pert)),'--k')
% xlabel('t (s)')
% ylabel('Mean firing rate ratio (negative/positive)')
% title('Mean firing rate ratio')
% ylim([0.8 1.6])
set(params.fig_handles(end),'Name','Firing rate ratio')

%% Channel correlation coefficients
% correlation = zeros(size(units,1),size(units,1));
% for iUnit = 1:size(units,1)
%     iUnit
%     for jUnit = iUnit:size(units,1)
%         temp = corrcoef(RP.fr(iUnit,:),RP.fr(jUnit,:));
%         correlation(iUnit,jUnit) = temp(1,2);
%     end
% end

% %% Bump firing rates separated by bump direction, frequency, movement direction and early/late bump
% for iUnit = 1:size(RP.firingrates_bump,3)
%     for iBump = 1:length(RP.bump_directions)
%         clear fr_all
%         if params.plot_each_neuron
%             params.fig_handles(end+1) = figure;
%             h_sub = [];
%         end
%         max_y = 0;    
%         for iBumpTime = 1:2
%             for iDir = 1:length(RP.perturbation_directions)
%                 if params.plot_each_neuron
%                     h_sub(end+1) = subplot(length(RP.perturbation_directions),2,iDir*2-1+iBumpTime-1);
%                     hold on   
%                     legend_str = {};
%                 end
%                 mean_fr = zeros(length(RP.perturbation_frequencies),length(RP.t_bump));
%                 for iFreq = 1:length(RP.perturbation_frequencies)  
%                     idx = intersect(RP.perturbation_directions_idx{iDir},RP.perturbation_frequencies_idx{iFreq});            
%                     idx = intersect(idx,RP.bump_directions_idx{iBump});
%                     if (iBumpTime == 1)
%                         idx = intersect(idx,RP.early_bump);
%                         bump_str = 'Early bump';
%                     else
%                         idx = intersect(idx,RP.late_bump);
%                         bump_str = 'Late bump';
%                     end
%                     fr_temp = RP.firingrates_bump(idx,:,iUnit);
%                     mean_fr(iFreq,:) = mean(fr_temp);
%                     if params.plot_each_neuron
%                         plot(RP.t_bump,mean_fr(iFreq,:),'Color',RP.perturbation_frequency_colors(iFreq,:))
%                         legend_str = [legend_str {[num2str(RP.perturbation_frequencies(iFreq))...
%                         ' Hz.']}];
%                     end
%                     fr_all(iDir,iUnit,iFreq,:) = mean(RP.firingrates_bump(idx,:,iUnit));  
%                 end
%                 if params.plot_each_neuron
%                     xlabel('Time from go cue (s)')
%                     ylabel('Firing rate (Hz)')
%                     title({['Bump: ' num2str(RP.bump_directions(iBump)*180/pi) '^o. '...
%                         'Movement: ' num2str(mod(180+round(RP.perturbation_directions(iDir)*180/pi),360))...
%                         '^o.'];[bump_str '. Unit ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2))]},'Interpreter','tex');
%                     set(params.fig_handles(end),'Name',['Firing rates ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2))...
%                         ' Bump ' num2str(RP.bump_directions(iBump)*180/pi)]) 
%                     legend(legend_str)
%                 end
%             end
%         end
%         if params.plot_each_neuron
%             set(h_sub,'YLim',[0 max(cellfun(@max,get(h_sub,'YLim')))])
%     %         h_axes = get(gcf,'Children');
%     %         set(h_axes,'YLim',[0 max_y]);        
%         end
%     end
% end
