function convertDataToBDF(baseDirectory,convertFolders,varargin)
% CONVERTDATATOBDF Converts all neural data files in a folder to BDF struct
%
%   This script will automatically load neural data and convert it.
% Works with Cerebus (.nev) and Plexon (.plx) files. You select a base
% directory (e.g. a monkey folder on the server) and then a cell array of
% folders (e.g. recording days) containing data files to convert to BDF.
% You can direct the program to any folder you want within the base
% directory, including subfolders (e.g. 'CerebusData\08-11-12').
%
% INPUTS:
%   baseDirectory: (string) the base data directory (e.g. 'z:\Jaco_8I1\')
%   convertFolders: (string or cell array of strings) folders to convert
%       (e.g. {'CerebusData\08-16-12','CerebusData\08-17-12'} )
%   varargin: specify more parameters as needed. Use a format
%               ...,'parameter_name',parameter_value,...
%       Options:
%           'rewrite': (boolean) rewrite any existing BDF files?
%           'haskin': (boolean) is there encoder data in the file?
%           'bdffolder': (string) name of bdf folder (default: 'BDFStructs')
%
% NOTES:
%   This program will create a folder called "BDFStructs" inside of the
% base directory and put the .mat files for each convertFolders there.
%
%   If the file only includes neural data (e.g. a second cerebus in a dual
% recording setup) then "get_cerebus_data" function needs a 'nokin' input
% so set 'haskin' to be false and this function will take care of it
%
% EXAMPLES:
%   Convert a folder with cerebus files (called \08-21-2012\) into BDFs
%       convertDataToBDF('Z:\Jaco_8I1\CerebusData\','08-21-2012');
%       -or- convertDataToBDF('Z:\Jaco_8I1\CerebusData\08-21-2012','');
%
%   Convert multiple folders of data
%       convertDataToBDF('Z:\MrT_9I4\M1\CerebusData\',{'06-21-2013','06-24-2013'});
%
%   Convert files from a dual cerebus, where only one gets the encoder data
%       convertDataToBDF('Z:\MrT_9I4\M1\CerebusData\',{'06-21-2013','06-24-2013'},'haskin',true);
%       convertDataToBDF('Z:\MrT_9I4\PMd\CerebusData\',{'06-21-2013','06-24-2013'},'haskin',false);
%%%%%%
% written by Matt Perich; last updated July 2013
%%%%%

if nargin < 2
    % If only baseDirectory is provided, assume that is desired folder
    convertFolders = '';
end

%%%%
% IF USING DATA WITHOUT KINEMATICS ETC (ie second cerebus in dual cerebus
% system) MUST SPECIFY 'nokin' ARGUMENT FOR GET_CEREBUS_DATA BELOW
%%%

%%%%% Define parameters
% set defaults
rewriteFiles = 0; % By default, don't rewrite files
hasKin = 1; % by default, assume there is encoder data
bdfFolderName = 'BDFStructs'; %name of folder to put BDFs in
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'rewrite'
            rewriteFiles = varargin{i+1};
        case 'haskin'
            hasKin = varargin{i+1};
        case 'bdffolder'
            bdfFolderName = varargin{i+1};
    end
end
%%%%%

% Check to see if convertFolders is a cell and make it one if not
if ~iscell(convertFolders)
    convertFolders = {convertFolders};
end

% Loop along the provided folders to convert
for iFolder = 1:length(convertFolders)
    disp(['Converting neural data files from ' convertFolders{iFolder} '...']);
    dirCB = fullfile(baseDirectory,convertFolders{iFolder},filesep);
    dirBDF = fullfile(baseDirectory,[filesep bdfFolderName filesep],convertFolders{iFolder},filesep);
    
    % If there isn't a BDF directory yet, create it
    if ~exist(dirBDF,'dir');
        mkdir(dirBDF);
    end
    
    % Get list of filenames in the folder
    files = dir(dirCB);
    files = {files.name};
    % We only want the .nev or .plx files
    [~,~,fileExts] = cellfun(@(x) fileparts(x),files,'UniformOutput',false);
    fileInds = strcmpi(fileExts,'.nev') | strcmpi(fileExts,'.plx');
    files = files(fileInds);
    
    % Loop along the .nev files found
    for iFile = 1:length(files)
        % Build paths for Cerebus/Plexon and BDFs
        CB_FileName = files{iFile};
        CB_FullFileName = fullfile(dirCB,CB_FileName);
        
        % is it .nev or .plx?
        [~,~,fileExt] = fileparts(CB_FileName);
        
        BDF_FileName = strrep(CB_FileName,fileExt,'.mat');
        BDF_FullFileName = fullfile(dirBDF,BDF_FileName);
        
        % Check if the file has already been converted...
        if ~exist(BDF_FullFileName,'file') || rewriteFiles
            disp(['Converting data file ' CB_FileName '...']);
            switch lower(fileExt)
                case '.nev'
                    % IF USING DATA WITHOUT ENCODER MUST SPECIFY 'nokin' ARGUMENT FOR GET_CEREBUS_DATA
                    if hasKin
                        out_struct = get_cerebus_data(CB_FullFileName,'verbose');
                    else
                        out_struct = get_cerebus_data(CB_FullFileName,'verbose','nokin');
                    end
                case '.plx'
                    % IF USING DATA WITHOUT ENCODER MUST SPECIFY 'nokin' ARGUMENT FOR GET_PLEXON_DATA
                    if hasKin
                        out_struct = get_plexon_data(CB_FullFileName,'verbose');
                    else
                        out_struct = get_plexon_data(CB_FullFileName,'verbose','nokin');
                    end
            end
            
            disp('Done.');
            disp(['Saving BDF struct to ' BDF_FullFileName '...']);
            save(BDF_FullFileName, 'out_struct');
        else
            disp(['Data file ' CB_FullFileName ' has already been converted. Skipping...']);
        end
    end
end