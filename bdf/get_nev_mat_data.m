function out_struct = get_nev_mat_data(varargin)
% GET_NEV_MAT_DATA Generates a BDF struct from NEVNSx structure or from
% .nev and .nsx files. If you want to sort the neurons in your files,
% use the "processSpikesForSorting.m" script. To see an example of how it is used,
% check out "mergeUnmergeSpikes.m".
%
%   OUT_STRUCT = GET_NEV_MAT_DATA(NEVNSx) returns a BDF populated by the
%   structure NEVNSx.
%   OUT_STRUCT = GET_NEV_MAT_DATA([filepath fileprefix]) returns a BDF 
%   populated by concatenating data from the files in [filepath fileprefix]
% 
%   OUT_STRUCT = GET_NEV_MAT_DATA(NEVNSx, VERBOSE) returns a BDF
%   populated by the structure NEVNSx and outputs status information acording
%   to the optional parameter VERBOSE.
%       VERBOSE - 1 => prints status info
%                 0 => prints nothing (default)

% $Id:

%% Initial setup
    
    % make sure LaTeX is turned off and save the old state so we can turn
    % it back on at the end
    defaulttextinterpreter = get(0, 'defaulttextinterpreter'); 
    set(0, 'defaulttextinterpreter', 'none');
    
    %initial setup
    opts=struct('verbose',0,'progbar',0,'force',1,'kin',1,'labnum',1,'eye',0,'rothandle',0,'ignore_jumps',0,'ignore_filecat',0,'delete_raw',0); %default to lab 1, no force, no eye
   
    % Parse arguments
    if (nargin == 1)
        fileOrStruct = varargin{1};
    else
        fileOrStruct = varargin{1};
        for i = 2:nargin
            opt_str = char(varargin{i} + ...
                (varargin{i} >= 65 & varargin{i} <= 90) * 32); % convert to lower case            
            if strcmp(opt_str, 'verbose')
                opts.verbose = 1;
            elseif strcmp(opt_str, 'progbar')
                opts.progbar = 1;
            elseif strcmp(opt_str, 'noeye')
                opts.eye = 0;
            elseif strcmp(opt_str, 'noforce')
                opts.force = 0;
            elseif strcmp(opt_str, 'nokin')
                opts.kin = 0;
                opts.force = 0;
            elseif strcmp(opt_str, 'rothandle')
                opts.rothandle = varargin{i+1};
            elseif strcmp(opt_str, 'ignore_jumps')
                opts.ignore_jumps=1;
            elseif strcmp(opt_str, 'ignore_filecat')
                opts.ignore_filecat=1;
            elseif strcmp(opt_str, 'delete_raw')
                opts.delete_raw=1;
            elseif isnumeric(varargin{i})
                opts.labnum=varargin{i};    %Allow entering of the lab number               
            else 
                error('Unrecognized option: %s', opt_str);
            end
        end
    end

    progress = 0;
    if (opts.verbose == 1)
        h = waitbar(progress, 'Opening NEVNSx');
    else
        h = 0;
    end
    
    if isstruct(fileOrStruct)
        NEVNSx = fileOrStruct;
    else
        [filepath,fileprefix,~] = fileparts(fileOrStruct);
        if ~strcmp(filepath(end),filesep)
            filepath(end+1) = filesep;
        end
        NEVNSx = cerebus2NEVNSx(filepath,fileprefix);
    end
    clear fileOrStruct

   
