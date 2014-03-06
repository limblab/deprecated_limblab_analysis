function [bins, bin_edge_times, pos, vel, TS, bad_rep] = ...
    smooth_raw_data(samp_freq, marker_data, TS, bins, PLOT_PARSING_FLAG, draw, cycles, cycle_times)
% Smooths raw Optotrak hand movement data using Woltring's GCV spline (cutoff 10 Hz) and
% uses velocity profile curves to determine reaction, movement and hold_b_times. 
% Based on the C code by Tony Reina, The Neurosciences Institute and
%  MATLAB code by Wei Wang, Wash U BME.
% 1. Inputs: Structure that contains the movement's timing parameters (TS)
%             includes holdA, delay, reaction, movement, holdB times
%            Sampling frequency of the data (samp_freq)
%            Marker movement data (marker_data = 8x3xtime array)
%            Bin structure with time in terms of bins (bins)
%               Struct: num_pre, num_mov, num_post, default_bin_size,
%                   bin_size
%            
% 3. Ouputs: Bin structure with time in terms of bins (bins)
%               Struct: num_pre, num_mov, num_post, bin_size
%            Absolute time of when all the bins start (bin_edge_times = 1 x num_tot_bins)
%            Position of the hand (pos = cycles x 8 x 3 x num_tot_bins)
%            Velocity of the hand (vel = cycles x 8 x 3 x num_tot_bins)
%            Timing structure with new values using smoothed and
%             thresholded data.
%            Status of processing (bad_rep)
%               bad_rep.status: 0=good,
%                   0001(b) = not enough data,
%                   0010(b) = doesn't reach offset threshold before mvmt ends, 
%                   0100(b) = double peak,
%                   1000(b) = hold B time is not long enough to fill all post bins.
%
%            WHEN USING FIXED BINS: Status of processing (bad_rep)
%               bad_rep.status: 
%                   0 = good
%                   1 = Hold A < 300ms
%                   2 = Rxn+mvmt < 300ms
%                   4 = Hold B < 300ms
%
% Also places the smoothed data into NUM_TOTAL_BINS bins.
% Usage: [bin_parameter, bin_edge_time, reaction_time_in_bins, pos, vel, TS, bad_rep, percentage] = smooth_raw_data(samp_freq, num_points, marker_data, TS, bin_size)
% NOTES: Since plot_time_marker.m will reflect what this function does, if you change this file 
% change the correspoding area in plot_time_marker.m
%
% Please see notes at the end of the code for documentation of how the movement time was processed.
%
% Date: 1-28-04 Sherwin Chan
% Revision History: 
%   2/18/2004 SSC
%       -Modified comments and help display
%   5/11/2004 SSC
%       -Modified so that it runs with db_proc_kinem_co.m
%   5/21/2004 SSC
%       -Calculate movement end time using thresholding
%       -Added field to bad_rep allowing for characterization of any double
%          peaked movements.
%   8/27/2004 SSC
%       -The velocities will be calculated in mm/ms -> m/s
%   10/4/2004 SSC
%       -added a PLOT_PARSING_FLAG variable so that the processing of the
%         time bins can be more easily visualized.
%   10/11/2004 SSC
%       -going to specify bin size this time and so the number of pre, mov
%       and post bins will vary for each movement.  For the movement to be
%       valid, all these bins (Hold A, Rxn + Mvmt, and Hold B) must contain
%       at least 300 ms worth of data.
%   2/19/2005 SSC
%       -changed the routine for finding the 2nd threshold crossing of a
%       second peak to account for the fact that one movement has its
%       second peak at the very end of its hold b time.
%   3/7/2005 SSC
%       -Changing the file so that the output will include cycles.  The
%       file will also be able to process both drawing and reaching data.
%   8/17/2005 SSC
%       -Minor correction to code to find movement offset.  Minor
%       correction to only look for peak of movement during movement time.

if nargin < 6, draw = 0;
    if nargin < 5, PLOT_PARSING_FLAG = 0;
    end; end;

