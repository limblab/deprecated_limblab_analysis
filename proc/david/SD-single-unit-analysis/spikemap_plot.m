function spikemap_plot(vel_heat_maps,chans,chan_to_plot)
% Plays animation of spiking heat map created by 'vel_spikemap.m' for unit
% 'chan_to_plot'

%% to-do
%-scale somehow so all plots for the plotted unit are on same color scale


%% plot
num_bins = size(vel_heat_maps,2);
if num_bins < 4
    one_row = 1;
else
    s_plots = init_subplot(num_bins);
    one_row = 0;
    if size(s_plots,1) == 1
        return;
    end
end

figure
axs = '[1 21 1 21]';
lbl = 1;
colormap(gray);
for i = 1:num_bins
    
    if one_row
        subplot(1,num_bins,i)
        if lbl
            xlabel('x-velocity');
            ylabel('y-velocity');
            lbl = 0;
        end
        title(chans(chan_to_plot,:));
        vmap = vel_heat_maps{chan_to_plot,i};
        xv = zeros(size(vmap,1),1);
        vmap = [vmap xv]; %#ok<AGROW>
        yv = zeros(1,size(vmap,2));
        vmap = [vmap; yv]; %#ok<AGROW>
        surf(vmap);
        view(0,90);
        axis( eval(axs) ); % these values will have to change if binning is changed in 'vel_spikemap'
        if i==num_bins %add colorbar with last one
           colorbar;
        end
    else
        eval(s_plots(i,:)); %get subplot arrangement
        title(chans(chan_to_plot,:));
        vmap = vel_heat_maps{chan_to_plot,i};
        xv = zeros(size(vmap,1),1);
        vmap = [vmap xv]; %#ok<AGROW>
        yv = zeros(1,size(vmap,2));
        vmap = [vmap; yv]; %#ok<AGROW>
        surf(vmap);
        view(0,90);
        axis( eval(axs) ); % these values will have to change if binning is changed in 'vel_spikemap'
        if i==num_bins %add colorbar with last one
           colorbar;
        end
    end
    
end



%% Internal functions
function s_plots = init_subplot(num_bins)
% A simple, though dirty, way to set up variable subplot sizes based on the
% number of subplots we want (which == num_bins)

if num_bins == 4 %case num_bins==4
    s_plots = [ 'subplot(2,2,1)'; 'subplot(2,2,3)'; 'subplot(2,2,2)'; 'subplot(2,2,4)' ];
    return;
elseif num_bins < 7 %case num_bins==5 or 6
    s_plots = [ 'subplot(2,3,1)'; 'subplot(2,3,3)'; 'subplot(2,3,5)';...
                'subplot(2,3,2)'; 'subplot(2,3,4)'; 'subplot(2,3,6)' ];
    return;
elseif num_bins < 9 %case num_bins==7 or 8
    s_plots = [ 'subplot(2,4,1)'; 'subplot(2,4,3)'; 'subplot(2,4,5)'; 'subplot(2,4,7)';...
                'subplot(2,4,2)'; 'subplot(2,4,4)'; 'subplot(2,4,6)'; 'subplot(2,4,8)' ];
    return;
elseif num_bins == 9
    s_plots = [ 'subplot(3,3,1)'; 'subplot(3,3,4)'; 'subplot(3,3,7)';...
                'subplot(3,3,2)'; 'subplot(3,3,5)'; 'subplot(3,3,8)';...
                'subplot(3,3,3)'; 'subplot(3,3,6)'; 'subplot(3,3,9)' ];
    return;
else
    disp('too many plots. bugger off.');
    s_plots = 0;
    return;
end



