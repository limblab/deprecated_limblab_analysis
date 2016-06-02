function ret = emg_stim(emg_array, channels, thresholds, freq, com_port)
%This function takes a matrix of emg values, and stimulates the
%corresponding channels for each row of values at the specified frequency
%EMG_ARRAY: input a low-pass-filtered array of EMGs; this assumes that
%array is sampled at 40 Hz
%CHANNELS: 
%THRESHOLDS: EMG and current limits for the conversion
%COM_PORT: the correct port for communications with wireless Ripple
%stimulator
%Testing function call emg_stim([1 2 3; 4 5 6], [1, 2], [1, 

%set default values
pw = .2; %Pulse width should be 200 us for all channels

%make stimulator object
%send pw, freq defaults to stimulator

%check size of EMG matrix and match each row with channels to determine 
%muscles to stimulate

%cycle through EMG array, and convert all values to current values (mA), 
%cycle through current array using tic and toc in while loop at approx. the
%frequency chosen, updating stimulator with new values for every channel,
%then running all of these updated values (constrain time to the running of
%updated values, not the updating itself? no wait, if run_cont is the rule,
%updating values is immediate.)

%should I use run_cont? I think so for this case, yeah.


end