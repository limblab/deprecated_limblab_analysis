function some_output = test_stim()

%first, define a serial channel
disp('define a serial channel');
s = serial('COM1','BaudRate',115200);

%define the inputs
disp('define inputs'); 
prefix = 'p'; %p - program, r - run, h - halt
chList = 1; %which channels do I want to stimulate?
mode = 'static_pulses'; %can I do an array with different values here for different channels?
amp = 1; % in mA
pw = .2; % in ms
freq = 30; % in Hz
pulses = 1; %how many happen? not sure ???
time2run = 0; %this is never used ???
stim_tip = .4; % interphase time in ms ???

%then write the important variables to a string
disp('write important variables to a string'); 
output_string = fns_stim_prog(prefix,chList,mode,amp,pw,freq,pulses,time2run,stim_tip); 

%write this info to the serial port
disp('send string to stimulator'); 
fopen(s); 
fwrite(s,output_string); 
fclose(s); pause(0.001);

%tell the stimulator to actually use the info we gave it earlier

for i=0:100 %stimulate a certain number of times -- could I control this just by changing the number of pulses? 
fopen(s); 
strOUT2 = fns_stim_prog('r', 0); %check with line 165 of stimrec
fwrite(s,strOUT2);
fclose(s);
pause(0.1)

end

%all done!
some_output = 0; 
disp('success!'); 
