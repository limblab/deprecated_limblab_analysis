function s = bin_spikes(bdf_cell,ts,channel,unit)
% BIN_SPIKES Bins spikes into bins of length ts, given set of BDFs
%   Given cell array of BDF data structures, BIN_SPIKES counts the number
%   of spikes that occur in ts millisecond bins and concatenates spike
%   counts from across BDFs. Result is returned in s.

% Author: Raeed Chowdhury
% Date Revised: 2014/07/02

% check if bdf_cell is cell array or just bdf
if ~iscell(bdf_cell)
    if isstruct(bdf_cell)
        bdf_cell = {bdf_cell};
    else
        error('bin_spikes:invalid_input','First input must be a BDF or cell array of BDFs')
    end
end

% loop over all BDFs in cell array
s = [];
for i = 1:length(bdf_cell)
    temp_bdf = bdf_cell{i};
    
    vt = temp_bdf.vel(:,1);
    t = vt(1):ts/1000:vt(end);
    
    spike_times = get_unit(temp_bdf,channel,unit);
    spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
    
    s = [s train2bins(spike_times, t)];
end