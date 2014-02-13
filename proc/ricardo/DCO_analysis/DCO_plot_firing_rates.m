function params = DCO_plot_firing_rates(data_struct,params)

DCO = data_struct.DCO;
bdf = data_struct.bdf;

%% Movement firing rates
for iUnit = 1:size(DCO.mov_firingrates,3)
    params.fig_handles(end+1) = figure;
    subplot(2,1,1)
    hold on    
    mean_fr = zeros(length(DCO.target_locations),length(DCO.t_mov));
    for iDirection = 1:length(DCO.target_locations)  
        mean_fr(iDirection,:) = mean(DCO.mov_firingrates(DCO.target_locations_idx{iDirection},:,iUnit));
        plot(DCO.t_mov,mean_fr(iDirection,:),'Color',DCO.direction_colors(iDirection,:))
    end
    [~,max_var_idx] = max(std(mean_fr));
    xlabel('Time from go cue (s)')
    ylabel('Firing rate (Hz)')
    title(['Unit ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2))])
    set(params.fig_handles(end),'Name',['Firing rates movement ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2))])
    legend(num2str(round(DCO.target_locations*180/pi)))
    
    subplot(2,2,3)
    hold on
    max_mod_fr = mean_fr(:,max_var_idx);
    plot(max_mod_fr([1:end 1]).*cos(DCO.target_locations([1:end 1])),...
        max_mod_fr([1:end 1]).*sin(DCO.target_locations([1:end 1])),'k-')
    plot(mean(max_mod_fr)*cos([0:.1:2*pi 0]),...
        mean(max_mod_fr)*sin([0:.1:2*pi 0]),'--k')
    axis square
    xlim(max([max_mod_fr;.1])*[-1.2 1.2])
    ylim(max([max_mod_fr;.1])*[-1.2 1.2])
    title(['Mov fr at t = ' num2str(DCO.t_mov(max_var_idx)) ' s'])    
    
    subplot(2,2,4)
    hold on        
    fr = zeros(length(DCO.target_forces),length(DCO.target_locations));   
    for iForce = 1:length(DCO.target_forces)             
        for iDirection = 1:length(DCO.target_locations)
            idx = intersect(DCO.target_locations_idx{iDirection},DCO.target_forces_idx{iForce});
            idx = intersect(idx,DCO.reward_trials);
            fr(iForce,iDirection) = mean(mean(DCO.hold_firingrates(idx,:,iUnit)));
        end          
        plot(fr(iForce,[1:end 1]).*cos(DCO.target_locations([1:end 1]))',...
            fr(iForce,[1:end 1]).*sin(DCO.target_locations([1:end 1]))',...
            'Color',DCO.force_colors(iForce,:),'LineStyle','-')       
    end
    mean_fr = mean(fr,2);
    max_fr = max(fr(:));
    for iForce = 1:length(DCO.force_colors)
        plot(mean_fr(iForce)*cos([0:.1:2*pi 0]),...
            mean_fr(iForce)*sin([0:.1:2*pi 0]),...
            'Color',DCO.force_colors(iForce,:),'LineStyle','--')
    end
    xlabel('Firing rate (Hz)')
    ylabel('Firing rate (Hz)')
    title('Force hold fr')
    set(params.fig_handles(end),'Name',['Firing rates movement ' num2str(bdf.units(iUnit).id(1)) '-' num2str(bdf.units(iUnit).id(2))])
    legend([num2str(DCO.target_forces) repmat(' N',length(DCO.target_forces),1)])
    xlim([-1.2 1.2]*max(max_fr,.1))
    ylim([-1.2 1.2]*max(max_fr,.1))
    axis square
end
