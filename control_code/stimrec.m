function [data, sample_rate] = stimrec(varargin)
%   STIMREC   Send a stim command, record the triggered input and return data
%       [DATA, SAMPLE_RATE] = STIMREC(ABORT, PULSEAMPS, PULSEWIDTH, FREQ, PULSECOUNT, SAMPLE_DURATION, MODE, EMG_labels, EMG_enable , PHONY)
%           ABORT:       a handle to a boolean abort switch (pointer)
%           PULSEAMPS:   a vector of pulse amplitudes for each channel (uA)
%           PULSEWIDTHS: a vector of pulse-widths for each channel (uSec)
%           FREQ:        the stimulation frequency (Hz)
%           PULSECOUNT:  the number of stimulation pulses
%           SAMPLE_DURATION:the duration of recording (ms)
%           MODE:        a string, either 'static_pulses','static_train',
%                        'mod_amp' or 'mod_pw'
%           EMG_labels:  cell array of 8 strings containing EMG labels
%           EMG_enable:  1x8 boolean vector to identify which muscles to plot
%          [PHONY:       (optional) just return fake data if nonzero]
% 
%   STIMREC handles the coupling between the stimulation and the analog
%   input.  It properly sets up the stimulator with the requested values
%   and the analog input object with the expected number of triggers.  It
%   sends the stimulation command, and then blocks while waiting for the
%   triggered response.  Once all data has been collected (or a timeout
%   occurred), it returns.
%
%   To simplify testing, STIMREC provides an optional PHONY parameter.  If
%   true, the function simply returns simulated data without attempting to
%   stimulate and record the triggered responses.
%
%   RETURN VALUES:
%   	DATA is three dimensional matrix: [sample, channel, pulse]
%   	SAMPLE_RATE is a scalar value
%   
%   Created by Matt Bauman on 2009-11-23.
%   Miller Limb Lab, Northwestern University.

%% Parse the arguments
    
    if nargin == 19
        abort       = varargin{1};
        stim_amps   = varargin{2};
        stim_width  = varargin{3};
        stim_freq   = varargin{4};
        stim_pulses = varargin{5};
        sample_duration = varargin{6};
        mode        = varargin{7};
        is_active   = varargin{8};
        EMG_labels  = varargin{9};
        EMG_enable  = varargin{10};
        nreps       = varargin{11};
        stim_tip    = varargin{12};
        freq_daq    = varargin{13};
        stim_delay  = varargin{14};
        handles     = varargin{15};
        calMat      = varargin{16};
        curr_action_text = varargin{17};
        active_channel_list = varargin{18};
        stim_offset = varargin{19};
    else
        error 'Incorrect number of arguments'
    end
    
    % Ensure the args are the correct dimension
    if ( ... % TODO: Validate the abort pointer
         ~all(size(stim_amps)  == [1,16]) || ...
         ~all(size(stim_width) == [1,16]) || ...
         ~all(size(stim_freq)  == [1,1])  || ...
         ~all(size(stim_pulses)== [1,16]) )
        error 'Incorrect argument dimensions'
    end
    
%% Common constants
    sample_rate = freq_daq; % in Hz
    samples_per_trigger = floor(sample_duration/1000*sample_rate); %TODO: Allow the user to set this
    recording_channels = find(EMG_enable);
    num_recording_channels = length(recording_channels);
    num_recordings = nreps;
    data = zeros(samples_per_trigger, num_recording_channels, num_recordings);
        
%% Program the stimulator
    % Define COM port for FNS-16 stimulator
    s = serial('COM1','BaudRate',115200);  % this seems to depend on the computer as to which com port is assigned
    % Determine whether channel is active 
    active_channel_count = sum(is_active);
    inactive_channel_list = find(is_active==0);
    % If not active, assign amplitude and pulse to be zero
    stim_amps(inactive_channel_list) = 0;
    stim_width(inactive_channel_list) = 0;
    % Output error if there are no active channels
    if (active_channel_count == 0)
        error 'No non-zero channels';
    end

    tic
    % Define program for each channel (note: some channels receive 0
    % amplitude current and pulse width)
%     fopen(s);
    for channel=1:16
        % Define program string with appropriate parameters for stimulator
        strOUT = fns_stim_prog('p',channel-1,mode,stim_amps(channel),stim_width(channel),stim_freq,stim_pulses(channel),sample_duration,stim_tip);
%         fprintf('\n%s',strOUT);
        
        % Send program to FNS-16 stimulator
        fopen(s); fwrite(s,strOUT); fclose(s); pause(0.001);
    end  
    toc
%% Setup the ai object

    % Reset to a known state and populate AI (takes ~330ms)
    % Perhaps just use ai = daqfind and flushdata(ai,'all').
    daqreset;
%     ai = analoginput('nidaq', 'Dev2');
    ai = analoginput('nidaq', 'Dev1');
    set(ai,'InputType', 'SingleEnded');
    set(ai.Channel,'InputRange', [-10 10],'SensorRange',[-10 10],'UnitsRange',[-10 10]);
    
    %add only enabled channels:
    addchannel(ai,find(EMG_enable)-1);
            
    % Setup trigger source as falling edge of an external ditigal signal
    set(ai,'TriggerType','Manual');
    
    % Setup sampling properties of ai object
    set(ai,'SampleRate', sample_rate);
    set(ai,'SamplesPerTrigger', samples_per_trigger);
    set(ai,'LoggingMode', 'Memory');
    pause(0.1);
 
 %% set up the AO object (for triggering Vicon)
 % added 2/10/15 by MCT for simultaneous Vicon data acquisition
 
