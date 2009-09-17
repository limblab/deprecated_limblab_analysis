function out_struct = calc_from_raw(raw_struct, opts)
% CALC_FROM_RAW populates the commonly used intermediate values within a
% BDF, using bdf.raw as the inputs for the calculation.

% $Id$

%% Initial setup

    addpath ./event_decoders

    % make sure LaTeX is turned off and save the old state so we can turn
    % it back on at the end
    %defaulttextinterpreter = get(0, 'defaulttextinterpreter'); 
    %set(0, 'defaulttextinterpreter', 'none');
    
    % Parse arguments
    out_struct = raw_struct;

    %progress = 0;
    %if (verbose == 1)
    %    h = waitbar(progress, 'Aggregating data...');
    %else
    %    h = 0;
    %end

    if opts.verbose
        disp('Reading continuous data...')
    end

%% Calculated Data
  
    robot_task = 0;
    wrist_flexion_task =0;
    ball_drop_task = 0;
    multi_gadget_task=0;
    % figure out which behavior is running if words are available
    if (isfield(out_struct.raw,'words') && ~isempty(out_struct.raw.words))
        
        [out_struct.words, out_struct.databursts] = extract_datablocks(out_struct.raw.words);
        start_trial_words = out_struct.words( bitand(hex2dec('f0'),out_struct.words(:,2)) == hex2dec('10') ,2);
        if ~isempty(start_trial_words)
            start_trial_code = start_trial_words(1);
            if ~isempty(find(start_trial_words ~= start_trial_code, 1))
