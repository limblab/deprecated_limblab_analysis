clear all; daqreset;
ai = analoginput('nidaq','Dev2');
addchannel(ai,0);
set(ai,'InputType', 'SingleEnded');
ai.SampleRate = 10000;
ai.SamplesPerTrigger = 10000;
ao = analogoutput('nidaq','Dev2');
addchannel(ao,0);
ao.SampleRate = 1000;
% Make sure the analog output is at zero.  This ensures that we can clearly
% see when the analog output begins.
putsample(ao,0)

% Generate an output test signal (1Hz sine wave) and load test signal into
% the analog output buffer.
outputSignal = sin(linspace(0,pi*2,ao.SampleRate)');
putdata(ao,outputSignal)

%%
% Start the acquisition and generation.  These two operations are
% not coordinated by hardware.  Because of the order in the brackets, the
% analog input is simply started before the analog output.
start([ai,ao])

% Wait up to two seconds to allow the operations to complete,
% and retrieve the results from the toolbox.
wait([ai,ao],2)
[data,time] = getdata(ai);

% Multiply the time by 1000 to convert seconds to milliseconds.
plot(time * 1000,data)
title('Synchronization using START')
xlabel('milliseconds')
ylabel('volts')
