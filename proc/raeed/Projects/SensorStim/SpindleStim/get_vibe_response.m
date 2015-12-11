function [vibe_avg] = get_vibe_response(units,vibe_trace,which_units)
% GET_VIBE_RESPONSE finds average firing rates of neurons during vibration
% and baseline. BEST USED WITH CONSTANT FREQUENCY VIBRATION
%   Inputs:
%       units - struct array of units from BDF
%       vibe_trace - n x 2 matrix of vibration signal (first column is time
%       vector, second column is trace)
%       which_units - list of indices into units variable to examine
%   Outputs:
%       vibe_avg - struct array with id, on_avg (average firing rate during
%       vibration), off_avg (average firing rate without vibration), and
%       on_rate (firing rates during each vibration epoch)
%   Author: Raeed Chowdhury
%   Date: 12/11/2015

% find vibration onset and offset
samp_rate = 1/mean(diff(vibe_trace(:,1)));
vibe_rect = abs(vibe_trace(:,2));
[b,a] = butter(3,25/(samp_rate/2)); % 25 Hz low pass filter
vibe_filt = filtfilt(b,a,double(vibe_rect)); % filter for envelope
vibe_thresh = (max(vibe_filt)+2*min(vibe_filt))/3;
vibe_on = vibe_rect>vibe_thresh;
vibe_trans = [0;diff(vibe_on(:))];
vibe_onset = vibe_trace((vibe_trans>0),1);
vibe_offset = vibe_trace((vibe_trans<0),1);

vibe_time = sum(vibe_on)/samp_rate;
off_time = sum(~vibe_on)/samp_rate;

if(length(vibe_onset)>length(vibe_offset) || isempty(vibe_onset))
    error('get_vibe_response:bad_vibe_trace','Vibration trace is irregular; verify signal')
end

% loop through units
vibe_avg = struct('id',{},'on_avg',{},'off_avg',{}); % should make this table instead of struct
for i = 1:length(which_units)
    vibe_avg(i).id = units(which_units(i)).id;
    
    ts = units(which_units(i)).ts;
    
    on_spike_sum = 0; % initialize to 0
    
    for j = 1:length(vibe_onset)
        on_spikes = sum(ts>vibe_onset(j) & ts<vibe_offset(j));
        on_spike_sum = on_spike_sum + on_spikes; % add spikes that occur between vibration onset and offset
        on_rate(j) = on_spikes/(vibe_offset(j)-vibe_onset(j));
    end
    
    off_spike_sum = length(ts)-on_spike_sum; % rest of spikes must be off-vibration
    
    vibe_avg(i).on_avg = on_spike_sum/vibe_time;
    vibe_avg(i).off_avg = off_spike_sum/off_time;
    vibe_avg(i).on_rate = on_rate;
end