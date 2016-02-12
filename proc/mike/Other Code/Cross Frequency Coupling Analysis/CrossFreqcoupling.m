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
fi =1;
numfp = 96;

FileList = Mihili_TG_PAC_CO_VR;

% HC_I = [1:22];
% BC_1DG = [23:25];
% BC_1DSp = [26:28];
% BC_I = [33:52];

%  LFPInds{1} = [73 6];% X control 
% % LFPInds{1} = [17 6];% Y control
% SpikeInds{1} = [42 1];
% ControlCh = 66;
% segment = 1;
% segInd = 1;

clear FileNotRun
%% Find file path, load file and start iterating through files
for q = 1:length(FileList) %[BC_I(1):BC_I(end)]%] HC_I(1):HC_I(end)  BC_1DG(1):BC_1DG(end) BC_1DSp(1):BC_1DSp(end)
    %
    %     if exist('fnam','var') == 0
    %             fnam{q} =  findBDFonCitadel(FileList{q,1})
    %     elseif length(fnam) >= q
    %         if isempty(fnam{q}) == 1
    %             fnam{q} =  findBDFonCitadel(FileList{q,1})
    %         end
    %     else
    fnam{q} =  FileList{q,1}
    %     end
    %
    %     if length(fnam{q}) < 4
    %         FilesNotRun{q,2} = 'File Not Found';
    %         FilesNotRun{q,1} = fnam
    %         continue
    %     end
    %
    %     try
    load(fnam{q})
    %     catch exception
    %         FilesNotRun{q,2} = exception;
    %         FilesNotRun{q,1} = fnam
    %         continue
    %     end
    %     if exist('out_struct','var') == 0
    %         continue
    %     end
    %% Declare input variables within loop that vary in each loop iteration:
    [sig, ~, ~, ~,~,~,~,~,~, analog_time_base] = SetPredictionsInputVar(out_struct);
 
    fpAssignScript2
    bdf = out_struct;
    Trials{1,q}.Targets = bdf.targets;
    clear fpchans
    
    [y, ~, t, numbins] = fpadjust(binsize, samplerate, fptimes, wsz, sig, fp, analog_time_base);

    clear y numbins sig analog_time_base
    tsFPorder = cell([q 96]);
    %% Bin and organize spikes
    if 1
        cells = unit_list(bdf);
        x = zeros(size(t,2),size(cells,1));
        for i = 1:length(cells)
            if cells(i,1) ~= 0
                ts{i} = get_unit(bdf, cells(i, 1), cells(i, 2));
                %             b = train2bins(ts{i},t);
                if cells(i,1) < 65
                    %                 x(:,cells(i,1)+32) = b;
                    tsFPorder{q,cells(i,1)+32} = ts{i};
                else
                    %                 x(:,cells(i,1)-64) = b;
                    tsFPorder{q,cells(i,1)-64} = ts{i};
                end
            else
                %             x(:,i) = zeros(length(y),1);
            end
        end
        clear b cells i ts t
    end

    
    %% Calculate trial stats
    FirstTrialInds=find(bdf.words(:,2)==17);
    Num.Trials_File(q) = length(FirstTrialInds);
    
    AbortTrialInds=find(bdf.words(:,2)==33);
    Num.Abort_File(q) = length(AbortTrialInds);
    
    SuccessTrialInds=find(bdf.words(:,2)==32);
    Num.Success_File(q) = length(SuccessTrialInds);
    
    Num.PercentSuccess_File(q) = (Num.Success_File(q)/Num.Trials_File(q))*100;
    clear FirstTrialInds AbortTrialInds SuccessTrialInds
    
    
    data1 = fp';
    data2 = tsFPorder{:};
    
    figure
    plot(fp(:,1:1000:end)')
    
    if 1
        %% Calculate theta-gamma PAC
        numfp = size(data1,2);
        filelength = size(data1,1);
            
        foldLengths = [30];
%         foldLengthslist = [5:5:200];
        foldnums = unique(floor(filelength./(foldLengths*1000)));
%         foldnumslist = unique(floor(filelength./(foldLengthslist*1000)));
        ifoldnum = 1;
        for numfolds = in(foldnums,[1 foldnums(end)])                        
            
            numfolds
            foldlength = floor(filelength/numfolds);
            samprate = 1000;
            
            [b0,a0]=butter(2,[58 62]/(samprate/2),'stop');
            %         tfmat=zeros(1,numfp,size(fpf,1),'single'); %numfp
            
            for fold = 1:numfolds
                
                data1Fold = data1((fold-1)*foldlength+1:(fold)*foldlength,:);
                fpf=filtfilt(b0,a0,data1Fold);
                
                %Band Pass Filter Theta and hilbert transform
                [b_theta,a_theta]=butter(2,[4 8]/(samprate/2));
                tfmat_theta=reshape(hilbert(filtfilt(b_theta,a_theta,fpf)),numfp,size(fpf,1));
                
                %Band Pass Filter Gamma 1 (30-100 Hz) and hilbert transform
                [b_gamma,a_gamma]=butter(2,[30 80]/(samprate/2));
                tfmat_gamma=reshape(hilbert(filtfilt(b_gamma,a_gamma,fpf)),numfp,size(fpf,1));
                
                %Band Pass Filter Gamma 2 (80-150 Hz) and hilbert transform
                [b_gamma2,a_gamma2]=butter(2,[80 150]/(samprate/2));
                tfmat_gamma2=reshape(hilbert(filtfilt(b_gamma2,a_gamma2,fpf)),numfp,size(fpf,1));
                
                %Calculate Phase for Theta and Amp for Gammas
                PhaseMat_theta{fold} = angle(tfmat_theta);
                AmpMat_gamma{fold} = real(tfmat_gamma);
                AmpMat_gamma2{fold} = real(tfmat_gamma2);
%                 
%                 [p_i_ThetaGamma{fold,q}] = binAmpByPhase(PhaseMat_theta{fold},AmpMat_gamma{fold});
%                 [p_i_ThetaGamma2{fold,q}] = binAmpByPhase(PhaseMat_theta{fold},AmpMat_gamma2{fold});
                                
                % **TO-DO**
                % Shuffle folds to make surrogate MI values more like Tort
                % methods.
                
                % Randomize Theta Phase and Bin Gamma Amplitude
                %                 fpf_theta = filtfilt(b_theta,a_theta,fpf);%Bandpass filter theta
                %             u1=pharand(fpf_theta); %Randomize theta phase
                %                 tfmat_theta_RandPhase(1,:,:)=reshape(hilbert(u1),1,numfp,size(fpf,1));% Hilbert transform BPed theta
                %                 PhaseMat_theta_RandPhase = angle(tfmat_theta); %Get phase angle
                %                 for shift = 1:1000
                
                
                % To-Do add other variables to be cleared
                clear fpf data1Fold tfmat_theta tfmat_gamma...
                    tfmat_gamma2 u1 tfmat_theta_RandPhase PhaseMat_theta_RandPhase...
                    
                
            end
            for fold = 1:numfolds
                numRep = round(200/numfolds);
%                 shifti = 1;
                shiftFold = randi(numfolds,numRep,1);
                for iShift = 1:numRep
%                     PhaseMat_theta_RandPhase = circshift(PhaseMat_theta,iShift,2);
                    [p_i_ThetaGamma_RandPhase{fold,q,iShift}] = binAmpByPhase(PhaseMat_theta{shiftFold(iShift)},AmpMat_gamma{fold});
                    [p_i_ThetaGamma2_RandPhase{fold,q,iShift}] = binAmpByPhase(PhaseMat_theta{shiftFold(iShift)},AmpMat_gamma2{fold});
%                     shifti = shifti + 1;
                end
%                 fi = fi+1;
%                 ifoldnum = ifoldnum + 1;
%                 fi = 1;
                clear a0 b0
            end
            clear PhaseMat_theta AmpMat_gamma AmpMat_gamma2
        end
        
    end
    if 0
        
        %% Calculate spike-field coherence

        try
            [Trials{q}, TargetID{q}] = parseTrials(bdf,data1,data2);
        catch
            FilesThatDidNotRun{q} =   FileList{q,:};
            continue
        end
        
        data1_randphase=pharand(data1);        
        [Trials_rand{q},~] = parseTrials(bdf,data1_randphase,data2);
        
        Trial_FPendMAT = cell2mat(Trials{q}.FPend);
        
        if isfield(Trials{q},'Fail_FPend') == 1
        Trial_Fail_FPendMAT = cell2mat(Trials{q}.Fail_FPend);
        elseif isfield(Trials{q},'Incomplete_FPend') == 1
        Trial_Incomplete_FPendMAT = cell2mat(Trials{q}.Incomplete_FPend);
        end
        
        Trial_FPend_randMAT = cell2mat(Trials_rand{q}.FPend);
        
        binsizes = 0.10;
        %         for g = 1:length(binsizes)
        
        win = [binsizes .05];
        paramsFP.tapers = [5 9];
        paramsFP.Fs = 1000;
        paramsFP.fpass = [0 300];
        paramsFP.pad = 1;
        paramsFP.err = [1 0.05];
        paramsFP.trialave = 1;
        segave = 0;
        fscorr = 1;
        t = 1-binsizes:.001:1 ;

        [Trials{q}.Cohgram,~,~,~,~,~,Trials{q}.fC,~,Trials{q}.confC_cohgram,~]=cohgramcpt(Trial_FPendMAT,Trials{q}.tsend,win,paramsFP);
               
        [Trials{q}.Coherency,~,~,~,~,Trials{q}.f,~,Trials{q}.confC_coherency,~]=coherencycpt(Trial_FPendMAT(end-1000*binsizes:end,:),Trials{q}.tsend,paramsFP,fscorr,t);
        clear Trial_FPendMAT

        if exist('Trial_Fail_FPendMAT','var') == 1
%             [Trials{q}.C_Fail_end,~,~,~,~,~,~,~]=cohgramcpt(Trial_Fail_FPendMAT,Trial_Fail_tsend,win,paramsFP);
            [Trials{q}.Fail_Coherency,~,~,~,~,~,~,Trials{q}.confC_Fail,~]=...
                coherencycpt(Trial_Fail_FPendMAT(end-1000*binsizes:end,:),Trials{q}.Fail_tsend,paramsFP,fscorr,t);
            clear Trial_Fail_FPendMAT
        end
        
        if exist('Trial_Incomplete_FPendMAT','var') == 1
%             [Trials{q}.C_Incomplete_end,~,~,~,~,~,~,~]=cohgramcpt(Trial_Incomplete_FPendMAT,Trial_Incomplete_tsend,win,paramsFP);
             [Trials{q}.Incomplete_Coherency,~,~,~,~,~,~,Trials{q}.confC_Incomplete,~]=...
                coherencycpt(Trial_Incomplete_FPendMAT(end-1000*binsizes:end,:),Trials{q}.Incomplete_tsend,paramsFP,fscorr,t);
            clear Trial_Incomplete_FPendMAT
        end
        
        [Trials{q}.Rand_Cohgram,~,~,~,~,~,~,~]= cohgramcpt(Trial_FPend_randMAT,Trials_rand{q}.tsend,win,paramsFP);
        
        [Trials{q}.Rand_Coherency,~,~,~,~,~,~,Trials{q}.Rand_confC_coherency,~]=...
                coherencycpt(Trial_FPend_randMAT(end-1000*binsizes:end,:),Trials_rand{q}.tsend,paramsFP,fscorr,t);
        clear Trial_FPend_randMAT paramsFP fscorr segave t        
        
    end
    
    clear sig words fp fptimes analog_time_base y t ts numbins PB cells x...
        ts b xOnline bdf Yrecon tsFPorder Numtrials
    
    clear tfmat_gamma tfmat_gamma2 tfmat_theta AmpMat_gamma AmpMat_gamma2...
        PhaseMat_theta tfmat_theta_RandPhase PhaseMat_theta_RandPhase
    %Trial_FPend Trial_tsend TrialPath TrialInput Trial_Fail_FPbegin ...
    %Trial_Fail_tsbegin Trial_Fail_FPend Trial_Fail_tsend
end

beep


