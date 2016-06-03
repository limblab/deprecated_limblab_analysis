function [A, spike_rates, smoothed_rates] = array_movie(bdf, monkey_name, varargin)
%
%   Author: David Bontrager (d-bontrager [at] northwestern.edu)
%   May 2010, Miller Lab, Northwestern University
%
%OUTPUT: animated figure playing video of cortical array activity
%
%INPUT: array_movie(bdf, 'monkey_name', [opts]): if monkey has more than one
%cortical array map in the M-file 'create_array_map', be sure to include
%the correct number on the end of the string (ex: 'tiki1' vs. 'tiki2'). If 
%no number is specified and monkey has more than 1 array map in
%'create_array_map,' the first map listed under that monkey in the 
%'if-elseif-else-end' string of 'create_array_map' will be returned (i.e.
%the argument 'tiki' will return 'tiki1_map' because it is highest in the
%string).
%OPTIONAL INPUT: (entered as a struct with below labels as field names)
%   --'start_time':     timestamp -in seconds- where the video will begin;
%   default: beginning of file. **Constraints: start_time > 0
%   --'duration':       length of video (in seconds); default: 5 seconds.
%   **Constraints: duration > 0
%   --'play_rate': relative to real-time speed (0.5 for half speed, 2
%   for double speed, etc.); default: 1x (real-time). **Constraints:
%   play_rate > 0
%   --'sound_chan': which neuron to play sound for (correlated to the
%   *channel* number as listed in Plexon, not electrode number related to
%   physical location); default: avg activity of that frame. **Constraints: 
%   0 < sound_chan < 101. 
%NOTES:
%Changing playback rate does NOT change bin size. Bin size (defaults to 50 ms)
%can be changed only by changing 'fps' below, in constants initialization.

% Data flow for this series of functions:
% In command prompt, call:
% ARRAY_MOVIE(bdf, monkey_name, [opts]);
%    |
%    |
%   And ARRAY_MOVIE calls:
%    |
%    |
%    +--BIN_SPIKES(bdf, fps, start_time);
%    +--ARRAY_ACTIVITY_MAP(spike_list, monkey_name, sound_chan);
%    |   |
%    |   +--CREATE_ARRAY_MAP(monkey_name);
%    +--CLIM_AVG(avg_activity, CLim, avg_max);
%    |
%    |
%   And then comes the output...
%    |
%    +--> 'spikes' figure created and images displayed sequentially in
%    figure; sound played according to spiking rate

%% Initialization
% check to see if any constants were set via 'varargin'
if (nargin == 2)        %Set arbitrary default values for the different play options
    start_time = 0;     %timestamp at which to start video       
    duration   = 5;     %length of video in seconds (when played in real-time)
    play_rate  = 1;     %playback rate (1 = real-time speed)
    sound_chan = 0;     %channel number to play sound for ('0' gives avg activity)
    frame_rate = 20;    %native fps to bin data to
    ff         = .3;    %low-pass filter value
else
    opts = varargin{1};
    if isfield( opts, 'start_time' ),  start_time = opts.start_time; else start_time = 0;   end
    if isfield( opts, 'duration'   ),  duration   = opts.duration;   else duration   = 5;   end
    if isfield( opts, 'play_rate'  ),  play_rate  = opts.play_rate;  else play_rate  = 1;   end
    if isfield( opts, 'sound_chan' ),  sound_chan = opts.sound_chan; else sound_chan = 0;   end
    if isfield( opts, 'frame_rate' ),  frame_rate = opts.frame_rate; else frame_rate = 20;  end
    if isfield( opts, 'filt_value' ),  ff         = opts.filt_value; else ff         = .3;  end
end

% Make sure it doesn't run past end of file (possible problem: assumes
% position data exists in bdf)
if (start_time + duration) > bdf.pos(end,1)
    disp('Warning: requested time exceeds file length.');
    return;
end

% -non-argumented constants
from_left   = 400;          %dimensions and location of figure (in pixels)
from_bottom = 50; 
fig_size    = 400;          %set as width AND height
Fs          = 20000;        %sound sampling frequency (arbitrary; sets sound pitch)
fps         = frame_rate;   %native frame rate of video (sets 'binsize' in 'bin_spikes')
frames      = duration*fps; %number of frames that will comprise the video
CLim        = 150;          %picked as the [C]olor [Lim]it (length of colormap) based on maximum value of all 
                            %'all_images' values (~200, generally). The values do in fact get higher than 150, 
                            %but only rarely
 
