function plot_heatmaps(vel_heat_maps,chan_names,chans_to_plot)
%simply runs multiple channels through 'spikemap_plot'

for chan = 1:length(chans_to_plot)
    
    spikemap_plot(vel_heat_maps,chan_names,chans_to_plot(chan))
    
end