%% Data Information
    progress = 1/8;
    if opts.verbose
        waitbar(progress,h,'Extracting Meta Information');
    end

 % Get general file info (EntityCount, TimeStampResolution and TimeSpan) 
    DateTime = [int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(2)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(4)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(1)) ...
        ' ' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(5)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(6)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(7)) '.' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(8))];

    out_struct.meta = struct('filename', NEVNSx.NEV.MetaTags.Filename, 'datetime', ...
        DateTime,'duration', NEVNSx.NEV.MetaTags.DataDurationSec, 'lab', opts.labnum, ...
        'bdf_info', ['converted with get_nev_mat_data on ' date],'processed_with',[]);

    if ispc
        [~,hostname]=system('hostname');
        hostname=strtrim(hostname);
        username=strtrim(getenv('UserName'));
    else
        hostname=[];
        username=[];
    end
    out_struct.meta.processed_with={'function','date','computer name','user name';'get_nev_mat_data',date,hostname,username};
    
    if isfield(NEVNSx.MetaTags,'FileSepTime')
        out_struct.meta.FileSepTime=NEVNSx.MetaTags.FileSepTime;
    else
        out_struct.meta.FileSepTime=[];
    end
    % Build catalogue of entities
    unit_list = unique([NEVNSx.NEV.Data.Spikes.Electrode;NEVNSx.NEV.Data.Spikes.Unit]','rows');
    
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
        
    stim_marker  = find(~cellfun('isempty',strfind(lower(NSx_info.NSx_labels),'stim')));
    emg_list = find(~cellfun('isempty',strfind(lower(NSx_info.NSx_labels),'emg_')));
    force_list = find(~cellfun('isempty',strfind(lower(NSx_info.NSx_labels),'force_')));
    fullbandwidth_list = find(NSx_info.NSx_sampling==30000);
    analog_list = setxor(1:length(NSx_info.NSx_labels),emg_list); % take out emgs channels
    analog_list = setxor(analog_list,force_list); % take out force channels
    analog_list = setxor(analog_list,fullbandwidth_list); % take out 30 kS/s channels
    
%% The Units
    progress = 2/8;
    if opts.verbose
        waitbar(progress,h,'Extracting Units');
    end
    
    if ~isempty(unit_list)        
        for i = size(unit_list,1):-1:1
            out_struct.units(i).id = unit_list(i,:);
            out_struct.units(i).ts = double(NEVNSx.NEV.Data.Spikes.TimeStamp(NEVNSx.NEV.Data.Spikes.Electrode==unit_list(i,1)...
                & NEVNSx.NEV.Data.Spikes.Unit==unit_list(i,2)))/30000;
            out_struct.units(i).ts = out_struct.units(i).ts';
            out_struct.units(i).waveforms = NEVNSx.NEV.Data.Spikes.Waveform(:,NEVNSx.NEV.Data.Spikes.Electrode==unit_list(i,1) &...
                NEVNSx.NEV.Data.Spikes.Unit==unit_list(i,2))';
            
            dn = diff(out_struct.units(i).ts);
            if any(dn<0) %test whether there was a ts reset in the file
                idx = find(dn<0,1,'last');
                if length(idx)>1
                    warning('BDF:MultipleResets', ['Unit %d contains more than one ts reset.'...
                            'All the data after the first reset is extracted.'],i);
                end
                out_struct.units(i).ts = out_struct.units(i).ts(idx+1:end);
                out_struct.units(i).waveforms = out_struct.units(i).waveforms(idx+1:end,:);
                clear idx;
            end
            clear dn;
        end
    end

%% The raw data analog data (other than emgs and full bandwidth data)

    if ~isempty(analog_list) && ~opts.delete_raw
        progress = 3/8;
        if opts.verbose
            waitbar(progress,h,'Extracting Raw Analog Data');
        end

        out_struct.raw.analog.channels = NSx_info.NSx_labels(analog_list);
        out_struct.raw.analog.adfreq = NSx_info.NSx_sampling(analog_list);
        
        for i = length(analog_list):-1:1
            if NSx_info.NSx_sampling(analog_list(i))==500
                out_struct.raw.analog.data{i} = single(NEVNSx.NS1.Data(NSx_info.NSx_idx(analog_list(i)),:))';
            elseif NSx_info.NSx_sampling(analog_list(i))==1000
                out_struct.raw.analog.data{i} = single(NEVNSx.NS2.Data(NSx_info.NSx_idx(analog_list(i)),:))';
            elseif NSx_info.NSx_sampling(analog_list(i))==2000
                out_struct.raw.analog.data{i} = single(NEVNSx.NS3.Data(NSx_info.NSx_idx(analog_list(i)),:))';
            elseif NSx_info.NSx_sampling(analog_list(i))==10000
                out_struct.raw.analog.data{i} = single(NEVNSx.NS4.Data(NSx_info.NSx_idx(analog_list(i)),:))';
            elseif NSx_info.NSx_sampling(analog_list(i))==30000
                out_struct.raw.analog.data{i} = single(NEVNSx.NS5.Data(NSx_info.NSx_idx(analog_list(i)),:))';
            end
            % 6.5584993 is the ratio when comparing the output of 
            % get_cerebus_data to the one from this script. It must come
            % from the data type conversion that happens when pulling 
            % analog data.
            out_struct.raw.analog.data{i} = out_struct.raw.analog.data{i}/6.5584993;
        end
        
        % The start time of each channel.  Note that this NS library
        % function ns_GetTimeByIndex simply multiplies the index by the 
        % ADResolution... so it will always be zero.
        out_struct.raw.analog.ts(1:length(analog_list)) = {0};
    else
        %build default analog fields anyways
        out_struct.raw.analog.channels = [];
        out_struct.raw.analog.adfreq = [];
        out_struct.raw.analog.ts = [];
        out_struct.raw.analog.data = [];
    end
    
%% The full bandwidth data
    if ~isempty(find(NSx_info.NSx_sampling==30000,1,'first')) && ~opts.delete_raw
        progress = 3/8;
        if opts.verbose
            waitbar(progress,h,'Extracting Full bandwidth Analog Data');
        end
        out_struct.raw.fullbandwidth.channels = NSx_info.NSx_labels(fullbandwidth_list);
        out_struct.raw.fullbandwidth.adfreq = NSx_info.NSx_sampling(fullbandwidth_list);
        for i = length(fullbandwidth_list):-1:1
            out_struct.raw.fullbandwidth.data{i} = single(NEVNSx.NS5.Data(NSx_info.NSx_idx(fullbandwidth_list(i)),:))';
            % 6.5584993 is the ratio when comparing the output of 
            % get_cerebus_data to the one from this script. It must come
            % from the data type conversion that happens when pulling 
            % analog data.
            out_struct.raw.fullbandwidth.data{i} = out_struct.raw.fullbandwidth.data{i}/6.5584993;
        end

        % The start time of each channel.  Note that this NS library
        % function ns_GetTimeByIndex simply multiplies the index by the 
        % ADResolution... so it will always be zero.
        out_struct.raw.fullbandwidth.ts(1:length(fullbandwidth_list)) = {0};
    end
%% The Emgs
    if ~isempty(emg_list) && ~opts.delete_raw
        progress = 4/8;
        if opts.verbose
            waitbar(progress,h,'Extracting EMG Data');
        end

        out_struct.emg.emgnames = NSx_info.NSx_labels(emg_list);
        out_struct.emg.emgfreq = NSx_info.NSx_sampling(emg_list);
               
        % ensure all emg channels have the same frequency
        if length(unique(out_struct.emg.emgfreq))>1         
            error('BDF:unequalEmgFreqs','Not all EMG channels have the same frequency');
        end
        out_struct.emg.emgfreq = unique(out_struct.emg.emgfreq);

        for i = length(emg_list):-1:1
            if NSx_info.NSx_sampling(emg_list(i))==500
                out_struct.emg.data(:,i+1) = single(NEVNSx.NS1.Data(NSx_info.NSx_idx(emg_list(i)),:))/6.5584993;
            elseif NSx_info.NSx_sampling(emg_list(i))==1000
                out_struct.emg.data(:,i+1) = single(NEVNSx.NS2.Data(NSx_info.NSx_idx(emg_list(i)),:))/6.5584993;
            elseif NSx_info.NSx_sampling(emg_list(i))==2000
                out_struct.emg.data(:,i+1) = single(NEVNSx.NS3.Data(NSx_info.NSx_idx(emg_list(i)),:))/6.5584993;
            elseif NSx_info.NSx_sampling(emg_list(i))==10000
                out_struct.emg.data(:,i+1) = single(NEVNSx.NS4.Data(NSx_info.NSx_idx(emg_list(i)),:))/6.5584993;
            elseif NSx_info.NSx_sampling(emg_list(i))==30000
                out_struct.emg.data(:,i+1) = single(NEVNSx.NS5.Data(NSx_info.NSx_idx(emg_list(i)),:))/6.5584993;
            end
        end        
       
        out_struct.emg.data(:,1) = single(0:1/out_struct.emg.emgfreq:(size(out_struct.emg.data,1)-1)/out_struct.emg.emgfreq);
    end

%% The Force for WF & MG tasks, or whenever an annalog channel is nammed force_* or Force_*)
    
    if ~isempty(force_list) 
        progress = 5/8;
        if opts.verbose
            waitbar(progress,h,'Extracting Force Data');
        end
      
        out_struct.force.labels = NSx_info.NSx_labels(force_list);
        out_struct.force.forcefreq = NSx_info.NSx_sampling(force_list);        
               
        % ensure all emg channels have the same frequency
        if length(unique(out_struct.force.forcefreq))>1         
            error('BDF:unequalEmgFreqs','Not all EMG channels have the same frequency');
        end
        out_struct.force.forcefreq = unique(out_struct.force.forcefreq);

        for i = length(force_list):-1:1
            if NSx_info.NSx_sampling(force_list(i))==500
                out_struct.force.data(:,i+1) = single(NEVNSx.NS1.Data(NSx_info.NSx_idx(force_list(i)),:));
            elseif NSx_info.NSx_sampling(force_list(i))==1000
                out_struct.force.data(:,i+1) = single(NEVNSx.NS2.Data(NSx_info.NSx_idx(force_list(i)),:));
            elseif NSx_info.NSx_sampling(force_list(i))==2000
                out_struct.force.data(:,i+1) = single(NEVNSx.NS3.Data(NSx_info.NSx_idx(force_list(i)),:));
            elseif NSx_info.NSx_sampling(force_list(i))==10000
                out_struct.force.data(:,i+1) = single(NEVNSx.NS4.Data(NSx_info.NSx_idx(force_list(i)),:));
            elseif NSx_info.NSx_sampling(force_list(i))==30000
                out_struct.force.data(:,i+1) = single(NEVNSx.NS5.Data(NSx_info.NSx_idx(force_list(i)),:));
            end
        end        
       
        out_struct.force.data(:,1) = single(0:1/out_struct.force.forcefreq:(size(out_struct.force.data,1)-1)/out_struct.force.forcefreq);
    end
    
