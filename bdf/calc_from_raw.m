function out_struct = calc_from_raw(raw_struct, opts)
% CALC_FROM_RAW populates the commonly used intermediate values within a
% BDF, using bdf.raw as the inputs for the calculation.

% $Id$

%% Initial setup

%    addpath ./event_decoders

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

    if opts.verbose==1
        disp('Reading continuous data...')
    end
  

%% Find task by start trial code
  
    center_out_task=0;
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
            elseif (start_trial_code >= hex2dec('11') && start_trial_code <= hex2dec('15')) ||...
                    start_trial_code == hex2dec('1a') || start_trial_code == hex2dec('1c')
                robot_task = 1;
                if start_trial_code == hex2dec('11')
                    center_out_task = 1;
                end
            elseif start_trial_code == hex2dec('1B')
                robot_task = 1;
            elseif start_trial_code == hex2dec('19')
                ball_drop_task = 1;
            elseif start_trial_code == hex2dec('16')
                multi_gadget_task = 1;
            else
                %close(h);
                error('BDF:unkownTask','Unknown behavior task with start trial code 0x%X',start_trial_code);
            end

        end
    else
        warning('BDF:noWords','No WORDs are present');
    end
    
%% Compile analog data
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
    
%% Position and Force for Robot Task
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

            if isfield(opts,'labnum')&& opts.labnum==2 %If lab2 was used for data collection
                l1=24.0; l2=23.5;
            else
                l1 = 25.0; l2 = 26.8;   %use lab1 robot arm lengths as default
            end
            th_t = out_struct.raw.enc(:,1); % encoder time stamps

            [b,a] = butter(8, 100/adfreq);

            th_1 = out_struct.raw.enc(:,2) * 2 * pi / 18000;
            th_2 = out_struct.raw.enc(:,3) * 2 * pi / 18000;
            th_1_adj = filtfilt(b, a, interp1(th_t, th_1, analog_time_base));
            th_2_adj = filtfilt(b, a, interp1(th_t, th_2, analog_time_base));
            
            th_1_adj = smooth(th_1_adj, 51)';
            th_2_adj = smooth(th_2_adj, 51)';
            
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

    
    
%% Force Handle Analog Signals
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

            % Check date of recording to see if it's before or after the
            % change to force handle mounting.
            if datenum(out_struct.meta.datetime) < datenum('5/27/2010')            
                fhcal = [ 0.1019 -3.4543 -0.0527 -3.2162 -0.1124  6.6517; ...
                         -0.1589  5.6843 -0.0913 -5.8614  0.0059  0.1503]';
                rotcal = [0.8540 -0.5202; 0.5202 0.8540];                
                force_offsets = [-0.1388 0.1850 0.2288 0.1203 0.0043 0.2845];
                Fy_invert = -1; % old force setup was left hand coordnates.
            else
                fhcal = [0.0039 0.0070 -0.0925 -5.7945 -0.1015  5.7592; ...
                        -0.1895 6.6519 -0.0505 -3.3328  0.0687 -3.3321]';
                rotcal = [1 0; 0 1];                
                force_offsets = [-.73 .08 .21 -.23 .25 .44];
                Fy_invert = 1;
            end % datenum(out_struct.meta.datetime) < datenum('5/27/2010')
            
            [b,a] = butter(4, 20/adfreq);
            raw_force = zeros(length(analog_time_base), 6);
            for c = 1:6
                channame = sprintf('ForceHandle%d', c);
                a_data = get_analog_signal(out_struct, channame);
                a_data = filtfilt(b, a, a_data);
                a_data = interp1( a_data(:,1), a_data(:,2), analog_time_base);
                raw_force(:,c) = a_data';
            end

            force_offsets = repmat(force_offsets, length(raw_force), 1);
            out_struct.force = (raw_force - force_offsets) * fhcal * rotcal;
            out_struct.force(:,2) = Fy_invert.*out_struct.force(:,2); % fix left hand coords in old force
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
    end % opts.force

%% Eye-Tracker (analog) data

if opts.eye
    eye_channels = find( strncmp(out_struct.raw.analog.channels, 'POG', 3) ); %#ok<EFIND>
    if(~isempty(eye_channels))
        
%------------init matrices/get raw data-----------------------------------
        %initialize  matrices... size = (length 2), in form [ t a ]
        x_data  = zeros( length(analog_time_base), 2 ); %#ok<NASGU>
        y_data  = zeros( length(analog_time_base), 2 ); %#ok<NASGU>
        raw_eye = zeros( length(analog_time_base), 3 );
        t = 1;      %naming "raw_eye" indices
        x = 2;
        y = 3;
        b = -4;%0.4;      %blink filter lower voltage limit
        
        x_data = get_analog_signal(out_struct, 'POGX');
        y_data = get_analog_signal(out_struct, 'POGY');
        
        raw_eye(:,t) = analog_time_base';                                 %time stamp
        raw_eye(:,x) = x_data( 1:length(analog_time_base), 2 );           %x-coord
        raw_eye(:,y) = y_data( 1:length(analog_time_base), 2 );           %y-coord
%------------end initialization-------------------------------------------
 
