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
% +-- UNITS   - Contains data on neurons and their firing
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
% |   +-- EVENTS - Contains the events structure exactly as it is removed
% |   |   |        from the plx file (not strobed words)
% |   |   +-- TIMESTAMPS - event timestamps 
% |   +-- WORDS - Not really a raw value, but an intermediate one.  This
% |               contains the words before they have been split into event
% |               codes and databursts
% |                        {[e1_1 e1_2 ... ] [e2_1 ... ] ...}
% +-- POS    - Position signal: [t1 x1 y1; t2 x2 y2; ... ]
% +-- VEL    - Velocity signal: as for position
% +-- ACC    - Acceleration signal: as for position
% +-- FORCE  - Force signal: [t1 x1 y1; t2 x2 y2; ... ]
% +-- WORDS  - Words: [ts1 word1, ts2 word2 ... ]
% +-- DATABURSTS - Data blocks: {ts1 [byte1_1 byte1_2 ...], 
% |                              ts2 [byte2_1 byte2_2 ...], ... }
% +-- KEYBOARD_EVENTS - Keybord events: [t1 key1, t2 key2 ... ]
% +-- EMG
% |   |
% |   +-- DATA     - EMG signals: [t1 emg1 emg2 ... emgN; t2 emg1 emg2 ... emgN; ... ]
% |   +-- EMGNAMES - Names of emg signals: {'EMG_muscle1', 'EMG_muscle2',...}  
% +-- META   - Metadata
%     |
%     +-- FILENAME
%     +-- DATETIME
%     +-- DURATION
%     +-- BDF_INFO - contains information about the version of
%                    get_plexon_data used to create the BDF

% $Id$

    % Add paths - take them back out at the end
    addpath ./lib_plx
    addpath ./lib_plx/core_files
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
    else
        h = 0;
    end

%% Data From PLX File    

    % Get MetaData
    [tscounts, wfcounts, evcounts] = plx_info(filename,1);
    [OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreThresh, ...
        SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, ...
        DateTime] = plx_information(filename);
    
    out_struct.meta = struct('filename', OpenedFileName, 'datetime', DateTime,'duration', Duration, ...
        'bdf_info', '$Id$');

    % Extract data from plxfile
    out_struct.units = get_units_plx(filename, verbose);
    out_struct.raw = get_raw_plx(filename, verbose);
    out_struct.keyboard_events = get_keyboard_plx(filename, verbose);
    
