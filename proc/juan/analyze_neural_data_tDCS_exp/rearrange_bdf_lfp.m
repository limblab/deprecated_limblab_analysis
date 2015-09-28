%
% Function to reorganize a BDF that contains LFPs. It creates an LFP field
% that follows the samestructure as the force or EMG fields.  
%
%   BDF = REARRANGE_BDF_LFP( BDF_Orig )
%

function BDF = rearrange_bdf_lfp( BDF_orig )


BDF                 = BDF_orig;

% remove some useless fields
BDF.meta            = rmfield(BDF.meta,'FileSepTime');
BDF                 = rmfield(BDF,'good_kin_data');

% check that all the analog channels are LFPs
if ~isempty( find( ~strncmp(BDF_orig.raw.analog.channels,'elec',4), 1 ) )
    error('There are some unexpected, not LFP analog channels')
end

% check if all the LFP channels were sampled at the same frequency. If not
% the code will quit 
if numel(unique(BDF_orig.raw.analog.adfreq)) > 1
    error('Not all the LFP channels were sampled at the same frequency')
end

% store the channel names
BDF.lfp.lfpnames    = BDF_orig.raw.analog.channels;

% store the LFP sampling frequency
BDF.lfp.lfpfreq     = BDF_orig.raw.analog.adfreq(1);

% create a matrix that will contain the data
BDF.lfp.data        = cell2mat(BDF_orig.raw.analog.data);
% add a time column
% lfp_time            = single( 0:1/BDF.lfp.lfpfreq:(size(BDF.lfp.data,1)-1)/BDF.lfp.lfpfreq );
lfp_time            = single( linspace(0,(size(BDF.lfp.data,1)-1)/BDF.lfp.lfpfreq,size(BDF.lfp.data,1)) );
BDF.lfp.data        = [lfp_time', BDF.lfp.data];


% clear the raw channels that contain the LFPs, since they are no longer
% necessary
raw_ch              = fieldnames(BDF.raw.analog);
for i = 1:size(raw_ch,1)
    BDF.raw.analog.(raw_ch{i}) = [];
end

% reorder the fields so it makes more sense
BDF                 = orderfields(BDF,[1 2 3 4 5 10 6 7 8 9]);

end

