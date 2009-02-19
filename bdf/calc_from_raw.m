function out_struct = calc_from_raw(varargin)
% CALC_FROM_RAW populates the commonly used intermediate values within a
% BDF, using bdf.raw as the inputs for the calculation.

% $Id$

%% Initial setup

    addpath ./event_decoders
    
    % make sure LaTeX is turned off and save the old state so we can turn
    % it back on at the end
    defaulttextinterpreter = get(0, 'defaulttextinterpreter'); 
    set(0, 'defaulttextinterpreter', 'none');
    
    % Parse arguments
    if (nargin == 1)
        out_struct = varargin{1};
        verbose    = 0;
    elseif (nargin == 2)
        out_struct = varargin{1};
        verbose    = varargin{2};
    else
        error ('Invalid number of arguments');
    end

    progress = 0;
    if (verbose == 1)
        h = waitbar(progress, 'Aggregating data...');
    else
        h = 0;
    end


%% Calculated Data
    
    % The highest analog sample rate (local copy)
    adfreq = max(out_struct.raw.analog.adfreq);
    
    robot_task = 0;
    wrist_flexion_task =0;
    ball_drop_task = 0;
    % figure out which behavior is running if words are available
    if (isfield(out_struct.raw,'words') && ~isempty(out_struct.raw.words))
        
        [out_struct.words, out_struct.databursts] = extract_datablocks(out_struct.raw.words);
        start_trial_words = out_struct.words( bitand(hex2dec('f0'),out_struct.words(:,2)) == hex2dec('10') ,2);
        if ~isempty(start_trial_words)
            start_trial_code = start_trial_words(1);
            if ~isempty(find(start_trial_words ~= start_trial_code, 1))
                close(h);
                error('BDF:inconsistentBehaviors','Not all trials are the same type');
            end

            if start_trial_code == hex2dec('17')
                wrist_flexion_task = 1;
            elseif start_trial_code >= hex2dec('11') && start_trial_code <= hex2dec('15')
                robot_task = 1;
            elseif start_trial_code == hex2dec('19')
                ball_drop_task = 1;
            else
                close(h);
                error('BDF:unkownTask','Unknown behavior task with start trial code 0x%X',start_trial_code);
            end

        end
    else
        warning('BDF:noWords','No WORDs are present');
    end
    
    % Compile analog data
    if isfield(out_struct.raw, 'analog') && ~isempty(out_struct.raw.analog)
        start_time = 1.0;
        last_analog_time = min([out_struct.raw.analog.ts{:}] + ...
            cellfun('length',out_struct.raw.analog.data) / out_struct.raw.analog.adfreq);
        if isfield(out_struct.raw,'enc') && ~isempty(out_struct.raw.enc)
            last_enc_time = out_struct.raw.enc(end,1);
            stop_time = floor( min( [last_enc_time last_analog_time] ) ) - 1;
        else
            stop_time = floor(last_analog_time)-1;
        end
        
        % Note: This uses the time base of the highest frequency analog
        % signal as the time base for interpolated signals like position
        analog_time_base = start_time:1/adfreq:stop_time;
    end
    
    %Position and Force for Robot Task
    if (isfield(out_struct.raw,'enc') && ~isempty(out_struct.raw.enc))
        % Position
        if (verbose == 1)
            progress = progress + .05;
            waitbar(progress, h, sprintf('Aggregating data...\nget position'));
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
    else
        if robot_task
            close(h);
            error('BDF:noPositionSignal','No position signal present');
        end
    end
    
    % Force Handle Analog Signals
    force_channels = find( strncmp(out_struct.raw.analog.channels, 'ForceHandle', 11) );
    if (~isempty(force_channels))
        if (verbose == 1)
            progress = progress + .05;
            waitbar(progress, h, sprintf('Aggregating data...\nget force'));
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
    else
        if robot_task
            warning('BDF:noForceSignal','No force handle signal found because no channel named ''ForceHandle*''');
        end
    end

    % Force (Cursor Pos) for Wrist Flexion task
    
    force_channels = find( strncmp(out_struct.raw.analog.channels, 'Force_', 6) ); %#ok<EFIND>
    if ~isempty(force_channels)
        % Getting Force
        if (verbose == 1)
            progress = progress + .05;
            waitbar(progress, h, sprintf('Aggregating data...\nget force'));
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
        if wrist_flexion_task
            close(h);
            error('BDF:noForceSignal','No force signal found because no channel named ''Force_*''');
        end
    end
    
    % EMGs
    emg_channels = find( strncmp(out_struct.raw.analog.channels, 'EMG_', 4) ); %#ok<EFIND>
    if ~isempty(emg_channels)
        if (verbose == 1)
            progress = progress + .05;
            waitbar(progress, h, sprintf('Aggregating data...\nget EMGs'));
        end
        
        % ensure all emg channels have the same frequency
        if ~all(out_struct.raw.analog.adfreq(emg_channels) == ...
                out_struct.raw.analog.adfreq(emg_channels(1)))
            close(h);
            error('BDF:unequalEmgFreqs','Not all EMG channels have the same frequency');
        end
        emg_freq = out_struct.raw.analog.adfreq(emg_channels(1));
        emg_time_base = start_time:1/emg_freq:stop_time;
        % extract emg channel data here
        out_struct.emg.emgnames = out_struct.raw.analog.channels(emg_channels);
        
        % Filtering
        % highpassfreq = 50; %50Hz
        % lowpassfreq = 5; %10Hz
        % [bh,ah] = butter(4, highpassfreq*2/emg_freq, 'high');
        % [bl,al] = butter(4, lowpassfreq*2/emg_freq, 'low');
        raw_emg = zeros(length(emg_time_base), length(emg_channels));
        for e = 1:(length(emg_channels))
            e_data = get_analog_signal(out_struct, out_struct.emg.emgnames(e));
            % e_data(:,2) = filtfilt(bh,ah,e_data(:,2)); % highpass at 50 Hz
            % e_data(:,2) = abs(e_data(:,2)); %rectify
            % e_data(:,2) = filtfilt(bl,al,e_data(:,2)); %lowpass at 10 Hz
            e_data = interp1( e_data(:,1), e_data(:,2), emg_time_base);
            raw_emg(:,e) = e_data';
        end
        out_struct.emg.data = [emg_time_base' raw_emg];
    else
        warning('BDF:noEmgSignal','No EMG signal found because no channel named ''EMG_*''');
    end
            
    if (isfield(out_struct,'keyboard_events') && ~isempty(out_struct.keyboard_events))
        out_struct.keyboard_events = sortrows( out_struct.keyboard_events, [1 2] );
    end
    
%% Clean up
    if (verbose == 1)
        close(h);
        wanttosave = questdlg('Do you want to save the output structure?','Save mat file'); 
    
        if(strcmp('Yes',wanttosave))
            savestruct(out_struct);
        else
            disp('The structure was not saved!')
        end
    end

    rmpath ./event_decoders
    
    set(0, 'defaulttextinterpreter', defaulttextinterpreter);
      

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
        matfilename = strrep(matfilename,'.nev','.mat');  %change '.nev' for '.mat'
        
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