MOVEMENT_CUTOFF_FREQUENCY = 10;         % frequency with which to filter data
MOVEMENT_ONSET  = 0.15;                 % threshold to define start of movement
MOVEMENT_OFFSET = 0.30;                 % threshold to define end of movement 
SECOND_PEAK = 0.66;                     % threshold for meeting criterion of 2nd peak 

if (draw == 0)  % If it is a reaching movement then do the following
    % Classify each repetition based on length of movement.
    bad_rep.status = 0;
    time = [1:size(marker_data, 3)]' * 1/samp_freq * 1000;
    if length(time) < 5 
        bad_rep.status = 1;
        pos = NaN;
        vel = NaN;
        return
    end
    
    % Do a preliminary filter on the marker data (#1) to calculate velocity from
    % position and calculate end of HoldA, start movement and stop movement
    % times using the times given in the timing structure.
    vel_1(:,:) = low_pass_filter(time * .001, squeeze(marker_data(1,:,1:end))', MOVEMENT_CUTOFF_FREQUENCY, 1)';
    start_ha_time = -TS.sync_time - TS.reaction_time - TS.hold_a_time;
    start_of_hold_a_index = max(1, floor((-TS.sync_time - TS.reaction_time - TS.hold_a_time)*0.001*samp_freq));
    end_of_hold_a_index = max(1, floor((-TS.sync_time - TS.reaction_time)*0.001*samp_freq));
    end_of_hold_b_index = end_of_hold_a_index + floor((TS.reaction_time + TS.movement_time + TS.hold_b_time)*0.001*samp_freq);
    start_move_index = max(1, floor((-TS.sync_time)*0.001*samp_freq));
    stop_move_index = max(1, floor((-TS.sync_time + TS.movement_time)*0.001*samp_freq));
    
    % Find peak velocity within reaction_time and movement_time.  Use peak
    %  velocity to help define movement onset and offset times.
    speed = sqrt(vel_1(1,:).^2 + vel_1(2,:).^2 + vel_1(3,:).^2);
    [peak, index] = max(speed(end_of_hold_a_index:stop_move_index));
    peak_index = index + end_of_hold_a_index - 1;
    pre_peak = speed(1:peak_index - 1);
    post_peak = speed(peak_index:end_of_hold_b_index);
    
    % Define movement onset as when the movement velocity crosses threshold and
    % if that is not sufficient then subtract off baseline mvmt speed to find
    % movement onset.
    onset = find(pre_peak < MOVEMENT_ONSET*peak);
    if isempty(onset) | onset(end) < end_of_hold_a_index
        baseline = min(speed(end_of_hold_a_index:peak_index));
        onset = find(pre_peak < (baseline + MOVEMENT_ONSET*(peak-baseline)));
    end
    onset = onset(end) + 1;
    
    % Define movement offset as when the movement velocity drops below threshold and
    % if that is not sufficient then use movement time to set the movement.
    offset = find(post_peak < MOVEMENT_OFFSET*peak);
    if isempty(offset)
        bad_rep.status = 2;
        start_hold_b_index = floor((-TS.sync_time + TS.movement_time)*0.001*samp_freq);
        post_move = speed(start_hold_b_index+1:end);
        [low, offset] = min(post_move);
        offset = offset + start_hold_b_index;
    else
        offset = offset + peak_index;
    end
    
    % Looks between the dropping below threshold and the end of the movement
    % for a possible second peak of speed during the motion.  If this second
    % peak of movement exists, then determine where the second movement peak
    % crosses the lower threshold again.  
    % On one movement, the peak is at the end of the hold b time, so had to
    % compensate for that here.
    new_post_peak = speed(offset:end_of_hold_b_index);
    sec_peak = find(new_post_peak > SECOND_PEAK*peak);
    if ~isempty(sec_peak)
        post_sec_peak = new_post_peak(sec_peak(end):end);
        post_sec_peak_index = sec_peak(end);
        bad_rep.status = bad_rep.status + 4;
        offset1 = find(post_sec_peak < MOVEMENT_OFFSET*peak);
        if ~isempty(offset1)
            offset = offset1(1) + post_sec_peak_index + offset;
        end
    end
    
    % low = min(post_peak);
    % percentage = low / peak;
    
    % Redefine reaction time and movement time based upon the onset of movement
    % and not the reaction time recorded by the Optotrak routine.
    onset_time = time(onset(1));
    offset_time = time(offset(1));
    TS.reaction_time = onset_time - (-TS.sync_time - TS.reaction_time);
    TS.hold_b_time = -TS.sync_time + TS.movement_time + TS.hold_b_time - offset_time;
    TS.movement_time = offset_time - onset_time;
    
    if isnan(bins.default_bin_size)
        % Bin_size undefined. Use predefined bin numbers.
        bins.bin_size = TS.movement_time/bins.num_movement_bins;
    else
        % Bin_size given. Compute movement epochs based on bin_size.
        bins.bin_size = bins.default_bin_size;
        bins.num_pre_bins = floor((TS.reaction_time + TS.hold_a_time)/bins.bin_size);
        bins.num_movement_bins = floor(TS.movement_time/bins.bin_size);
        bins.num_post_bins = floor((TS.movement_time + TS.hold_b_time - bins.num_movement_bins * bins.bin_size)/bins.bin_size);
        bins.num_total_bins = bins.num_pre_bins + bins.num_movement_bins + bins.num_post_bins;
    end
    
    % Resample movement data according to (total bin number +1 ) samples over smoothed kinematic data.
    resample_time = [-bins.num_pre_bins:1:-1 0:(bins.num_movement_bins + bins.num_post_bins)]' * bins.bin_size;
    bin_edge_times = resample_time + onset_time;
    
    if bin_edge_times(end) > time(end_of_hold_b_index)
        bad_rep.status = bad_rep.status + 8;
    end
    
    for i = 1:size(marker_data, 1)
        current_marker = squeeze(marker_data(i,:,:))';
        % Check to make sure that the array contains real data values and calculate smoothed velocity and position
        %  for each cycle and marker.
        if sum(isnan(current_marker(:))) < 0.5 * length(current_marker(:))
            if bin_edge_times(1) < 0
                filter_time = bin_edge_times - bin_edge_times(1);
            else
                filter_time = bin_edge_times;
            end
            vel(1,i,:,:) = low_pass_filter(time * 0.001, current_marker, MOVEMENT_CUTOFF_FREQUENCY, 1, filter_time*0.001)';
            pos(1,i,:,:) = low_pass_filter(time * 0.001, current_marker, MOVEMENT_CUTOFF_FREQUENCY, 0, filter_time*0.001)';
        else
            vel(1,i,:,:) = repmat(NaN, [size(marker_data, 2) bins.num_total_bins + 1]);
            pos(1,i,:,:) = repmat(NaN, [size(marker_data, 2) bins.num_total_bins + 1]);
        end
    end
    
    bins.reaction_time_in_bins = sum(bin_edge_times>=(onset_time - TS.reaction_time) & bin_edge_times<onset_time);
    bin_edge_times = bin_edge_times';
    
    if ~isnan(bins.default_bin_size)
        bad_rep.status = 0;
        if ((bins.num_pre_bins - bins.reaction_time_in_bins) * bins.default_bin_size) < 300
            bad_rep.status = bad_rep.status + 1;
        end
        if ((bins.reaction_time_in_bins + bins.num_movement_bins) * bins.default_bin_size) < 300
            bad_rep.status = bad_rep.status + 2;
        end
        if (bins.num_post_bins * bins.default_bin_size) < 300
            bad_rep.status = bad_rep.status + 4;
        end
    end
elseif (draw == 1)
    % Classify each repetition based on length of movement.
    bad_rep.status = 0;
    time = [1:size(marker_data, 3)]' * 1/samp_freq * 1000;
    if length(time) < 5 
        bad_rep.status = 1;
        pos = NaN;
        vel = NaN;
        return
    end
    
    % Split the movement into different parts depending on the cycle
    time_offset = -TS.sync_time;
    time_for_cycle = 0;
    num_cycles = size(cycle_times, 2);
    for i = 1:num_cycles
        time_offset = time_offset + time_for_cycle;
        if i == 1
            time_for_cycle = cycle_times(i);
        else        
            time_for_cycle = cycle_times(i) - cycle_times(i-1);
        end
        if isnan(bins.default_bin_size)
            % Bin_size undefined. Use predefined bin numbers.
            bins.bin_size(i) = time_for_cycle/bins.num_movement_bins;
        else
            % Bin_size given. Compute movement epochs based on bin_size.
            bins.num_pre_bins = floor((TS.reaction_time + TS.hold_a_time)/bins.bin_size);
            bins.num_movement_bins = floor(TS.movement_time/bins.bin_size);
            bins.num_post_bins = floor((TS.movement_time + TS.hold_b_time - bins.num_movement_bins * bins.bin_size)/bins.bin_size);
        end
        resample_time = [-bins.num_pre_bins:1:-1 0:(bins.num_movement_bins + bins.num_post_bins)]' * bins.bin_size(i);
        bin_edge_times(:,i) = resample_time + time_offset;
        for j = 1:size(marker_data, 1)
            current_marker = squeeze(marker_data(j,:,:))';
            % Check to make sure that the array contains real data values and calculate smoothed velocity and position
            %  for each cycle and marker.
            if sum(isnan(current_marker(:))) < 0.5 * length(current_marker(:))
                if bin_edge_times(1,i) < 0
                    filter_time(:,i) = bin_edge_times(:,i) - bin_edge_times(:,1);
                else
                    filter_time(:,i) = bin_edge_times(:,i);
                end
                vel(i,j,:,:) = low_pass_filter(time * 0.001, current_marker, MOVEMENT_CUTOFF_FREQUENCY, 1, filter_time(:,i)*0.001)';
                pos(i,j,:,:) = low_pass_filter(time * 0.001, current_marker, MOVEMENT_CUTOFF_FREQUENCY, 0, filter_time(:,i)*0.001)';
            else
                vel(i,j,:,:) = repmat(NaN, [size(marker_data, 2) bins.num_total_bins + 1]);
                pos(i,j,:,:) = repmat(NaN, [size(marker_data, 2) bins.num_total_bins + 1]);
            end
        end
    end
    % Format the data for correct output.
    bin_edge_times = bin_edge_times';
end


% Plot the processing scheme
if PLOT_PARSING_FLAG && draw == 0
    figure(1)
    clf
    speed = speed/peak*100;
    plot(time, speed, 'LineWidth', 2)
    hold on
    plot(time(start_of_hold_a_index:onset(1)), speed(start_of_hold_a_index:onset(1)),'g', 'LineWidth', 2);
    plot(time(offset(1):end_of_hold_b_index), speed(offset(1):end_of_hold_b_index),'r', 'LineWidth', 2);
    plot([time(1) time(onset(1))], [MOVEMENT_ONSET MOVEMENT_ONSET]*100, ':c')
    plot([time(offset(1)) time(end)], [MOVEMENT_OFFSET MOVEMENT_OFFSET]*100, ':b')
    plot([onset_time onset_time], [0 100], ':c')
    plot([offset_time offset_time], [0 100], ':b') % plot mvmt stop point too
    axis([time(start_of_hold_a_index) time(end) 0 100]);
    xlabel('Time (ms)')
    ylabel('% of peak')
    title(sprintf('hold-a time %d  reaction time %d  movement time %d  hold-b time %d', TS.hold_a_time, TS.reaction_time, TS.movement_time, TS.hold_b_time))
    hold off
    drawnow
    pause
end


