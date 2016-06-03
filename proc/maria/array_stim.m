function array_stim(current_array, sending_freq, stim_freq, sampled_freq, stretch_factor, pw, channels, repeats, muscle_names, com_port)
%current_array should be in the form of a matrix of arrays that each have
%averaged, filtered EMG data to be sent to the corresponding channel
%pw: in ms, freqs: in hz, currents in current_array: in mA (mA and ms will
%be converted to us and uA)
%sending_freq is the rate at which I should send it to the
%stimulator--assume 20, usually
%stim_freq is the freq I should set the stimulator to (usually 30-40)
%sampled_freq is the freq at which the original current array is sampled.

%get conversion factor for xq from frequency value (hz)
%TODO: deal with losing resolution - say, a spike at the end doesn't
%necessarily show up


for i=1:size(current_array, 2)
    conv_fact = stretch_factor*sending_freq; %this will lead to a slight "stretching" effect of the step over time
    x = 1/sampled_freq:1/sampled_freq:length(current_array{i})/5000;
    xq = 1/conv_fact:1/conv_fact:length(current_array{i})/5000;
    ds_array{i} = interp1(x, current_array{i}, xq);
    %hold on;
    figure(1); hold on;
    plot(x, current_array{i})
    figure(2); hold on;
    plot(xq, ds_array{i}, 'linewidth', 2);
    %disp(length(ds_array{i})); %NOTE: if these aren't all the same length it'll be a nuisance
end
%TODO: figure out a way to plot this so it shows the intermediate points
%(so if it's stimulating at 40Hz, and the sample is assumed to be at 100
%hz, it shows the point in between. wait. uhm.)

legend(muscle_names);

length_stim = size(ds_array{1}, 2)/sending_freq; %gets the number of seconds being spent stimulating
disp(['The total time spent stimulating is ' num2str(length_stim)]);
save([datestr(now, 'yyyymmdd_HHMMSS'), '.mat'], 'current_array', 'ds_array', 'muscle_names', 'length_stim', 'sending_freq', 'stim_freq', 'pw');

%repeating_array{i} = 0; %somehow get the number of times to repeat each variable and then
%use that to make a repeating array and then I can plot.
%TODO: now is a good time to save workspace variables: I should save all
%the amplitude data I just plotted, do a calculation with the sample_freq and the
%frequency of stimulation so I know the actual timing (of each pulse and of
%total length of stimulation), correlate that with muscle names and stick
%pw on the end of the whole file. hmm.

%if the stimulator object doesn't exist yet, set it up:
if ~exist('ws', 'var')
    ws = wireless_stim(com_port, 1); %the number has to do with verbosity of running feedback
    ws.init(1, ws.comm_timeout_disable);
end

%set train delay so I have staggered pulses
for i=length(channels)
    ws.set_TD(50+500*i, channels(i));
end

%TODO: check this
%send timing pulse
command{1} = struct('CathDur', 1000, ...    % us
    'AnodDur', 1000, ...    % us
    'CathAmp', 2000+32768, ... %uA
    'AnodAmp', 32768-2000, ... %uA
    'TL', 10, ... %ms
    'Freq', 1, ... %Hz
    'Run', ws.run_once ...
    );
ws.set_stim(command, 16);
ws.set_Run(ws.run_once_go)
pause(2); %wait for the Vicon to be activated


%set constant parameters for stimulator
command{1} = struct('Freq', stim_freq, ...        % Hz
    'CathDur', pw*1000, ...    % us
    'AnodDur', pw*1000 ...    % us
    ); %kind of strange to put this here, need to define the amps to all be zero first TODO
ws.set_stim(command, channels);

ws.set_Run(ws.run_cont, channels);

%stimulate at appropriate channels in loop
%now that this is converted to an array of only the values I'll be sending,
%I need to actually stimulate! using a while loop with tic and toc ugh.

for steps=1:repeats %take as many steps as is specified
    for i=1:length(ds_array{1})%for every data point
        a = tic;
        for j = 1:size(ds_array, 2) %for every muscle
            command{1} = struct('CathAmp', ds_array{j}(i)*1000+32768,... %in uA
                'AnodAmp', 32768-ds_array{j}(i)*1000);
            ws.set_stim(command, channels(j)); %send updated amplitude to stimulator
        end
        %wait until it's time to do the next data point
        while toc(a)<(1/sending_freq)
            toc(a);
        end
        timearray(i) = toc(a);
    end
end
ws.set_Run(ws.run_stop, channels);
%TODO: pause long enough for stim to end??
end
