function out_struct = get_cerebus_data(varargin)
% GET_CEREBUS_DATA Generates a BDF struct from nev and ns* files
%   OUT_STRUCT = GET_CEREBUS_DATA(FILENAME) returns a BDF populated by the
%   file FILENAME.
% 
%   OUT_STRUCT = GET_CEREBUS_DATA(FILENAME, VERBOSE) returns a BDF
%   populated by the file FILENAME and outputs status information acording
%   to the optional parameter VERBOSE.
%       VERBOSE - 1 => prints status info
%                 0 => prints nothing (default)

% $Id$

%% Initial setup
    % Add paths - take them back out at the end
%     addpath ./lib_cb
%     addpath ./event_decoders
%     
    % make sure LaTeX is turned off and save the old state so we can turn
    % it back on at the end
    defaulttextinterpreter = get(0, 'defaulttextinterpreter'); 
    set(0, 'defaulttextinterpreter', 'none');
    
    %initial setup
    opts=struct('verbose',0,'progbar',0,'force',0,'kin',1,'labnum',1); %default to lab 1, no force
   
    % Parse arguments
    if (nargin == 1)
        filename   = varargin{1};
    else
        filename   = varargin{1};
        if ischar(varargin{2})
            if strcmpi(varargin{2},'verbose')
                opts.verbose= 1;
            else
                opts.verbose=0;
            end
        else
            opts.verbose=0;
            opts.labnum=varargin{2};
        end
    end
  
    progress = 0;
    if (opts.verbose == 1)
        h = waitbar(0, sprintf('Opening: %s', filename));
    else
        h = 0;
    end

%% Open the file

    % Load the Cerebus library
    % TODO: MAKE PATH DYNAMIC : DONE
    [nsresult] = ns_SetLibrary(which('nsNEVLibrary.dll'));
    if (nsresult ~= 0)
        close(h);
        error('Error opening library!');
    end

    % Load the file
    [nsresult, hfile] = ns_OpenFile(filename);
    if (nsresult ~= 0)
        close(h);
        error('Error opening file!');
    end

    % Get general file info (EntityCount, TimeStampResolution and TimeSpan)
    [nsresult, FileInfo] = ns_GetFileInfo(hfile);
    if (nsresult ~= 0)
        close(h);
        error('Data file information did not load!');
    end
    DateTime = [int2str(FileInfo.Time_Month) '/' int2str(FileInfo.Time_Day) '/' int2str(FileInfo.Time_Year) ...
        ' ' int2str(FileInfo.Time_Hour) ':' int2str(FileInfo.Time_Min) ':' int2str(FileInfo.Time_Sec) '.' int2str(FileInfo.Time_MilliSec)];

    out_struct.meta = struct('filename', filename, 'datetime', DateTime,'duration', FileInfo.TimeSpan, ...
        'bdf_info', '$Id$');

%% Data Information

    % Build catalogue of entities
    [nsresult, EntityInfo] = ns_GetEntityInfo(hfile, 1:FileInfo.EntityCount);
    unit_list    = find([EntityInfo.EntityType] == 4 & ~strncmp({EntityInfo.EntityLabel},'Stim_', 5));
    stim_marker  = find([EntityInfo.EntityType] == 4 & strncmp({EntityInfo.EntityLabel},'Stim_', 5));

    % segment_list = find([EntityInfo.EntityType] == 3);
    emg_list     = find([EntityInfo.EntityType] == 2 & strncmp({EntityInfo.EntityLabel}, 'EMG_', 4));
    force_list   = find([EntityInfo.EntityType] == 2 & strncmpi({EntityInfo.EntityLabel}, 'force_', 6));
    analog_list  = find([EntityInfo.EntityType] == 2 & ~strncmp({EntityInfo.EntityLabel}, 'EMG_', 4)...
                                                     & ~strncmpi({EntityInfo.EntityLabel}, 'force_', 6) );
    event_list   = find([EntityInfo.EntityType] == 1);

    if opts.verbose == 1
        unit_list_item_count   = sum([EntityInfo(unit_list).ItemCount]);
        analog_list_item_count = sum([EntityInfo(analog_list).ItemCount]);
        emg_list_item_count    = sum([EntityInfo(emg_list).ItemCount]);
        force_list_item_count  = sum([EntityInfo(force_list).ItemCount]);
        event_list_item_count  = sum([EntityInfo(event_list).ItemCount]);
        stim_marker_count      = sum([EntityInfo(stim_marker).ItemCount]);
        % segment_list_item_count = sum([EntityInfo(segment_list).ItemCount]);
        relevant_entity_count = unit_list_item_count + emg_list_item_count+ force_list_item_count+...
            analog_list_item_count + event_list_item_count + stim_marker_count;
        entity_extraction_weight = 0.9;
    end

