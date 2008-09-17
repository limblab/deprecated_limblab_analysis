function out_struct = get_plexon_data(varargin)
% GET_PLEXON_DATA Generates Brian's datastructure from plx file
%   OUT_STRUCT = GET_PLEXON_DATA(FILENAME) returns Brian's datastructure
%   read from the PLX file FILENAME.
%
%   OUT_STRUCT = GET_PLEXON_DATA(FILENAME, VERBOSE) returns Brian's
%   datastructure read from the PLX file FILENAME and outputs status
%   information acording to the optional parameter VERBOSE.  
%       VERBOSE - 1 => prints status info
%                 0 => prints nothing
%
% NOTE: Throws out first full second and last full second rounded up.
%
% Data structure format follows (actual field names are lowercase):
%
% OUT_STRUCT
% |
% +-- UNITS   - Contins data on neurons and their firing
% |   |
% |   +-- ID  - List of units in the form {[chan1 unit1] [chan2 unit2] ... }
% |   +-- TS  - List of spike timestamps for each unit in the form:
% |               {[u1_s1 u1_s2 ... ] [u2_s1 ... ] ... }
% +-- RAW     - Struct containing raw data (for verification purposes)
% |   |
% |   +-- ENC    - Encoder values stored in three columns with a timestamp:
% |   |              [t_1 sh_1 el_1; t_2 sh_2 el_2; ... ]
% |   +-- ANALOG - Raw analog signals (not computed to signals like force)
% |   |   +-- ADFREQ   - Sampleing frequency
% |   |   +-- CHANNELS - Names of channels: {'chan1' 'chan2' ... }
% |   |   +-- TS       - Start times of analog channels
% |   |   +-- DATA     - Raw analog data: [t1 ch1_1 ch2_1 ... chn_1;
% |   |                                    t2 ch1_2 ch2_2 ... chn_2; ... ]
% |   +-- EVENTS - contains the events structure exactly as it is removed
% |       |        from the plx file (not strobed words)
% |       +-- TIMESTAMPS - event timestamps 
% |                        {[e1_1 e1_2 ... ] [e2_1 ... ] ...}
% +-- POS    - Position signal: [t1 x1 y1; t2 x2 y2; ... ]
% +-- FORCE  - Force signal: [t1 x1 y1; t2 x2 y2; ... ]
% +-- WORDS  - Words: [ts1 word1, ts2 word2 ... ]
% +-- KEYBOARD_EVENTS - Keybord events: [t1 key1, t2 key2 ... ]
% +-- META   - Metadata
%     |
%     +-- FILENAME
%     +-- DATETIME
%     +-- DURATION

    % Add paths - take them back out at the end
    addpath ./core_files
    addpath ./event_decoders

    % make sure LaTeX is turned off and save the old state so we can turn
    % it back on at the end
    defaulttextinterpreter = get(0, 'defaulttextinterpreter'); 
    set(0, 'defaulttextinterpreter', 'none');
    
    % Initial setup
    if (nargin == 1)
        filename = varargin{1};
        verbose = 0;
    elseif (nargin == 2)
        filename = varargin{1};
        verbose = varargin{2};
    else
        error ('Invalid number of arguments');
    end

    progress = 0;
    if (verbose == 1)
        h = waitbar(0, sprintf('Opening: %s', filename));
    end

%% Data From PLX File
    
    % Get MetaData
    [tscounts, wfcounts, evcounts] = plx_info(filename,1);
    [OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreThresh, ...
        SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, ...
        DateTime] = plx_information(filename);
    
    out_struct.meta = struct('filename', OpenedFileName, 'datetime', DateTime,'duration', Duration);

    % Extract data from plxfile
    %out_struct.units = get_units(filename, verbose);
    out_struct.raw = get_raw(filename, verbose);
    
