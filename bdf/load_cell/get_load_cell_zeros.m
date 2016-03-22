function zero_vals = get_load_cell_zeros(filename)
% GET_LOAD_CELL_ZEROS returns the 6 load cell offset values to be used in
% calculation of load cell force output in calc_from_raw_script. Use only
% on data file collected while the handle is not being used. This function
% only works for data collected with the Cerebus system.
%   Inputs -
%       filename - full path and file prefix of a file collected while
%       handle is still

% Check file
if(isempty(dir([filename '*'])))
    error('File does not exist');
end

% Load in NEVNSx struct
[filepath,fileprefix,~] = fileparts(filename);
if ~strcmp(filepath(end),filesep)
    filepath(end+1) = filesep;
end
NEVNSx = cerebus2NEVNSx(filepath,fileprefix);

% Assemble info about analog channels
NSx_info.NSx_labels = {};
NSx_info.NSx_sampling = [];
NSx_info.NSx_idx = [];

if ~isempty(NEVNSx.NS1)
    if strcmpi(NEVNSx.NS1.MetaTags.FileTypeID, 'NEURALSG') %%%% SOMEWHAT HACKY in case of older file version
        labels = strcat(repmat({'analogNS1_'},NEVNSx.NS1.MetaTags.ChannelCount,1),strtrim(cellstr(num2str((1:NEVNSx.NS1.MetaTags.ChannelCount)'))))';
        NSx_info.NSx_labels = [NSx_info.NSx_labels{:} labels]';
        NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(500,1,NEVNSx.NS1.MetaTags.ChannelCount)];
        NSx_info.NSx_idx = [NSx_info.NSx_idx 1:NEVNSx.NS1.MetaTags.ChannelCount];
    elseif strcmpi(NEVNSx.NS1.MetaTags.FileTypeID, 'NEURALCD') % newer file version
        NSx_info.NSx_labels = {NSx_info.NSx_labels{:} NEVNSx.NS1.ElectrodesInfo.Label}';
        NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(500,1,size(NEVNSx.NS1.ElectrodesInfo,2))];
        NSx_info.NSx_idx = [NSx_info.NSx_idx 1:size(NEVNSx.NS1.ElectrodesInfo,2)];
    end
end
if ~isempty(NEVNSx.NS2)
    if strcmpi(NEVNSx.NS2.MetaTags.FileTypeID, 'NEURALSG') %%%% SOMEWHAT HACKY in case of older file version
        labels = strcat(repmat({'analogNS2_'},NEVNSx.NS2.MetaTags.ChannelCount,1),strtrim(cellstr(num2str((1:NEVNSx.NS2.MetaTags.ChannelCount)'))))';
        NSx_info.NSx_labels = [NSx_info.NSx_labels{:} labels]';
        NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(1000,1,NEVNSx.NS2.MetaTags.ChannelCount)];
        NSx_info.NSx_idx = [NSx_info.NSx_idx 1:NEVNSx.NS2.MetaTags.ChannelCount];
    elseif strcmpi(NEVNSx.NS2.MetaTags.FileTypeID, 'NEURALCD') % newer file version
        NSx_info.NSx_labels = {NSx_info.NSx_labels{:} NEVNSx.NS2.ElectrodesInfo.Label}';
        NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(1000,1,size(NEVNSx.NS2.ElectrodesInfo,2))];
        NSx_info.NSx_idx = [NSx_info.NSx_idx 1:size(NEVNSx.NS2.ElectrodesInfo,2)];
    end
end
if ~isempty(NEVNSx.NS3)
    if strcmpi(NEVNSx.NS3.MetaTags.FileTypeID, 'NEURALSG')
        labels = strcat(repmat({'analogNS3_'},NEVNSx.NS3.MetaTags.ChannelCount,1),strtrim(cellstr(num2str((1:NEVNSx.NS3.MetaTags.ChannelCount)'))))';
        NSx_info.NSx_labels = [NSx_info.NSx_labels{:} labels]';
        NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(2000,1,NEVNSx.NS3.MetaTags.ChannelCount)];
        NSx_info.NSx_idx = [NSx_info.NSx_idx 1:NEVNSx.NS3.MetaTags.ChannelCount];
    elseif strcmpi(NEVNSx.NS3.MetaTags.FileTypeID, 'NEURALCD')
        NSx_info.NSx_labels = {NSx_info.NSx_labels{:} NEVNSx.NS3.ElectrodesInfo.Label};
        NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(2000,1,size(NEVNSx.NS3.ElectrodesInfo,2))];
        NSx_info.NSx_idx = [NSx_info.NSx_idx 1:size(NEVNSx.NS3.ElectrodesInfo,2)];
    end
end
if ~isempty(NEVNSx.NS4)
    if strcmpi(NEVNSx.NS4.MetaTags.FileTypeID, 'NEURALSG')
        labels = strcat(repmat({'analogNS4_'},NEVNSx.NS4.MetaTags.ChannelCount,1),strtrim(cellstr(num2str((1:NEVNSx.NS4.MetaTags.ChannelCount)'))))';
        NSx_info.NSx_labels = [NSx_info.NSx_labels{:} labels]';
        NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(10000,1,NEVNSx.NS4.MetaTags.ChannelCount)];
        NSx_info.NSx_idx = [NSx_info.NSx_idx 1:NEVNSx.NS4.MetaTags.ChannelCount];
    elseif strcmpi(NEVNSx.NS4.MetaTags.FileTypeID, 'NEURALCD')
        NSx_info.NSx_labels = {NSx_info.NSx_labels{:} NEVNSx.NS4.ElectrodesInfo.Label}';
        NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(10000,1,size(NEVNSx.NS4.ElectrodesInfo,2))];
        NSx_info.NSx_idx = [NSx_info.NSx_idx 1:size(NEVNSx.NS4.ElectrodesInfo,2)];
    end
end
if ~isempty(NEVNSx.NS5)
    if strcmpi(NEVNSx.NS5.MetaTags.FileTypeID, 'NEURALSG')
        labels = strcat(repmat({'analogNS5_'},NEVNSx.NS5.MetaTags.ChannelCount,1),strtrim(cellstr(num2str((1:NEVNSx.NS5.MetaTags.ChannelCount)'))))';
        NSx_info.NSx_labels = [NSx_info.NSx_labels{:} labels]';
        NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(30000,1,NEVNSx.NS5.MetaTags.ChannelCount)];
        NSx_info.NSx_idx = [NSx_info.NSx_idx 1:NEVNSx.NS5.MetaTags.ChannelCount];
    elseif strcmpi(NEVNSx.NS5.MetaTags.FileTypeID, 'NEURALCD')
        NSx_info.NSx_labels = {NSx_info.NSx_labels{:} NEVNSx.NS5.ElectrodesInfo.Label}';
        NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(30000,1,size(NEVNSx.NS5.ElectrodesInfo,2))];
        NSx_info.NSx_idx = [NSx_info.NSx_idx 1:size(NEVNSx.NS5.ElectrodesInfo,2)];
    end
end

NSx_info.NSx_labels = NSx_info.NSx_labels(~cellfun('isempty',NSx_info.NSx_labels));
NSx_info.NSx_labels = deblank(NSx_info.NSx_labels);

% Get force offsets from NSx
if ( ~isempty(NSx_info.NSx_labels))
    force_channels = find( strncmpi(NSx_info.NSx_labels, 'ForceHandle', 11) );
end
if (exist('force_channels','var') && length(force_channels)==6)
    % extract force channels
    raw_force_cell = cell(1, 6);
    time_vector = cell(1,6);
    adfreq = 0;
    last_analog_time = inf;
    for c = 1:6
        channame = sprintf('ForceHandle%d', c);
        achan_index=find(~cellfun('isempty',strfind(lower(NSx_info.NSx_labels),lower(['ForceHandle',num2str(c)]))));
        if isempty(achan_index)
            error('calc_from_raw:ChannelNotFound',['Could not find a force channel named: ', channame, '. Continuing leaving force for that column empty'])
        elseif length(achan_index)>1
            warning('calc_from_raw:ExtraChannelFound',['Found extra channels matching the string: ', channame, '. Continuing leaving force for that column empty'])
            a_data = [];
        else
            if NSx_info.NSx_sampling(achan_index)==500
                a_data = single(NEVNSx.NS1.Data(NSx_info.NSx_idx(achan_index),:))';
            elseif NSx_info.NSx_sampling(achan_index)==1000
                a_data = single(NEVNSx.NS2.Data(NSx_info.NSx_idx(achan_index),:))';
            elseif NSx_info.NSx_sampling(achan_index)==2000
                a_data = single(NEVNSx.NS3.Data(NSx_info.NSx_idx(achan_index),:))';
            elseif NSx_info.NSx_sampling(achan_index)==10000
                a_data = single(NEVNSx.NS4.Data(NSx_info.NSx_idx(achan_index),:))';
            elseif NSx_info.NSx_sampling(achan_index)==30000
                a_data = single(NEVNSx.NS5.Data(NSx_info.NSx_idx(achan_index),:))';
            end
        end
        [b,a] = butter(4, 200/NSx_info.NSx_sampling(achan_index));
        a_data = filtfilt(b, a, double(a_data));
        raw_force_cell{c} = a_data';
        time_vector{c} = (0:length(a_data)-1)' / NSx_info.NSx_sampling(achan_index);
        
        % find max sampling frequency
        adfreq = max(NSx_info.NSx_sampling(achan_index),adfreq);
        last_analog_time = min(length(a_data)/NSx_info.NSx_sampling(achan_index),last_analog_time);
    end
    
    % compile load cell outputs into one array with one sampling frequency
    %   extract max sampling time vector
    adfreq = max(NSx_info.NSx_sampling);
    start_time = 1;
    stop_time = floor(last_analog_time)-1;
    analog_time_base = start_time:1/adfreq:stop_time;
    raw_force = zeros(length(analog_time_base),6);
    for c = 1:6
        raw_force(:,c) = interp1(time_vector{c},raw_force_cell{c},analog_time_base);
    end
    
    % Calculate force offsets
    zero_vals = mean(raw_force);

else
    error('BDF:noForceSignal','No force handle signal found because get_load_cell_zeros did not find 6 channels named ''ForceHandle*''');
end