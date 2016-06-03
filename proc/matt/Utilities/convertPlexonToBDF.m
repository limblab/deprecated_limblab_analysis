function convertPlexonToBDF(dataPath,convertFolders,rewriteFiles)
% CONVERTCERBEUSTOBDF Converts all Plexon files in a folder to BDF structs
% 
%   This script will automatically load Plexon data and convert it.
% Caveat: it assumes a pretty stereotyped structure. You select a base
% directory and within it there must be folders named "PlexonData" and
% "BDFStructs". You can direct the program to any folder you want within
% PlexonData, including subfolders (e.g. 'MattData\08-11-12').
%
% INPUTS:
%   dataPath:       the base data directory (e.g. 'data:\Jaco_8I1\')
%   convertFolders: folders to convert (e.g. {'08-16-12','08-17-12'}
%                     NOTE: folders should exist in 'dataPath\PlexonData\'
%   reWriteFiles:   flag (0/1) if existing BDFs should be rewritten

%%%%%
% Hard code some defaults for my own development use...
if nargin < 2
    dataPath = 'Y:\Jaco_8I1\'; % Set a base directory
    convertFolders = {'08-26-12'}; % Define what dates to convert data for
end
%%%%%

% By default, don't rewrite files
if nargin < 3
    rewriteFiles = 0;
end

for iFolder = 1:length(convertFolders)
    disp(['Converting Plexon data files from ' convertFolders{iFolder} '...']);
    dirCB = fullfile(dataPath,'\PlexonData\',convertFolders{iFolder},'\');
    dirBDF = fullfile(dataPath,'\BDFStructs\',convertFolders{iFolder},'\');
    
    % If there isn't a BDF directory yet, create it
    if ~exist(dirBDF,'dir');
        mkdir(dirBDF);
    end
    
    % Get list of filenames in the folder
    files = dir(dirCB);
    files = {files.name};
    % We only want the .plx files
    [~,~,fileExts] = cellfun(@(x) fileparts(x),files,'UniformOutput',false);
    files = files(strcmpi(fileExts,'.plx'));
    
    % Loop along the .plx files found
    for iFile = 1:length(files)
        % Build paths for Plexon and BDFs
        CB_FileName = files{iFile};
        CB_FullFileName = fullfile(dirCB,CB_FileName);
        
        BDF_FileName = strrep(CB_FileName,'.plx','.mat');
        BDF_FullFileName = fullfile(dirBDF,BDF_FileName);
        
        % Check if the file has already been converted...
        if ~exist(BDF_FullFileName,'file') || rewriteFiles
            disp(['Converting data file ' CB_FileName '...']);

            out_struct = get_plexon_data(CB_FullFileName,'verbose');
            disp('Done.');
            disp('Saving BDF struct...');
            save(BDF_FullFileName, 'out_struct');        
        else
            disp(['Data file ' CB_FullFileName ' has already been converted. Skipping...']);
        end
    end
end