%% The Units
    if ~isempty(unit_list)
        if (opts.verbose == 1)
            progress = progress + (1 - entity_extraction_weight);
            waitbar(progress,h,sprintf('Opening: %s\nExtracting Units...', filename));
        end

        [nsresult,neural_info] = ns_GetNeuralInfo(hfile, unit_list);
        for i = length(unit_list):-1:1
            [nsresult,neural_data] = ns_GetNeuralData(hfile, unit_list(i), 1, EntityInfo(unit_list(i)).ItemCount);
            out_struct.units(i).id = [neural_info(i).SourceEntityID neural_info(i).SourceUnitID];
            out_struct.units(i).ts = neural_data;
        end

        if (opts.verbose == 1)
            progress = progress + entity_extraction_weight*unit_list_item_count/relevant_entity_count;
        end
    end

%% The raw data analog data (other than emgs)
    if ~isempty(analog_list)
        if (opts.verbose == 1)
            waitbar(progress,h,sprintf('Opening: %s\nExtracting Analog...', filename));
        end
        [nsresult,analog_info] = ns_GetAnalogInfo(hfile, analog_list);
  
        out_struct.raw.analog.channels = {EntityInfo(analog_list).EntityLabel};
        out_struct.raw.analog.adfreq = [analog_info(:).SampleRate];
        % The start time of each channel.  Note that this NS library
        % function ns_GetTimeByIndex simply multiplies the index by the 
        % ADResolution... so it will always be zero.
        out_struct.raw.analog.ts(1:length(analog_list)) = {0};
        for i = length(analog_list):-1:1
            % Note that this is often a lot of data; grabbing it all at once
            % yeilds too large a contiguous block on most machines, resulting
            % in an out of memory error. Also: this takes a really long time.
            [nsresult,cont_count,analog_data] = ns_GetAnalogData(hfile, analog_list(i), 1, EntityInfo(analog_list(i)).ItemCount);
            if (cont_count ~= EntityInfo(analog_list(i)).ItemCount)
                warning('BDF:contiguousAnalog','Channel %d does not contain contiguous data',i)
            end
            out_struct.raw.analog.data(i) = {analog_data.*4.1666667}; %multiplying by 4.1666667 converts analog_data in mV
            if (opts.verbose == 1)
                progress = progress + entity_extraction_weight*EntityInfo(analog_list(i)).ItemCount/relevant_entity_count;
                waitbar(progress,h,sprintf('Opening: %s\nExtracting Analog...', filename));
            end
        end
    else
        %build default analog fields anyways
        out_struct.raw.analog.channels = [];
        out_struct.raw.analog.adfreq = [];
        out_struct.raw.analog.ts = [];
        out_struct.raw.analog.data = [];
    end

%% The Emgs
    if ~isempty(emg_list)
        if (opts.verbose == 1)
            waitbar(progress,h,sprintf('Opening: %s\nExtracting EMGs...', filename));
        end

        [nsresult,emg_info] = ns_GetAnalogInfo(hfile, emg_list);
        out_struct.emg.emgnames = {EntityInfo(emg_list).EntityLabel};
        % ensure all emg channels have the same frequency
        if ~all( [emg_info.SampleRate] == emg_info(1).SampleRate)
            close(h);
            error('BDF:unequalEmgFreqs','Not all EMG channels have the same frequency');
        end

        emgfreq = [emg_info(1).SampleRate];
        out_struct.emg.emgfreq = emgfreq;

        for i = length(emg_list):-1:1
            % Note that this is often a lot of data; grabbing it all at once
            % yeilds too large a contiguous block on most machines, resulting
            % in an out of memory error. Also: this takes a really long time.
            [nsresult,cont_count,emg_data] = ns_GetAnalogData(hfile, emg_list(i), 1, EntityInfo(emg_list(i)).ItemCount);
            if (cont_count ~= EntityInfo(emg_list(i)).ItemCount)
                warning('BDF:contiguousAnalog','Channel %d does not contain contiguous data',i)
            end
            out_struct.emg.data(:,i+1) = emg_data.*4.1666667; %multiplying by 4.1666667 converts emg_data in mV
            if (opts.verbose == 1)
                progress = progress + entity_extraction_weight*EntityInfo(emg_list(i)).ItemCount/relevant_entity_count;
                waitbar(progress,h,sprintf('Opening: %s\nExtracting EMGs...', filename));
            end
        end
        out_struct.emg.data(:,1) = 0:1/emgfreq:(length(emg_data)-1)/emgfreq;
        clear emg_data emgfreq;
    end
    