%                close(h);
%                error('BDF:inconsistentBehaviors','Not all trials are the same type');
            end

            if start_trial_code == hex2dec('17')
                wrist_flexion_task = 1;
            elseif start_trial_code >= hex2dec('11') && start_trial_code <= hex2dec('15')
                robot_task = 1;
            elseif start_trial_code == hex2dec('19')
                ball_drop_task = 1;
            elseif start_trial_code == hex2dec('16')
                multi_gadget_task = 1;
            else
                close(h);
                error('BDF:unkownTask','Unknown behavior task with start trial code 0x%X',start_trial_code);
            end

        end
    else
        warning('BDF:noWords','No WORDs are present');
    end
    
    % Compile analog data
    if isfield(out_struct.raw, 'analog') && ~isempty(out_struct.raw.analog.data)
            
        % The highest analog sample rate (local copy)
        adfreq = max(out_struct.raw.analog.adfreq);
        
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
        if robot_task
            % Position
            %if (verbose == 1)
            %    progress = progress + .05;
            %    waitbar(progress, h, sprintf('Aggregating data...\nget position'));
            %end
            if opts.verbose
                disp('Aggregating data... get position')
            end

            if ~exist('adfreq','var')
                % There was no analog data, so we need a default timebase for
                % the encoder
                adfreq = 1000; %Arbitrarily 1KHz
                start_time = 1.0;
                last_enc_time = out_struct.raw.enc(end,1);
                stop_time = floor(last_enc_time) - 1;
                analog_time_base = start_time:1/adfreq:stop_time;
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
            out_struct.pos = [out_struct.raw.enc(:,1) out_struct.raw.enc(:,2)/1000 out_struct.raw.enc(:,3)/1000];
        end
    else
        if robot_task
            close(h);
            error('BDF:noPositionSignal','No position signal present');
        end
    end

    
    
    % Force Handle Analog Signals
    if opts.force
        force_channels = find( strncmp(out_struct.raw.analog.channels, 'ForceHandle', 11) ); %#ok<EFIND>
        if (~isempty(force_channels))
            %if (verbose == 1)
            %    progress = progress + .05;
            %    waitbar(progress, h, sprintf('Aggregating data...\nget force'));
            %end

            if opts.verbose
                disp('Aggregating data... get force')
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
            if (robot_task)
                warning('BDF:noForceSignal','No force handle signal found because no channel named ''ForceHandle*''');
            end
        end

        % Force (Cursor Pos) for Wrist Flexion and MG tasks
        % (or just Force_x for MG task when recording stim evoked
        %  force with air pressure device)
        %% Contrarily to previous analog data, we don't want to skip the first
        %% second of data.    
        force_channels = find( strncmp(out_struct.raw.analog.channels, 'Force_', 6) | strncmp(out_struct.raw.analog.channels,'force_',6) ); %#ok<EFIND>
        if isempty(force_channels)
            if wrist_flexion_task || multi_gadget_task
                close(h);
                error('BDF:noForceSignal','No force signal found because no channel named ''Force_*''');
            end
        else
            % Getting Force
            %if (verbose == 1)
            %    progress = progress + .05;
            %    waitbar(progress, h, sprintf('Aggregating data...\nget force'));
            %end
        
            %verify that all force channels are rec with same sampling rate
            if ~all(out_struct.raw.analog.adfreq(force_channels)== out_struct.raw.analog.adfreq(force_channels(1)))
                close(h);
                error('BDF:unequalForceFreqs','Not all Force channels have the same sampling frequency');
            else
                out_struct.force.forcefreq = out_struct.raw.analog.adfreq(force_channels(1));
            end

            % extract force data for WF and MG task here
            out_struct.force.labels = out_struct.raw.analog.channels(force_channels);
            out_struct.force.data = zeros(size(out_struct.raw.analog.data{force_channels(1)},1),length(force_channels)+1);

            for i=1:length(force_channels)
                out_struct.force.data(:,[1 i+1]) = get_analog_signal(out_struct, out_struct.force.labels{i});
            end
        end
    end % opts.force
    
    % Stimulator serial data
    if (isfield(out_struct.raw,'serial') && ~isempty(out_struct.raw.serial))
        % Getting serial data
        if (verbose == 1)
            progress = progress + .05;
            waitbar(progress, h, sprintf('Aggregating data...\nget serial data'));
        end

        %find the first parameter that correspond to the command, in case
        %it was not the first received
        row_lag = 0;
        first_cmd = out_struct.raw.serial(row_lag+1, 2);
        while first_cmd<hex2dec('C0') || first_cmd>hex2dec('FA')
            row_lag = row_lag+1;
            first_cmd = out_struct.raw.serial(row_lag+1, 2);
        end
        
        %number of rows in serial data from first command parameter to
        %last parameter of last complete stim update
        num_rows = size(out_struct.raw.serial,1);
        num_valid_rows = num_rows-row_lag-mod(num_rows-row_lag,5);
        
        out_struct.stim = zeros(num_valid_rows/5,7);
        stim_cmd_index = 0;
        
        %for every fifth row of bdf.raw.serial, starting with the first command row, add
        %entry to bdf.stim
        for row_count = row_lag+1:5:num_valid_rows-4
            
            stim_cmd_index=stim_cmd_index+1;
            cmd  = bitshift(bitand(out_struct.raw.serial(row_count, 2),hex2dec('F0')),-4);
            
            %verify that the cmd param make sense, not a very robust way
            %to determine if there is a missing byte...
            if cmd == 0
                continue;
            elseif cmd<12 || cmd > 15
                warning('BDF:missingSerialByte','The serial data is inconsistent at ts=%d.\nThe serial data field will not be populated',ts);
                out_struct.stim =  [];
                break;
            end
            
            % calculate parameters
            ts = out_struct.raw.serial(row_count+4,1); %ts of the last serial byte of that command
            chan = bitand(out_struct.raw.serial(row_count, 2),hex2dec('0F'));
            freq = out_struct.raw.serial((row_count+1), 2) ;
            I = out_struct.raw.serial((row_count+2), 2)/10 ;
            PW = out_struct.raw.serial((row_count+3), 2) ;
            NP = out_struct.raw.serial((row_count+4), 2) ;
            
            % put them into stim field
            out_struct.stim(stim_cmd_index,:) = [ts cmd chan freq I PW NP];
        end
    end    
  



    if (isfield(out_struct,'databursts') && ~isempty(out_struct.databursts) && (wrist_flexion_task || multi_gadget_task) )
        if (verbose == 1)
            progress = progress + .05;
            waitbar(progress, h, sprintf('Aggregating data...\nextracting targets'));
        end
        
        out_struct.targets.corners = zeros(length(out_struct.databursts),5);
        out_struct.targets.rotation = zeros(length(out_struct.databursts),2);
        for i=1:length(out_struct.databursts)
            out_struct.targets.corners(i,2:5)=bytes2float(out_struct.databursts{i,2}(7:22));
            out_struct.targets.corners(i,1)=out_struct.databursts{i,1};
            out_struct.targets.rotation(i,1)=out_struct.databursts{i,1};
            out_struct.targets.rotation(i,2)=bytes2float(out_struct.databursts{i,2}(3:6));
        end
    end
            
    if (isfield(out_struct,'keyboard_events') && ~isempty(out_struct.keyboard_events))
        out_struct.keyboard_events = sortrows( out_struct.keyboard_events, [1 2] );
    end
          
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
            disp(['File: ', fullfilename,' saved successfully']);
        end
    end

end % close outermost function
