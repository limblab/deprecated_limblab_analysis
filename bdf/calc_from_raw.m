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
            elseif start_trial_code == hex2dec('1E')
                robot_task = 1;
            elseif start_trial_code == hex2dec('1F')
                robot_task = 1;
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
        
        start_time = floor(1.0 + out_struct.raw.analog.ts{1});
        last_analog_time = min(cellfun(@(x) x(1),out_struct.raw.analog.ts) + ...
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
                if datenum(out_struct.meta.datetime) < datenum('10/05/2012')
                    l1=24.75; l2=23.6;
                elseif datenum(out_struct.meta.datetime) < datenum('17-Jul-2013')
                  l1 = 24.765; l2 = 24.13;
                else
                    l1 = 24.765; l2 = 23.8125;
                end
            else
                l1 = 25.0; l2 = 26.8;   %use lab1 robot arm lengths as default
            end
            % account for mangled encoder timestamps (non-monotonic)
            while ~isempty(out_struct.raw.enc(:,1)) && nnz(diff(out_struct.raw.enc(:,1))<0)
                out_struct.raw.enc(find(diff(out_struct.raw.enc(:,1))<0,1,'last'),:)=[];
            end
            th_t = out_struct.raw.enc(:,1); % encoder time stamps

            [b,a] = butter(8, 100/adfreq);

            th_1 = out_struct.raw.enc(:,2) * 2 * pi / 18000;
            th_2 = out_struct.raw.enc(:,3) * 2 * pi / 18000;
            th_1_adj = interp1(th_t, th_1, analog_time_base);
            th_2_adj = interp1(th_t, th_2, analog_time_base);
            
            th_1_adj(isnan(th_1_adj)) = th_1_adj(find(~isnan(th_1_adj),1,'first')); % when datafile started before encoders were zeroed.
            th_2_adj(isnan(th_2_adj)) = th_2_adj(find(~isnan(th_2_adj),1,'first'));
            
            % Removed encoder filtering, unnecessary.  Still filtering
            % velocity and acceleration
%             th_1_adj = filtfilt(b, a, th_1_adj);
%             th_2_adj = filtfilt(b, a, th_2_adj);      
%             th_1_adj = smooth(th_1_adj, 51)';
%             th_2_adj = smooth(th_2_adj, 51)';
            
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
            
        elseif wrist_flexion_task
            
%             enc_freq = 1000;
            
            time_pos = out_struct.raw.enc(:,1);            
            x_pos = out_struct.raw.enc(:,2)/1000;
            y_pos = out_struct.raw.enc(:,3)/1000;
            
%             %LP filter at 100 Hz:
%             [b, a] = butter(8, 100*2/enc_freq);
%             
%             dx = [0; diff(x_pos)./diff(time_pos)];
%             dx = filtfilt(b,a,dx);
%             dy = [0; diff(y_pos) .* enc_freq];
%             dy = filtfilt(b,a,dy);
%             ddx = [0; diff(dx)./diff(time_pos)];
%             ddx = filtfilt(b,a,ddx);
%             ddy = [0; diff(dy) .* enc_freq];
%             ddy = filtfilt(b,a,ddy);
            
            out_struct.pos = [time_pos x_pos  y_pos];
%             out_struct.vel = [time_pos    dx     dy];
%             out_struct.acc = [time_pos   ddx    ddy];                      
            
        end
    else
        if robot_task && opts.kin
%            close(h);
            error('BDF:noPositionSignal','No position signal present');
        end
    end

    
%% Force Handle Analog Signals
    if robot_task && opts.force 
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
            elseif opts.rothandle
                % Fx,Fy,scaleX,scaleY from ATI calibration file:
                % \\citadel\limblab\Software\ATI FT - March
                % 2011\Calibration\FT7520.cal
                % fhcal = [Fx;Fy]./[scaleX;scaleY]
                % force_offsets acquired empirically by recording static
                % handle.
                fhcal = [-0.0129 0.0254 -0.1018 -6.2876 -0.1127 6.2163;...
                        -0.2059 7.1801 -0.0804 -3.5910 0.0641 -3.6077]'./1000;
                rotcal = [-1 0; 0 1];  
                force_offsets = [306.5423 -847.5678 132.1442 -177.3951 -451.7461 360.2517]; %these offsets computed Jan 14, 2013
                force_offsets = [373.2183 -1017.803 -87.8063 -107.1702 -709.7454 21.6321];
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
                force_offsets = [306.5423 -847.5678  132.1442 -177.3951 -451.7461 360.2517]; %these offsets computed Jan 14, 2013
                Fy_invert = 1;
            end 
            
            [b,a] = butter(4, 200/adfreq);
            raw_force = zeros(length(analog_time_base), 6);
            
            % Calculate force offsets for this particular file
            % Find longest time range of no movement
            temp_d = diff(out_struct.pos(:,2))<.004 & diff(out_struct.pos(:,3))<.004;
            q = diff([0 temp_d(:)' 0]);
            v1 = find(q == 1); v2 = find(q == -1); 
            v = v2-v1;
            [max_v,max_v_ind] = max(v);
            no_mov_idx = v1(max_v_ind):v2(max_v_ind);
            force_offsets_temp = zeros(1,6);
            
            for c = 1:6
                channame = sprintf('ForceHandle%d', c);
                a_data = double(get_analog_signal(out_struct, channame));   
                a_data(:,2) = filtfilt(b, a, a_data(:,2));
                a_data = interp1( a_data(:,1), a_data(:,2), analog_time_base);                
                raw_force(:,c) = a_data';
                force_offsets_temp(c) = mean(a_data(no_mov_idx));
            end
            
            if max_v > 1000  % Only use if there are more than 
                             % 1000 contiguous movement free samples                
                force_offsets = force_offsets_temp;
            end
            
            force_offsets = repmat(force_offsets, length(raw_force), 1);
            out_struct.force = (raw_force - force_offsets) * fhcal * rotcal;
            clear force_offsets; % cleanup a little
            out_struct.force(:,2) = Fy_invert.*out_struct.force(:,2); % fix left hand coords in old force
            
            % Removed stupid loop for calculating rotation matrix of
            % handle, substituted by next 4 lines
%             for p = 1:size(out_struct.force, 1)                
%                 r = [cos(-th_2_adj(p)) sin(th_2_adj(p)); -sin(th_2_adj(p)) cos(th_2_adj(p))];
% %                 r = [cos(th_1_adj(p)) sin(-th_1_adj(p)); -sin(-th_1_adj(p)) cos(-th_1_adj(p))];
%                 % Modified rotation matrix on Jan 15, 2013. Old matrix was
%                 % incorrect, rotating handle force with respect to shoulder
%                 % and not elbow as it should.
%                 out_struct.force(p,:) = out_struct.force(p,:) * r;
%             end

            temp = out_struct.force;            
            out_struct.force(:,1) = temp(:,1).*cos(-th_2_adj)' - temp(:,2).*sin(th_2_adj)';
            out_struct.force(:,2) = temp(:,1).*sin(th_2_adj)' + temp(:,2).*cos(th_2_adj)';
            clear temp
            out_struct.force = [analog_time_base' out_struct.force];

            analog_channels = find(~strncmp(out_struct.raw.analog.channels, 'ForceHandle', 11) &...
                ~isempty(out_struct.raw.analog.channels)); %#ok<EFIND>
            if ~isempty(analog_channels)
                out_struct.analog.ts = analog_time_base;
                for c = 1:length(analog_channels)
                    channame = out_struct.raw.analog.channels{analog_channels(c)};
                    fs = out_struct.raw.analog.adfreq(analog_channels(c));
                    chan_time_base = 1/fs:1/fs:length(out_struct.raw.analog.data{analog_channels(c)})/fs;
                    a_data = get_analog_signal(out_struct, channame);                
                    a_data = interp1(chan_time_base, a_data, analog_time_base);
                    out_struct.analog.channel{c} = channame;
                    out_struct.analog.data{c} = a_data(:,2);
                end
            end
            
        else
            if (robot_task)
                warning('BDF:noForceSignal','No force handle signal found because no channel named ''ForceHandle*''');
            end
            analog_channels = find(~strncmp(out_struct.raw.analog.channels, 'ForceHandle', 11) &...
                ~isempty(out_struct.raw.analog.channels)); %#ok<EFIND>
            if ~isempty(analog_channels)
                out_struct.analog.ts = analog_time_base;
                for c = 1:length(analog_channels)
                    channame = out_struct.raw.analog.channels(c);
                    fs = out_struct.raw.analog.adfreq(c);
                    chan_time_base = 1/fs:1/fs:length(out_struct.raw.analog.data{c})/fs;
                    a_data = double(get_analog_signal(out_struct, channame));
                    a_data = a_data(fs:end-(out_struct.meta.duration-out_struct.vel(end,1))*fs,2);
                    if fs~=adfreq
                        a_data = interp1(chan_time_base, a_data, analog_time_base);
                    end
                    out_struct.analog.channel{c} = channame;
                    out_struct.analog.data{c} = a_data;
                end
            end
        end
    end % opts.force

%% EMG for robot task, making time base same as that for all analog signals
% Chris: you should reconsider and remove the "robot_task" from below!
if robot_task && isfield(out_struct,'emg')
    new_emg = interp1(out_struct.emg.data(:,1), out_struct.emg.data(:,2:end), analog_time_base);
    out_struct.emg.data = [analog_time_base' new_emg];
    out_struct.emg.emgfreq = round(1/mode(diff(analog_time_base(1:1000))));
    clear new_emg;
end        
        
%% Eye-Tracker Analog Signals
if opts.eye
    eye_channels = find( strncmp(out_struct.raw.analog.channels, 'POG', 3) ); %#ok<EFIND>
    if(~isempty(eye_channels))
        
%------------init matrices/get raw data-----------------------------------
        %initialize  matrices... size = (length 2), in form [ t a ]
        x_data  = zeros( length(analog_time_base), 2 ); %#ok<NASGU>
        y_data  = zeros( length(analog_time_base), 2 ); %#ok<NASGU>
        raw_eye = zeros( length(analog_time_base), 3 );
        t = 1;
        x = 2;      %'raw_eye' indices
        y = 3;
        
        x_data = get_analog_signal(out_struct, 'POGX');
        y_data = get_analog_signal(out_struct, 'POGY');
        
        raw_eye(:,t) = analog_time_base';                                 %time stamp
        raw_eye(:,x) = x_data( 1:length(analog_time_base), 2 );           %x-coord
        raw_eye(:,y) = y_data( 1:length(analog_time_base), 2 );           %y-coord
%------------end initialization-------------------------------------------
 

        t_valid = raw_eye(:,t);
        x_valid = raw_eye(:,x);
        y_valid = raw_eye(:,y);

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
        burst_size = median(cellfun(@numel,out_struct.databursts(:,2)));
                
        if (wrist_flexion_task ||multi_gadget_task || center_out_task)
            % burst_size = 34; %newest version as of 08-2010
            % burst_size = 22; %for older files
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
        if size(dx,1)==1
            dx = [0 dx];
        else
            dx = [0;dx];
        end
    end
end % close outermost function
