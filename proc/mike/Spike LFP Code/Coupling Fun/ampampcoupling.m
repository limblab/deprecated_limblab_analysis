function [AA_Coupling] = ampampcoupling(bdf)

% Consider making these variables inputs to the function
binsize = 50;
samplerate = 1000;
wsz = 256;

[sig, samplerate, words, fp,~,~,~,~,fptimes, analog_time_base] = SetPredictionsInputVar(bdf);

[y, fp, t] = fpadjust(binsize, samplerate, fptimes, wsz, sig, fp, analog_time_base);

params.tapers = [5 9];

params.Fs = .001;
    
params.fpass = [0 300];
% params.pad
% params.err  
params.trialave = 0;
win = [SizeofWindow WindowStepsize]

[S,f,varS,C,Serr]=mtspectrumsegc(data,win,params,segave)


c = xcov(S,'coef')
% Subtracts mean and then calculates corr coef

%% Calculate spike-field coherence

[C,phi,S12,S1,S2,f,zerosp,confC,phistd,Cerr]=
coherencycpt(data1,data2,params,fscorr,t)