%--------------------------BLINK FILTER; NO POSITION DATA IN OUTPUT-------------------        
% THIS WILL NEED TO BE CHANGED TO ACCOMODATE THE CHANGE TO RAW DATA
filter = 0;
if filter
        t_valid      = zeros( length( (raw_eye(:,x) > b)), 1 );  %#ok<NASGU>
        x_valid      = zeros( length( (raw_eye(:,x) > b)), 1 );  %#ok<NASGU> %generating null arrays in prep.
        y_valid      = zeros( length( (raw_eye(:,x) > b)), 1 );  %#ok<NASGU>
        
        t_valid      = raw_eye( (raw_eye(:,x) > b), t );
        x_valid      = raw_eye( (raw_eye(:,x) > b), x ); %filtering out data from "blinks" (y-values below zero - any time no pupil diameter is detected by system)
        y_valid      = raw_eye( (raw_eye(:,x) > b), y ); %FUTURE WORK: modify filter to interpolate POG values during blinks
        
        %Now to process the raw data (analog voltages): transform voltage
        %levels to x/y values
        s_unit = 5/409.5;               %some constant used in transformation (from Alex's "plot_pog.m" code)
        
        % initializing low pass filter for pog
        [b,a]        = butter(9,.4); %values from Alex's 'plot_pog' code; have not checked to see how optimal they are
        filter       = 0;             %currently only able to change this *in the code* (right here)

        %applying filter if wanted //Butterworth low pass
        if filter
            x_valid  = filtfilt( b, a, x_valid );
            y_valid  = filtfilt( b, a, y_valid );
        end
else
    t_valid = raw_eye(:,t);
    x_valid = raw_eye(:,x);
    y_valid = raw_eye(:,y);
end
        
        % converting coordinate systems (analog output to pog)*(to cm)
        % Monitor size = 304.1mm x 228.1mm
        % No. of Vertical POG Units: 240  |||  No. of Horiz. POG Units: 256
        %x_valid      = ( (x_valid/s_unit) - 130 );% / ( 10*(304.1/256) );     %converting for screen resolution difference (E/T coords not same as behavior screen coords)
        %y_valid      = (-1)*( (y_valid/s_unit) - 120 );% / ( 10*(228.1/240) )*(-1);
        
        %finalizing output values
        out_struct.eye = [ t_valid x_valid y_valid ];
%---------------------------END BLINK FILTER-----------------------------------------        
        

%-----------------------------NO BLINK FILTER; OUTPUT INCL. POSITION DATA------------        
%     [ code has been cut out and pasted into a .txt file on David's computer; if
%       re-inserted, must also remove "blink filter" section of this cell (which
%       also exists in the .txt file; also, be sure to make "raw_eye" 5 columns
%       wide in initialization]
%-----------------------------END NO BLINK FILTER (code avail in .txt file)----------

        
    end         %ending "if(~isempty(eye_channels))"
end             %ending "if opts.eye"

%% Stimulator serial data
    if (isfield(out_struct.raw,'serial') && ~isempty(out_struct.raw.serial))

        % Getting serial data
        if opts.verbose
            disp('Aggregating data... get serial data')
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
  


%% Extract target info from databursts
     if (isfield(out_struct,'databursts') && ~isempty(out_struct.databursts) && (wrist_flexion_task || multi_gadget_task || center_out_task) )

        if opts.verbose
            disp('Aggregating data... extracting target information');
        end
        
        num_trials = size(out_struct.databursts,1);
                
        out_struct.targets.corners = zeros(num_trials,5,'single');
        
        if wrist_flexion_task
            burst_size = 34;
            num_burst = 0;
            out_struct.targets.rotation = zeros(num_trials,2,'single');            
            for i=1:num_trials
                if size(out_struct.databursts{i,2})~=burst_size
                    warning('calc_from_raw: Inconsistent Databurst at Time %.4f',out_struct.databursts{i,1});
                else
                    num_burst = num_burst+1;
                    out_struct.targets.corners(num_burst,2:5)=bytes2float(out_struct.databursts{i,2}(burst_size-15:end));
                    out_struct.targets.corners(num_burst,1)=out_struct.databursts{i,1};
                    out_struct.targets.rotation(num_burst,1)=out_struct.databursts{i,1};
                    out_struct.targets.rotation(num_burst,2)=bytes2float(out_struct.databursts{i,2}(15:18));
                end
            end
            out_struct.targets.rotation = out_struct.targets.rotation(1:num_burst,:);
            out_struct.targets.corners  = out_struct.targets.corners(1:num_burst,:);
        elseif center_out_task
            burst_size = 30;
            for i=1:num_trials
                if size(out_struct.databursts{i,2})~=burst_size
                    warning('calc_from_raw: Inconsistent Databurst at Time %.4f',out_struct.databursts{i,1});
                else
                    out_struct.targets.corners(i,2:5)=bytes2float(out_struct.databursts{i,2}(burst_size-15:end));
                    out_struct.targets.corners(i,1)=out_struct.databursts{i,1};
                end
            end
        else
            burst_size = 18;
            for i=1:num_trials
                out_struct.targets.corners(i,2:5)=bytes2float(out_struct.databursts{i,2}(burst_size-15:end));
                out_struct.targets.corners(i,1)=out_struct.databursts{i,1};
            end
        end
     end
    
%% Get Keyboard_events
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
end % close outermost function
