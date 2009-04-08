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
    addpath ./lib_cb
    addpath ./event_decoders
    
    % make sure LaTeX is turned off and save the old state so we can turn
    % it back on at the end
    defaulttextinterpreter = get(0, 'defaulttextinterpreter'); 
    set(0, 'defaulttextinterpreter', 'none');
    
    % Parse arguments
    if (nargin == 1)
        filename   = varargin{1};
        verbose    = 0;
    elseif (nargin == 2)
        filename   = varargin{1};
        verbose    = varargin{2};
    else
        error ('Invalid number of arguments');
    end

    progress = 0;
    if (verbose == 1)
        h = waitbar(0, sprintf('Opening: %s', filename));
    else
        h = 0;
    end

%% Open the file

    % Load the Cerebus library
    % TODO: MAKE PATH DYNAMIC
    [nsresult] = ns_SetLibrary('lib_cb/nsNEVLibrary.dll');
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

%% Extract data

    % Build catalogue of entities
    [nsresult, EntityInfo] = ns_GetEntityInfo(hfile, 1:FileInfo.EntityCount);
    unit_list    = find([EntityInfo.EntityType] == 4);
    % segment_list = find([EntityInfo.EntityType] == 3);
    emg_list     = find([EntityInfo.EntityType] == 2 & strncmp({EntityInfo.EntityLabel}, 'EMG_', 4));
    analog_list  = find([EntityInfo.EntityType] == 2 & ~strncmp({EntityInfo.EntityLabel}, 'EMG_', 4));
    event_list   = find([EntityInfo.EntityType] == 1);

    if verbose == 1
        unit_list_item_count   = sum([EntityInfo(unit_list).ItemCount]);
        analog_list_item_count = sum([EntityInfo(analog_list).ItemCount]);
        emg_list_item_count    = sum([EntityInfo(emg_list).ItemCount]);
        event_list_item_count  = sum([EntityInfo(event_list).ItemCount]);
        % segment_list_item_count = sum([EntityInfo(segment_list).ItemCount]);
        relevant_entity_count = unit_list_item_count + emg_list_item_count+...
            analog_list_item_count + event_list_item_count;
        entity_extraction_weight = 0.9;
    end

    % the units
    if ~isempty(unit_list)
        if (verbose == 1)
            progress = progress + (1 - entity_extraction_weight);
            waitbar(progress,h,sprintf('Opening: %s\nExtracting Units...', filename));
        end

        [nsresult,neural_info] = ns_GetNeuralInfo(hfile, unit_list);
        for i = length(unit_list):-1:1
            [nsresult,neural_data] = ns_GetNeuralData(hfile, unit_list(i), 1, EntityInfo(unit_list(i)).ItemCount);
            out_struct.units(i).id = [neural_info(i).SourceEntityID neural_info(i).SourceUnitID];
            out_struct.units(i).ts = neural_data;
        end

        if (verbose == 1)
            progress = progress + entity_extraction_weight*unit_list_item_count/relevant_entity_count;
        end
    end

    % The raw data analog data (other than emgs)
    if ~isempty(analog_list)
        if (verbose == 1)
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
            out_struct.raw.analog.data(i) = {analog_data};
            if (verbose == 1)
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

    % the emgs
    if ~isempty(emg_list)
        if (verbose == 1)
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
        % The start time of each channel.  Note that this NS library
        % function ns_GetTimeByIndex simply multiplies the index by the 
        % ADResolution... so it will always be zero.
%        out_struct.raw.analog.ts(1:length(analog_list)) = {0};
        for i = length(emg_list):-1:1
            % Note that this is often a lot of data; grabbing it all at once
            % yeilds too large a contiguous block on most machines, resulting
            % in an out of memory error. Also: this takes a really long time.
            [nsresult,cont_count,emg_data] = ns_GetAnalogData(hfile, emg_list(i), 1, EntityInfo(emg_list(i)).ItemCount);
            if (cont_count ~= EntityInfo(emg_list(i)).ItemCount)
                warning('BDF:contiguousAnalog','Channel %d does not contain contiguous data',i)
            end
            out_struct.emg.data(:,i+1) = emg_data;
            if (verbose == 1)
                progress = progress + entity_extraction_weight*EntityInfo(emg_list(i)).ItemCount/relevant_entity_count;
                waitbar(progress,h,sprintf('Opening: %s\nExtracting EMGs...', filename));
            end
        end
        out_struct.emg.data(:,1) = 0:1/emgfreq:(length(emg_data)-1)/emgfreq;
        clear emg_data emgfreq;
    end
        
        
    % grab the events
    if ~isempty(event_list)
        if (verbose == 1)
            waitbar(progress,h,sprintf('Opening: %s\nExtracting Events...', filename));
        end
        for i = length(event_list):-1:1
            [nsresult,event_ts,event_data] = ns_GetEventData(hfile,event_list(i),1:EntityInfo(event_list(i)).ItemCount);
            if (event_list(i) == 145)
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
                all_enc = [event_ts, bitand(hex2dec('FE'),event_data) + bitget(event_data,1)];
                out_struct.raw.enc = get_encoder(all_enc(logical(all_enc(:,2)),:));
            else
                % something else; kludge it into events
                out_struct.raw.events{i} = struct(...
                    'event_name', EntityInfo(event_list(i)).EntityLabel,...
                    'event_id', event_list(i),...
                    'event_data',[event_ts, event_data]);
            end
        end
    end


%% Clean up
    if (verbose == 1)
        waitbar(1,h,sprintf('Opening: %s\nCleaning Up...', filename));
    end

    ns_CloseFile(hfile);

    set(0, 'defaulttextinterpreter', defaulttextinterpreter);
    
    rmpath ./lib_cb
    rmpath ./event_decoders
    
    if (verbose == 1)
        close(h);
    end
    
    
    
%% Extract data from the raw struct

    out_struct = calc_from_raw(out_struct,verbose);

end
