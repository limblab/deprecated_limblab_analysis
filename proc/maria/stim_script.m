% [channels, ws] = start_stim; %initiates ws object, sets up init channel values
% 
% %NEXT MOVES IN A NORMAL PROGRAM DOING THING: SINGLE CHANNEL STIM, MULTI
% %CHANNEL STIM, STIM ALL? 
% 
% %% stimulate a single channel
% ch_array = channels.bfa; 
% trainlen = ch_array(6)-ch_array(5); %length of train in ms: get from timing var
% polarity = 1; %1 is cathode first, 0 is anode first
% command{1} = struct('TL', trainlen, 'Freq', ch_array(4), 'CathAmp', ch_array(2)+32768,'AnodAmp', 32768-ch_array(2), ...
%     'CathDur', ch_array(3)*1000, 'AnodDur', ch_array(3)*1000, 'PL', polarity);
% 
% ws.set_stim(command, ch_array(1)); %this might be too much? 
% 
% ws.set_TD(50, ch_array(1)); %set train delay (time from when stim receive command and starts going, must be >= 50)
% 
% ws.set_Run(ws.run_once, ch_array(1)); %can also set run continuous to just once
% 
% %% stimulate multiple channels
% ch_arrays = {channels.vl, channels.bfa, channels.ip}; 
% ch_num = []; 
% %clear('command');
% for ch=1:length(ch_arrays)
%     ch_array = ch_arrays{ch};
%     disp(ch_arrays); 
%     disp(ch_array); 
%     ch_num(ch) = ch_array(1); %add the channel number to the array for run stim later
%     trainlen = ch_array(6)-ch_array(5); %length of train in ms: get from timing var
%     polarity = 1; %1 is cathode first, 0 is anode first
%     
%     command{1} = struct('TL', trainlen, 'Freq', ch_array(4), 'CathAmp', ch_array(2)+32768,'AnodAmp', ch_array(2)-32768, ...
%         'CathDur', ch_array(3)*1000, 'AnodDur', ch_array(3)*1000, 'PL', polarity)
%     
%     ws.set_stim(command, ch_array(1)); %this might be too much data?
%     ws.set_TD(50, ch_array(1));
% end
% 
% ws.set_Run(ws.run_once, ch_num); 


%initiate wireless stim object
serial_string = 'COM4'; %this is different via mac and windows
ws = wireless_stim(serial_string, 1); %the number has to do with verbosity of running feedback
ws.init(1, ws.comm_timeout_disable);

command{1} = struct('TL', 100, ... % 100ms
    'Freq', 30, ...        % 30 Hz
    'CathDur', 200, ...    % 200 us
    'AnodDur', 200, ...    % 200 us
    'TD', 100, ...           % train delay per channel
    'PL', 1, ...           % Cathodic first
    'Run', ws.run_once ... % Single train mode
    );

%NOW SET AMPSSSS (OR LEAVE DEFAULT??)
channel_list = 1:ws.num_channels;  % all channels
ws.set_stim(command, channel_list);  % set the parameters

command{1} = struct('CathAmp', 32768+3000, 'AnodAmp', 32768-3000, 'Run', ws.run_once_go);
ws.set_stim(command, channel_list);

delete(ws);

