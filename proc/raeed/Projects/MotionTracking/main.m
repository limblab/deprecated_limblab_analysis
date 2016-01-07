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

%% 4a. Plot handle to determine some points to remove
%We want to remove the time points when the monkey has thrown away the
%handle, since then the hand won't be at the same position as the handle
if ~rotation_known
    figure; scatter(handle_pos_ds(:,1),handle_pos_ds(:,2))
%Note- this plot can be removed if the limits (below) are always the same
end
%% 4b. Set limits of handle points
%We'll remove times when the handle is outside these limits
if ~rotation_known
    x_lim_handle=[-10,10]; %x limits (min and max)
    y_lim_handle=[-55,-35]; %y limits (min and max)
end

%% 4c. Get Translation and Rotation

if ~rotation_known
    plot_flag=1;
    [ R, Tpre, Tpost, times_good, pos_h, colors_xy ] = get_translation_rotation( bdf, all_medians, x_lim_handle, y_lim_handle, plot_flag );
    %Save a file w/ T and R, so it can be used for other files from the
    %same day
else
    %Else load a file that has T and R
end


%% 4b. Perform Translation and Rotation on the kinect data

plot_flag=1;
[ kinect_pos,kinect_pos2 ] = do_translation_rotation( all_medians, all_medians2, R, Tpre, Tpost, plot_flag, times_good, pos_h, colors_xy );

%% 5. FIND TIMES TO EXCLUDE (BECAUSE THE MONKEY THROUGH AWAY THE HANDLE)

%% 5a. Calculate the distances of the hand marker to the handle (and plot)
%This can be used to determine times when the monkey has thrown away the
%handle

k=reshape(kinect_pos(3,:,:),[3,n_times]);
h=handle_pos_ds;
h(:,3)=0;

err=NaN(1,n_times);
for i=1:n_times    
    err(i)=pdist2(k(:,i)',h(i,:));
end

figure; plot(err)

%This can be used in combination w/ the z-force

%% 6. PUT KINECT DATA INTO BDF

%% 7. PUT KINECT MOTION TRACKING DATA INTO TRC FORMAT
