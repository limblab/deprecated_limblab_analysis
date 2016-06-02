function ret=stim
%initiate wireless stim object
serial_string = 'COM3'; %this is different via mac and windows; use instrfind to check location
ws = wireless_stim(serial_string, 1); %the number has to do with verbosity of running feedback
ws.init(1, ws.comm_timeout_disable);

%make command for basic stuff that won't change
command{1} = struct('TL', 500, ... % 100ms
    'Freq', 10, ...        % 30 Hz
    'CathDur', 200, ...    % 200 us
    'AnodDur', 200, ...    % 200 us
    'TD', 100, ...           % train delay per channel
    'PL', 1, ...           % Cathodic first
    'Run', ws.run_once ... % Single train mode
    );

%set channels to stimulate
%channel_list = 1:ws.num_channels;  % all channels
%channel_list = [1 2 3];  % some channels
channel_list = 2; %one channel
ws.set_stim(command, channel_list);  % set the parameters for all channels listed

%set amps and run immediately
amp = 3; %this is in mA (but it gets programmed in uA)

command{1} = struct('CathAmp', 32768+(amp*1000), 'AnodAmp', 32768-(amp*1000), 'Run', ws.run_cont);
ws.set_stim(command, channel_list); %note: I need to figure out setting different channels to different currents, simultaneously
 

%how to control timing of the pulses. 
pause(10); 
% 
% a = ws.get_stim(2);
% a{1}
% disp('get run state: '); 
% ws.get_Run(2)
% disp('run cont value: '); 
% ws.run_cont
% 
% disp('end'); 
% 
delete(ws); %get rid of the object and close the serial connection. 

ret = 0; 

end