%% Analog trig
    progress = 6/8;
    if opts.verbose
        waitbar(progress,h,'Extracting Analog Trigger');
    end

    if ~isempty(stim_marker)       
        %populate stim marker ts
        stim_data = double(NEVNSx.NEV.Data.Spikes.TimeStamp(NEVNSx.NEV.Data.Spikes.Electrode==stim_marker))/30000;        
        out_struct.stim_marker = stim_data;        
        
        ds = diff(stim_data);
        if any(ds<0) %test whether there was a ts reset in the file
            idx = find(ds<0);
            if length(idx)>1
                warning('BDF:MultipleResets', ['StimMarker contains more than one ts reset.'...
                        'Only the last continuous segement is extracted.']);
            end
            out_struct.stim_marker = stim_data( (idx(end)+1):end);
            clear idx;
        end
        clear ds;

    end   
        
%% Events

    if ~isempty(NEVNSx.NEV.Data.SerialDigitalIO.TimeStamp)  
    progress = 7/8;
    if opts.verbose
        waitbar(progress,h,'Extracting Events');
    end
          
        event_data = double(NEVNSx.NEV.Data.SerialDigitalIO.UnparsedData);
        event_ts = NEVNSx.NEV.Data.SerialDigitalIO.TimeStampSec';       
        
        de = diff(event_ts);
        if any(de<0) %test whether there was a ts reset in the file
            idx = find(de<0);
            if length(idx)>1
                warning('BDF:MultipleResets', ['Events contains more than one ts reset.'...
                        'Only the last continuous segement is extracted.'],i);
            end
            event_data = event_data( (idx(end)+1):end);
            event_ts   = event_ts  ( (idx(end)+1):end);
            clear idx;
        end
        clear de;
        
        % Check if file was recorded before the digital input cable was
        % switched.
        if datenum(out_struct.meta.datetime) - datenum('14-Jan-2011 14:00:00') < 0 
            % The input cable for this was bugged: Bits 0 and 8
            % are swapped.  The WORD is mostly on the high byte (bits
            % 15-9,0) and the ENCODER is mostly on the
            % low byte (bits 7-1,8).
            all_words = [event_ts, bitshift(bitand(hex2dec('FE00'),event_data),-8)+bitget(event_data,1)];
            all_enc = [event_ts, bitand(hex2dec('00FE'),event_data) + bitget(event_data,9)];
        else
            %The WORD is on the high byte (bits
            % 15-8) and the ENCODER is on the
            % low byte (bits 8-1).
            all_words = [event_ts, bitshift(bitand(hex2dec('FF00'),event_data),-8)];
            all_words = all_words(logical(all_words(:,2)),:);
            all_enc = [event_ts, bitand(hex2dec('00FF'),event_data)];
        end             

        % Remove all zero words.
        actual_words = all_words(logical(all_words(:,2)),:);
        % Remove all repeated words (due to encoder data timing)

        word_indices_remove = find(diff(actual_words(:,1))<0.0005 & diff(actual_words(:,2))==0)+1;

        if ~isempty(word_indices_remove)
            word_indices_keep = setxor(word_indices_remove,1:length(actual_words));
            actual_words = actual_words(word_indices_keep,:);
        end

        if ~opts.delete_raw
            %if this section is skipped, calc_from_raw *should* catch the
            %delete_raw flag, and get the word/encoder values directly from
            %actual_words and all_enc, rather than looking for the
            %out_struct.raw fields
            out_struct.raw.words = actual_words;

            % and encoder data
            if opts.kin
                if opts.ignore_jumps
                    out_struct.raw.enc = get_encoder(all_enc,[0 out_struct.meta.duration]);
                else
                    [out_struct.raw.enc, out_struct.meta.jump_times]= get_encoder(all_enc,out_struct.meta.FileSepTime);
                end
            end
        end
    end
   
%% Clean up
    set(0, 'defaulttextinterpreter', defaulttextinterpreter);        
    
%% Extract data from the raw struct
    progress = 8/8;
    if opts.verbose
        waitbar(progress,h,'Processing Raw Data');
    end
    %out_struct = calc_from_raw(out_struct,opts);
    calc_from_raw_script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if opts.verbose
        close(h);
    end

end