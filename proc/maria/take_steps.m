function ret = take_steps


% %initiate wireless stim object
% serial_string = 'COM3';
% ws = wireless_stim(serial_string, 1);
% ws.init(1, ws.comm_timeout_disable);

%input channels to stimulate (in struct?)...that way I can store good steps
%in a .mat file
%input starting pw, amp, ?? for each channel to stimulate **
%format: [channel, starting amp, starting pw, freq, time to start stim (ms), time to end (ms)]
channels = struct(...
    'bfa', [1, 3, .2, 40, 1, 200], ... %abducts thigh, flexes hindlimb
    'vl', [2, 3, .2, 40, 201, 400], ... %extends hindlimb
    'ip', [3, 3, .2, 40, 1, 200], ... %flexes thigh
    'st', [4, 3, .2, 40, 1, 200], ... %flexes hindlimb
    'sm', [5, 3, .2, 40, 201, 400], ... %extends hindlimb
    'ta', [6, 2, .2, 40, 1, 200], ... %flexes foot
    'lg', [7, 2, .2, 40, 201, 400]); %points toe

stim_one(channels.vl); 
stim_multi([channels.vl, channels.sm]); 

end

%input timing (total cycle time for one step, time between steps, number of
%steps, time to stimulate each muscle)

%input how we want to vary the signal (from .mat file???)

%% send stimulation

%stimulate a single channel
function ret = stim_one(ch_array)
    trainlen = ch_array(6)-ch_array(5); %length of train in ms: get from timing var
    polarity = 1; %1 is cathode first, 0 is anode first
    command = {'TL', trainlen, 'Freq', ch_array(4), 'CathAmp', ch_array(2),'AnodAmp', ch_array(2), ...
        'CathDur', ch_array(3)*1000, 'AnodDur', ch_array(3)*1000, 'PL', polarity}; 
    
    ws.set_stim(command, ch_array(1)); 
    
    ws.set_TD(50, ch_array(1)); %set train delay (time from when stim receive command and starts going, must be >= 50)
    
    ws.set_Run(ws.run_once, ch_array(1)); %can also set run continuous to just once
    ret = 0; 
end

%stimulate several channels of your choosing

function ret = stim_multi(ch_list)
    %WAIT HOW??? THERE IS A WAY. BUT WHAT IS IT.
    polarity = 1; 
    channels = zeros(1,16);
    commands = zeros(1,16); 
    
    for i = 1:length(ch_list)
        ch_array = ch_list(i); 
        trainlen = ch_array(6)-ch_array(5);
        channels(i) = ch_array(1); 
        
        commands(i) = {'TL', trainlen, 'Freq', ch_array(4), 'CathAmp', ch_array(2),'AnodAmp', ch_array(2), ...
        'CathDur', ch_array(3)*1000, 'AnodDur', ch_array(3)*1000, 'PL', polarity};
    
        % for multiple stim, do I set stim inside for loop or can I keep
        % all of the command structs in a list and do all of them at once
        % later?
        ws.set_stim(commands(i), ch_array(1));
        ws.set_TD(50, ch_array(1)); %set train delay (??)
    
        ws.set_Run(ws.run_once, ch_array(1));
    end
    ret = 0; 
end

%stimulate all programmed channels (hopefully in a stepping motion)
function ret = stim_all(ch_list)
    %somehow need to break this down so I don't overwhelm the stimulator
    %what parts overwhelm stim? set_stim? set_run? 

end


%% update variables

%update amplitude
function ret = update_amp(ch_array, new_val)
    %do I want to update and run or just update the array? 
    %BOTH
    %so, pass in array, update correct value, run ws.setCathAmp and
    %setAnodAmp

end

%update pw



%% double-check pulse to send

function ret = pulse_plot(ch_struct)
    %take each array out of the ch_struct
    %label each row according the field name
    %

end


