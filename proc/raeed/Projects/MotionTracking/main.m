%1. load cerebus file
%2. load colortracking file
%3. align times (based on led square wave)
%4. put kinect marker locations in handle coordinates
%   -if this is the first file from the day, find the rotation matrix and then use it
%   -if not, just use the rotation matrix found from another file from the day

%Output will be all the markers in handle coordinates, and in cerebus time
%% 1. LOAD CEREBUS FILE
folder = 'C:\Users\rhc307\Documents\Data\experiment_20151120_RW_003\';
prefix = 'Chips_20151120_RW_003';
bdf = get_nev_mat_data([folder prefix],6,'ignore_jumps');

%% 2. LOAD MOTION TRACKING FILE
load([folder 'ct_chips_CO_actpass_151117.mat'])

%Note - this folder may be different than the one w/ the cerebus file?

%% 3. ALIGN TIMES (PUT THE MOTION TRACKING FILE IN CEREBUS TIME) 

%% 3a. Plot LED vals
figure; plot(times,led_vals,'r');
title('Kinect LED vals')

%% 3b. Enter kinect start time estimate

kinect_start_guess=7.6;

%% 3c. Align kinect led values with cerebus squarewave

plot_flag=1; %Whether to plot the match between the kinect LED and cerebus squarewaves
kinect_times  = match_squarewave_main( bdf, led_vals, times, kinect_start_guess, plot_flag);

%% 4. PUT KINECT MARKER LOCATIONS IN HANDLE COORDINATES

rotation_known=0; %Whether the rotation matrix is already known (from another file from that day)

%% 4a. Get Translation and Rotation

if ~rotation_known
    [ T,R ] = get_translation_rotation( bdf, all_medians );
    %Save a file w/ T and R, so it can be used for other files from the
    %same day
else
    %Else load a file that has T and R

end


%% 4b. Perform Translation and Rotation on the kinect data

[ kinect_pos,kinect_pos2 ] = do_translation_rotation( all_medians, all_medians2, T, R );

%% 5. Put Kinect data into bdf

%% 6. Put Kinect motion tracking data into trc format
