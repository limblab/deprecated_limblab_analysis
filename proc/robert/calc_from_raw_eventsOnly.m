function out_struct = calc_from_raw(raw_struct, opts)
% CALC_FROM_RAW populates the commonly used intermediate values within a
% BDF, using bdf.raw as the inputs for the calculation.

% $Id: calc_from_raw.m 541 2011-06-28 18:51:40Z ricardo $

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
    random_walk_task=0;
    % figure out which behavior is running if words are available
    if (isfield(out_struct.raw,'words') && ~isempty(out_struct.raw.words))
        
        [out_struct.words, out_struct.databursts] = extract_datablocks(out_struct.raw.words);
        start_trial_words = out_struct.words( bitand(hex2dec('f0'),out_struct.words(:,2)) == hex2dec('10') ,2);
        if ~isempty(start_trial_words)
            start_trial_code = start_trial_words(1);
%            if ~isempty(find(start_trial_words ~= start_trial_code, 1))
%                close(h);
%                error('BDF:inconsistentBehaviors','Not all trials are the same type');
%            end

            if start_trial_code == hex2dec('17')
                wrist_flexion_task = 1;
            elseif (start_trial_code >= hex2dec('11') && start_trial_code <= hex2dec('15')) ||...
                    start_trial_code == hex2dec('1a') || start_trial_code == hex2dec('1c') ||...
                    start_trial_code == hex2dec('18')
                robot_task = 1;
                if start_trial_code == hex2dec('11')
                    center_out_task = 1;
                elseif start_trial_code == hex2dec('12')
                    random_walk_task = 1;
                end
            elseif start_trial_code == hex2dec('1B')
                robot_task = 1;
            elseif start_trial_code == hex2dec('19')
                ball_drop_task = 1;
            elseif start_trial_code == hex2dec('16')
                multi_gadget_task = 1;
            elseif start_trial_code == hex2dec('1D')
                robot_task = 1;
            else
                %close(h);
                error('BDF:unkownTask','Unknown behavior task with start trial code 0x%X',start_trial_code);
            end

        end
    else
        warning('BDF:noWords','No WORDs are present');
    end
    
    out_struct.raw=[];
%% Compile analog data
    if isfield(out_struct.raw, 'analog') && ~isempty(out_struct.raw.analog.data)
            
        % The highest analog sample rate (local copy)
        adfreq = max(out_struct.raw.analog.adfreq);
        
        start_time = floor(1.0 + out_struct.raw.analog.ts{1});
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
    if (isfield(out_struct.raw,'enc') && ~isempty(out_struct.raw.enc) && opts.kin)
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
            elseif isfield(opts,'labnum')&& opts.labnum==3 %If lab3 was used for data collection
                l1=25.0; l2=23.5;                
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
        if robot_task && opts.kin
%            close(h);
%             error('BDF:noPositionSignal','No position signal present');
        end
    end

    
%% Force Handle Analog Signals
    if 0 % robot_task && opts.force 
        force_channels = find( strncmp(out_struct.raw.analog.channels, 'ForceHandle', 11) ); %#ok<EFIND>
        if (~isempty(force_channels))

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
            elseif datenum(out_struct.meta.datetime) < datenum('6/28/2011')
                fhcal = [0.0039 0.0070 -0.0925 -5.7945 -0.1015  5.7592; ...
                        -0.1895 6.6519 -0.0505 -3.3328  0.0687 -3.3321]';
                rotcal = [1 0; 0 1];                
                force_offsets = [-.73 .08 .21 -.23 .25 .44];
                Fy_invert = 1;
            else
                % Fx,Fy,scaleX,scaleY from ATI calibration file:
                % \\citadel\limblab\Software\ATI FT - March
                % 2011\Calibration\FT7520.cal
                % fhcal = [Fx;Fy]./[scaleX;scaleY]
                % force_offsets acquired empirically by recording static
                % handle.
                fhcal = [-0.0129 0.0254 -0.1018 -6.2876 -0.1127 6.2163;...
                        -0.2059 7.1801 -0.0804 -3.5910 0.0641 -3.6077]'./1000;
                rotcal = [1 0; 0 1];                
                force_offsets = [-1888.095 -1160.662 1032.623...
                    -998.567 809.171 2836.314];
                Fy_invert = 1;
            end 
            
            [b,a] = butter(4, 20/adfreq);
            raw_force = zeros(length(analog_time_base), 6);
            for c = 1:6
                channame = sprintf('ForceHandle%d', c);
                a_data = get_analog_signal(out_struct, channame);
                a_data(:,2) = filtfilt(b, a, a_data(:,2));
