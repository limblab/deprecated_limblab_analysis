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
% |
% +-- META   - Metadata
%     |
%     +-- FILENAME
%     +-- DATETIME
%     +-- DURATION
%     +-- LAB      - contains the labnum specifying which lab we think this
%     |              file was recorded in. (used to calculate pos from angles)
%     +-- BDF_INFO - contains information about the version of
%                    get_plexon_data used to create the BDF

% $Id$

    % make sure LaTeX is turned off and save the old state so we can turn
    % it back on at the end
    defaulttextinterpreter = get(0, 'defaulttextinterpreter'); 
    set(0, 'defaulttextinterpreter', 'none');
    
    % Initial setup
    opts = struct('verbose', 0, 'progbar', 0, 'force', 1, 'kin', 1, 'eye', 1, 'labnum', 2);
    
    if (nargin == 1)
        filename = varargin{1};
    else
        filename = varargin{1};
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
                warning('GetPlxData:InvalidOption','NoKin option not currently implemented');
            elseif isnumeric(varargin{i})
                opts.labnum=varargin{i};    %Allow entering of the lab number               
            else 
                error('Unrecognized option: %s', opt_str);
            end
        end
    end

    if (opts.verbose)
        disp(sprintf('Opening: %s', filename));
    end
    
    %progress = 0;
    %if (verbose == 1)
    %    h = waitbar(0, sprintf('Opening: %s', filename));
    %else
    %    h = 0;
    %end
        
%% Data From PLX File    

    % Get MetaData
    [tscounts, wfcounts, evcounts] = plx_info(filename,0);
    [OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreThresh, ...
        SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, ...
        DateTime] = plx_information(filename);
    
    temp = findstr(DateTime,':')+1;
    if strcmp(DateTime(temp(1)),' ')
        DateTime(temp(1)) = '0';
    end
    if strcmp(DateTime(temp(2)),' ')
        DateTime(temp(2)) = '0';
    end
    
    out_struct.meta = struct('filename', OpenedFileName, 'datetime', ...
        DateTime,'duration', Duration, 'lab', opts.labnum, ...
        'bdf_info', '$Id$');

    % Extract data from plxfile
    out_struct.units = get_units_plx(filename, opts);
    out_struct.raw = get_raw_plx(filename, opts);    
    out_struct.keyboard_events = get_keyboard_plx(filename, opts);
    
%% Clean up
    set(0, 'defaulttextinterpreter', defaulttextinterpreter);

%% Extract data from the raw struct
    
    out_struct = calc_from_raw(out_struct,opts);

    if opts.verbose
        disp('Done')
    end
    
end
