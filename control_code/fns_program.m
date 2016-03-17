function string_to_send = fns_program(action, ch_list, mode, amp, pw, varargin)
% STRING_TO_SEND 
% Creates a string with the correct formatting to be sent to the FNS-16 stimulator, which programs and runs the stimulator
%
% INPUTS
%     action: prompts the stimulator to use one of these prefixes listed in the
%     manual - 0(program to follow; load and run immediately), 1(run all
%     channels with programs; one character command), 2(halt all running
%     channels; one char command), 3(run a list of channels), 4(halt a list of
%     channels), 5(program to follow; load but do not run), 8(turn off
%     high-voltage outputs; one char command), 9(same action as 8)
%     
%     ch_list: a list of channels which the program should apply to; valid
%     inputs will be anywhere from 1 to 16 channels
%    
%     mode: what type of pulses you will send, can be - 0(program to
%     follow), 1(single execution of a waveform), 2(train of n pulses),
%     3(train of pulses for time t), 4(run existing program), 9(halt running
%     program)
%     
%     amp: stimulation current, in mA
%     
%     pw: pulse width, in ms
% 
%     freq: only used in mode 0??? TODO
% 
% OPTIONAL INPUTS
%     polarity: 1 for first phase positive, 0 for first phase negative.
%     Default value is 1.
% 
%     int_time: ???? TODO interphase time/ usually assume default is .4 ms
%
%     no_pulses: number of pulses in train (0-65000), only used in mode 2
%
%     run_time: length of time to run train in ms (0-65000), only used in
%     mode 3

%%Deal with optional inputs and define variables based on inputs
% set defaults for optional inputs
numvarargs = length(varargin);
optargs = {1 .4 0 0};

% and overwrite defaults with specified values
optargs(1:numvarargs) = varargin;

% Place optional args in memorable variable names
[polarity, int_time, no_pulses, run_time] = optargs{:};

%

%TODO copy - 
%current phases from amp
%pulse width from time phases
%repetition time from freq

%will need to pass - prefix, channel mask, mode, polarity, phase1current, phase2current, time phase1, timephase2, interphase time, repetition time, termination char



