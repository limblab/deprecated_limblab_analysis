function file_names = merge_spikes(file_path,file_prefix)
% MERGE_SPIKES Merge spikes from separate NEVs for easier sorting.
%   MERGE_SPIKES(file_path,file_prefix) merges all NEVs in file_path,
%   prefixed by file_prefix into one file, named <file_prefix>_spikes.nev,
%   creating a metatags file for later unmerging. Returns file_names, a
%   list of file names to separate merged sorted file into. Also saves file
%   names into mat file.
%   
%   DEPRECATED. JUST USE PROCESSSPIKESFORSORTING
%
%   See also UNMERGE_SPIKES.

% Author: Raeed Chowdhury
% Last Revision: 2014/07/02

% get cell array of file names
files = dir([file_path file_prefix '*.nev']);
file_names = cell(size(files));
for i = 1:length(file_names)
    file_names{i} = files(i).name;
end
save([file_path file_prefix '_filenames.mat'],'file_names');

% merge files and create metatags file
processSpikesForSorting(file_path,file_prefix);