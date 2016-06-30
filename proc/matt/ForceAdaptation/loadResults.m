function varargout = loadResults(root_dir,sessionInfo,type,subdata,varargin)
% Centralizing the data loading so I can change filenames, etc, easily if
% necessary
%
% root_dir is root directory up to where the monkey subfolders are
%
% sessionInfo is 1x4 cell array with:
%   { 'monkey', 'date', 'condition', 'task' }
%
% type is string with what to load:
%   'data' loads processed data
%          varargin: ...,'epoch')
%   'tuning' loads tuning and classification info if it exists
%          varargin: ...,'array','parameterSet','method','window')
%   'tracking' loads tracking data
%          varargin: nothing
%   'adaptation' loads behavioral adaptation results
%          varargin: nothing
%
% subdata is a string or cell array of strings specifying which sub-fields
% to load if you don't want the whole file. Pass empty array otherwise
%   e.g. 'tuning' will have fields for both tuning and classes
% you can have multiple subdata as cell array, but you must request the
% same number of outputs when you call loadResults.
%   e.g. [tuning, classes] = loadData('etc',{etc},'tuning',{'tuning','classes'},etc...);

pdName = 'Processed'; % name of processed data subfolder

if nargin < 4
    subdata  = [];
    varargin = {};
end

monkey = sessionInfo{1};
date   = sessionInfo{2};
cond   = sessionInfo{3};
task   = sessionInfo{4};

if ~isempty(subdata)
    if ~iscell(subdata)
        subdata = {subdata};
    end
    varargout = cell(1,length(subdata));
else
    varargout = cell(1,1);
end

% check if root_dir has the monkey name included (it can go either way)
if strcmpi(root_dir(end),filesep)
    root_dir(end) = [];
end
if length(root_dir) < length(monkey)+1
    root_dir = fullfile(root_dir,monkey);
elseif ~strcmpi(root_dir(end-length(monkey)+1:end),monkey)
    root_dir = fullfile(root_dir,monkey);
end

root_dir = fullfile(root_dir,pdName);

% load data
switch lower(type)
    case 'data'
        if length(varargin) ~= 1
            error('Did not receive the correct extra info for data...');
        end
        epoch    = varargin{1};
        dataFile = fullfile(root_dir,date,[task '_' cond '_' epoch '_' date '.mat']);
    case 'tuning'
        if length(varargin) ~= 4
            error('Did not receive the correct extra info for tuning...');
        end
        array    = varargin{1};
        name     = varargin{2};
        method   = varargin{3};
        window   = varargin{4};
        dataFile = fullfile(root_dir,date,[array '_tuning'],[task '_' cond '_' name '_' method '_' window '_' date '.mat']);
    case 'tracking'
        if ~isempty(varargin)
            error('Did not receive the correct extra info for tracking...');
        end
        dataFile = fullfile(root_dir,date,[task '_' cond '_tracking_' date '.mat']);
    case 'adaptation'
        if ~isempty(varargin)
            error('Did not receive the correct extra info for adaptation...');
        end
        dataFile = fullfile(root_dir,date,[task '_' cond '_adaptation_' date '.mat']);
end

% assign the outputs
if exist(dataFile,'file')
    if isempty(subdata)
        varargout{1} = load(dataFile);
        i = 1;
    else
        if nargout == 1 && length(subdata)==1 % probably want everything returned as a struct
            load(dataFile,subdata{1});
            eval(['temp.(subdata{1}) = ' subdata{1} ';']);
            varargout{1} = temp.(subdata{1});
            i = 1;
        elseif nargout == length(subdata) % return each requested item as its own variable
            for i = 1:length(subdata)
                load(dataFile,subdata{i});
                eval(['varargout{i} = ' subdata{i} ';']);
            end
        else
            error('Number of requested outputs does not match subdata request...');
        end
    end
else
    disp('LoadResults Warning: File does not exist.');
    varargout{1} = NaN;
    i = 1;
end

% output the file path if the person wants it
varargout{i+1} = dataFile;