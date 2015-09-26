%
% Function to combine a BDF and a binned file with the same name (i.e.
% originating from the same NEV file) into a single file. This new file
% will be named "file_name_bin_BDF_lfp.mat".  
%
%   [BDF, binnedData] = MERGE_BIN_LFP_BDF(file_path, file_name)
%

function [BDF, binnedData] = merge_bin_bdf_lfp( file_path, file_name )


% add a file separator at the end of the path, if it's not there
if ~strcmp(file_path(end),filesep)
   file_path        = [file_path, filesep]; 
end

% load both files
bin_file_name       = [file_name '_bin.mat'];
bdf_file_name       = [file_name '_BDF.mat'];

load([file_path, bin_file_name]);
load([file_path, bdf_file_name]);

% Re-arrange the BDF 
BDF                 = rearrange_bdf_lfp(BDF);  %#ok<NODEF>

% Save BDF and binnedData into a file
save([file_path, file_name, '_bin_BDF_lfp.mat'],'BDF','binnedData');
