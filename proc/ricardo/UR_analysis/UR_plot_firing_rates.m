function params = UR_plot_firing_rates(data_struct,params)

UR = data_struct.UR;
bdf = data_struct.bdf;

if isempty(UR.firingrates_mov)
    return
end
% %% Movement firing rates
% for iUnit = 1:size(UR.firingrates_mov,3)
%     params.fig_handles(end+1) = figure;
%     subplot(2,1,1)
%     hold on    
%     mean_fr = zeros(length(UR.movement_directions),length(UR.t_mov));
%     for iDirection = 1:length(UR.movement_directions)  
%         idx = intersect(UR.movement_directions_idx{iDirection},UR.no_bump_trials);
%         mean_fr(iDirection,:) = mean(UR.firingrates_mov(idx,:,iUnit));
%         plot(UR.t_mov,mean_fr(iDirection,:),'Color',UR.direction_colors(iDirection,:))
%     end
%     [~,max_var_idx] = max(std(mean_fr));
%     xlabel('Time from movement onset (s)')
%     ylabel('Firing rate (Hz)')
%     title(['Unit ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2))])
%     set(params.fig_handles(end),'Name',['Firing rates movement ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2))])
%     legend(num2str(round(UR.movement_directions*180/pi)))
%     
%     subplot(2,2,3)
%     hold on
%     max_mod_fr = mean_fr(:,max_var_idx);
%     plot(max_mod_fr([1:end 1]).*cos(UR.movement_directions([1:end 1])),...
%         max_mod_fr([1:end 1]).*sin(UR.movement_directions([1:end 1])),'k-')
%     plot(mean(max_mod_fr)*cos([0:.1:2*pi 0]),...
%         mean(max_mod_fr)*sin([0:.1:2*pi 0]),'--k')
%     axis square
%     xlim(max([max_mod_fr;.1])*[-1.2 1.2])
%     ylim(max([max_mod_fr;.1])*[-1.2 1.2])
%     title(['Mov fr at t = ' num2str(UR.t_mov(max_var_idx)) ' s'])    
%     
% end

%% Movement firing rates separated by stiffness
for iUnit = 1:size(UR.firingrates_mov,3)
    if (params.plot_all_units)
        params.fig_handles(end+1) = figure;
        max_y = 0;
    end
    for iDir = 1:length(UR.movement_directions)
        if (params.plot_all_units)
            subplot(2,length(UR.movement_directions),iDir)
            hold on
        end
        mean_fr = zeros(length(UR.stiffnesses),length(UR.t_mov));
        for iStiffness = 1:length(UR.stiffnesses)  
            idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
            idx = intersect(idx,UR.no_bump_trials);
            mean_fr(iStiffness,:) = mean(UR.firingrates_mov(idx,:,iUnit));
            fr_all(iStiffness,iUnit,iDir,:) = mean(UR.firingrates_mov(idx,:,iUnit));
            if (params.plot_all_units)
                subplot(2,length(UR.movement_directions),iDir)
                hold on
                plot(UR.t_mov,mean_fr(iStiffness,:),'Color',UR.stiffness_colors(iStiffness,:))
                max_y = max(max_y,max(mean_fr(:)));
                xlabel('Time from go cue (s)')
                ylabel('Firing rate (Hz)')
                title(['Movement direction: ' num2str(round(UR.movement_directions(iDir)*180/pi)) '^o. Unit ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2))])            
            end
            for iBump = 1:length(UR.bump_directions_idx)
                idx = intersect(UR.stiffnesses_idx{iStiffness},UR.movement_directions_idx{iDir});
                idx = intersect(idx,UR.bump_trials);
                idx = intersect(idx,UR.bump_directions_idx{iBump});
                temp = mean(UR.firingrates_bump(idx,:,iUnit));
                if (params.plot_all_units)
                    subplot(2,length(UR.bump_directions),length(UR.bump_directions_idx)+iBump)
                    hold on
                    plot(UR.t_bump,temp,'Color',UR.stiffness_colors(iStiffness,:))
                    xlabel('Time from bump onset (s)')
                    ylabel('Firing rate (Hz)')
                    title(['Bump direction: ' num2str(round(UR.bump_directions(iBump)*180/pi)) '^o.'])
                    max_y = max(max_y,max(temp(:)));
                end
            end

        end        
        temp = mean_fr(1,:)./mean_fr(2,:);
        fr_ratio_all(iUnit,iDir,:) = temp;        
        temp(isnan(temp)) = [];
        temp(isinf(temp)) = [];
        fr_ratio(iUnit,iDir) = mean(temp);
        if (params.plot_all_units)
            set(params.fig_handles(end),'Name',['Firing rates movement ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2))]) 
        end
    end
    if (params.plot_all_units)
        h_axes = get(gcf,'Children');
        set(h_axes,'YLim',[0 max_y]);
        legend(num2str(UR.stiffnesses))
    end
end

%% Average firing rate ratio
fr_ratio_all(isnan(fr_ratio_all)) = 1;
fr_ratio_all(isinf(fr_ratio_all)) = 1;
mean_fr_ratio_all = mean(mean(fr_ratio_all,1),2);
mean_fr_ratio_all = reshape(mean_fr_ratio_all,1,[]);

for iUnit = 1:size(fr_all,2)
    temp = fr_all(:,iUnit,:,:);
    temp = max(temp(:));
    fr_all_norm(:,iUnit,:,:) = fr_all(:,iUnit,:,:)/temp;
end

params.fig_handles(end+1) = figure;
subplot(211)
hold on
legend_str = {};
for iStiffness = 1:length(UR.stiffnesses)    
    temp = fr_all_norm(iStiffness,:,:,:);
    if size(temp,1)>1
        temp = squeeze(mean(mean(temp,2),3));
    else
        temp = squeeze(mean(temp,2));
    end
    plot(UR.t_mov,temp,'Color',UR.stiffness_colors(iStiffness,:));
    legend_str = [legend_str {['K = ' num2str(UR.stiffnesses(iStiffness))...
        ' N/cm']}];
end

xlabel('t (s)')
ylabel('normalized firing rate')
title('Normalized firing rate')
legend(legend_str)

subplot(212)
hold on
plot(UR.t_mov,mean_fr_ratio_all)
plot(UR.t_mov,ones(size(UR.t_mov)),'--k')
xlabel('t (s)')
ylabel('Mean firing rate ratio (negative/positive)')
title('Mean firing rate ratio')
ylim([0.8 1.6])
set(params.fig_handles(end),'Name','Firing rate ratio')

%% Channel correlation coefficients
% correlation = zeros(size(units,1),size(units,1));
% for iUnit = 1:size(units,1)
%     iUnit
%     for jUnit = iUnit:size(units,1)
%         temp = corrcoef(UR.fr(iUnit,:),UR.fr(jUnit,:));
%         correlation(iUnit,jUnit) = temp(1,2);
%     end
% end

