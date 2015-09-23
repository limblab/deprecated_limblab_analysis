%
% Function to reorganize an out_struct with LFP field
%

function out_struct = rearrange_bdf_lfp( out_struct_orig )


out_struct          = out_struct_orig;

% remove some useless fields
out_struct.meta     = rmfield(out_struct.meta,'FileSepTime');
out_struct          = rmfield(out_struct,'good_kin_data');

% check that all the analog channels are LFPs
if ~isempty( find( ~strncmp(out_struct_orig.raw.analog.channels,'elec',4), 1 ) )
    error('There are some unexpected, not LFP analog channels')
end

% check if all the LFP channels were sampled at the same frequency. If not
% the code will quit 
if numel(unique(out_struct_orig.raw.analog.adfreq)) > 1
    error('Not all the LFP channels were sampled at the same frequency')
end

% store the LFP sampling frequency
out_struct.lfp.lfpfreq  = out_struct_orig.raw.analog.adfreq(1);

% store the channel names
out_struct.lfp.lfpnames = out_struct_orig.raw.analog.channels;

% create a matrix that will contain the data
out_struct.lfp.data     = cell2mat(out_struct_orig.raw.analog.data);


% clear the raw channels that contain the LFPs, since they are no longer
% necessary
raw_ch              = fieldnames(out_struct.raw.analog);
for i = 1:size(raw_ch,1)
    out_struct.raw.analog.(raw_ch{i}) = [];
end

% reorder the fields so it makes more sense
out_struct          = orderfields(out_struct,[1 2 3 4 5 10 6 7 8 9]);

end

