function [AA_Coupling] = ampampcoupling(bdf)

% Consider making these variables inputs to the function
binsize = 50;
samplerate = 1000;
wsz = 256;

%% Condition and organize fps
[sig, samplerate, words, fp,~,~,~,~,fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
[y, fp, t] = fpadjust(binsize, samplerate, fptimes, wsz, sig, fp, analog_time_base);

%% Condition and organize spikes
cells = unit_list(bdf);
for i = 1:length(cells)
    if cells(i,1) ~= 0
        ts = get_unit(bdf, cells(i, 1), cells(i, 2));
        b = train2bins(ts,t);
        if cells(i,1) < 33
            x(:,cells(i,1)+64) = b;
        else
            x(:,cells(i,1)-32) = b;
        end
    else
        x(:,i) = zeros(length(y),1);
    end
end

%% Set input params for multitaper spectrum

paramsFP.tapers = [5 9];
paramsFP.Fs = .001;  
paramsFP.fpass = [0 300];
% params.pad
% params.err  
paramsFP.trialave = 0;
win = [.256 .050]
segave = 0;


% data = time x channels/trials
[S_FP,f_FP,varS_FP,C_FP,Serr_FP]=mtspectrumsegc(data,win,paramsFP,segave)
[S,f,varS,C,Serr]=mtspectrumsegpb(x,win,params,segave)


c = xcov(S,'coef')
% Subtracts mean and then calculates corr coef

%% Calculate spike-field coherence

[C,phi,S12,S1,S2,f,zerosp,confC,phistd,Cerr]=
coherencycpt(data1,data2,params,fscorr,t)