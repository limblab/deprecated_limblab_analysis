function some_output = test_stim_multi()

%first, define a serial channel
%if this errors, run the following: 
%delete(instrfindall);
%clear s;
disp('define a serial channel');
s = serial('COM1','BaudRate',115200);

%define the inputs
disp('define inputs'); 
%prefix = 'p'; %p - program, r - run, h - halt
chList = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]; %which channels do I want to stimulate?
mode = 'static_pulses'; %can I do an array with different values here for different channels?
amp = [4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3]; % in mA
pw = [.2,.4,.4,.4,.4,.2,.2,.2,.2,.4,.4,.4,.4,.2,.2,.2]; % in ms
freq = 40; % in Hz - all channels must have the same frequency
pulses = 10; %number of pulses in a train; range = 0-65000
time2run = 0; %this is never used WHAT???
stim_tip = .4; % interphase time in ms (what does that mean???)

%then write the important variables to a string
disp('write important variables to a string'); 

for channel=1:length(chList)
    % Define program string with appropriate parameters for stimulator
    output_string = fns_stim_prog('p',channel-1,mode,amp(channel),pw(channel),freq,pulses,time2run,stim_tip);
    % Send program to FNS-16 stimulator
    disp(['send string to stimulator for channel ',num2str(channel-1)] ); 
    fopen(s); fwrite(s,output_string); fclose(s); pause(0.001);
end  

%write this info to the serial port
disp('send string to stimulator'); 
% fopen(s); 
% fwrite(s,output_string); 
% fclose(s); pause(0.001);


%tell the stimulator to actually use the info we gave it earlier
 

%what to send: alternate "flexors" and "extensors" (ie take a break after
%each train) - so do 10 pulses @ 40 hz = .25s of stimulation. Then pause
%for .25s to simulate the alternation between phases. Do 10 cycles of this
%(10 "steps"). Then wait 30s to let some charge diffuse. Repeat this whole
%thing 50 times to simulate one session of stimulation. Check wires, repeat
%session until everything is breaking down. 

for i=1:50 %one session - should take about 30 min
    for j=1:10 %10 steps
        fopen(s); 
        strOUT2 = fns_stim_prog('r', chList-1); %run 10-pulse train
        fwrite(s,strOUT2);
        fclose(s);
        pause(.5); %pause .25 to let the stim run and .25 for alternating
    end
    pause(30); %let the charge diffuse
end


%all done!
some_output = 0; 
disp('success!'); 
