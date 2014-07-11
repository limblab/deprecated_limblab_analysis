function bdf_cell = unmerge_spikes(file_path,file_prefix,file_names)
% UNMERGE_SPIKES Separate merged spikes (from MERGE_SPIKES).
%   UNMERGE_SPIKES(file_path,file_prefix,file_names) separates a file
%   called <file_prefix>_spikes-s.nev into a list of files using file_names
%   (returned from MERGE_SPIKES). Requires that metatags file is in
%   file_path. Returns a cell array containing one bdf per separated file.
%
%   See also MERGE_SPIKES.

% Author: Raeed Chowdhury
% Last Revision: 2014/07/09

% Run processSpiesForSorting again to separate sorted spikes into their
% original files.
mergingStatus = processSpikesForSorting(file_path,file_prefix);
if strcmp(mergingStatus,'processed')
	% If everything went well, create bdfs for your files (you might
	% want to split them up by task.)
	bdf_cell = cell(size(file_names));
	for i = 1:length(file_names)
		bdf_cell{i} = get_nev_mat_data([file_path file_names{i}],3);
	end
end