%                 a_data(:,2) = filtfilt(b, a, a_data(:,2));
                a_data = interp1( a_data(:,1), a_data(:,2), analog_time_base);
                raw_force(:,c) = a_data';
            end

            force_offsets = repmat(force_offsets, length(raw_force), 1);
            out_struct.force = (raw_force - force_offsets) * fhcal * rotcal;
            clear force_offsets; % cleanup a little
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

if 0 % opts.eye
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
% with variable 'filter' = 0, no boundary filter imposed
filter = 0;
if filter
        t_valid      = zeros( length( (raw_eye(:,x) > b)), 1 );  %#ok<NASGU>
        x_valid      = zeros( length( (raw_eye(:,x) > b)), 1 );  %#ok<NASGU> %generating null arrays in prep.
        y_valid      = zeros( length( (raw_eye(:,x) > b)), 1 );  %#ok<NASGU>
        
        t_valid      = raw_eye( (raw_eye(:,x) > b), t );
        x_valid      = raw_eye( (raw_eye(:,x) > b), x ); %filtering out data from "blinks" (y-values below zero - any time no pupil diameter is detected by system)
        y_valid      = raw_eye( (raw_eye(:,x) > b), y ); %FUTURE WORK: modify filter to interpolate POG values during blink
        
        % initializing low pass filter for pog
        [b,a]        = butter(9,.4); %values from Alex's 'plot_pog' code; have not checked to see how optimal they are
        filter       = 0;             %currently only able to change this *in the code* (right here)

        %applying filter if wanted //Butterworth low pass
        if filter
            x_valid  = filtfilt( b, a, x_valid );
            y_valid  = filtfilt( b, a, y_valid );
        end
else %not filtering data at all (current process: do all filtering later; will incorporate blink filter/interpolation/etc. into this later)
    t_valid = raw_eye(:,t);
    x_valid = raw_eye(:,x);
    y_valid = raw_eye(:,y);
end
        %Now to process the raw data (analog voltages): transform voltage
        %levels to x/y values
        %s_unit = 5/409.5;               %some constant used in transformation (from Alex's "plot_pog.m" code)
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
        
        out_struct.stim = get_stim_commands(out_struct);
    end    
  
%% Extract target info from databursts
     if (isfield(out_struct,'databursts') && ~isempty(out_struct.databursts) )

        if opts.verbose
            disp('Aggregating data... extracting target information');
        end
        
        num_trials = size(out_struct.databursts,1);
        num_burst = 0;
        burst_size = out_struct.databursts{1,2}(1);
                
        if (wrist_flexion_task ||multi_gadget_task || center_out_task)
%               burst_size = 34; %newest version as of 08-2010
%               burst_size = 22; %for older files
            out_struct.targets.corners = zeros(num_trials,5);
            out_struct.targets.rotation = zeros(num_trials,2);            
            for i=1:num_trials
                if size(out_struct.databursts{i,2})~=burst_size
                    warning('calc_from_raw: Inconsistent Databurst at Time %.4f',out_struct.databursts{i,1});
                else
                    num_burst = num_burst+1;
                    out_struct.targets.corners(num_burst,2:5)=bytes2float(out_struct.databursts{i,2}(burst_size-15:end));
                    out_struct.targets.corners(num_burst,1)=out_struct.databursts{i,1};
                    if wrist_flexion_task
                        out_struct.targets.rotation(num_burst,1)=out_struct.databursts{i,1};
                        out_struct.targets.rotation(num_burst,2)=bytes2float(out_struct.databursts{i,2}(burst_size-19:burst_size-16));
                    end
                end
            end
            out_struct.targets.rotation = out_struct.targets.rotation(1:num_burst,:);
            out_struct.targets.corners  = out_struct.targets.corners(1:num_burst,:);
        elseif random_walk_task
            num_targets = (burst_size - 18)/8;
            out_struct.targets.centers = zeros(num_trials,2+2*num_targets);
            for i=1:num_trials
                if size(out_struct.databursts{i,2})~=burst_size
                    warning('calc_from_raw: Inconsistent Databurst at Time %.4f',out_struct.databursts{i,1});
                else
                    try
                        num_burst = num_burst+1;
                        out_struct.targets.centers(num_burst,1)    =out_struct.databursts{i,1};
                        out_struct.targets.centers(num_burst,2)    =bytes2float(out_struct.databursts{i,2}(15:18));
                        out_struct.targets.centers(num_burst,3:end)=bytes2float(out_struct.databursts{i,2}(19:end));
                    catch
                        warning('calc_from_raw: Inconsistent Databurst at Time %.4f',out_struct.databursts{i,1});
                    end
                end
            end
            out_struct.targets.centers = out_struct.targets.centers(1:num_burst,:);
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
