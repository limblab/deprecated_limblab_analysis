function [channels, ws] = start_stim

% 
%initiate wireless stim object
serial_string = 'COM4'; %this is different via mac and windows
ws = wireless_stim(serial_string, 1); %the number has to do with verbosity of running feedback
ws.init(1, ws.comm_timeout_disable);

%THESE PARAMETERS OF WS CAN BE CHANGED: 
% command_fields = {'TL', ...      % Train length, length of train pulse (ms)
%     'Freq', ...    % Frequency of pulses (Hz) default:
%     'CathDur', ... % Duration of just Cathode phase (us) default:
%     'AnodDur', ... % Duration of just Anode phase (us) default:
%     'CathAmp', ... % Amplitude of Cathode pulse 0-65535 levels default: 
%     'AnodAmp', ... % Amplitude of Anode pulse 0-65535 levels default:
%     'TD', ...      % Train Delay, time to delay a pulse (us) default:
%     'PL', ...      % Polarity, 1=Cathodic first, 0=Anodic first default:
%     'IPIDur', ...  % Intra-phase Interval (us) default: 
%     'Run', ...     % Start/Stop the stim, 0=stop, 1=run, 2=continuous
%     default:
%     };


%input channels to stimulate in struct (can store this info later as .mat)
%this must be arranged in increasing numerical order
%format: [channel, starting amp, starting pw (ms), freq, time to start stim (ms), 
%time to end (ms)]
channels = struct(...
    'bfa', [1, 3, .2, 30, 1, 200], ... %abducts thigh, flexes hindlimb
    'vl', [2, 3, .2, 40, 201, 400], ... %extends hindlimb
    'ip', [3, 3, .2, 40, 1, 200], ... %flexes thigh
    'st', [4, 3, .2, 40, 1, 200], ... %flexes hindlimb
    'sm', [5, 3, .2, 40, 201, 400], ... %extends hindlimb
    'ta', [6, 2, .2, 40, 1, 200], ... %flexes foot
    'lg', [7, 2, .2, 40, 201, 400]); %points toe

%pulse_plot(channels.bfa);
%sigs = make_sig_array(channels.vl, 600)
%plot(sigs)

end



function sig_array = make_sig_array(ch_array, totaltime, ws_object) 
%this function makes an array at 20 hz (50 ms) from the on/off signal
%input: on/off times, amplitude
%output: array of amplitudes every 50 ms
    starttime = ch_array(end-1); %ms
    endtime = ch_array(end); %ms
    amp = ch_array(3); %amplitude in mA (TODO check that unit!)
    ipi = ws_object.get_IPIDur(ch_array(1)); %get the IPI setting for that channel
    td = ws_object.get_TD(ch_array(1)); 
    
    %okay, step one: TD. pause as long as TD. if it's greater than 50
    %maybe? keep subtracting from it and adding to the array? while loop?
    %then do the loop thing. I need to add the negative part of the pulse
    %to that
    %THEN do IPI and deal with each pair of pulses. 
    %bahhhhh
    
    sig_array = 0; %start value is 0
    index = 1; 
    for i=0:50:td
        index=i/50+1;
        sig_array(index) = 0; 
    end
    
    if starttime ~= 0
        for i=td:50:starttime
            %from time 0 to start time, set stim to 0
            index = i/50+1 %increment index
            sig_array(index) = 0; 
        end
    end
    for i=starttime:50:endtime
        %set stim to amplitude (TODO neg and pos amplitudes?)
        index = int16(i/50)+1 %TODO check that this index is correct
        sig_array(index) = amp; 
    end
    for i=endtime:50:totaltime-1
        index = i/50+1 
        sig_array(index) = 0; 
    end
    % TODO this only takes care of one pulse! how do I then do another one?
    % NEED TO DEAL WITH IPI!!!!
    

end

function ret = pulse_plot(ch_array) %balls. I should rewrite this with the arrays and mult sigs
    x_points = 0;
    y_points = 0; 
    y_cycle = [0, ch_array(2), ch_array(2), 0, 0, -ch_array(2), -ch_array(2), 0]; 
    x_cycle = [50/1000, 0, ch_array(3), 0, 50/1000, 0, ch_array(3), 0]; %need to rewrite this to get the TD and IPI somehow?
    x_sum = 0; 
    for i=1:3 %arbitrary number of cycles to graph - need to add start and end time
        for j = 1:length(y_cycle) 
            index = ((i-1)*length(y_cycle)+j+1);
            %convert input parameters to a vector
            x_sum = x_sum + x_cycle(j); 
            x_points(index) = x_sum;
            y_points(index) = y_cycle(j);
        end
        x_sum = 1/ch_array(4)*1000*i; %start next pair at 1/freq
        %add time to start and time to end
    end
    %disp(x_points)
    %disp(y_points)
    ret = [x_points, y_points];
    plot(x_points, y_points)
end



