function[size_map, color_map, normalizers, fig_handle] = ArrayMapPlot(monkey,implant,unit_ids,size_metric,size_norm,color_metric,color_labels,suppress_plot,varargin) 
%__________________________________________________________________________
%
%                                  Inputs 
%__________________________________________________________________________
%
%        monkey - string with monkey name (eg 'Mihili')
%       implant - string with implant region (eg 'M1' or 'PMd')
%      unit_ids - vector with channel and unit information in the form of
%                 channel.unit (eg [1.1 1.2 3.1 3.2 ... 96.1])
%   size_metric - vector containing desired metric (must be same size as
%                 unit_ids)
%     size_norm - 
%                 [](default) - automatically adjust plotted marker sizes 
%                                to fit data range of 'size_metric'
%                      scalar - uses input value to create custom scaling 
%                               of 'size_metric' for plotting purposes
%
%                   *warning* - inputting non-empty  may result in broken 
%                               code (negative plot sizes, etc.) so be sure 
%                               raw data is appropriate before scaling.
%  
%  color_metric - vector containing desired metric (must be same size as
%                 unit_ids)
%  color_labels:
%                   'auto' - normal plot with colorbar
%                       '' - normal plot without colorbar
%               {'labels'} - cell array containing labels for categorical
%                           color labels. Color_metric contain numbers from
%                           the set (1:1:N)
% suppress_plot - optional input to suppress plot and only return array
%                 values (1 to suppress). Leave empty for all other 
%                 plotting
%__________________________________________________________________________
%
%                                  Outputs
%__________________________________________________________________________
%
%       size_map - array map in (x,y) coordinates with size metric. Map
%                  will be 3 dimensional if there are multiple units on one
%                  channel, with (x,y,z) corresponding to the zth unit on 
%                  the channel at (x,y) 
%      color_map - array map in (x,y) coordinates with color metric.
%__________________________________________________________________________
%
%                              Implementation                                 
%__________________________________________________________________________
%
% ArrayMapPlot(monkey,implant,unit_ids,size_metric)
%   Plots the metric in 'size_metric' as circles, with each radius
%   corresponding to the value
%
% ArrayMapPlot(monkey,implant,unit_ids,size_metric,size_norm,color_metric)
% 	Plots the 'size_metric' with circle size, and 'color_metric' with
%   circle color. Will also plot a colorbar.
%
% ArrayMapPlot(monkey,implant,unit_ids,size_metric,size_norm,color_metric,color_labels)
%   color_labels can take a few forms:
%                        'auto' - Same as with only 5 inputs
%                            '' - Will do size and color plot without the colorbar
%       {'label1','label2',...} - Can plot 'color_metric' categorical variables

%% Markers or Colors (Plotting Options - changeable by user)
Plot_type = 'o';
Color_map = 'winter';

%%
if nargin == 4
    color_metric = ones(length(unit_ids),1);
    color_labels = '';
    size_norm = [];
    suppress_plot = 0;
elseif nargin == 6  
    color_labels = 'auto';
    suppress_plot = 0;
elseif nargin == 7
    suppress_plot = 0;
end

% Function to parse unit information
info_parse = @(id) [floor(id) round(10*(id - floor(id)))];

%% Get Mapfile and assign metrics
map = ArrayMap(monkey,implant); % Get mapfile

unit_metrics = size_metric; % Assign metrics for size 
unit_categories = color_metric; % Assign metrics for color

%% Size Normalization
if isempty(size_norm)
    minval = min(unit_metrics(:));
    maxval = max(unit_metrics(:));
    rangeval = maxval - minval;

    size_scale = 40; size_offset = 1;

    unit_metrics_scaled = size_scale*(unit_metrics - minval)/rangeval + size_offset;
    unit_metrics_scaled(isnan(unit_metrics_scaled))=1;
    
    normalizers.size_scale = size_scale;
    normalizers.rangeval = rangeval;
    normalizers.size_offset = size_offset;
    normalizers.minval = minval;
else
    unit_metrics_scaled = size_norm * unit_metrics;
    unit_metrics_scaled(isnan(unit_metrics_scaled))=1;
    
    normalizers.size_scale = 1;

end

%% Color Normalization
num_unique = length(unique(unit_categories(unit_categories~=0)));
if ~iscell(color_labels) % If using auto (continuous) color plotting
    mincol = min(unit_categories(:));
    maxcol = max(unit_categories(:));
    rangecol = maxcol - mincol;

    col_scale = 60; col_offset = 2;
    
    unit_categories_scaled = round(col_scale*(unit_categories - mincol)/rangecol) + col_offset;
    unit_categories_scaled(isnan(unit_categories_scaled)) = 1;
else % If color information is categorical
    unit_categories_scaled = unit_categories;
end
%% Populate map with metrics and flip to prepare for plotting
%Initialize arrays
[metric_map, categ_map, size_map, color_map, flipped_map, flipped_cat] = ...
    deal(zeros(size(map,1),size(map,2),max(round(10*(unit_ids - floor(unit_ids))))));
for i = 1:length(unit_ids) %Loop through units and place metrics on map
    
    chan_unit = info_parse(unit_ids(i)); % Parse channel/unit information
    channel = chan_unit(1); unitnum = chan_unit(2);
    
    [locx,locy] = find(map==channel); % Find channel location on array
    
    metric_map(locx,locy,unitnum) = unit_metrics_scaled(i); % Place scaled value on map
    size_map(locx,locy,unitnum) = unit_metrics(i); % Place raw value in output
    
    categ_map(locx,locy,unitnum) = unit_categories_scaled(i); % Place scaled value on map
    color_map(locx,locy,unitnum) = unit_categories(i); % Place raw value in output
end

%% Do plotting
if suppress_plot ~= 1
    for i = 1:size(metric_map,3) % Flip map to prepare for plotting
        flipped_map(:,:,i) = flipud(metric_map(:,:,i))';
        flipped_cat(:,:,i) = flipud(categ_map(:,:,i))';
    end

    fig_handle = figure; hold on; 
    if iscell(color_labels)
        c = colormap(eval([Color_map '(' num2str(num_unique) ')']));
    else
        c = colormap(eval(Color_map));
    end

    for k = 1:size(metric_map,3) % Loop through multi-unit channels
        for j = 1:size(metric_map,2) % First dimension
            for i = 1:size(metric_map,1) % Second dimension
                if flipped_map(i,j,k) > 0 && flipped_cat(i,j,k) ~= 0
                    plot(i,j,Plot_type,'Color',c(flipped_cat(i,j,k),:),'MarkerSize',flipped_map(i,j,k),'LineWidth',5);
                end
            end
        end
    end

    if iscell(color_labels)
        lcolorbar(color_labels);
    elseif ~isempty(color_labels) && rangecol~=0
        caxis([mincol - col_offset/col_scale * rangecol, ...
            maxcol + col_offset/col_scale * rangecol]);
        colorbar
    end

    axis square
    axis off
else
    fig_handle = 0;
end
