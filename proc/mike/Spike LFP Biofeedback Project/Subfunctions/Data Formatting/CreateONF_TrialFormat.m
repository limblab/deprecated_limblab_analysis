% Create ONF Trial Format

clear FileNotRun
%% Find file path, load file and start iterating through files
for q =  [BC_I(1):BC_I(end)] % HC_I(1):HC_I(end)  BC_1DG(1):BC_1DG(end) BC_1DSp(1):BC_1DSp(end)]
    
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

    clear y numbins
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
        clear b cells i ts
    end

    %% Calculate trial stats
    FirstTrialInds=find(bdf.words(:,2)==17);
    Num.Trials_File(q) = length(FirstTrialInds);

    AbortTrialInds=find(bdf.words(:,2)==33);
    Num.Abort_File(q) = length(AbortTrialInds);
    
    SuccessTrialInds=find(bdf.words(:,2)==32);
    TenMinInts = length(bdf.vel)/12000;
    Num.Success_File(q) = length(SuccessTrialInds)/TenMinInts;
        
    Num.PercentSuccess_File(q) = (Num.Success_File(q)/(Num.Trials_File(q)-Num.Abort_File(q)))*100*TenMinInts;
%     clear FirstTrialInds AbortTrialInds SuccessTrialInds
%     continue
    data(q).fptimes = fptimes;
    data(q).FPs = fp;
    data(q).SpikeTimes = tsFPorder;
    
    % Robert's fpassign puts NaNs in the matrix and this throws everything
    % off, remove them here.
    fp(isnan(fp)==1)= 0;
    [b,a]=butter(2,[58 62]/(samprate/2),'stop');
    fpf=filtfilt(b,a,fp')';
    
    if AdjustCorr == 1
        [PB, ~, ~, ~, y, t] = MRScalcFeatMat(sig, 'vel', numfp, ...
            binsize, folds, numlags,numsides,samplerate, fp,fptimes, ...
            analog_time_base,fnam,256,[],[],[],[],bdf.words);
        
        clear analog_time_base sig
    end
    
    for i = 1:length(bandstarts)                
        [b,a]=butter(2,[bandstarts(i) bandends(i)]/(samprate/2));
        TrialBP= filtfilt(b,a,fp');
        BP_Vec = smooth(abs(hilbert(TrialBP)).^2,21,'moving');
        Phase_Vec = angle((hilbert(TrialBP)));
        try
            BP(:,:,i) = reshape(BP_Vec,size(TrialBP,1),size(TrialBP,2));
            BPh(:,:,i) = reshape(Phase_Vec,size(TrialBP,1),size(TrialBP,2));            
        catch
            clear BP
            BP(:,:,i) = reshape(BP_Vec,size(TrialBP,1),size(TrialBP,2));
            BPh(:,:,i) = reshape(Phase_Vec,size(TrialBP,1),size(TrialBP,2));
            
        end
    end
    
    
%     AllGam3 = squeeze(BP(:,:,3));
%     [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
%         CorrCoeffMap(AllGam3,1,1:96)
%     
%     subplot(7,4,q)
%     imagesc(rOnline.map)

    clear a b BP_Vec PhaseVec TrialBP
 %%    
        
    for  k = in(ControlCh,[1 96]) % 1:size(fp,1) %
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
                if PhasorOn == 0
                    Trials{k,q} = parseTrials(bdf,BP(:,k,:),FPstartTime,SpikeTimes);
                    Trials{k,q}.Targets = bdf.targets;
                else
                    Trials{k,q} = parseTrials(bdf,BPh(:,k,:),FPstartTime,SpikeTimes);
                    TrialsRawFP{k,q} = parseTrials(bdf,fpf(k,:)',FPstartTime,SpikeTimes);                   
                end
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
        
        if AdjustCorr == 1
            if flag_SpHG == 1
            % Binned spike counts (50 ms bins)
            SpikeCounts = train2bins(SpikeTimes,t);
            % Binned spike counts on fp timescale (1 ms)
            SpikeTrain = train2bins(SpikeTimes,fptimes);
            KernelSize = 20;
            SpikeRate = train2cont(SpikeTrain,KernelSize);
            end
            if isempty(IncCorr) == 0
                for Inc = 1:length(IncCorr)
                    PB_temp = PB;
                    if flag_LGHG == 1
                        
                        PB_temp(7,k,:) = squeeze( PB(7,k,:)- IncCorr(Inc) *PB(7,k,:) ) + IncCorr(Inc) * PB(5,k,:);
                        PB_temp = squeeze(PB_temp([7 5],k,:))';
                        
                        BP_temp = BP;
                        BP_temp(:,k,1) = ( BP(:,k,1)- IncCorr(Inc)*BP(:,k,1) ) + (IncCorr(Inc) * BP(:,k,2))';
                    elseif flag_SpHG == 1
%                         R_PB6 = range(PB(6,k,:));
%                         R_Sp = range(SpikeRate);
%                         ScaleF = R_PB6/R_Sp;
                        PB_temp(6,k,:) = squeeze( PB(6,k,:)- IncCorr(Inc) *PB(6,k,:) ) + (IncCorr(Inc) * (SpikeCounts))';
                        PB_temp = [squeeze(PB_temp(6,k,:)) SpikeCounts'];
                        
                        BP_temp = BP;
                        BP_temp(:,k,3) = ( BP(:,k,3)- (IncCorr(Inc)*BP(:,k,3)) ) + (IncCorr(Inc) * SpikeRate)';
                    end
                   
                    [ypred,x,ytnew] = predMIMO3(PB_temp,H_temp,numsides,1,y);
                    % Cutoff first four points because predMIMO throws out
                    % first 4 points when filters length == 10
                    if length(t) > size(ypred,1)
                        Lt = length(t);
                        Lyp = size(ypred,1);
                        t = t(Lt-Lyp+1:end);
                    end

                    % Online, there is a 60 second low pass filter to keep
                    % the mean position around zero, also add the offset
                    % the file started with (y(1,1))
                    NewVelX = y(1,1) + ypred(:,1)- smooth(ypred(:,1),1200);  
%                     scalef = mean(abs(y(:,1)))/mean(abs(NewVelX));
%                     if scalef > 1
%                     NewVelX = scalef * NewVelX;
%                     end
                    NewPosX = cumsum(NewVelX * diff(bdf.pos([1 2],1)));   
                    NewPosX = NewPosX - smooth(NewPosX,1200);
                    
                    % Online, there is a 60 second low pass filter to keep
                    % the mean velocity around zero, also add the offset
                    % that the file started with
                    NewVelY = y(1,2) + ypred(:,2); %- smooth(ypred(:,2),1200);                                        
%                     scalef = mean(abs(y(:,2)))/mean(abs(NewVelY));
%                     if scalef > 1
%                         NewVelY = scalef * NewVelY;
%                     end
                    NewPosY = cumsum(NewVelY * diff(bdf.pos([1 2],1)));
                    NewPosY = NewPosY - smooth(NewPosY,1200);
                    
                    CorrAdj_bdf{Inc,ACFInd}.vel = [t' NewVelX NewVelY];
                    CorrAdj_bdf{Inc,ACFInd}.pos = [t' NewPosX NewPosY];
                    CorrAdj_bdf{Inc,ACFInd}.words = bdf.words;
                    CorrAdj_bdf{Inc,ACFInd}.targets = bdf.targets;
                    CorrAdj_bdf{Inc,ACFInd}.meta = bdf.meta;
                    CorrAdj_bdf{Inc,ACFInd}.databursts = bdf.databursts;
                    CorrAdj_bdf{Inc,ACFInd}.CorrID = (sprintf('%d%s',IncCorr*100,'%_IncCorr'));                     
                    
                    Trials{Inc,ACFInd} = parseTrials(bdf,BP_temp(:,k,:),FPstartTime,SpikeTimes);
                    Trials{Inc,ACFInd}.Targets = bdf.targets;
                    clear PB_temp BP_temp x ytnew NewPosX NewPosY NewVelX NewVelY
                end
            end
            startInd = length(IncCorr);
            if isempty(DecCorr) == 0    
                for Dec = 1:length(DecCorr)
                    PB_temp = PB;
                    if flag_LGHG == 1
                        
                        PB_temp(7,k,:) = squeeze( PB(7,k,1)- DecCorr(Dec) * PB(7,k,:) ) + DecCorr(Dec) * range(PB(7,k,:)) * randn([length(PB(7,k,:)) 1]);
                        PB_temp = squeeze(PB_temp([7 5],k,:))';    
                        
                        BP_temp = BP;
                        BP_temp(:,k,1) = (BP(:,k,1)- DecCorr(Dec) * BP(:,k,1)) + DecCorr(Dec) * range(BP(:,k,1)) * randn([length(BP(:,k,1)) 1]);
                    elseif flag_SpHG == 1                        
                        PB_temp(6,k,:) = squeeze( PB(6,k,1)- DecCorr(Dec) * PB(6,k,:) ) + DecCorr(Dec) * range(PB(6,k,:)) * randn([length(PB(6,k,:)) 1]);
                        PB_temp = [squeeze(PB_temp(6,k,:)) SpikeCounts'];
                        
                        BP_temp = BP;
                        BP_temp(:,k,3) = (BP(:,k,3)- DecCorr(Dec) * BP(:,k,3))  + DecCorr(Dec) * range(BP(:,k,3)) * randn([length(BP(:,k,3)) 1]);
                    end
                                   
                    [ypred,x,ytnew] = predMIMO3(PB_temp,H_temp,numsides,1,y);
                    
                    NewVelX = y(1,1) + ypred(:,1) - smooth(ypred(:,1),1200);                         
                    NewPosX = cumsum(NewVelX * diff(bdf.pos([1 2],1)));
                    NewPosX = NewPosX - smooth(NewPosX,1200);
                    
                    NewVelY = y(1,2) + ypred(:,2) - smooth(ypred(:,2),1200); 
                    NewPosY = cumsum(NewVelY * diff(bdf.pos([1 2],1)));
                    NewPosY = NewPosY - smooth(NewPosY,1200);
                    
                    CorrAdj_bdf{startInd+ Dec,ACFInd}.pos = [t' NewPosX NewPosY];
                    CorrAdj_bdf{startInd+ Dec,ACFInd}.words = bdf.words;
                    CorrAdj_bdf{startInd+ Dec,ACFInd}.targets = bdf.targets;
                    CorrAdj_bdf{startInd+ Dec,ACFInd}.meta = bdf.meta;
                    CorrAdj_bdf{startInd+ Dec,ACFInd}.databursts = bdf.databursts;
                    CorrAdj_bdf{startInd+ Dec,ACFInd}.CorrID = (sprintf('%d%s',DecCorr*100,'%_DecCorr'));
                                        
                    Trials{startInd+ Dec,ACFInd} = parseTrials(bdf,BP_temp(:,k,:),FPstartTime,SpikeTimes);
                    Trials{startInd+ Dec,ACFInd}.Targets = bdf.targets;
                    clear PB_temp x ytnew NewPosX NewPosY
                end            
            end
            ACFInd = ACFInd + 1;
            clear startInd PB
        end
    end
    
    if exist('bdf','var')
        if length(ControlCh) < 2
        [sig, samplerate, ~, ~,~,~,~,~,~, analog_time_base] = SetPredictionsInputVar(bdf);
        words = bdf.words;
        
        [PB, ~, ~, ~, ~, ~] = MRScalcFeatMat(sig, 'vel', numfp, ...
            binsize, folds, numlags,numsides,samplerate, fp,fptimes, ...
            analog_time_base,fnam,256,[],[],[],[],words);
        
        Trials{ControlCh,q}.RangePB_G3 = mean(range(PB(6,ControlCh,:)));
        Trials{ControlCh,q}.RangePB_G2 = mean(range(PB(5,ControlCh,:)));
        Trials{ControlCh,q}.RangePB_G0 = mean(range(PB(7,ControlCh,:)));
        Trials{ControlCh,q}.RangeSp = mean(range(train2bins(tsFPorder{q,ControlCh},t)));
        clear PB BP analog_time_base sig words
        end
    end
    clear k
    
    clear fp fptimes tsFPorder BP i samprate smplerate

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