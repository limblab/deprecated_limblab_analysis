% Create ONF Trial Format

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
ind = 1;

numlags  = 10; % Number of lags used online
Offlinelags = 1; % Number of lags to use offline
numsides = 1;
lambda   = 1;
binsamprate = floor(1/binsize);
numfp = 96;
folds = 10;

% FileList = Mini_U41_SpikeX_Ch73_Gam3Y; 
bandstarts = [30, 130, 200];
bandends   = [50, 200, 300];

% HC_I = [1:22];
% BC_1DG = [23:25];
% BC_1DSp = [26:28];
% BC_I = [35:38];

%  LFPInds{1} = [73 6];% X control 
% % LFPInds{1} = [17 6];% Y control
% SpikeInds{1} = [42 1];
% ControlCh = 73;

% Use these vars if you want to split up files in to segments
segment = 1;
whole = 1;
WinLen = 300; % in seconds
overlap = 60; % in sec
segInd = 1;

clear FileNotRun
%% Find file path, load file and start iterating through files
for q = [BC_I(1):BC_I(end)]%] HC_I(1):HC_I(end)  BC_1DG(1):BC_1DG(end) BC_1DSp(1):BC_1DSp(end) 
    
    if exist('fnam','var') == 0         
            fnam{q} =  findBDFonCitadel(FileList{q,1})
    elseif length(fnam) >= q
        if isempty(fnam{q}) == 1
            fnam{q} =  findBDFonCitadel(FileList{q,1})  
        elseif length(fnam{q}) < 4
            fnam{q} =  findBDFonCitadel(FileList{q,1}) 
        end
    else
        fnam{q} =  findBDFonCitadel(FileList{q,1}) 
    end
    
    if length(fnam{q}) < 4
        FilesNotRun{q,2} = 'File Not Found';
        FilesNotRun{q,1} = fnam
        continue
    end
    
    try
        load(fnam{q})
    catch exception
        FilesNotRun{q,2} = exception;
        FilesNotRun{q,1} = fnam
        continue
    end
    if exist('out_struct','var') == 0
        continue
    end
    %% Declare input variables within loop that vary in each loop iteration:
    [sig, ~, ~, ~,~,~,~,~,~, analog_time_base] = SetPredictionsInputVar(out_struct);
 
    fpAssignScript2
    bdf = out_struct;
    Trials{1,q}.Targets = bdf.targets;
    clear out_struct fpchans
    
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
    
    data(q).fptimes = fptimes;
    data(q).FPs = fp;
    data(q).SpikeTimes = tsFPorder;
    
    % Robert's fpassign puts NaNs in the matrix and this throws everything
    % off, remove them here.
    fp(isnan(fp)==1)= 0;
    
    for i = 1:length(bandstarts)
        [b,a]=butter(2,[bandstarts(i) bandends(i)]/(samprate/2));
        TrialBP= filtfilt(b,a,fp');
        BP_Vec = smooth(abs(hilbert(TrialBP)).^2,21,'moving');
        try
            BP(:,:,i) = reshape(BP_Vec,size(TrialBP,1),size(TrialBP,2));
        catch
            clear BP
            BP(:,:,i) = reshape(BP_Vec,size(TrialBP,1),size(TrialBP,2));
        end
    end
    
%     AllGam3 = squeeze(BP(:,:,3));
%     [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
%         CorrCoeffMap(AllGam3,1,1:96)
%     
%     subplot(7,4,q)
%     imagesc(rOnline.map)

    clear a b BP_Vec TrialBP
 %%    
        
    for  k = ControlCh % 1:size(fp,1) %
        FPstartTime = fptimes(1);
        SpikeTimes = tsFPorder{q,k};
        tic
        if segment == 1 
            
            segments =  (size(BP,1) - (WinLen *1000))/(overlap * 1000) + 1;
            for f = 1:segments
                % Check if BC or HC
                if diff(bdf.pos([1 2],1)) < 0.01
                    kin_ind = (f-1) * (overlap*1000)+1: (f-1)*(overlap*1000) + (WinLen*1000);
                else
                    kin_ind = (f-1) * (overlap*20)+1: (f-1)*(overlap*20) + (WinLen*20);
                end
                
                fp_ind = (f-1) * (overlap*1000)+1: (f-1) * (overlap*1000) + (WinLen*1000);
                
                if kin_ind(end) < length(bdf.pos)
                    segments.meta = bdf.meta;
                    segments.pos = bdf.pos(kin_ind,:);
                    segments.vel = bdf.vel(kin_ind,:);
                    segments.words = bdf.words(bdf.words(:,1) > segments.pos(1,1) & bdf.words(:,1) < segments.pos(end,1),:);
                    
                    BP_seg = BP(fp_ind,:,:);
                    SpikeTimes_seg = SpikeTimes(SpikeTimes > segments.pos(1,1) & SpikeTimes < segments.pos(end,1));
                    
                    % Reset all times to 1 so that the indices work out
                    segments.pos(:,1) = segments.pos(:,1) - (bdf.pos(kin_ind(1),1)-1);
                    segments.vel(:,1) = segments.vel(:,1) - (bdf.vel(kin_ind(1),1)-1);
                    segments.words(:,1) = segments.words(:,1) - (bdf.vel(kin_ind(1),1)-1);
                    SpikeTimes_seg = SpikeTimes_seg - (bdf.pos(kin_ind(1),1)-1);
                    
                    Trials_seg{k,segInd} = parseTrials(segments,BP_seg(:,k,:),FPstartTime,SpikeTimes_seg);
                    Trials_seg{k,segInd}.Targets = bdf.targets;
                    Trials_seg{k,segInd}.meta = bdf.meta;
                    segInd = segInd + 1;
                    clear segments BP_seg SpikeTimes_seg kin_ind fp_ind
                else
                    continue
                end
            end
        end    
        
        if whole == 1 
            try
                Trials{k,q} = parseTrials(bdf,BP(:,k,:),FPstartTime,SpikeTimes);
                Trials{k,q}.Targets = bdf.targets;
                %         [TrialsRawFP{k,q}] = parseTrials(bdf,fp(k,:)',FPstartTime,SpikedataToParse);
            catch exception
                FilesNotRun{q,2} = exception;
                FilesNotRun{q,1} = fnam
                clear fp bdf BP i samprate
                clear FPdataToParse SpikeTimes segments BP_seg SpikeTimes_seg
                continue
            end
            
            toc
            clear FPdataToParse segments BP_seg SpikeTimes_seg
        end
    end
    if exist('bdf','var')
        [sig, samplerate, ~, ~,~,~,~,~,~, analog_time_base] = SetPredictionsInputVar(bdf);
        words = bdf.words;
        
        [PB, ~, ~, ~, y{q}, t] = MRScalcFeatMat(sig, 'vel', numfp, ...
            binsize, folds, numlags,numsides,samplerate, fp,fptimes, ...
            analog_time_base,fnam,256,[],[],[],[],words);
        
        Trials{ControlCh,q}.RangePB_G3 = mean(range(PB(6,ControlCh,:)));
        Trials{ControlCh,q}.RangePB_G2 = mean(range(PB(5,ControlCh,:)));
        Trials{ControlCh,q}.RangePB_G0 = mean(range(PB(7,ControlCh,:)));
        Trials{ControlCh,q}.RangeSp = mean(range(train2bins(tsFPorder{q,ControlCh},t)));
        clear PB analog_time_base sig words
    end
    clear k
    
    clear fp fptimes bdf tsFPorder BP i samprate smplerate

end
beep

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
    %
    %     rInputAvg(q) = cellfun(@mean,rtrialInput)
    %     rSignalAvg(q) = cellfun(@mean,rtrialSig)
    
    %     figure(q)
    %     plot(rtrialSig{q})
    %
    %     figure(q+5)
    %     plot(rtrialInput{q})