%% Calculated Data

    start_time = 1.0;
    last_enc_time = out_struct.raw.enc(end,1);
    last_analog_time = out_struct.raw.analog.ts{1} + ...
        length(out_struct.raw.analog.data{1}) / out_struct.raw.analog.adfreq;
    stop_time = floor( min( [last_enc_time last_analog_time] ) ) - 1;
    analog_time_base = start_time:1/out_struct.raw.analog.adfreq:stop_time;

    % Position
    if (verbose == 1)
        progress = progress + .05;
        waitbar(progress, h, sprintf('Opening: %s\nget position', filename));
    end

    l1 = 24.0; l2 = 23.5;
    th_t = out_struct.raw.enc(:,1); % encoder time stamps

    th_1 = out_struct.raw.enc(:,2) * 2 * pi / 18000;
    th_1 = interp1(th_t, th_1, analog_time_base);
    
    th_2 = out_struct.raw.enc(:,3) * 2 * pi / 18000;
    th_2 = interp1(th_t, th_2, analog_time_base);
    
    % convert to x and y
    x = - l1 * sin( th_1 ) + l2 * cos( -th_2 );
    y = - l1 * cos( th_1 ) - l2 * sin( -th_2 );
    
    out_struct.pos = [analog_time_base' x' y'];

    % Force
    if (verbose == 1)
        progress = progress + .05;
        waitbar(progress, h, sprintf('Opening: %s\nget force', filename));
    end
    
    fhcal = [ 0.1019 -3.4543 -0.0527 -3.2162 -0.1124  6.6517; ...
             -0.1589  5.6843 -0.0913 -5.8614  0.0059  0.1503]';
    rotcal = [0.8540 -0.5202; 0.5202 0.8540];
    
    raw_force = zeros(length(analog_time_base), 6);
    for c = 1:6
        channame = sprintf('ForceHandle%d', c);
        a_data = get_analog_signal(out_struct, channame);
        a_data = interp1( a_data(:,1), a_data(:,2), analog_time_base);
        raw_force(:,c) = a_data';
    end
    
    out_struct.force = raw_force * fhcal * rotcal;
    out_struct.force(:,2) = -out_struct.force(:,2);    
    for p = 1:size(out_struct.force, 1)
        r = [cos(th_1(p)) sin(-th_1(p)); -sin(-th_1(p)) cos(-th_1(p))];
        out_struct.force(p,:) = out_struct.force(p,:) * r;
    end
    
    out_struct.force = [analog_time_base' out_struct.force];
    
    % Words
    out_struct.words = get_words(out_struct.raw.events.timestamps);
    
    % Keyboard Events
    out_struct.keyboard_events = [];
    for k = 1:9
        if (verbose == 1)
            progress = progress + .1/9;
            waitbar(progress, h, sprintf('Opening: %s\nget keyboard events', filename));
        end
        
        event_index = 100 + k;
        try 
            [n, ts] = plx_event_ts(filename, event_index);
        catch
            ts = [];
        end
        for evt = 1:length(ts)
            out_struct.keyboard_events = ...
                [out_struct.keyboard_events; ...
                ts(evt) k];
        end
    end
        
    if ~isempty(out_struct.keyboard_events)
        out_struct.keyboard_events = sortrows( out_struct.keyboard_events, [1 2] );
    end
    
    set(0, 'defaulttextinterpreter', defaulttextinterpreter);
    
    if (verbose == 1)
        close(h);
    end

    rmpath ./core_files
    rmpath ./event_decoders
    
%% Subroutines

    % get_units
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function units = get_units(filename, verbose) 
        % Get general info needed for events and units
        tscounts = plx_info(filename, 1);
        [max_num_units num_channels] = size(tscounts);

        %
        % Get Units 
        %
        num_total_units = sum(sum(tscounts > 0));
        ids = cell(1, num_total_units);
        tss = cell(1, num_total_units);
        unit_counter = 1;

        for chan = 1:num_channels-1
            if (verbose == 1)
                progress = progress + .3/num_channels;
                waitbar(progress, h, sprintf('Opening: %s\nget units (%d)', filename, chan));
            end
            for unit = 1:max_num_units-1
                % only create a unit if it has spikes
                if (tscounts(unit+1, chan+1) > 0)
                    [n, ts] = plx_ts(filename, chan, unit);

                    ids{unit_counter} = [chan unit];
                    tss{unit_counter} = ts;

                    unit_counter = unit_counter + 1;
                end
            end
        end

        units = struct('id', ids, 'ts', tss); 
    end

    % get_raw
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function raw = get_raw(filename, verbose)
    	% list of channels that we care about
        [tscounts, wfcounts, evcounts] = plx_info(filename,1);
        chans_with_data = sum(evcounts(300:363) > 0);
        [n, chan_list] = plx_adchan_names(filename);
        
        chan_count = 1;
        for i = 0:63             
            if evcounts(300+i) > 0 
                [adfreq, n, ts, fn, ad] = plx_ad(filename, i);
 
                if chans_with_data == size(chan_list, 1)
                    channame = chan_list(chan_count, :);
                else
                    channame = chan_list(i+1, :);
                end
                channame = deblank(channame);
                tmp_channels{chan_count} = channame;
                    
                tmp_data{chan_count} = ad;
                tmp_ts{chan_count} = ts;
                                 
                chan_count = chan_count + 1;
            end           
            
            if (verbose == 1)
                progress = progress + .3/64;
                waitbar(progress, h, sprintf('Opening: %s\nget analog (%d of %d)', filename, i+1, 64));
            end
        end

        raw.analog.channels = tmp_channels;
        raw.analog.adfreq = adfreq;
        raw.analog.ts = tmp_ts;
        for i = 1:length(tmp_channels)
            raw.analog.data{i} = tmp_data{i} / 409.3;
        end
        
        % get strobed events and values
        [n, strobe_ts, strobe_value] = plx_event_ts(filename, 257);
        raw.enc = get_encoder([strobe_ts strobe_value]);
        
        % Get individual events
        for i = 3:10
            if (verbose == 1)
                progress = progress + .2/8;
                waitbar(progress, h, sprintf('Opening: %s\nget events', filename));
            end
            
            try
                [n, ts] = plx_event_ts(filename, i);
            catch
                ts = [];
            end
            raw.events.timestamps{i-2} = ts;
        end
    end

end % close outermost function
