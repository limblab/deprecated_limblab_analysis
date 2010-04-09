function spike_activity = array_movie(bdf, monkey_name)
%input: array_movie(bdf, 'name')
%return: nothing, really - just creates a bunch of images in folder
%specified in 'filename' (currently "tmp")

spike_activity = 0; %#ok<NASGU>

%Data flow for this series of functions:
%In command prompt, call:
%ARRAY_MOVIE(bdf, monkey_name);
%   |
%   +--BIN_SPIKES(bdf);
%   +--ARRAY_ACTIVITY_MAP(spike_list, monkey_name);
%   |   |
%   |   +--CREATE_ARRAY_MAP(monkey_name);
%   +--EXPAND_IMAGE(curr_image, width, height);
%   |
%   |
%   +-->.tif files created in 'tmp' folder
%% Bin spike data

binned_data = bin_spikes(bdf); %call bin_spikes --> returns array of usable units and matrix of binned spike rates
spike_list  = binned_data.spike_list; %array containing channel numbers for each signal (for usable channels only)
spike_rates = binned_data.spike_rates; %matrix in which the columns are usable channels, rows are 50ms time bins


%% Create subscript array

%returns 2 dimensional matrix with subscripts of position of each channel
%in aray
subs = array_activity_map(spike_list, monkey_name);


%% Create images

%initializing
fig1     = figure('Visible', 'off'); %#ok<NASGU> %initializing figure so an empty window does not pop up whenever the function is called 
%num_bins = size( spike_rates, 1 );  %total number of bins (several thousand)
length   = 30; %length of video in seconds
fps      = 20; %frame rate of vdeo
frames   = length*fps;
width    = 400; %desired width and heigh in pixels of final images 
height   = 400;
map = colormap(jet(150)); %150 was quasi-randomly picked based on maximum value of curr_image:
% higher number pushes values to blue, lower pushes to red; most values are
% in the 40-60 range, but some do get above 100 (120 might be the max, not
% 100% sure)

%create array activity image for each time bin, store to 'tmp' folder as a
%TIFF image
for i = 1:frames
    
    curr_image = accumarray( subs, spike_rates(i,:), [10 10] ); %put together a matrix with spike rate counts compiled in corresponding electrode positions
    curr_image = expand_image( curr_image, width, height ); %enlarge matrix to desired size
    filename = sprintf('tmp/frame%03d.tif',i); %3 digits in filename gives up to 50s of footage (4 digits: up to ~8mins)
    imwrite( curr_image , map, filename, 'tif' );

end

spike_activity = 1; %...have to return something, I suppose