% -arrays
spikes        = figure('Visible','off'); %create figure with visibility off so a figure isn't created upon creation of CMap
image_axes    = axes('Parent',spikes);   %create axes to contain image, set 'spikes' figure as parent  
CMap          = colormap(jet(CLim));     %pre-define colormap for figure display
avg_activity  = zeros( frames, 1 );      %stores avg activity values for all frames
savg_activity = zeros( 1, 10 );          %a single row to add to the bottom [of the image matrix] that represents average activity within the given frame
all_images    = zeros( 10, 10, frames ); %stores all images (before avg activity row is added on)
all_w_avgs    = zeros( 11, 10, frames ); %stores all images (after avg activity row is added on)

CMap(1:3,:)   = 0; %sets the electrodes with no activity to black instead of dark blue within colormap 'map'
%% Bin spike data

disp('Binning data...');
binned_data    = bin_spikes(bdf, fps, start_time, ff); %returns list of usable units and matrix of binned spike rates
spike_list     = binned_data.spike_list;               %list containing channel numbers for each signal (for usable channels only)
spike_rates    = binned_data.spike_rates;              %matrix in which the columns are usable channels, rows are time bins
smoothed_rates = binned_data.smoothed_rates;
num_units      = length( spike_list );                 %number of active units in data file

%% Create subscript array

% returns 2-D matrix with subscripts of position of each channel in cortical
% array
[subs, audio_subs] = array_activity_map(spike_list, monkey_name, sound_chan);


%% Create images

% Create cortical array activity image for each time bin
% **NOTE: Must create images in separate loop from adding avg activity rows
%         to allow access to *all* 'avg_activity' values (need max value to
%         use scaling function 'clim_avg')
disp('Compiling images...');
for i = 1:frames
    
    all_images(:,:,i) = accumarray( subs, smoothed_rates(i,:), [10 10] );  %put together a matrix with spike rate counts compiled in corresponding electrode positions
    summed            = sum( sum( all_images(:,:,i) ) );                   %sum of all activity within current frame
    avg_activity(i)   = round( summed/num_units );                         %storing *average* activity over the array in each particular frame
    
end
%scale average values based on max avg of this dataset
avg_activity = clim_avg(avg_activity, CLim);
%adds a row to the bottom of each frame to display the average value, and 
%saves it into the 'all_w_avgs' array
for i = 1:frames
    
    savg_activity(:)   = avg_activity(i);                            %create entire row of the scaled avg value for that frame
    all_w_avgs(:,:,i)  = vertcat(all_images(:,:,i), savg_activity);  %adding average activity as extra row on bottom of image

end
A = all_w_avgs(:,:,1:100); %arbitrary output matrices to play with

%% Play image sequence
% set figure property values
set(spikes,'Colormap',CMap,'Name','Spike Activity','NextPlot','replacechildren','NumberTitle','off',...
                'Position',[ from_left from_bottom fig_size fig_size*2 ],'Units','pixels');
            
%Based on value of 'audio_subs' (determined in 'array_activity_map'),
%assigns matrix element as channel to play sound for (if 'sound_chan' is
%input as '0', 'avg_activity' is played)
if ( audio_subs == 0 )
    aud_activity = avg_activity;
else
    aud_activity = all_w_avgs( audio_subs(1), audio_subs(2), : );
end
smin = min( aud_activity );
smax = max( aud_activity );
smax = smax*0.6; %scale 'smax' down with a quasi-arbitrarily picked number 
                 %to give audible variation over the normal range of values
                 %because very few values will be near maximum value

time_plot = zeros(frames,1);
set(spikes,'Visible','on');
% runs through 'all_w_images', playing sound as appropriate
disp('Playing animation...');
for i = 1:frames
    
    tic
    
    if ( aud_activity(i) ~= 0 )
        soundsc( aud_activity(i), Fs, [ smin smax ] );    % volume level corresponds to activity level
    end
    subplot(2,1,1)
        image( all_w_avgs(:,:,i));
    %image( all_w_avgs(:,:,i), 'Parent', image_axes ); % change image being displayed in figure to current frame
    time_plot(1:i) = aud_activity(1:i);
    subplot(4,1,3)
        stairs( time_plot );
    
    % take calculating time into account (determine correct playback rate)
    pause_time = (1/fps)/play_rate - toc;
    pause(pause_time);
    
end
disp('Animation complete.');

%Do we really want this? closes video window after it's done playing
%set(spikes, 'Visible','off');



