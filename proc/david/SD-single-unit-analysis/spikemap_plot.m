function spikemap_plot(vel_heat_maps,chans,chan_to_plot)
% Plays animation of spiking heat map created by 'vel_spikemap.m' for unit
% 'chan_to_plot'
%
% vel_heat_maps{unit,i} = heat_map(1:num_vbins,1:num_vbins);
% where 'i' indexes through all the time bins of that unit

%% to-do
%-scale somehow so all plots for the plotted unit are on same color scale
%(so the subplot coloration is all the same relative to other time bins on
%that same figure) ===> this functionality will be in 'chng2img'

%% Normalize/Scale so relative output across subplots is all the same

% Scales all values within each unit so they span the colormap range and
% changes to an image
%vmaps = chng2img(vel_heat_maps);
vmaps = vel_heat_maps;

%% plot
num_bins = size(vmaps,2);
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
axs = '[1 11 1 11]';
colormap(gray);
for i = 1:num_bins
    
    time_bin = -0.4 + (i-1)*0.05; % '-.4'=time start set in vel_spikemap, '.05'=bin size (not currently variable)
    title_text = strcat([ num2str(time_bin) 'sec']);
    if one_row
        subplot(1,num_bins,i)
        vmap = vmaps{chan_to_plot,i};
        xv = zeros(size(vmap,1),1);
        vmap = [vmap xv]; %#ok<AGROW>
        yv = zeros(1,size(vmap,2));
        vmap = [vmap; yv]; %#ok<AGROW>
        surf(vmap);
        view(0,90);
        axis( eval(axs) ); % these values will have to change if binning is changed in 'vel_spikemap'
        title(title_text);
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
        title(title_text);
    end
    
end



%% Internal functions
function vmaps = chng2img(vel_heat_maps)
% Steps to take:
%   -for each unit, read min and max values, normalize values in each time
%   bin to the range present across all time bins of that unit
%   -add 3rd dim. to firing rate matrix so it can represent an RGB image,
%   change subplotting to "image" instead of "surf"

vhm = vel_heat_maps; %let's make later typing a little easier...
num_units = size(vhm,1); %number of units
num_bins  = size(vhm,2); %number of time bins
dim_x = size(vhm{1,1},2);
dim_y = size(vhm{1,1},1);
unit_stats = (-1)*ones(num_units,4); % [ min  max  mean  median ] - may later remove mean or median

% GET MAX/MIN VALUES FOR EACH UNIT
num_els = dim_x*dim_y;
disp('Calculating min and max values for each unit');
for unit = 1:num_units
    
    all_vals = zeros(dim_y,dim_x*num_bins); %and one array to hold them all
    for bin = 1:num_bins    
        init = num_els*(bin-1) + 1;
        fin  = num_els*bin;
        all_vals(init:fin) = vhm{unit,bin};%(1:end);
    end
    unit_stats(unit,:) = [ min(min(all_vals)) max(max(all_vals))...
                           mean(mean(all_vals)) median(median(all_vals)) ];
                       
    vhm{unit,:} = scale_unit(vhm{unit,:});
    
end



function scaled_unit = scale_unit(unit_vhms)



function s_plots = init_subplot(num_bins)
% A simple, though thoroughly dirty way to set up variable subplot sizes based on the
% number of subplots we want (which == num_bins)

if num_bins == 4 %case num_bins==4
    s_plots = [ 'subplot(2,2,1)'; 'subplot(2,2,2)'; 'subplot(2,2,3)'; 'subplot(2,2,4)' ];
    return;
elseif num_bins < 7 %case num_bins==5 or 6
    s_plots = [ 'subplot(2,3,1)'; 'subplot(2,3,2)'; 'subplot(2,3,3)';...
                'subplot(2,3,4)'; 'subplot(2,3,5)'; 'subplot(2,3,6)' ];
    return;
elseif num_bins < 9 %case num_bins==7 or 8
    s_plots = [ 'subplot(2,4,1)'; 'subplot(2,4,2)'; 'subplot(2,4,3)'; 'subplot(2,4,4)';...
                'subplot(2,4,5)'; 'subplot(2,4,6)'; 'subplot(2,4,7)'; 'subplot(2,4,8)' ];
    return;
elseif num_bins == 9
    s_plots = [ 'subplot(3,3,1)'; 'subplot(3,3,2)'; 'subplot(3,3,3)';...
                'subplot(3,3,4)'; 'subplot(3,3,5)'; 'subplot(3,3,6)';...
                'subplot(3,3,7)'; 'subplot(3,3,8)'; 'subplot(3,3,9)' ];
    return;
else
    disp('too many plots. bugger off.');
    s_plots = 0;
    return;
end
 
