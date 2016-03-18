function out = wireless_stim_test(serial_string, verbosity)
    out = 1; %if the program fails, this returns a nonzero value
    ws = wireless_stim(serial_string, verbosity); %ie 'COM3', 1
    ws.init(1, ws.comm_timeout_disable); 
    out = practice(ws,1:ws.num_channels); 
    %set up variables so it's easy to change all of them here
    trainlen = 100; %length of train pulse (ms)
    freq = 40; %frequency (hz)
    cath = 100; %pw of cathode phase (us)
    anod = cath; %pw of anode phase (us)
    traindel = 10; %train delay (ms): see "test.m" to see how this is config diff per channel
    polarity = 1; %1 is cathode first, 0 is anode first
    channels = 1:ws.num_channels;
    %interphase = ?? %left as default but there is an 'IPIDur' interphase duration option
    mode = ws.run_once; %call property ws.run_ for whichever option to get number
    command = {'TL', trainlen, 'Freq', freq, 'CathDur', cath, 'AnodDur', anod, ...
        'TD', traindel, 'PL', polarity, 'Run', mode}; 
    ws.set_stim(command, channels); 
    
    ws.set_TD(50, channels);
    
    ws.set_Run(ws.run_cont, channels);
    
end

%zigbee only accepts 155 bytes so we can't send too much info at once
%limit is two parameters in all 16 channels (but only gets compressed if
%doing all channels - can't do this in 12)

function out = practice(ws, channels)
    offset = 32768; 
    packet{1} = struct('Freq', 40, 'CathAmp',3000+offset, 'AnodAmp', offset-3000); 
    ws.set_stim(packet, channels); 
    
    ws.set_TD(50, channels); 
    
    ws.set_Run(ws.run_cont, channels);
    out = 0; 
end


%functions I need: 
% update amplitude
% update pw
% ALL PARAMETERS ARE IN THIS STRUCT: 
%         command_fields = {'TL', ...      % Train length, length of train pulse (ms)
%                           'Freq', ...    % Frequency of pulses (Hz)
%                           'CathDur', ... % Duration of just Cathode phase (us)
%                           'AnodDur', ... % Duration of just Anode phase (us)
%                           'CathAmp', ... % Amplitude of Cathode pulse 0-65535 levels
%                           'AnodAmp', ... % Amplitude of Anode pulse 0-65535 levels
%                           'TD', ...      % Train Delay, time to delay a pulse (us)
%                           'PL', ...      % Polarity, 1=Cathodic first, 0=Anodic first
%                           'IPIDur', ...  % Intra-phase Interval (us)
%                           'Run', ...     % Start/Stop the stim, 0=stop, 1=run, 2=continuous
%                           };
% update parameters for multiple channels (split up so 155 bytes isn't a
% problem)
% also, need to deal with whether this is bipolar or monopolar stim (how?
% look at how it's dealt with in call_run...
% 