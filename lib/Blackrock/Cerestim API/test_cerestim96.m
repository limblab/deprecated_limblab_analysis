temp=cerestim96;
temp.connect();
isconnected=temp.isConnected()


tic
%single pulse on module 1, cathodic first, 20uA, 200uS @ 200hz
temp.setStimPattern('waveform',1,'polarity',0,'pulses',1,'amp1',20,'amp2',20,'width1',200,'width2',200,'interphase',53,'frequency',200)
temp.beginSequence()
%send electrode 1 the stimulus in stim pattern 1
temp.autoStim(1,1);
temp.endSequence()
toc

