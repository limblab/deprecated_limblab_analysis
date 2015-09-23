%
% Function to combine a BDF and a binned file with the same prefix (i.e.
% originating from the same) into a single file. This file will be named
% "prefix_bin_BDF_lfp.mat".
%
%   [BDF, BINNEDDATA] = MERGE_BIN_LFP_BDF(FILEPATH, FILEPREFIX)

%

function [BDF, binnedData] = merge_bin_bdf_lfp( file_path, file_prefix )


% add a file separator at the end of the path, if it's not there
if ~strcmp(file_path(end),filesep)
   file_path        = [file_path, filesep]; 
end

% load both files
bin_file_name       = [file_prefix '_bin.mat'];
bdf_file_name       = [file_prefix '_BDF.mat'];

load([file_path, bin_file_name]);
load([file_path, bdf_file_name]);

% Re-arrange the BDF 
BDF                 = rearrange_bdf_lfp(BDF);  %#ok<NODEF>

% Save BDF and binnedData into a file
save([file_path, file_prefix, '_bin_BDF_lfp.mat'],'BDF','binnedData');