%  ao = analogoutput('nidaq','Dev2');
 ao = analogoutput('nidaq','Dev1');
 addchannel(ao,[0 1]);
 set(ao,'TriggerType','Manual');
 startdata = [zeros(1,1) 5*ones(1,50) zeros(1,1); zeros(1,52)]'; % data for turning VICON acquisiton on 
 stopdata = [zeros(1,52); zeros(1,1) 5*ones(1,50) zeros(1,1); ]'; % data for turning VICON acquisiton off 
 putdata(ao,startdata);  % set it up for starting VICON data
    
%% Collect the data
    
    for trig = 1:num_recordings
        start([ai ao]); pause(0.001);
        % get the data from this trigger
        try
            set(curr_action_text,'String',sprintf('Stimulating muscle(s): %s at %s mA', mat2str(cell2mat(strcat(EMG_labels(stim_amps>0)))),num2str(stim_amps(stim_amps>0))));
            stim_offset = 500;
            if stim_offset>1e-2
                trigger([ai ao]);fopen(s);
                disp('starting VICON')
                strOUT2 = fns_stim_prog('r',active_channel_list-1);
                pause(stim_offset/1e3);
                fwrite(s,strOUT2);
%                 pause(stim_offset/1e3);
%                 strOUT2 = fns_stim_prog('r',active_channel_list(5:13)-1);
%                 fwrite(s,strOUT2);
%                 pause(stim_offset/1e3);
%                 for me = 1:active_channel_count
%                     tic
%                     strOUT2 = fns_stim_prog('r',active_channel_list(me)-1);
%                     fwrite(s,strOUT2);
%                     pause(stim_offset/1e3);
%                     toc
%                 end
                fclose(s);
            else
                trigger(ai); fopen(s);
                strOUT2 = fns_stim_prog('r',active_channel_list-1);
                fwrite(s,strOUT2);
                fclose(s);
            end
            
            wait(ai,(sample_duration*1.25)/1e3);

            putdata(ao,stopdata);  % stop the Vicon data acquisition
            start(ao);
            trigger(ao);
            disp('stopping VICON');

            data(:,:,trig) = getdata(ai);
    
            % -------------------------------------------------------------
            % Plot raw forces, force endpoint vectors, AND point on recruitment curves
            plot_forces(data,sample_rate,trig,handles,EMG_labels,EMG_enable,calMat);
            % -------------------------------------------------------------
            
            % -------------------------------------------------------------
            % Plot stimulations
            plot_stimulations(data,sample_rate,trig,handles,EMG_labels,EMG_enable);
            % -------------------------------------------------------------
            
            if (abort.value)
                error 'Stimulation and data collection aborted.'
            end
        catch lasterror
%             fns('stop');
            fopen(s); fwrite(s,'2'); fclose(s);
            stop(ai);
            priorPorts = instrfind; % finds any existing Serial Ports in MATLAB
            delete(priorPorts);
            rethrow(lasterror);
        end
        % -----------------------------------------------------------------
        % Waitbar for multiple recordings at same stimulus level
        if (num_recordings > 1 && trig~=num_recordings) 
            % Incorporate delay to avoid muscle fatigue
            set(curr_action_text,'String',strcat('Preventing fatigue after STIM #',num2str(trig)));
            hWaitBar = waitbar(0,sprintf('Preventing fatigue after STIM to %s at %s mA',mat2str(cell2mat(strcat(EMG_labels(stim_amps>0)))),num2str(stim_amps(stim_amps>0))));
            delayTime = stim_delay;
            goAhead = 1;
            startTime = clock;          
            while goAhead == 1
                % Compute how much time has elapsed
                tempTime = etime(clock,startTime);
                % Determine whether to abort or update waitbar
                if tempTime > delayTime
                    % End delay
                    goAhead = 0;
                    waitbar(1,hWaitBar);
                else
                    % Update waitbar
                    waitbar(tempTime/delayTime,hWaitBar);
                end
            end
            delete(hWaitBar);
        end
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Waitbar for modulation (pulse amplitude and pulse width)
        if strcmp(mode,'mod_pw') || strcmp(mode,'mod_amp')
            % Incorporate delay to avoid muscle fatigue
            if stim_delay > 0;
                set(curr_action_text,'String','Preventing fatigue');
                hWaitBar = waitbar(0,sprintf('Preventing fatigue after STIM to %s at %s mA',mat2str(cell2mat(strcat(EMG_labels(stim_amps>0)))),num2str(stim_amps(stim_amps>0))));
                delayTime = stim_delay;
                goAhead = 1;
                startTime = clock;          
                while goAhead == 1
                    % Compute how much time has elapsed
                    tempTime = etime(clock,startTime);
                    % Determine whether to abort or update waitbar
                    if tempTime > delayTime
                        % End delay
                        goAhead = 0;
                        waitbar(1,hWaitBar);
                    else
                        % Update waitbar
                        waitbar(tempTime/delayTime,hWaitBar);
                    end
                end
                delete(hWaitBar);
            end
        end
        % -----------------------------------------------------------------
    end

%% And shut back down
%     fns('stop');
    fopen(s); fwrite(s,'2#'); fclose(s);
    stop(ai);
    priorPorts = instrfind; % finds any existing Serial Ports in MATLAB
    delete(priorPorts);
    % Set current status as idle
    set(curr_action_text, 'String', 'idle');
end %  function
