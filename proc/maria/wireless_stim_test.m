function out = wireless_stim_test(serial_string, verbosity)
    ws = wireless_stim(serial_string, verbosity); 
    ws.init(1, ws.comm_timeout_disable); 
    practice(ws,1:ws.num_channels)
    
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

end