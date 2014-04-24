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
pri = 1;
fi =1;
%% Find file path, load file and start iterating through files
for q = 1:length(FileList_1D_2D_HC)
    
    fnam =  findBDFonCitadel(FileList_1D_2D_HC{q})
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
    
    %% Calculate trial stats
    FirstTrialInds=find(bdf.words(:,2)==17);
    NumTrials_File(q) = length(FirstTrialInds);
    
    AbortTrialInds=find(bdf.words(:,2)==33);
    NumAbort_File(q) = length(AbortTrialInds);
    
    SuccessTrialInds=find(bdf.words(:,2)==32);
    NumSuccess_File(q) = length(SuccessTrialInds);
    
    PercentSuccess_File(q) = (NumSuccess_File(q)/NumTrials_File(q))*100;
    
    
    data1 = fp(LFPInds{1}(1),:)';
    data2 = tsFPorder{SpikeInds{1}};
    data2 = data2(data2>=1.0);
    
    numfolds = 20;
    
    if 0
        %% Calculate theta-gamma PAC
        for fold = 1:numfolds
            
            numfp = size(data1,2);
            filelength = size(data1,1);
            
            foldlength = floor(filelength/numfolds);
            data1Fold = data1((fold-1)*foldlength+1:(fold)*foldlength);
            
            samprate = 1000;
            
            [b0,a0]=butter(2,[58 62]/(samprate/2),'stop');
            fpf=filtfilt(b0,a0,data1Fold);
            
            tfmat=zeros(1,numfp,size(fpf,1),'single'); %numfp
            
            %Band Pass Filter Theta and hilbert transform
            [b_theta,a_theta]=butter(2,[4 8]/(samprate/2));
            tfmat_theta(1,:,:)=reshape(hilbert(filtfilt(b_theta,a_theta,fpf)),1,numfp,size(fpf,1));
            
            %Band Pass Filter Gamma 1 (30-100 Hz) and hilbert transform
            [b_gamma,a_gamma]=butter(2,[30 80]/(samprate/2));
            tfmat_gamma(1,:,:)=reshape(hilbert(filtfilt(b_gamma,a_gamma,fpf)),1,numfp,size(fpf,1));
            
            %Band Pass Filter Gamma 2 (80-150 Hz) and hilbert transform
            [b_gamma2,a_gamma2]=butter(2,[80 150]/(samprate/2));
            tfmat_gamma2(1,:,:)=reshape(hilbert(filtfilt(b_gamma2,a_gamma2,fpf)),1,numfp,size(fpf,1));
            
            %Calculate Phase for Theta and Amp for Gammas
            PhaseMat_theta = angle(tfmat_theta);
            AmpMat_gamma = real(tfmat_gamma);
            AmpMat_gamma2 = real(tfmat_gamma2);
            
            [p_i_ThetaGamma(fi,:)] = binAmpByPhase(PhaseMat_theta,AmpMat_gamma);
            [p_i_ThetaGamma2(fi,:)] = binAmpByPhase(PhaseMat_theta,AmpMat_gamma2);
            
            fi = fi+1;
            
            % Randomize Theta Phase and Bin Gamma Amplitude
            fpf_theta = filtfilt(b_theta,a_theta,fpf);%Bandpass filter theta
            u1=pharand(fpf_theta); %Randomize theta phase
            tfmat_theta_RandPhase(1,:,:)=reshape(hilbert(u1),1,numfp,size(fpf,1));% Hilbert transform BPed theta
            PhaseMat_theta_RandPhase = angle(tfmat_theta_RandPhase); %Get phase angle
            [p_i_ThetaGamma_RandPhase(pri,:)] = binAmpByPhase(PhaseMat_theta_RandPhase,AmpMat_gamma);
            [p_i_ThetaGamma2_RandPhase(pri,:)] = binAmpByPhase(PhaseMat_theta_RandPhase,AmpMat_gamma2);
            pri = pri+1;
            
            clear fpf data1Fold
            
        end
    end
    
    if 1
       
        %% Calculate spike-field coherence
        data1_randphase=pharand(data1);
        
        [Trial_FPend{q}, Trial_tsend, Trial_Path_Whole,...
         TargetID{q}, Trial_Incomplete_FPend{q}, Trial_Incomplete_tsend, Trial_Incomplete_Path_Whole...
         Trial_Fail_FPend{q}, Trial_Fail_tsend, Trial_Fail_Path_Whole] = parseTrials(bdf,y,xOnline,data1,data2);
     
        [Trial_FPend_rand{q},~,~,~,~,~,~,~,~,~] = parseTrials(bdf,y,xOnline,data1_randphase,data2);
        
        Trial_Path_Whole_File{q} = Trial_Path_Whole;
        Trial_Fail_Path_Whole_File{q} = Trial_Fail_Path_Whole;
        Trial_Incomplete_Path_Whole_File{q} = Trial_Incomplete_Path_Whole;
         
        Trial_FPendMAT = cell2mat(Trial_FPend{q});
        Trial_Fail_FPendMAT = cell2mat(Trial_Fail_FPend{q});
        Trial_Incomplete_FPendMAT = cell2mat(Trial_Incomplete_FPend{q});
        
        Trial_FPend_randMAT = cell2mat(Trial_FPend_rand{q});
        
        Trial_tsendCELL{q} = Trial_tsend;
        Trial_Fail_tsendCELL{q} = Trial_Fail_tsend;
        Trial_Incomplete_tsendCELL{q} = Trial_Incomplete_tsend;

        binsizes = [0.05 0.1 0.15 0.2 .25 0.5];
        for g = 1:length(binsizes)
        
            win = [binsizes(g) .05];
            paramsFP.tapers = [5 9];
            paramsFP.Fs = 1000;
            paramsFP.fpass = [0 300];
            paramsFP.pad = 1;
            paramsFP.err = [1 0.05];
            paramsFP.trialave = 1;
            segave = 0;
            fscorr = 0;
            t= [];
            
            %    [C_begin,phi,S12,S1,S2,t,f,zerosp]=cohgramcpt(Trial_FPbeginMAT,Trial_tsbegin,win,paramsFP);
            [C_end,~,~,~,~,~,fC{g},~,confC_cohgram,phistd]=cohgramcpt(Trial_FPendMAT,Trial_tsend,win,paramsFP);

            [Coh_end,~,~,~,~,f{g},~,confC_Temp,phistd]=coherencycpt(Trial_FPendMAT(end-1000*binsizes(g):end,:),Trial_tsend,paramsFP,fscorr,[1-binsizes(g):.001:1]);            

                
            if isempty(Trial_Fail_FPendMAT) == 0
                [C_Fail_end,~,~,~,~,~,~,~]=cohgramcpt(Trial_Fail_FPendMAT,Trial_Fail_tsend,win,paramsFP);
            else
                C_Fail_end = [];
            end
            
            if isempty(Trial_Incomplete_FPendMAT) == 0
                [C_Incomplete_end,~,~,~,~,~,~,~]=cohgramcpt(Trial_Incomplete_FPendMAT,Trial_Incomplete_tsend,win,paramsFP);
            else
                C_Incomplete_end = [];
            end
            
            [C_end_rand,~,~,~,~,~,~,~]= cohgramcpt(Trial_FPend_randMAT,Trial_tsend,win,paramsFP);
            
            %     [C_Fail_begin,phi,S12,S1,S2,f,zerosp]=cohgramcpt(Trial_Fail_FPbeginMAT,Trial_Fail_tsbegin,win,paramsFP);
            %     [C_Fail_end,phi,S12,S1,S2,f,zerosp]=cohgramcpt(Trial_Fail_FPendMAT,Trial_Fail_tsend,win,paramsFP);
            
            Cohgram(g,q).Success = C_end;
            Cohgram(g,q).Error = confC_cohgram;
            
            Coherency(g,q).AllFiles = Coh_end;
%             Coherency(g,q).Error = confCavg;
            
            Cohgram(g,q).Fail = C_Fail_end;
            Cohgram(g,q).Incomplete = C_Incomplete_end;
            
            Cohgram(g,q).rand = C_end_rand;
            
            clear Coh_end confC_Temp

        end
        
        clear Coh_end Trial_FPendMAT Trial_tsend Trial_Path_Whole...
        Trial_Fail_FPendMAT Trial_Fail_tsend Trial_Fail_Path_Whole...
        Trial_Incomplete_FPendMAT Trial_Incomplete_tsend Trial_Incomplete_Path_Whole    
    end
    
    clear sig words fp fptimes analog_time_base y t ts numbins PB cells x...
        ts b xOnline bdf Yrecon tsFPorder Numtrials
    
    clear tfmat_gamma tfmat_gamma2 tfmat_theta AmpMat_gamma AmpMat_gamma2...
        PhaseMat_theta tfmat_theta_RandPhase PhaseMat_theta_RandPhase
    %Trial_FPend Trial_tsend TrialPath TrialInput Trial_Fail_FPbegin ...
    %Trial_Fail_tsbegin Trial_Fail_FPend Trial_Fail_tsend
end

beep