%% Calculated Data

    % Analog sample rate (local copy)
    adfreq = out_struct.raw.analog.adfreq(1);

    % Words
    out_struct.raw.words = get_words(out_struct.raw.events.timestamps);
    [out_struct.words, out_struct.databursts] = extract_datablocks(out_struct.raw.words);

    % figure out which behavior is running
    robot_task = 0;
    wrist_flexion_task =0;
    start_trial_words = out_struct.words( bitand(hex2dec('f0'),out_struct.words(:,2)) == hex2dec('10') ,2);
    if ~isempty(start_trial_words)
        start_trial_code = start_trial_words(1);
        if ~isempty(find(start_trial_words ~= start_trial_code, 1))
            error('Not all trials are the same type');
        end
    
        if start_trial_code == hex2dec('17')
            wrist_flexion_task = 1;
        elseif start_trial_code >= hex2dec('11') && start_trial_code <= hex2dec('15')
            robot_task = 1;
        else
            error('Unknown behavior task');
        end
    end

    % Compile analog data
    if isfield(out_struct.raw, 'analog')
        start_time = 1.0;
        last_analog_time = out_struct.raw.analog.ts{1} + ...
            length(out_struct.raw.analog.data{1}) / adfreq;
        if robot_task
            last_enc_time = out_struct.raw.enc(end,1);
            stop_time = floor( min( [last_enc_time last_analog_time] ) ) - 1;
        elseif wrist_flexion_task
            stop_time = floor(last_analog_time)-1;
        else
            stop_time = floor(last_analog_time)-1;
        end

        analog_time_base = start_time:1/adfreq:stop_time;
    end
    
    %Position and Force for Robot Task
    if robot_task
        % Position
        if (verbose == 1)
            progress = progress + .05;
            waitbar(progress, h, sprintf('Opening: %s\nget position', filename));
        end

        l1 = 24.0; l2 = 23.5;
        th_t = out_struct.raw.enc(:,1); % encoder time stamps

        [b,a] = butter(8, 100/adfreq);

        th_1 = out_struct.raw.enc(:,2) * 2 * pi / 18000;
        th_2 = out_struct.raw.enc(:,3) * 2 * pi / 18000;
        th_1_adj = interp1(th_t, filtfilt(b, a, th_1), analog_time_base); 
        th_2_adj = interp1(th_t, filtfilt(b, a, th_2), analog_time_base); 

        % convert to x and y
        x = - l1 * sin( th_1_adj ) + l2 * cos( -th_2_adj );
        y = - l1 * cos( th_1_adj ) - l2 * sin( -th_2_adj );

        % get derivatives
        dx = kin_diff(x);
        dy = kin_diff(y);

        ddx = kin_diff(dx);
        ddy = kin_diff(dy);

        % write into structure
        out_struct.pos = [analog_time_base'   x'   y'];
        out_struct.vel = [analog_time_base'  dx'  dy'];
        out_struct.acc = [analog_time_base' ddx' ddy'];

        % Force
        if (verbose == 1)
            progress = progress + .05;
            waitbar(progress, h, sprintf('Opening: %s\nget force', filename));
        end

        fhcal = [ 0.1019 -3.4543 -0.0527 -3.2162 -0.1124  6.6517; ...
                 -0.1589  5.6843 -0.0913 -5.8614  0.0059  0.1503]';
        rotcal = [0.8540 -0.5202; 0.5202 0.8540];

        [b,a] = butter(4, 20/adfreq);
        raw_force = zeros(length(analog_time_base), 6);
        for c = 1:6
            channame = sprintf('ForceHandle%d', c);
            a_data = get_analog_signal(out_struct, channame);
            a_data = filtfilt(b, a, a_data);
            a_data = interp1( a_data(:,1), a_data(:,2), analog_time_base);
            raw_force(:,c) = a_data';
        end

        force_offsets = [-0.1388 0.1850 0.2288 0.1203 0.0043 0.2845];
        force_offsets = repmat(force_offsets, length(raw_force), 1);
        out_struct.force = (raw_force - force_offsets) * fhcal * rotcal;
        out_struct.force(:,2) = -out_struct.force(:,2);    
        for p = 1:size(out_struct.force, 1)
            r = [cos(th_1_adj(p)) sin(-th_1_adj(p)); -sin(-th_1_adj(p)) cos(-th_1_adj(p))];
            out_struct.force(p,:) = out_struct.force(p,:) * r;
        end
        
        out_struct.force = [analog_time_base' out_struct.force];
        
    elseif wrist_flexion_task
        % Force (Cursor Pos) for Wrist Flexion task    
        
        force_channels = find( strncmp(out_struct.raw.analog.channels, 'Force_', 6) ); %#ok<EFIND>
        if ~isempty(force_channels)
            % Getting Force
            if (verbose == 1)
                progress = progress + .05;
                waitbar(progress, h, sprintf('Opening: %s\nget force', filename));
            end

            % extract force data for WF task here
            [b,a] = butter(4, 20/adfreq); % lowpass at 10 Hz
            force_x = get_analog_signal(out_struct, 'Force_x');
            force_x = filtfilt(b,a,force_x);
            force_x = interp1( force_x(:,1), force_x(:,2), analog_time_base);
            force_y = get_analog_signal(out_struct, 'Force_y');
            force_y = filtfilt(b,a,force_y);
            force_y = interp1( force_y(:,1), force_y(:,2), analog_time_base);
            out_struct.force = [analog_time_base' force_x' force_y'];
        else
            disp('No force signal found because no channel named ''Force_*''');
            out_struct.force = [];
        end

    end
    
    % EMGs
    emg_channels = find( strncmp(out_struct.raw.analog.channels, 'EMG_', 4) ); %#ok<EFIND>
    if ~isempty(emg_channels)
        if (verbose == 1)
            progress = progress + .05;
            waitbar(progress, h, sprintf('Opening: %s\nget EMGs', filename));
        end
              
        % extract emg channel data here
   
        out_struct.emg.emgnames = out_struct.raw.analog.channels(emg_channels);
        
        highpassfreq = 50; %50Hz
        lowpassfreq = 5; %10Hz
        
        [bh,ah] = butter(4, highpassfreq*2/adfreq, 'high');
        [bl,al] = butter(4, lowpassfreq*2/adfreq, 'low');
        raw_emg = zeros(length(analog_time_base), length(emg_channels));
        for e = 1:(length(emg_channels))
            e_data = get_analog_signal(out_struct, out_struct.emg.emgnames(e));
            %e_data(:,2) = filtfilt(bh,ah,e_data(:,2)); % highpass at 50 Hz
            %e_data(:,2) = abs(e_data(:,2)); %rectify
            %e_data(:,2) = filtfilt(bl,al,e_data(:,2)); %lowpass at 10 Hz
            e_data = interp1( e_data(:,1), e_data(:,2), analog_time_base);
            raw_emg(:,e) = e_data';
        end
        out_struct.emg.data = [analog_time_base' raw_emg];
    else
        disp('No EMG signal found because no channel named ''EMG_*''');
    end
            
    if ~isempty(out_struct.keyboard_events)
        out_struct.keyboard_events = sortrows( out_struct.keyboard_events, [1 2] );
    end
    
    set(0, 'defaulttextinterpreter', defaulttextinterpreter);
    if (verbose == 1)
        close(h);
        wanttosave = questdlg('Do you want to save the output structure?','Save mat file'); 
    
        if(strcmp('Yes',wanttosave))
            savestruct(out_struct);
        else
            disp('The structure was not saved!')
        end
    end
    
    rmpath ./lib_plx
    rmpath ./lib_plx/core_files
    rmpath ./event_decoders
      

%% Subroutines

    % diferentiater function for kinematic signals
    % should differentiate, LP filter at 100Hz and add a zero to adjust for
    % temporal shift
    function dx = kin_diff(x) 
        [b, a] = butter(8, 100/adfreq);
        dx = diff(x) .* adfreq;
        dx = filtfilt(b,a,dx);
        dx = [0 dx];
    end

    % save matfile
    function savestruct(out_struct)
    
        matfilename = out_struct.meta.filename;
        matfilename = strrep(matfilename,'.plx','.mat');  %change '.plx' for '.mat'
        
        [FileName,PathName] = uiputfile( matfilename, 'Save mat file');
        
        fullfilename = fullfile(PathName, FileName);
        
        if isequal(FileName,0) || isequal(PathName,0)
            disp('The structure was not saved!')
        else
            save(fullfilename, 'out_struct');
            disp(['File: ', fullfile(PathName, FileName),' saved successfully'])
        end
    end

end % close outermost function
    
    
    
