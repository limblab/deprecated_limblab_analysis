function array_stim(current_array, freq, pw, channels, com_port)
%current_array should be in the form of a matrix of arrays that each have
%averaged, filtered EMG data to be sent to the corresponding channel

%get conversion factor for xq from frequency value (hz)
%TODO: deal with losing resolution - say, a spike at the end doesn't
%necessarily show up
for i=1:size(current_array, 2)
    figure; hold on; 
    conv_fact = freq*3/2; %this will lead to a slight "stretching" effect of the step over time
    x = 1/5000:1/5000:length(current_array{i})/5000;
    xq = 1/conv_fact:1/conv_fact:length(current_array{i})/5000;
    ds_array{i} = interp1(x, current_array{i}, xq);
    %hold on;
    plot(x, current_array{i})
    plot(xq, ds_array{i});
    disp(length(ds_array{i})); %NOTE: if these aren't all the same length it'll be a nuisance
end

%if the stimulator object doesn't exist yet, set it up:
if ~exist('ws', 'var')
    ws = wireless_stim(com_port, 1); %the number has to do with verbosity of running feedback
    ws.init(1, ws.comm_timeout_disable);
end

%set train delay so I have staggered pulses
for i=length(channels)
    ws.set_TD(50+500*i, channels(i)); 
end

%set constant parameters for stimulator
command{1} = struct('Freq', freq, ...        % Hz
    'CathDur', pw*1000, ...    % us
    'AnodDur', pw*1000 ...    % us
    ); %kind of strange to put this here, need to define the amps to all be zero first TODO
ws.set_stim(command, channels);

ws.set_Run(ws.run_cont, channels); 

%stimulate at appropriate channels in loop
%now that this is converted to an array of only the values I'll be sending,
%I need to actually stimulate! using a while loop with tic and toc ugh.
timearray = zeros(1, 2000); 
for i=1:length(ds_array{1})%for every data point
    a = tic;
    for j = 1:size(current_array, 2) %for every muscle
        command{1} = struct('CathAmp', current_array{j}(i)*1000+32768,... %in uA
            'AnodAmp', 32768-current_array{j}(i)*1000); 
        ws.set_stim(command, channels(j)); %send updated amplitude to stimulator
    end
    %wait until it's time to do the next data point
    while toc(a)<(1/freq)
        toc(a);
    end
    timearray(i) = toc(a); 
end

ws.set_Run(ws.run_stop, channels); 
%TODO: pause long enough for stim to end??
end
    