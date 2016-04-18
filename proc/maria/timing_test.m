if ~exist('ws', 'var')
    serial_string = 'COM6'; %this is different via mac and windows; use instrfind to check location
    ws = wireless_stim(serial_string, 1); %the number has to do with verbosity of running feedback
    ws.init(1, ws.comm_timeout_disable);
end

%TODO update these vals

command{1} = struct('TL', tl, ...%ms
    'Freq', freq, ...        % Hz
    'CathDur', pw, ...    % us
    'AnodDur', pw, ...    % us
    'CathAmp', amp+32768, ... % uA
    'AnodAmp', 32768-amp, ... % uA
    'Run', ws.run_once ... % Single train mode
    );
ws.set_stim(command, ch);

%now run this on the channels we need to do to indicate to vicon that it
%needs to start
