function plot_speed_scatter(scatter_cell,spikeguide,units)
% plot output from 'sd_speed_scatter', with 'units' being output from
% 'plot_spike_windows'

%pull unit numbers out of cell array into matrix
u_nums = zeros(size(scatter_cell,1),1);
for i = 1:size(scatter_cell,1)
    u_nums(i) = scatter_cell{i,2};
end
u_nums = u_nums(find(u_nums));
for i = 1:length(units)
    
    idx = find(u_nums==units(i),1);
    if ~isempty(idx)
        this_unit = scatter_cell{idx,1}; % [ speed  firing_rate ]
        figure
        plot(this_unit(:,1),this_unit(:,2),'.');
        xlabel('Speed along PD (cm/s)');
        ylabel('Firing rate (Hz)');
        title(spikeguide(units(i),:));
    else
        disp(strcat(['Unit ' spikeguide(units(i),:) ' not found.']));
    end
    
end