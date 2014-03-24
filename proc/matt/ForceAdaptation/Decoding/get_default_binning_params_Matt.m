function params = get_default_binning_params_Matt(datastruct, varargin)

if nargin > 1
    params = varargin{1};
elseif nargin ==0 || nargin > 2
    warning('Wrong number of arguments');
    evalin('base','help convertBDF2binned');
    params = [];
    return;
else
    params = [];
end

% Find file duration
if isfield(datastruct, 'emg')
    duration = double(datastruct.emg.data(end,1));
elseif isfield(datastruct,'aforce')
    duration = double(datastruct.force.data(end,1));
elseif isfield(datastruct,'pos')
    duration = double(datastruct.pos(end,1)-datastruct.pos(1,1));
else
    fprintf('BDF2BIN: no emg or force field present in input structure\n');
    duration = datastruct.meta.duration;
end

%% Default Parameters (all units are in seconds):
params_defaults = struct(...
    'binsize'       , 0.05,...
    'starttime'     , 0.0,...
    'stoptime'      , 0.0,...
    'EMG_hp'        , 50,...
    'EMG_lp'        , 10,...
    'minFiringRate' , 0.0,...
    'NormData'      , false,...
    'Find_States'   , false,...
    'Unsorted'      , true,...
    'TriKernel'     , false,...
    'sig'           , 0.04,...
    'ArtRemEnable'  , false,...
    'NumChan'       , 10,...
    'TimeWind'      , 0.0005);

%% Update missing values with defaults
all_param_names = fieldnames(params_defaults);
for i=1:numel(all_param_names)
    if ~isfield(params,all_param_names(i))
        params.(all_param_names{i}) = params_defaults.(all_param_names{i});
    end
end

%% Validation of time parameters

if (params.starttime <0.0 || params.starttime > duration-params.binsize) %making sure the start time is valid, must be at least 10 secs before eof    
    fprintf('Start time must be between %.1f and %.1f seconds\n',0.0,duration-params.binsize); %
    fprintf('Start time set to beginning of data (0.0 seconds)\n');
    params.starttime =  0.0;
else
    fprintf('Start time set to %.1f seconds\n',params.starttime);
end
if params.stoptime ==0
    params.stoptime = duration - mod(duration,params.binsize);
    fprintf('Stop time set to end of data (%.2f seconds)\n', params.stoptime);
elseif (params.stoptime <binsize || params.stoptime > duration)
    fprintf(['Stop time must be at least one bin after start time and cannot be higher than file duration (%.1f)\n' ...
                 '"Stop time" set to last multiple of binsize (%.2f seconds).\n'],duration,duration-mod(duration,params.binsize));
    params.stoptime=duration-mod(duration,params.binsize);
else 
    fsprintf('Stop time set to %.2f seconds\n',params.stoptime);
end

% if mod(1,binsize)
%     disp('Please choose a binsize that is a factor of 1');
%     disp('data conversion aborted');
%     params = [];    
%     return
% end

