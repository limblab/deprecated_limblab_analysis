function spikemap_plot(vel_heat_maps,chans,chan_to_plot)
% Plays animation of spiking heat map created by 'vel_spikemap.m' for unit
% 'chan_to_plot'


num_bins = size(vel_heat_maps,2);


for i = 1:num_bins
    
    figure
    xlabel('x-velocity');
    ylabel('y-velocity');
    colormap(gray);
    title(chans(chan_to_plot,:));
    vmap = vel_heat_maps{chan_to_plot,i};
    xv = zeros(size(vmap,1),1);
    vmap = [vmap xv]; %#ok<AGROW>
    yv = zeros(1,size(vmap,2));
    vmap = [vmap; yv]; %#ok<AGROW>
    surf(vmap);
    view(0,90);
    colorbar;
    axis( [1 21 1 21] ); % these values will have to change if binning is changed in 'vel_spikemap'
    
end