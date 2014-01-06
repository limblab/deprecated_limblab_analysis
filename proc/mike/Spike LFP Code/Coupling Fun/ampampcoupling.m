function [AA_Coupling] = ampampcoupling(out_struct, LFPInds, SpikeInds, ControlType)
% bdf - plain old bdf
% LFPinds{1} - {[LFPchannel, freqind]} - x direction
% LFPinds{2} - {[LFPchannel, freqind]} - y direction

% ***Make sure to convert the spike channel to the corresponding LFP
% channel!
% Spikeinds{1} - {[LFPchannel, unit]} - x direction
% Spikeinds{2} - {[LFPchannel, unit]} - y direction

% ControlType{1} - {'Control Type'} - 'HC' or 'BC'
% ControlType{2} - [ControlSignalX, ControlSignalY] - LFP ==1; Spike == 2
% ex. [Spike, Spike] = [2, 2]; [LFP, Spike] = [1, 2]; [LFP, LFP] = [1, 1];
% Consider making these variables inputs to the function
binsize = 50;
wsz = 256;
bdf = out_struct;
clear out_struct
%% Determine Control Type
if strcmp(ControlType{1},'BC')
    samplerate = .05;
elseif strcmp(ControlType{1},'HC')
    samplerate = 1000;
end

%% Condition and organize fps
[sig, ~, words, fp,~,~,~,~,fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
[y, fp, t, numbins] = fpadjust(binsize, samplerate, fptimes, wsz, sig, fp, analog_time_base);
[PB] = calculateBandPower(wsz, size(fp,1), numbins, samplerate, fp, binsize, y, t);

%% Bin and organize spikes
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

%% Pick out correct input signals and arrange into xOnline matrix
[xOnline] = PickOutInputSignals(LFPInds,SpikeInds,ControlType,PB,x);

%% Plot actual and reconstructed velocity
dir =['X';'Y'];
for i = 1:2
    figure(i) 
    plot(y(:,i),'r')
    hold on
    %% Check reconstructed velocity, make sure it matches online predictions
    if ControlType{2}(i) == 2 % plot spike for x direction
        xrecon(:,i) = xOnline(:,i);
        plot(xrecon(:,i),'g')
        plot(((xrecon(5:end,i)*H(5,i)+xrecon(4:end-1,i)*H(4,i)+xrecon(3:end-2,i)*H(3,i)+xrecon(2:end-3,i)*H(2,i)+xrecon(1:end-4,i)*H(1,i)))*SigGain(2),'b')   % this shortens spike input by 5
        title('Spike Input (green) Spike Reconstructed(blue) Predicted velocity (red) in',dir(i))
        
    else % plot LFP for x direction
        xrecon(:,i) = xOnline(:,i);
        plot(xrecon(:,i),'g')
        plot(xrecon(:,i)*max(abs(H(:,i)))*SigGain(1),'b')
        title('LFP Input (green) LFP Reconstructed(blue) Predicted velocity (red) in',dir(i))
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

% [C,phi,S12,S1,S2,f,zerosp,confC,phistd,Cerr]=
% coherencycpt(data1,data2,params,fscorr,t)