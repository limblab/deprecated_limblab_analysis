% CALC_FROM_RAW populates the commonly used intermediate values within a
% BDF, using out_struct.raw as the inputs for the calculation.

% $Id: calc_from_raw.m 1817 2015-06-02 00:15:31Z chris $

%% Initial setup

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
    elseif (isfield(opts,'delete_raw') && opts.delete_raw && exist('actual_words','var'))
        [out_struct.words, out_struct.databursts] = extract_datablocks(actual_words);
    end
    if isfield(out_struct,'words')
        start_trial_words = out_struct.words( bitand(hex2dec('f0'),out_struct.words(:,2)) == hex2dec('10') ,2);
        if ~isempty(start_trial_words)
            start_trial_code = start_trial_words(1);

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
            cellfun('length',out_struct.raw.analog.data) ./ out_struct.raw.analog.adfreq);
        if isfield(out_struct.raw,'enc') && ~isempty(out_struct.raw.enc)
            last_enc_time = out_struct.raw.enc(end,1);
            stop_time = floor( min( [last_enc_time last_analog_time] ) ) - 1;
        else
            stop_time = floor(last_analog_time)-1;
        end
        
        % Note: This uses the time base of the highest frequency analog
        % signal as the time base for interpolated signals like position
        analog_time_base = start_time:1/adfreq:stop_time;        
    elseif isfield(opts,'delete_raw') && opts.delete_raw && exist('analog_list','var') && ~isempty(analog_list) && exist('NEVNSx','var') && exist('NSx_info','var')
        adfreq=max(NSx_info.NSx_sampling(analog_list));
        % The start time of each channel.  Note that the NS library
        % function ns_GetTimeByIndex simply multiplies the index by the 
        % ADResolution... so it will always be zero. We want to clip
        % the first second of data so we use 1 here. note that the
        % prior clause of the if statement adds 1 to the minimum value
        % to account for data coming from plexon or TDT systems that
        % may not use this timing scheme
        start_time = 1.0;
        last_analog_time=inf;

        for i = length(analog_list):-1:1
            if NSx_info.NSx_sampling(analog_list(i))==1000
                last_analog_time = min(length(NEVNSx.NS2.Data(NSx_info.NSx_idx(analog_list(i)),:))/1000,last_analog_time);
            elseif NSx_info.NSx_sampling(analog_list(i))==2000
                last_analog_time = min(length(NEVNSx.NS3.Data(NSx_info.NSx_idx(analog_list(i)),:))/2000,last_analog_time);
            elseif NSx_info.NSx_sampling(analog_list(i))==10000
                last_analog_time = min(length(NEVNSx.NS4.Data(NSx_info.NSx_idx(analog_list(i)),:))/10000,last_analog_time);
            elseif NSx_info.NSx_sampling(analog_list(i))==30000
                last_analog_time = min(length(NEVNSx.NS5.Data(NSx_info.NSx_idx(analog_list(i)),:))/30000,last_analog_time);
            end
        end
        stop_time=floor(last_analog_time)-1;
        analog_time_base = start_time:1/adfreq:stop_time; 
    end
%% get full bandwidth data if it exists
    if isfield(out_struct.raw,'fullbandwidth')
        out_struct.fullbandwidth.channels=out_struct.raw.fullbandwidth.channels;
        out_struct.fullbandwidth.adfreq=out_struct.raw.fullbandwidth.adfreq;
        out_struct.fullbandwidth.data=cell2mat(out_struct.raw.fullbandwidth.data);
        out_struct.fullbandwidth.ts=out_struct.raw.fullbandwidth.ts;
    elseif (opts.delete_raw && exist('NEVNSx','var') && exist('fullbandwidth_list','var') && ~isempty(fullbandwidth_list))
        out_struct.fullbandwidth.channels = NSx_info.NSx_labels(fullbandwidth_list);
        out_struct.fullbandwidth.adfreq = NSx_info.NSx_sampling(fullbandwidth_list);
        
        out_struct.fullbandwidth.data = (1/6.5584993)*single(NEVNSx.NS5.Data(NSx_info.NSx_idx(fullbandwidth_list),:))';
        % 6.5584993 is the ratio when comparing the output of 
        % get_cerebus_data to the one from this script. It must come
        % from the data type conversion that happens when pulling 
        % analog data.
        
        % The start time of each channel.  Note that this NS library
        % function ns_GetTimeByIndex simply multiplies the index by the 
        % ADResolution... so it will always be zero.
        out_struct.raw.fullbandwidth.ts(1:length(fullbandwidth_list)) = zeros(1,length(fullbandwidth_list));;
    end
