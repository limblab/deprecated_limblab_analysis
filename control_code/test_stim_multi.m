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
mode = 'static_train'; %can I do an array with different values here for different channels?
amp = [1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2]; % in mA
pw = [.2,.3,.2,.3,.2,.3,.2,.3,.2,.3,.2,.3,.2,.3,.2,.3]; % in ms
freq = 30; % in Hz - all channels must have the same frequency
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

%for i=0:100 %stimulate a certain number of times -- could I control this just by changing the number of pulses? 
fopen(s); 
strOUT2 = fns_stim_prog('r', chList-1); %check with line 165 of stimrec
fwrite(s,strOUT2);
fclose(s);
pause(0.1)

%end

%all done!
some_output = 0; 
disp('success!'); 