%% The Force for WF & MG tasks, or whenever the force channel is nammed force_* or Force_*)
    if ~isempty(force_list)
        
        if (opts.verbose == 1)
            waitbar(progress,h,sprintf('Opening: %s\nExtracting Force Data...', filename));
        end

        [nsresult,force_info] = ns_GetAnalogInfo(hfile, force_list);
        out_struct.force.labels = {EntityInfo(force_list).EntityLabel};
        % ensure all force channels have the same frequency
        if ~all( [force_info.SampleRate] == force_info(1).SampleRate)
            close(h);
            error('BDF:unequalForceFreqs','Not all force channels have the same frequency');
        end

        forcefreq = [force_info(1).SampleRate];
        out_struct.force.forcefreq = forcefreq;

        for i = length(force_list):-1:1
            % Note that this is often a lot of data; grabbing it all at once
            % yeilds too large a contiguous block on most machines, resulting
            % in an out of memory error. Also: this takes a really long time.
            [nsresult,cont_count,force_data] = ns_GetAnalogData(hfile, force_list(i), 1, EntityInfo(force_list(i)).ItemCount);
            if (cont_count ~= EntityInfo(force_list(i)).ItemCount)
                warning('BDF:contiguousAnalog','Channel %d does not contain contiguous data',i)
            end
            out_struct.force.data(:,i+1) = force_data.*4.1666667; %multiplying by 4.1666667 converts force_data in mV
            if (opts.verbose == 1)
                progress = progress + entity_extraction_weight*EntityInfo(force_list(i)).ItemCount/relevant_entity_count;
                waitbar(progress,h,sprintf('Opening: %s\nExtracting force...', filename));
            end
        end
        out_struct.force.data(:,1) = 0:1/forcefreq:(length(force_data)-1)/forcefreq;
        clear force_data forcefreq;

    end
    
%% Analog trig
    if ~isempty(stim_marker)
        if (opts.verbose == 1)
            waitbar(progress,h,sprintf('Opening: %s\nExtracting Events...', filename));
        end
        
        %populate stim marker ts
        [nsresult,stim_data] = ns_GetNeuralData(hfile, stim_marker, 1, EntityInfo(stim_marker).ItemCount);
        out_struct.stim_marker = stim_data;
        
        if (opts.verbose == 1)
            progress = progress + entity_extraction_weight*EntityInfo(stim_marker(i)).ItemCount/relevant_entity_count;
            waitbar(progress,h,spintf('Opening: %s\nExtracting Stim Marker', filename));
        end
    end   
        
%% Events        
    if ~isempty(event_list)
        if (opts.verbose == 1)
            waitbar(progress,h,sprintf('Opening: %s\nExtracting Events...', filename));
        end
        
        % grab the words -- event_list ID 145
        [nsresult,event_ts,event_data] = ns_GetEventData(hfile,145,1:EntityInfo(145).ItemCount);
        % we have the digin serial line
        % The input cable for this is currently bugged: Bits 0 and 8
        % are swapped.  The WORD is mostly on the high byte (bits
        % 15-9,0) and the ENCODER is mostly on the
        % low byte (bits 7-1,8).

        % Get all words... including zeros.
        all_words = [event_ts, bitshift(bitand(hex2dec('FE00'),event_data),-8)+bitget(event_data,1)];
        % Remove all zero words.
        out_struct.raw.words = all_words(logical(all_words(:,2)),:);

        % and encoder data
        all_enc = [event_ts, bitand(hex2dec('00FE'),event_data) + bitget(event_data,9)];
        out_struct.raw.enc = get_encoder(all_enc(logical(all_enc(:,2)),:));
        
        % Grab the serial data -- event ID 146
        [nsresult,event_ts,event_data] = ns_GetEventData(hfile,146,1:EntityInfo(146).ItemCount);
        out_struct.raw.serial = [event_ts, event_data];
    end

%% Clean up
    if (opts.verbose == 1)
        waitbar(1,h,sprintf('Opening: %s\nCleaning Up...', filename));
    end

    ns_CloseFile(hfile);

    set(0, 'defaulttextinterpreter', defaulttextinterpreter);
    
%     rmpath ./lib_cb
%     rmpath ./event_decoders
    
    if (opts.verbose == 1)
        close(h);
    end
    
    
    
%% Extract data from the raw struct
  
    out_struct = calc_from_raw(out_struct,opts);

end