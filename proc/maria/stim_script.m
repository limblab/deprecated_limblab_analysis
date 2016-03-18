[channels, ws] = start_stim; %initiates ws object, sets up init channel values

%NEXT MOVES IN A NORMAL PROGRAM DOING THING: SINGLE CHANNEL STIM, MULTI
%CHANNEL STIM, STIM ALL? 

%% stimulate a single channel
ch_array = channels.vl; 
trainlen = ch_array(6)-ch_array(5); %length of train in ms: get from timing var
polarity = 1; %1 is cathode first, 0 is anode first
command = {'TL', trainlen, 'Freq', ch_array(4), 'CathAmp', ch_array(2),'AnodAmp', ch_array(2), ...
    'CathDur', ch_array(3)*1000, 'AnodDur', ch_array(3)*1000, 'PL', polarity};

ws.set_stim(command, ch_array(1)); %this might be too much? 

ws.set_TD(50, ch_array(1)); %set train delay (time from when stim receive command and starts going, must be >= 50)

ws.set_Run(ws.run_once, ch_array(1)); %can also set run continuous to just once

%% stimulate multiple channels
ch_arrays = [channels.vl, channels.bfa, channels.ip]; 
ch_num = []; 
for ch=1:length(ch_arrays)
    ch_array = ch_arrays(ch);
    ch_num(ch) = ch_array(1); %add the channel number to the array for run stim later
    trainlen = ch_array(6)-ch_array(5); %length of train in ms: get from timing var
    polarity = 1; %1 is cathode first, 0 is anode first
    command = {'TL', trainlen, 'Freq', ch_array(4), 'CathAmp', ch_array(2),'AnodAmp', ch_array(2), ...
        'CathDur', ch_array(3)*1000, 'AnodDur', ch_array(3)*1000, 'PL', polarity};
    
    ws.set_stim(command, ch_array(1)); %this might be too much data?
    ws.set_TD(50, ch_array(1));
end

ws.set_Run(ws.run_once, ch_num); 


