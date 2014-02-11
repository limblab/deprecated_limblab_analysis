%function [AA_Coupling] = ampampcoupling(out_struct, LFPInds, SpikeInds, ControlType, H, SigGain)
% bdf - plain old bdf
%% Inputs
% LFPinds{1} - [LFPchannel, freqind] - x direction
% LFPinds{2} - [LFPchannel, freqind] - y direction
% **Placement of ch and freq index in first or second cell only matters if
% doing 2 feature LFP control otherwise put in first cell if doing
% 1 spike/1 LFP feature control

% ****Make sure to convert the spike channel to the corresponding LFP
% channel!
% Spikeinds{1} - [LFPchannel, unit] - x direction
% Spikeinds{2} - [LFPchannel, unit] - y direction
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
%% Find file path, load file and start iterating through files
for q = 1:length(Mini_Learning)
    
    fnam =  findBDFonCitadel(Mini_Learning{q})
    try
        load(fnam)
    catch exception
        continue
    end
    
    %% Declare input variables within loop that vary in each loop iteration:
    
    if exist('out_struct','var')
        bdf = out_struct;
        clear out_struct
    end
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
        [xOnline] = PickOutInputSignals(LFPInds,SpikeInds,ControlType,PB,x);
    
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
    data2 = tsFPorder{SpikeInds{1}};
    data2 = data2(data2>=1.0);
    
    tic
    [Trial_Success_FPend, Trial_Success_tsend, Trial_Success_Path_Whole...
    Trial_Success_Path_Whole_Good] = parseTrials(bdf,y,xOnline,data1,data2);
    toc
    
    Trial_Success_Path_Whole_File{q} = Trial_Success_Path_Whole;
    Trial_Success_Path_Whole_Good_File{q} = Trial_Success_Path_Whole_Good;
    
    win = [.25 .05];
    paramsFP.tapers = [5 9];
    paramsFP.Fs = 1000;
    paramsFP.fpass = [0 300];
    paramsFP.pad = 1;
    % params.err
    paramsFP.trialave = 1;
    segave = 0;
    fscorr = 0;
    
    
%    Trial_Success_FPbeginMAT = cell2mat(Trial_Success_FPbegin);
    Trial_Success_FPendMAT = cell2mat(Trial_Success_FPend);
    
%    Trial_Fail_FPbeginMAT = cell2mat(Trial_Success_FPbegin);
%    Trial_Fail_FPendMAT = cell2mat(Trial_Success_FPend);
    
%    [C_Success_begin,phi,S12,S1,S2,t,f,zerosp]=cohgramcpt(Trial_Success_FPbeginMAT,Trial_Success_tsbegin,win,paramsFP);
    [C_Success_end,phi,S12,S1,S2,t,f,zerosp]=cohgramcpt(Trial_Success_FPendMAT,Trial_Success_tsend,win,paramsFP); 

%     [C_Fail_begin,phi,S12,S1,S2,f,zerosp]=cohgramcpt(Trial_Fail_FPbeginMAT,Trial_Fail_tsbegin,win,paramsFP);
%     [C_Fail_end,phi,S12,S1,S2,f,zerosp]=cohgramcpt(Trial_Fail_FPendMAT,Trial_Fail_tsend,win,paramsFP);
     
    C_AllFiles(:,:,q) = nanmean(C_Success_end,3);
    
    
    clear sig words fp fptimes analog_time_base y t ts numbins PB cells x ts b xOnline bdf Yrecon tsFPorder
    clear Trial_Success_FPend Trial_Success_FPendMAT Trial_Success_tsend Trial_Success_Path_Whole...
        Trial_Success_Path_Whole_Good
    %Trial_Success_FPend Trial_Success_tsend TrialPath TrialInput Trial_Fail_FPbegin ...
    %Trial_Fail_tsbegin Trial_Fail_FPend Trial_Fail_tsend
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

