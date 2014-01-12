function [AA_Coupling] = ampampcoupling(out_struct, LFPInds, SpikeInds, ControlType, H, SigGain)
% bdf - plain old bdf
%% Inputs
% LFPinds{1} - {[LFPchannel, freqind]} - x direction
% LFPinds{2} - {[LFPchannel, freqind]} - y direction

% ***Make sure to convert the spike channel to the corresponding LFP
% channel!
% Spikeinds{1} - {[LFPchannel, unit]} - x direction
% Spikeinds{2} - {[LFPchannel, unit]} - y direction

% ControlType{1} - {'Control Type'} - 'HC' or 'BC'
% ControlType{2} - [ControlSignalX, ControlSignalY] - LFP ==1; Spike == 2
% ex. [Spike, Spike] = [2, 2]; [LFP, Spike] = [1, 2]; [LFP, LFP] = [1, 1];

%% Consider making these variables inputs to the function
binsize = .05;
wsz = 256;
samplerate = 1000;
bdf = out_struct;
clear out_struct

%% Condition and organize fps
[sig, ~, words, fp,~,~,~,~,fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
[y, fp, t, numbins] = fpadjust(binsize, samplerate, fptimes, wsz, sig, fp, analog_time_base);
[PB, t, y] = calculateBandPower(wsz, size(fp,1), numbins, samplerate, fp, binsize, y, t);

%% Bin and organize spikes
cells = unit_list(bdf);
for i = 1:length(cells)
    if cells(i,1) ~= 0
        ts = get_unit(bdf, cells(i, 1), cells(i, 2));
        b = train2bins(ts,t);
        if cells(i,1) < 65
            x(:,cells(i,1)+32) = b;
        else
            x(:,cells(i,1)-64) = b;
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
    plot(y((size(H,1)):end,i+1),'r')
    hold on
    %% Check reconstructed velocity, make sure it matches online predictions
    if ControlType{2}(i) == 2 % plot spike
        xrecontmp = xOnline(:,i);
        
        Yrecon(:,i) = (xrecontmp(10:end)*H(10,i)+xrecontmp(9:end-1)*H(9,i)+...
            xrecontmp(8:end-2)*H(8,i)+xrecontmp(7:end-3)*H(7,i)+xrecontmp(6:end-4)*H(6,i)...
            +xrecontmp(5:end-5)*H(5,i)+xrecontmp(4:end-6)*H(4,i)+xrecontmp(3:end-7)*H(3,i)...
            +xrecontmp(2:end-8)*H(2,i)+xrecontmp(1:end-9)*H(1,i))*SigGain(i);
        r = corrcoef(y((size(H,1)):end-4,i+1),Yrecon(5:end,i))
        
        plot(xOnline(:,i),'g')
        plot(Yrecon,'b')   % this shortens spike input by 5
        title('Spike Input (green) Spike Reconstructed(blue) Actual Predicted velocity (red)')
        clear xrecontmp
    else % plot LFP
        xrecontmp = xOnline(:,i);
        
        Yrecon(:,i) = (xrecontmp(10:end)*H(10,i)+xrecontmp(9:end-1)*H(9,i)+...
            xrecontmp(8:end-2)*H(8,i)+xrecontmp(7:end-3)*H(7,i)+xrecontmp(6:end-4)*H(6,i)...
            +xrecontmp(5:end-5)*H(5,i)+xrecontmp(4:end-6)*H(4,i)+xrecontmp(3:end-7)*H(3,i)...
            +xrecontmp(2:end-8)*H(2,i)+xrecontmp(1:end-9)*H(1,i));%*SigGain(i);
        r = corrcoef(y((size(H,1))+1:end,i+1),Yrecon(1:end-1,i))
        
        plot(xOnline(:,i),'g')
        plot(Yrecon,'b')
        title('LFP Input (green) LFP Reconstructed(blue) Actual Predicted velocity (red)')
        clear xrecontmp
    end
end

%% Parse and Separate Trials

[TrialPath TrialInput] = parseTrials(bdf,Yrecon)


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