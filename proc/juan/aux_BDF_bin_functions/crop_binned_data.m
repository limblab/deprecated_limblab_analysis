%
% Crop BDFs between certain specific times t_i and t_f, or between two
% words w_i and w_f
%
%   cropped_binned_data = crop_binned_data( binned_data, cropping_times )
%
%
% Input (optional):
%   binned_data             : binned_data struct
%   cropping_time           : N x 2 matrix, where N is the number of
%                               intervals (e.g., defined by start and
%                               trial_end words), OR N x 1 matrix, where
%                               each element is the index of a bin to keep
%
% Output:
%   cropped_binned_data     : cropped binned_data struct
%
%
% NOTE: the current version does not crop the words or the targets !!!!
%


function cropped_binned_data = crop_binned_data( binned_data, cropping_times )


% see if we passed a vector with the intervals for cropping (it would be a
% 2-by-N size matrix)
if size(cropping_times,2) == 2
    % get bin size
    bin_size                = mean(diff(binned_data.timeframe));

    % convert word times to bin numbers
    cropping_times_bin      = zeros(size(cropping_times,1),2);
    cropping_times_bin(:,1) = ceil(cropping_times(:,1)/bin_size);
    cropping_times_bin(:,2) = floor(cropping_times(:,2)/bin_size);

    % create a matrix with the indexes of the bins to keep
    indx_keep               = [];
    for i = 1:size(cropping_times_bin,1)
        indx_keep           = [indx_keep, cropping_times_bin(i,1):cropping_times_bin(i,2)];
    end
% or an N-by 1 matrix with the bins to keep
else
    % check that we have passed integers (indexes of bins to cut) rather
    % than messing up with the format
    if ceil(cropping_times) ~= floor(cropping_times)
        error('cropping times are not specified in the right format')
    end
    % otherwise use this vector for cropping
    indx_keep           = cropping_times;
end
    
    
% crop the binned file
binned_data.timeframe   = binned_data.timeframe(indx_keep);

binned_data.meta.processed_with{size(binned_data.meta.processed_with,1)+1,1} = 'crop_binned_data';
binned_data.meta.processed_with{size(binned_data.meta.processed_with,1)+1,2} = datestr(now,'dd-mmm-yyyy');

binned_data.emgdatabin  = binned_data.emgdatabin(indx_keep,:);

if isfield(binned_data,'forcedatabin')
    if ~isempty(binned_data.forcedatabin)
        binned_data.forcedatabin = binned_data.forcedatabin(indx_keep,:);
    end
end

binned_data.spikeratedata = binned_data.spikeratedata(indx_keep,:);

if isfield(binned_data,'cursorposbin')
    if ~isempty(binned_data.cursorposbin)
        binned_data.cursorposbin = binned_data.cursorposbin(indx_keep,:);
    end
end
if ~isempty(binned_data.velocbin)
    binned_data.velocbin = binned_data.velocbin(indx_keep,:);
end
if ~isempty(binned_data.accelbin)
    binned_data.accelbin = binned_data.accelbin(indx_keep,:);
end

if isfield(binned_data,'smoothedspikerate')
    binned_data.smoothedspikerate = binned_data.smoothedspikerate(indx_keep,:);
end

% return variable
cropped_binned_data     = binned_data;