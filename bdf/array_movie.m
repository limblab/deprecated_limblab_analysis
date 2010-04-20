function avgs = array_movie(bdf, monkey_name)
%INPUT: array_movie(bdf, 'monkey_name') ...if monkey has more than one
%array map in the M-file 'create_array_map', be sure to include the correct
%number on the end of the string (ex: 'tiki1' vs. 'tiki2'). If no number is
%specified and monkey has more than 1 array map in 'create_array_map,' the
%first map listed under that monkey in the 'if-elseif-else-end' string of 
%'create_array_map' will be returned (i.e. the argument 'tiki' will
%return 'tiki1_map' because it is earlier in the string)
%OUTPUT: nothing within MATLAB command window/workspace - just creates a 
%bunch of images in folder specified in 'filename' (currently "tmp")

%Data flow for this series of functions:
%In command prompt, call:
%ARRAY_MOVIE(bdf, monkey_name);
%   |
%   |
%  And ARRAY_MOVIE calls:
%   |
%   |
%   +--BIN_SPIKES(bdf);
%   +--ARRAY_ACTIVITY_MAP(spike_list, monkey_name);
%   |   |
%   |   +--CREATE_ARRAY_MAP(monkey_name);
%   +--CLIM_AVE(avg_activity(i), CLim, avg_max);
%   +--EXPAND_IMAGE(curr_image, width, height);
%   |
%   |
%  And then comes the output...
%   |
%   +--> .tif files created in 'tmp' folder

%% Bin spike data

binned_data = bin_spikes(bdf); %call bin_spikes --> returns array of usable units and matrix of binned spike rates
spike_list  = binned_data.spike_list; %array containing channel numbers for each signal (for usable channels only)
spike_rates = binned_data.spike_rates; %matrix in which the columns are usable channels, rows are 50ms time bins


%% Create subscript array

%returns 2 dimensional matrix with subscripts of position of each channel
%in array
subs = array_activity_map(spike_list, monkey_name);


%% Create images

%Initializing:
%-constants
fig1     = figure('Visible', 'off'); %#ok<NASGU> %initializing figure so an empty window does not pop up when the function is called 
length   = 30; %length of video in seconds
fps      = 20; %frame rate of vdeo
frames   = length*fps; %number of frames that will comprise the video
width    = 400; %desired width and height of final images (in pixels)
height   = 400;
CLim     = 150; %150 was quasi-randomly picked as the color limit (length of the colormap) based on
% maximum value of all 'all_images' values. The values do in fact get
% higher than 150, but only rarely

%-arrays
map          = colormap(jet(CLim)); %pre-define colormap for use in 'imwrite' function
map(1:3,:)   = 0; %makes the electrodes with no activity represented by black instead of blue
avg_activity = zeros( 1, 10 ); %a single row to add to the bottom [of the image matrix] that represents average activity within the given frame
all_activity = zeros( frames, 1 ); %stores avg activity values for all frames
all_images   = zeros( 10, 10, frames ); %stores all images (before avg activity row is added on)
num_units    = size(  spike_list, 1 );  %number of active units in data file

%Create array activity image for each time bin
%Must create images in separate loop from converting to frames to allow
%access to *all* 'all_activity' values (need max value to use scaling
%function 'clim_ave')
for i = 1:frames
    
    curr_image        = accumarray( subs, spike_rates(i,:), [10 10] ); %put together a matrix with spike rate counts compiled in corresponding electrode positions
    summed            = sum( sum(curr_image) ); %total activity within curr_image
    all_activity(i)   = round( summed/num_units ); %storing *average* activity over the array
    all_images(:,:,i) = curr_image;
    
end

%max avg activity value to allow scaling of averages
avg_max = max(all_activity);
%scales average values based on max average of this dataset, adds a row to
%the bottom of 'curr_image' to display the average value, expands the
%image, and prints it out to a TIFF into the 'tmp' folder
for i = 1:frames
    
    curr_image      = all_images(:,:,i); %set a local variable to current frame
    all_activity(i) = clim_ave(all_activity(i), CLim, avg_max); %scaling average activity values to cover greater range of colormap values
    avg_activity(:) = all_activity(i);   %create entire row of the scaled avg value for that frame
    curr_image      = vertcat(curr_image, avg_activity); %adding average activity as an extra row on bottom of image
    curr_image      = expand_image( curr_image, width, height ); %enlarge matrix to desired size
    filename        = sprintf('tmp/frame%03d.tif',i); %3 digits in filename gives up to 50s of footage (4 digits: up to ~8mins); assuming 50 ms bins
    
    imwrite( curr_image , map, filename, 'tif' ); %write image to TIFF file

end

avgs = all_activity; %returns array storing average activity value for each time bin/frame (just for reference)
