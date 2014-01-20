%function [AA_Coupling] = ampampcoupling(out_struct, LFPInds, SpikeInds, ControlType, H, SigGain)
% bdf - plain old bdf
%% Inputs
% LFPinds{1} - {[LFPchannel, freqind]} - x direction
% LFPinds{2} - {[LFPchannel, freqind]} - y direction
% **Placement of ch and freq index in first or second cell only matters if
% doing 2 feature LFP control otherwise put in first cell if doing
% 1 spike/1 LFP feature control

% ****Make sure to convert the spike channel to the corresponding LFP
% channel!
% Spikeinds{1} - {[LFPchannel, unit]} - x direction
% Spikeinds{2} - {[LFPchannel, unit]} - y direction
% **Placement of ch and unit index in first or second cell only matters if
% doing 2 unit Spike control otherwise put in first cell if doing 1
% spike/1 LFP feature control

% ControlType{1} - {'Control Type'} - 'HC' or 'BC'
% ControlType{2} - [ControlSignalX, ControlSignalY] - LFP ==1; Spike == 2
% ex. [Spike, Spike] = [2, 2]; [LFP, Spike] = [1, 2]; [LFP, LFP] = [1, 1];

%% Consider making these variables inputs to the function
binsize = .05;
wsz = 256;
samplerate = 1000;
colors = [1:.2:0; 0:.2:1; 1:.2:0];
%% Find file path, load file and start iterating through files
for q = 1% : length(FileList)
    
%     fnam =  findBDFonCitadel(FileList{1})
%     try
%         load(fnam)
%     catch exception
%         continue
%     end
    
    %% Declare input variables within loop that vary in each loop iteration:
    
    if exist('out_struct','var')
        bdf = out_struct;
        clear out_struct
    end
    
    %% Condition and organize fps
    [sig, ~, words, fp,~,~,~,~,fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
    [y, ~, t, numbins] = fpadjust(binsize, samplerate, fptimes, wsz, sig, fp, analog_time_base);
    [PB, t, y] = calculateBandPower(wsz, size(fp,1), numbins, samplerate, fp, binsize, y, t);
    
    %% Bin and organize spikes
    cells = unit_list(bdf);
    for i = 1:length(cells)
        if cells(i,1) ~= 0
            ts{i} = get_unit(bdf, cells(i, 1), cells(i, 2));
            b = train2bins(ts{i},t);
            if cells(i,1) < 65
                x(:,cells(i,1)+32) = b;
                tsFPorder{cells(i,1)+32} = ts{i};
            else
                x(:,cells(i,1)-64) = b;
                tsFPorder{cells(i,1)-64} = ts{i};
            end
        else
            x(:,i) = zeros(length(y),1);
        end
    end
    
    %% Pick out correct input signals and arrange into xOnline matrix
%    [xOnline] = PickOutInputSignals(LFPInds,SpikeInds,ControlType,PB,x);
    
    %% Plot actual and reconstructed velocity
%     dir =['X';'Y'];
%     for i = 1:2
%         figure(i+12)
%         plot(y((size(H,1)):end,i+1),'r')
%         hold on
%         %% Check reconstructed velocity, make sure it matches online predictions
%         if ControlType{2}(i) == 2 % plot spike
%             xrecontmp = xOnline(:,i);
%             
%             Yrecon(:,i) = (xrecontmp(10:end)*H(10,i)+xrecontmp(9:end-1)*H(9,i)+...
%                 xrecontmp(8:end-2)*H(8,i)+xrecontmp(7:end-3)*H(7,i)+xrecontmp(6:end-4)*H(6,i)...
%                 +xrecontmp(5:end-5)*H(5,i)+xrecontmp(4:end-6)*H(4,i)+xrecontmp(3:end-7)*H(3,i)...
%                 +xrecontmp(2:end-8)*H(2,i)+xrecontmp(1:end-9)*H(1,i))*SigGain(i);
%             r = corrcoef(y((size(H,1)):end-4,i+1),Yrecon(5:end,i))
%             
%             plot(xOnline(:,i),'g')
%             plot(Yrecon,'b')   % this shortens spike input by 5
%             title('Spike Input (green) Spike Reconstructed(blue) Actual Predicted velocity (red)')
%             clear xrecontmp
%         else % plot LFP
%             xrecontmp = xOnline(:,i);
%             
%             Yrecon(:,i) = (xrecontmp(10:end)*H(10,i)+xrecontmp(9:end-1)*H(9,i)+...
%                 xrecontmp(8:end-2)*H(8,i)+xrecontmp(7:end-3)*H(7,i)+xrecontmp(6:end-4)*H(6,i)...
%                 +xrecontmp(5:end-5)*H(5,i)+xrecontmp(4:end-6)*H(4,i)+xrecontmp(3:end-7)*H(3,i)...
%                 +xrecontmp(2:end-8)*H(2,i)+xrecontmp(1:end-9)*H(1,i));%*SigGain(i);
%             r = corrcoef(y((size(H,1))+1:end,i+1),Yrecon(1:end-1,i))
%             
%             plot(xOnline(:,i),'g')
%             plot(Yrecon,'b')
%             title('LFP Input (green) LFP Reconstructed(blue) Actual Predicted velocity (red)')
%             clear xrecontmp
%         end
%     end
%     
%     %% Parse and Separate Trials
%     
%     [TrialPath, TrialInput, rtrialSig{q}, pSig, rtrialInput{q}, pInput, rtrialpathcat(q), pCatPath, rtrialinputcat(q), pCatInput] = parseTrials(bdf,y,xOnline);
%     
%     rInputAvg(q) = cellfun(@mean,rtrialInput)
%     rSignalAvg(q) = cellfun(@mean,rtrialSig)
    
    %     figure(q)
    %     plot(rtrialSig{q})
    %
    %     figure(q+5)
    %     plot(rtrialInput{q})
    
    %% Calculate spike-field coherence
    data1 = fp(LFPInds{1}(1),:)';
    data2 = ts{SpikeInds{1}(1)};
    win = 50;
    paramsFP.tapers = [3 5];
    paramsFP.fpass = [0 300];
    params.pad = 1;
    % params.err
    segave = 0;
    fscorr = 0;
    
    [C,phi,S12,S1,S2,f,zerosp]=coherencysegcpt(data1,data2,win,paramsFP,segave,fscorr);
    
%    clear sig words fp fptimes analog_time_base y fp t ts numbins PB cells x ts b xOnline bdf Yrecon tsFPorder
end
%% Set input params for multitaper spectrum

% paramsFP.tapers = [5 9];
% paramsFP.Fs = .001;
% paramsFP.fpass = [0 300];
% % params.pad
% % params.err
% paramsFP.trialave = 0;
% win = [.256 .050]
% segave = 0;
%
%
% % data = time x channels/trials
% [S_FP,f_FP,varS_FP,C_FP,Serr_FP]=mtspectrumsegc(data,win,paramsFP,segave)
% [S,f,varS,C,Serr]=mtspectrumsegpb(x,win,params,segave)
%
%
% c = xcov(S,'coef')
% Subtracts mean and then calculates corr coef