%% Position for robot and wrist flexion tasks
    if (robot_task && opts.kin)
        % Position
        if opts.verbose
            disp('Aggregating data... get position')
        end

        if ( isfield(out_struct.raw,'enc')&& ~isempty(out_struct.raw.enc))
            %if the encoder values are already populated in
            %out_struct.raw.enc, use that field
            % account for mangled encoder timestamps (non-monotonic)
            while ~isempty(out_struct.raw.enc(:,1)) && nnz(diff(out_struct.raw.enc(:,1))<0)
                out_struct.raw.enc(find(diff(out_struct.raw.enc(:,1))<0,1,'last'),:)=[];
            end
            th_t = out_struct.raw.enc(:,1); % encoder time stamps
            th_1 = out_struct.raw.enc(:,2) * 2 * pi / 18000;
            th_2 = out_struct.raw.enc(:,3) * 2 * pi / 18000;
        elseif (isfield(opts,'delete_raw') && opts.delete_raw && exist('all_enc','var'))
            %if out_struct.raw.enc does not exist because the delete_raw
            %flag is set, and we have the base data in a variable called
            %all_enc available in the workspace of the calling function:
            if opts.ignore_jumps
                temp = get_encoder(all_enc,[0 out_struct.meta.duration]);
            else
                [temp, out_struct.meta.jump_times]= get_encoder(all_enc,out_struct.meta.FileSepTime);
            end
            % account for mangled encoder timestamps (non-monotonic)
            while ~isempty(temp(:,1)) && nnz(diff(temp(:,1))<0)
                temp(find(diff(temp(:,1))<0,1,'last'),:)=[];
            end
            th_t=temp(:,1);
            th_1=temp(:,2) * 2 * pi / 18000;
            th_2=temp(:,3) * 2 * pi / 18000;
            clear temp
        else
            error('BDF:noPositionSignal','No position signal present');
        end
        
        if ~exist('adfreq','var')
            % There was no analog data, so we need a default timebase for
            % the encoder
            adfreq = 1000; %Arbitrarily 1KHz
            start_time = 1.0;
            last_enc_time = th_t(end,1);
            stop_time = floor(last_enc_time) - 1;
            analog_time_base = start_time:1/adfreq:stop_time;
        end
        
        th_1_adj = interp1(th_t, th_1, analog_time_base);
        th_2_adj = interp1(th_t, th_2, analog_time_base);

        th_1_adj(isnan(th_1_adj)) = th_1_adj(find(~isnan(th_1_adj),1,'first')); % when datafile started before encoders were zeroed.
        th_2_adj(isnan(th_2_adj)) = th_2_adj(find(~isnan(th_2_adj),1,'first'));

        % convert encoder angles to x and y
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
        elseif isfield(opts,'labnum')&& opts.labnum==6 %If lab6 was used for data collection
            if datenum(out_struct.meta.datetime) < datenum('01-Jan-2015')
                l1=27; l2=36.8;
            else
                l1=46.8; l2=45;
            end
        else
            l1 = 25.0; l2 = 26.8;   %use lab1 robot arm lengths as default
        end            

        x = - l1 * sin( th_1_adj ) + l2 * cos( -th_2_adj );
        y = - l1 * cos( th_1_adj ) - l2 * sin( -th_2_adj );

        % get derivatives
        [b, a] = butter(8, 100/adfreq);
        dx = gradient(x,1/adfreq);
        dx = filtfilt(b,a,dx);
        dy = gradient(y,1/adfreq);
        dy = filtfilt(b,a,dy);

        ddx = gradient(dx,1/adfreq);
        ddx = filtfilt(b,a,ddx);
        ddy = gradient(dy,1/adfreq);
        ddy = filtfilt(b,a,ddy);

        % write into structure
        out_struct.pos = [analog_time_base'   x'   y'];
        out_struct.vel = [analog_time_base'  dx'  dy'];
        out_struct.acc = [analog_time_base' ddx' ddy'];

        %clear databursts and unit activity outside the
        %analog_time_base window
        if (isfield(out_struct, 'units') && ~isempty(out_struct.units))
            for i=1:length(out_struct.units)
                out_struct.units(i).ts=out_struct.units(i).ts( out_struct.units(i).ts >= min(analog_time_base) & out_struct.units(i).ts <= max(analog_time_base) );
                out_struct.units(i).waveforms=out_struct.units(i).waveforms(out_struct.units(i).ts >= min(analog_time_base) & out_struct.units(i).ts <= max(analog_time_base),:);
            end
        end
        
        if (isfield(out_struct, 'databursts') && ~isempty(out_struct.databursts))
            out_struct.databursts=out_struct.databursts(([out_struct.databursts{:,1}]'>=min(analog_time_base) & [out_struct.databursts{:,1}]'<=max(analog_time_base)),:);
        end
        
        if (isfield(out_struct, 'words') && ~isempty(out_struct.words))
            out_struct.words=out_struct.words((out_struct.words(:,1)>=min(analog_time_base) & out_struct.words(:,1)<=max(analog_time_base)),:);
        end
    elseif wrist_flexion_task && opts.kin
        if(isfield(out_struct.raw,'enc') && ~isempty(out_struct.raw.enc))
            analog_time_base = out_struct.raw.enc(:,1);
            x_pos = out_struct.raw.enc(:,2)/1000;
            y_pos = out_struct.raw.enc(:,3)/1000;
        elseif(isfield(opts,'delete_raw') && opts.delete_raw && exist('NEVNSx','var')&& exist('all_enc','var'))
            if opts.ignore_jumps
                temp = get_encoder(all_enc,[0 out_struct.meta.duration]);
            else
                [temp, out_struct.meta.jump_times]= get_encoder(all_enc,out_struct.meta.FileSepTime);
            end
            analog_time_base = tempc(:,1);
            x_pos = temp(:,2)/1000;
            y_pos = temp(:,3)/1000;
        end
            out_struct.pos = [analog_time_base x_pos  y_pos];
    end
    
%% Robot_task:Force Handle and Analog Signals
    if robot_task && opts.force 
        if ( ~isempty(out_struct.raw.analog.channels))
            force_channels = find( strncmp(out_struct.raw.analog.channels, 'ForceHandle', 11) );
        elseif(isfield(opts,'delete_raw') && opts.delete_raw && exist('NEVNSx','var') )
            force_channels = find(~cellfun('isempty',strfind(lower(NSx_info.NSx_labels),'ForceHandle')));
        end
        if (exist('force_channels','var') && length(force_channels)==6)
            raw_force = zeros(length(analog_time_base), 6);
            zero_force = [];
            for c = 1:6
                channame = sprintf('ForceHandle%d', c);
                if ( ~isempty(out_struct.raw.analog))
                    achan_index = find(strcmp(out_struct.raw.analog.channels, channame));
                    if isempty(achan_index)
                        warning('calc_from_raw:ChannelNotFound',['Could not find a force channel named: ', channame, '. Continuing leaving force for that column empty'])
                        a_data = [];
                    elseif length(achan_index)>1
                        warning('calc_from_raw:ExtraChannelFound',['Found extra channels matching the string: ', channame, '. Continuing leaving force for that column empty'])
                        a_data = [];
                    else
                        a = out_struct.raw.analog.data{achan_index};
                        t = (0:length(a)-1)' / out_struct.raw.analog.adfreq(achan_index) + out_struct.raw.analog.ts{achan_index}(1);
                        a_data = [t a];
                    end
                else %we know that if out_struct.raw.analog is empty an NEVNSx structure exists, otherwise the force_channels vector would be empty
                    achan_index=find(~cellfun('isempty',strfind(lower(NSx_info.NSx_labels),['ForceHandle',num2str(c)])));
                    if isempty(achan_index)
                        warning('calc_from_raw:ChannelNotFound',['Could not find a force channel named: ', channame, '. Continuing leaving force for that column empty'])
                        a_data = [];
                    elseif length(achan_index>1)
                        warning('calc_from_raw:ExtraChannelFound',['Found extra channels matching the string: ', channame, '. Continuing leaving force for that column empty'])
                        a_data = [];
                    else
                        if NSx_info.NSx_sampling(achan_index)==1000
                            a = single(NEVNSx.NS2.Data(NSx_info.NSx_idx(achan_index),:))';
                        elseif NSx_info.NSx_sampling(achan_index)==2000
                            a = single(NEVNSx.NS3.Data(NSx_info.NSx_idx(achan_index),:))';
                        elseif NSx_info.NSx_sampling(achan_index)==10000
                            a = single(NEVNSx.NS4.Data(NSx_info.NSx_idx(achan_index),:))';
                        elseif NSx_info.NSx_sampling(achan_index)==30000
                            a = single(NEVNSx.NS5.Data(NSx_info.NSx_idx(achan_index),:))';
                        end
                        t = (0:length(a)-1)' / NSx_info.NSx_sampling(achan_index);
                        a_data=[t a];
                    end
                end
                zero_force = [zero_force;round(a_data((a_data(:,2)==0),1)*1000)/1000];
                a_data = interp1( a_data(:,1), a_data(:,2), analog_time_base);  
                [b,a] = butter(4, 200/adfreq);
                a_data = filtfilt(b, a, double(a_data));
                raw_force(:,c) = a_data';
            end
        
            if opts.verbose
                disp('Aggregating data... get force')
            end
            % Check lab number for calibration parameters
            if isfield(opts,'labnum')&& opts.labnum==3 %If lab3 was used for data collection
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
                    % \\citadel\limblab\Software\ATI FT\Calibration\Lab 3\FT7520.cal
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
                    % \\citadel\limblab\Software\ATI FT\Calibration\Lab 3\FT7520.cal
                    % fhcal = [Fx;Fy]./[scaleX;scaleY]
                    % force_offsets acquired empirically by recording static
                    % handle.
                    fhcal = [-0.0129 0.0254 -0.1018 -6.2876 -0.1127 6.2163;...
                            -0.2059 7.1801 -0.0804 -3.5910 0.0641 -3.6077]'./1000;
                    rotcal = [1 0; 0 1];  
                    force_offsets = [306.5423 -847.5678  132.1442 -177.3951 -451.7461 360.2517]; %these offsets computed Jan 14, 2013
                    Fy_invert = 1;
                end
            elseif isfield(opts,'labnum')&& opts.labnum==6 %If lab6 was used for data collection
                if opts.rothandle
                    % Fx,Fy,scaleX,scaleY from ATI calibration file:
                    % \\citadel\limblab\Software\ATI FT\Calibration\Lab 6\FT16018.cal
                    % fhcal = [Fx;Fy]./[scaleX;scaleY]
                    % force_offsets acquired empirically by recording static
                    % handle.
                    fhcal = [0.02653 0.02045 -0.10720 5.94762 0.20011 -6.12048;...
                            0.15156 -7.60870 0.05471 3.55688 -0.09915 3.44508]'./1000;
                    rotcal = [-1 0; 0 1];  
                    force_offsets = zeros(1,6); %NEEDS TO BE MEASURED EMPRICALLY
                    Fy_invert = 1;
                else
                    % Fx,Fy,scaleX,scaleY from ATI calibration file:
                    % \\citadel\limblab\Software\ATI FT\Calibration\Lab 6\FT16018.cal
                    % fhcal = [Fx;Fy]./[scaleX;scaleY]
                    % force_offsets acquired empirically by recording static
                    % handle.
                    fhcal = [0.02653 0.02045 -0.10720 5.94762 0.20011 -6.12048;...
                            0.15156 -7.60870 0.05471 3.55688 -0.09915 3.44508]'./1000;
                    rotcal = [1 0; 0 1];  
                    force_offsets = zeros(1,6); %NEEDS TO BE MEASURED EMPIRICALLY
                    Fy_invert = 1;
                end
            else
                error('calc_from_raw:LabNotSet','calc_from_raw needs the lab number in order to select the correct load cell calibration')
            end
            
            % Calculate force offsets for this particular file
            % Find longest time range of no movement
            temp_d = diff(out_struct.pos(:,2))<.004 & diff(out_struct.pos(:,3))<.004;   
            temp_d = abs(diff(raw_force(:,1)))<1 & abs(diff(raw_force(:,2)))<1 &...
                abs(diff(raw_force(:,3)))<1 & abs(diff(raw_force(:,4)))<1 &...
                abs(diff(raw_force(:,5)))<1 & abs(diff(raw_force(:,6)))<1;
            q = diff([0 temp_d(:)' 0]);
            v1 = find(q == 1); v2 = find(q == -1); 
            v = v2-v1;
            [max_v,max_v_ind] = max(v);
            no_mov_idx = v1(max_v_ind):v2(max_v_ind);
            force_offsets_temp = mean(raw_force(no_mov_idx,:));
            
            if max_v > 1000  % Only use if there are more than 
                             % 1000 contiguous movement free samples                
                force_offsets = force_offsets_temp;
            else
                force_offsets = mean(raw_force);
            end
            
            [n,bin] = histc(zero_force,unique(zero_force));
            multiple = find(n==6);
            zero_force = unique(zero_force(ismember(bin,multiple)));
            
            temp = [1;find(diff(zero_force)>1)+1];
            if ~isempty(zero_force)
                for i = 1:length(temp)
                    zero_force = [zero_force;((zero_force(temp(i))-.2):.001:(zero_force(temp(i))+1.2))']; 
                end
                [~,~,ia] = intersect(round(zero_force*1000)/1000,round(analog_time_base*1000)/1000);
            else
                ia = [];
            end
            
            force_offsets = repmat(force_offsets, length(raw_force), 1);
            out_struct.force = (raw_force - force_offsets) * fhcal * rotcal;
            clear force_offsets; % cleanup a little
            out_struct.force(:,2) = Fy_invert.*out_struct.force(:,2); % fix left hand coords in old force
            
            temp = out_struct.force;
            if isfield(opts,'labnum')&& opts.labnum==3 %If lab3 was used for data collection            
                out_struct.force(:,1) = temp(:,1).*cos(-th_2_adj)' - temp(:,2).*sin(th_2_adj)';
                out_struct.force(:,2) = temp(:,1).*sin(th_2_adj)' + temp(:,2).*cos(th_2_adj)';
            elseif isfield(opts,'labnum')&& opts.labnum==6 %If lab6 was used for data collection         
                out_struct.force(:,1) = temp(:,1).*cos(-th_1_adj)' - temp(:,2).*sin(th_1_adj)';
                out_struct.force(:,2) = temp(:,1).*sin(th_1_adj)' + temp(:,2).*cos(th_1_adj)';
            end
            clear temp
            out_struct.force = [analog_time_base' out_struct.force];
            out_struct.force(ia,2:3) = 0;
           
        else
            warning('BDF:noForceSignal','No force handle signal found because calc_from_raw did not find 6 channels named ''ForceHandle*''');
        end
        
    end % matches with if robot_task & opts.force
    if robot_task
        %now handle any channels that aren't the robot_task force channels
        if (~isempty(out_struct.raw.analog.channels))
            analog_channels = find(~strncmp(out_struct.raw.analog.channels, 'ForceHandle', 11) &...
                ~isempty(out_struct.raw.analog.channels)); 
            if ~isempty(analog_channels)
                out_struct.analog.ts = analog_time_base;
                for c = 1:length(analog_channels)
                    %assign channel names
                    out_struct.analog.channel(c) = out_struct.raw.analog.channels(c);
                    %get subsampled analog data
                    fs = out_struct.raw.analog.adfreq(analog_channels(c));
                    chan_time_base = 1/fs:1/fs:length(out_struct.raw.analog.data{analog_channels(c)})/fs;
                    a_data = double(out_struct.raw.analog.data{analog_channels(c)});   
                    if fs==max(out_struct.raw.analog.adfreq)
                       %we don't need to interpolate since this data was collected
                       %with the same freq as analog_time_base:
                       a_data=a_data(round(analog_time_base*fs));
                    else
                        %we need to interpolate to the analog_time_base
                        a_data = interp1(chan_time_base, a_data, analog_time_base);
                    end
                    out_struct.analog.data(:,c) = a_data;
                end
            end
        elseif (exist('analog_list','var') && exist('NEVNSx','var'))
            if ~isempty(analog_list)
                out_struct.analog.channel = NSx_info.NSx_labels(analog_list);
                out_struct.analog.ts = analog_time_base;
                for c = length(analog_list):-1:1
                    if NSx_info.NSx_sampling(analog_list(c))==1000
                        a_data = single(NEVNSx.NS2.Data(NSx_info.NSx_idx(analog_list(c)),:))';
                    elseif NSx_info.NSx_sampling(analog_list(c))==2000
                        a_data = single(NEVNSx.NS3.Data(NSx_info.NSx_idx(analog_list(c)),:))';
                    elseif NSx_info.NSx_sampling(analog_list(c))==10000
                        a_data = single(NEVNSx.NS4.Data(NSx_info.NSx_idx(analog_list(c)),:))';
                    elseif NSx_info.NSx_sampling(analog_list(c))==30000
                        a_data = single(NEVNSx.NS5.Data(NSx_info.NSx_idx(analog_list(c)),:))';
                    end
                    % 6.5584993 is the ratio when comparing the output of 
                    % get_cerebus_data to the one from this script. It must come
                    % from the data type conversion that happens when pulling 
                    % analog data.
                    a_data = a_data/6.5584993;
                    step=1/NSx_info.NSx_sampling(analog_list(c));
                    chan_time_base = step:step:length(a_data)*step;
                    if NSx_info.NSx_sampling(analog_list(c))==max(NSx_info.NSx_sampling(analog_list))
                       %we don't need to interpolate since this data was collected
                       %with the same freq as analog_time_base:
                       a_data=a_data(round(analog_time_base/step));
                    else
                        %we need to interpolate to the analog_time_base
                        a_data = interp1(chan_time_base, a_data, analog_time_base);
                    end
                    out_struct.analog.data(:,c) = a_data;
                end
            end
        end
    end
%% EMG for robot task, making time base same as that for all analog signals
% Chris: you should reconsider and remove the "robot_task" from below!
if robot_task && isfield(out_struct,'emg')
    new_emg = interp1(out_struct.emg.data(:,1), out_struct.emg.data(:,2:end), analog_time_base);
    new_emg = reshape(new_emg,length(analog_time_base),[]);
    out_struct.emg.data = [analog_time_base' new_emg];
    out_struct.emg.emgfreq = round(1/mode(diff(analog_time_base(1:1000))));
    clear new_emg;
end        
        
%% Eye-Tracker Analog Signals
if opts.eye
    if (~isempty(out_struct.raw.analog.channels))
        eye_channels = find( strncmp(out_struct.raw.analog.channels, 'POG', 3) ); 

        x_data = get_analog_signal(out_struct, 'POGX');
        y_data = get_analog_signal(out_struct, 'POGY');
    elseif isfield(opts,'delete_raw') && opts.delete_raw && exist('NEVNSx','var')
            achan_index = find(~cellfun('isempty',strfind(lower(NSx_info.NSx_labels),'POGX')));
            if isempty(achan_index)
                analog_data = [];
            else
                if NSx_info.NSx_sampling(analog_list(i))==1000
                    a = single(NEVNSx.NS2.Data(NSx_info.NSx_idx(achan_index),:))';
                elseif NSx_info.NSx_sampling(analog_list(i))==2000
                    a = single(NEVNSx.NS3.Data(NSx_info.NSx_idx(achan_index),:))';
                elseif NSx_info.NSx_sampling(analog_list(i))==10000
                    a = single(NEVNSx.NS4.Data(NSx_info.NSx_idx(achan_index),:))';
                elseif NSx_info.NSx_sampling(analog_list(i))==30000
                    a = single(NEVNSx.NS5.Data(NSx_info.NSx_idx(achan_index),:))';
                end
                % 6.5584993 is the ratio when comparing the output of 
                % get_cerebus_data to the one from this script. It must come
                % from the data type conversion that happens when pulling 
                % analog data.
                a = a/6.5584993;
                t = (0:length(a)-1)' / data.raw.analog.adfreq(achan_index) + data.raw.analog.ts{achan_index}(1);
    
                x_data = [t a];
            end
            achan_index = find(~cellfun('isempty',strfind(lower(NSx_info.NSx_labels),'POGY')));
            if isempty(achan_index)
                analog_data = [];
            else
                if NSx_info.NSx_sampling(analog_list(i))==1000
                    a = single(NEVNSx.NS2.Data(NSx_info.NSx_idx(achan_index),:))';
                elseif NSx_info.NSx_sampling(analog_list(i))==2000
                    a = single(NEVNSx.NS3.Data(NSx_info.NSx_idx(achan_index),:))';
                elseif NSx_info.NSx_sampling(analog_list(i))==10000
                    a = single(NEVNSx.NS4.Data(NSx_info.NSx_idx(achan_index),:))';
                elseif NSx_info.NSx_sampling(analog_list(i))==30000
                    a = single(NEVNSx.NS5.Data(NSx_info.NSx_idx(achan_index),:))';
                end
                % 6.5584993 is the ratio when comparing the output of 
                % get_cerebus_data to the one from this script. It must come
                % from the data type conversion that happens when pulling 
                % analog data.
                a = a/6.5584993;
                t = (0:length(a)-1)' / data.raw.analog.adfreq(achan_index) + data.raw.analog.ts{achan_index}(1);
    
                y_data = [t a];
            end
    end
    if(exist('x_data','var'))
    
%------------init matrices/get raw data-----------------------------------
        %initialize  matrices... size = (length 2), in form [ t a ]
        x_data  = zeros( length(analog_time_base), 2 ); 
        y_data  = zeros( length(analog_time_base), 2 ); 
        raw_eye = zeros( length(analog_time_base), 3 );
        t = 1;
        x = 2;      %'raw_eye' indices
        y = 3;
                
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
          
%% generate masking vector for good data, using the concatenation times and jump times stored during loading of the bdf.
    bad_times=[];
    out_struct.good_kin_data=ones(size(out_struct.pos,1),1);
    if isfield(opts,'ignore_jumps')
        if ~opts.ignore_jumps
            bad_times=reshape(out_struct.meta.jump_times,length(out_struct.meta.jump_times),1);
        end
    end
    if isfield(opts,'ignore_filecat')
        if ~opts.ignore_filecat
            bad_times=[bad_times;reshape(out_struct.meta.FileSepTime,numel(out_struct.meta.FileSepTime),1)];
        end
    end
    if ~isempty(bad_times)
        temp=bad_times>analog_time_base(1) & bad_times<analog_time_base(end);
        bad_times=sort(bad_times(temp));
        %convert times into indices:
        bad_ind=(bad_times-analog_time_base(1))*adfreq;
        %convert single indices into 1s range. note that adfreq is taken as
        %shorthand for 1s*adfreq here 
        %a direct indexing method is used instead of a for-loop for speed
        bad_ind=repmat(bad_ind,1,round(adfreq));
        range_mat=repmat(([1:round(adfreq)]-round(0.5*adfreq)),size(bad_ind,1),1);
        bad_ind=reshape((bad_ind+range_mat)',numel(bad_ind),1); 
        clear range_mat
        %set indices corresponding to bad data equal to zero in out_struct.good_kin_data
        out_struct.good_kin_data(round(bad_ind))=0;
        clear bad_ind
    end
