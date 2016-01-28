%% Test m-file to develop staggered stimulation
clear all; close all; clc;
% Define input variables
vec = [1:3 5 7 9]; % active channels
stim_offset = 200; % msec

is_active = zeros(1,16);
is_active(vec) = 1;
stim_amps = 1*ones(1,16);
stim_width = 0.1*ones(1,16);
mode = 'static_train';
stim_freq = 50;
stim_pulses = 25;
sample_duration = 3000;
stim_tip = 0.1;
num_recordings = 1;
EMG_enable = zeros(1,16);
EMG_enable(vec) = 1;
sample_rate = 5000; % in Hz
samples_per_trigger = floor(sample_duration/1000*sample_rate);
    
%% Define COM port for FNS-16 stimulator
s = serial('COM4','BaudRate',115200);
% Determine whether channel is active 
active_channel_count = sum(is_active);
inactive_channel_list = find(is_active==0);
active_channel_list = find(is_active==1);
% If not active, assign amplitude and pulse to be zero
stim_amps(inactive_channel_list) = 0;
stim_width(inactive_channel_list) = 0;

%% Determine number of stim_pulses for each muscle if staggered stimulation
stim_pulses = stim_pulses*ones(1,16); 
% randomize active channel list
z = randperm(numel(1:active_channel_count));
active_channel_list_random = active_channel_list(z); % this well generate random arrangement of indices 
stim_pulses_upd = stim_pulses(1);
add_pulses = floor((stim_offset/1e3)*stim_freq);
for ii = 1:active_channel_count
    stim_pulses(active_channel_list_random(ii)) = stim_pulses_upd;
    stim_pulses_upd = stim_pulses_upd + add_pulses;
end
active_channel_list_random = fliplr(active_channel_list_random);

%% Define program for each channel (note: some channels receive 0 (amplitude current and pulse width)
tic
for channel=1:16
    % Define program string with appropriate parameters for stimulator
    strOUT = fns_stim_prog('p',channel-1,mode,stim_amps(channel),stim_width(channel),stim_freq,stim_pulses(channel),sample_duration,stim_tip);
    fprintf('\n%s',strOUT);

    % Send program to FNS-16 stimulator
    fopen(s); fwrite(s,strOUT); fclose(s); pause(0.001);
end
toc

%% Setup the ai object
% Reset to a known state and populate AI (takes ~330ms)
% Perhaps just use ai = daqfind and flushdata(ai,'all').
daqreset;
ai = analoginput('nidaq', 'Dev2');
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

%% Collect data
for trig = 1:num_recordings
    start(ai); pause(0.001);
    % get the data from this trigger
    try
        trigger(ai); fopen(s);
        strOUT2 = fns_stim_prog('r',active_channel_list_random-1);
        flcose(s);
%         for me = 1:active_channel_count
%             tic
%             strOUT2 = fns_stim_prog('r',active_channel_list_random(me)-1);
% %             fopen(s); fwrite(s,strOUT2); fclose(s);
%             fwrite(s,strOUT2);
%             pause(stim_offset/1e3);
%             toc
%         end
%         fclose(s);
        wait(ai,(sample_duration*1.25)/1e3);
        data(:,:,trig) = getdata(ai);

    catch lasterror
%             fns('stop');
        fopen(s); fwrite(s,'2'); fclose(s);
        stop(ai);
        priorPorts = instrfind; % finds any existing Serial Ports in MATLAB
        delete(priorPorts);
        rethrow(lasterror);
    end
end

%% And shut back down
%     fns('stop');
fopen(s); fwrite(s,'2'); fclose(s);
stop(ai);
priorPorts = instrfind; % finds any existing Serial Ports in MATLAB
delete(priorPorts);

%% Plot results
for ii = 1:active_channel_count
   subplot(active_channel_count,1,ii)
   xData = (1:size(data,1))/sample_rate;
   yData = data(:,ii,1);
   plot(xData,yData);
   axis([0 samples_per_trigger/sample_rate -0.5 0.5])
end
