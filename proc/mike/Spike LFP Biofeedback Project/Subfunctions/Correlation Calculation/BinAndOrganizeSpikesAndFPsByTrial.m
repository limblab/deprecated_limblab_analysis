function [AvgCorr,Exceptions] = BinAndOrganizeSpikesAndFPsByTrial(Trials, ControlCh, ...
    HC_I, BC_I, BC_1DG, BC_1DSp, flag_SpHG, flag_LGHG, monkey_name, AdjustCorr, IncCorr, DecCorr, iters)

FP_Trial_timeIndex_start = [1750:2250];
FP_Trial_timeIndex_MV = [1750:2250];
samprate = 1000;
KernelSize = 20;

SlideCorr = 0;
SpikeWin = .5;
SpikeOv = .1;
SpikeStartTime = -0.1;
FPStartIndex = 2100; % Since FPs include 2 seconds after reward, 2000 needs to be subtracted to start at reward
WinOv_ms = 100; % in ms
CorrWindow = 500;
ErrI = 1;
TimeThres = 30; % This is a threshold for what trial lengths will be considered when calculating the correlation
% % Flags
flag_EvalRbyTarg = 0;
flag_HCcorr = 0;

for f = [BC_I(1):BC_I(end) HC_I(1):HC_I(end)]% BC_1DG(1):BC_1DG(end) BC_1DSp(1):BC_1DSp(end)]
    %This loop iterates over files
    % BC_1DG(1):BC_1DG(end) BC_1DSp(1):BC_1DSp(end)]
    for k = in(ControlCh,[1 96])
        if isfield(Trials{k,f},'FPend') == 1
            MaxTrialLength(1) = max(cellfun(@length,Trials{k,f}.FPend(:,1)));
        elseif isfield(Trials{k,f},'Incomplete_FPend') == 1
            MaxTrialLength(2) = max(cellfun(@length,Trials{k,f}.Incomplete_FPend(:,1)));
        elseif isfield(Trials{k,f},'Fail_FPend') == 1
            MaxTrialLength(3) = max(cellfun(@length,Trials{k,f}.Fail_FPend(:,1)));
        else
            continue
        end
        
        MaxTL = max(MaxTrialLength);
        if SlideCorr == 1
            NumWindows = floor((MaxTL)/WinOv_ms);
        else 
            NumWindows = 1;
        end
        fpByTrialEnd_64 = [];
        fpByTrialEnd_65 = [];
        SpikeRatesByTrialEnd_64 = [];
        SpikeRatesByTrialEnd_65 = [];
        i64 = 1;
        i65 = 1;
        for bin = 1:NumWindows%length(KernelSize) %This loop is for calculating corr across sliding window
            
            
            tstart = [-.25:.001:.25];
            tend = [(SpikeStartTime-SpikeWin)-(bin-1)*SpikeOv:.001:SpikeStartTime-(bin-1)*SpikeOv];
            FP_Trial_timeIndex_end = (bin-1)*WinOv_ms;
            
            %This loop iterates over channels
            % Inside it, each channel has spikes and fps binned and then
            % correlations calculated on trial averaged traces.
            TrialInd = 1;
            
            if isfield(Trials{k,f},'tsend') == 1
                
                for i = 1:length(Trials{k,f}.tsend) %This loop bins spikes and FPs over trials
                    % Bin spikes by trial
                    % Skip trials where the binning window goes past the
                    % length of the trial itself
                    if length(Trials{k,f}.FPend{i,1}) <= (FPStartIndex + FP_Trial_timeIndex_end + CorrWindow)
                        continue
                    end
                    if Trials{k,f}.TTT(i) > TimeThres
                        continue
                    end
                    try
                        SpikeCountsTempStart = train2bins(Trials{k,f}.tsstart(1,i).times,tstart);
                        %                         SpikeCountsTempMaxV = train2bins(Trials{k,f}.tsMaxV(1,i).times,tstart);
                        SpikeCountsTempEnd = train2bins(Trials{k,f}.tsend(1,i).times,tend);
                        
                        SpikeRatesByTrialStart(TrialInd,:) = train2cont(SpikeCountsTempStart,KernelSize);
                        %                         SpikeRatesByTrialMaxV(i,:) = train2cont(SpikeCountsTempMaxV,KernelSize);
                        SpikeRatesByTrialEnd(TrialInd,:) = train2cont(SpikeCountsTempEnd,KernelSize);
                        
                        if Trials{k,f}.TargetID(i) == 64
                            SpikeRatesByTrialEnd_64(i64,:) = SpikeRatesByTrialEnd(TrialInd,:);
                        elseif Trials{k,f}.TargetID(i) == 65
                            SpikeRatesByTrialEnd_65(i65,:) = SpikeRatesByTrialEnd(TrialInd,:);
                        end
                    catch
                        exception.Channel = k;
                        exception.File = f;
                        exception.Trial = i;
                        exception.bin = bin;
                        exception.type = 'Success';
                        Exceptions{ErrI} = exception;
                        ErrI = ErrI + 1;
                        continue
                    end
                    
                    % This loops over the 3 gamma bands that we're
                    % interested in
                    for C = 1:size(Trials{k,f}.FPstart,2)
                        if isempty(Trials{k,f}.FPstart{i,C}) == 0
                            fpByTrialStart(TrialInd,:,C) = Trials{k,f}.FPstart{i,C}(FP_Trial_timeIndex_start);
                            %                             fpByTrialMaxV(i,:,C) = Trials{k,f}.FPMaxV{i,C}(FP_Trial_timeIndex_MV);
                            fpByTrialEnd(TrialInd,:,C) = Trials{k,f}.FPend{i,C}(end-FPStartIndex-CorrWindow-FP_Trial_timeIndex_end:end-FPStartIndex-FP_Trial_timeIndex_end);
                            if Trials{k,f}.TargetID(i) == 64
                                fpByTrialEnd_64(i64,:,C) = [Trials{k,f}.FPend{i,C}(end-FPStartIndex-CorrWindow-FP_Trial_timeIndex_end:end-FPStartIndex-FP_Trial_timeIndex_end)];
                                if C == 3
                                    i64 = i64 + 1;
                                end
                            elseif Trials{k,f}.TargetID(i) == 65
                                fpByTrialEnd_65(i65,:,C) = [Trials{k,f}.FPend{i,C}(end-FPStartIndex-CorrWindow-FP_Trial_timeIndex_end:end-FPStartIndex-FP_Trial_timeIndex_end)];
                                if C == 3
                                    i65 = i65 + 1;
                                end
                            end
                            
                            %                             if C == 1
                            %                                 [b,a]=butter(2,[58 62]/(samprate/2),'stop');
                            %                                 fpf=filtfilt(b,a,fp')';
                            %                                 tfmatByTrialStart(i,:) = fft(TrialsRawFP{k,f}.FPstart{i,C}(FP_Trial_timeIndex_start));
                            %                                 tfmatByTrialMaxV(i,:) = fft(TrialsRawFP{k,f}.FPMaxV{i,C}(FP_Trial_timeIndex_MV));
                            % %                                 tfmatByTrialEnd(i,:) = fft(TrialsRawFP{k,f}.FPend{i,C}(FP_Trial_timeIndex_end));
                            % %
                            %                                 fpSpectByTrialStart(i,:) = log( tfmatByTrialStart(i,:).* conj(tfmatByTrialStart(i,:)));
                            %                                 fpSpectByTrialMaxV(i,:) = log( tfmatByTrialMaxV(i,:).* conj(tfmatByTrialMaxV(i,:)));
                            %                                 fpSpectByTrialEnd(i,:) = log( tfmatByTrialEnd(i,:).* conj(tfmatByTrialEnd(i,:)));
                            %                             end
                        else
                            continue
                        end
                        
                        
                    end
                    TrialInd = TrialInd + 1;
                end
            end
            i64 = 1;
            i65 = 1;
            clear SpikeCountsTempEnd SpikeCountsTempMaxV...
                SpikeCountsTempStart
            
            if exist('fpByTrialEnd','var')
                fpByTrialEnd_AllTrials = fpByTrialEnd;
                SpikeRatesByTrialEnd_AllTrials = SpikeRatesByTrialEnd;
                TrialInd = size(fpByTrialEnd,1) + 1;
                
            else
                fpByTrialEnd_AllTrials = [];
                SpikeRatesByTrialEnd_AllTrials = [];
                TrialInd = 1;
            end
            
            if isfield(Trials{k,f},'Incomplete_tsend')
                % For looping over all incomplete trials
                
                for i = 1:length(Trials{k,f}.Incomplete_tsend)
                    if length(Trials{k,f}.Incomplete_FPend{i,1}) <= (FPStartIndex + FP_Trial_timeIndex_end + CorrWindow)
                        continue
                    end
                    try
                        SpikeCountsTempEnd_Incomplete = train2bins(Trials{k,f}.Incomplete_tsend(1,i).times,tend);
                        SpikeRatesByTrialEnd_AllTrials(TrialInd,:) = train2cont(SpikeCountsTempEnd_Incomplete,KernelSize);
                    catch
                        exception.Channel = k;
                        exception.File = f;
                        exception.Trial = i;
                        exception.bin = bin;
                        exception.type = 'Incomplete';
                        Exceptions{ErrI} = exception;
                        ErrI = ErrI + 1;
                        continue
                    end
                    % For looping over the three gamma bands we're looking at
                    for C = 1:size(Trials{k,f}.Incomplete_FPend,2)
                        if isempty(Trials{k,f}.Incomplete_FPend{i,C}) == 0
                            fpByTrialEnd_AllTrials(TrialInd,:,C) = Trials{k,f}.Incomplete_FPend{i,C}(end-FPStartIndex-CorrWindow-FP_Trial_timeIndex_end:end-FPStartIndex-FP_Trial_timeIndex_end);
                            
                        else
                            continue
                        end
                    end
                    TrialInd = TrialInd + 1;
                end
            end
            
            TrialInd = size(fpByTrialEnd_AllTrials,1) + 1;
            
%             if isfield(Trials{k,f},'Fail_tsend')
%                 
%                 for i = 1:length(Trials{k,f}.Fail_tsend)
%                     
%                     if length(Trials{k,f}.Fail_FPend{i,1}) <= (FPStartIndex + FP_Trial_timeIndex_end + CorrWindow)
%                         continue
%                     end
%                     
%                     try
%                         SpikeCountsTempEnd_Fail = train2bins(Trials{k,f}.Fail_tsend(1,i).times,tend);
%                         SpikeRatesByTrialEnd_AllTrials(TrialInd,:) = train2cont(SpikeCountsTempEnd_Fail,KernelSize);
%                     catch
%                         exception.Channel = k;
%                         exception.File = f;
%                         exception.Trial = i;
%                         exception.bin = bin;
%                         exception.type = 'Fail';
%                         Exceptions{ErrI} = exception;
%                         ErrI = ErrI + 1;
%                         continue
%                     end
%                     for C = 1:size(Trials{k,f}.Fail_FPend,2)
%                         if isempty(Trials{k,f}.Fail_FPend{i,C}) == 0
%                             fpByTrialEnd_AllTrials(TrialInd,:,C) = Trials{k,f}.Fail_FPend{i,C}(end-FPStartIndex-CorrWindow-FP_Trial_timeIndex_end:end-FPStartIndex-FP_Trial_timeIndex_end);
%                         else
%                             continue
%                         end
%                     end
%                     TrialInd = TrialInd + 1;
%                 end
%             end
            
            if isempty(fpByTrialEnd_AllTrials) == 1 && exist('fpByTrialEnd','var') == 0
                continue
            end
            
            clear i Trial_GammaEnd Trial_GammaStart RhoValTrial PvalTrial...
                SpikeCountsTempEnd SpikeCountsTempStart SpikeCountsTempMaxV...
                C TrialInd SpikeCountsTempEnd_Fail SpikeCountsTempEnd_Incomplete
            
            if isfield('Trials','TargetID')
                TList = Trials{k,f}.TargetID;
                Targs = unique(Trials{k,f}.TargetID)
                Targs(Targs == 0 ) = []
            end
            
            if isfield('Trials','Incomplete_TargetID')
                TList = Trials{k,f}.Incomplete_TargetID;
                Targs = unique(Trials{k,f}.Incomplete_TargetID)
                Targs(Targs == 0 ) = []
            end
            
            if isfield('Trials','Fail_TargetID')
                TList = Trials{k,f}.Fail_TargetID;
                Targs = unique(Trials{k,f}.Fail_TargetID)
                Targs(Targs == 0 ) = []
            end
            
            l = 1;
            %                 for tid = Targs
            %                     MeanSpikeRateByTargStart = mean(SpikeRatesByTrialStart(tid == TList,:));
            %                     MeanFPByTargStart = squeeze(mean(fpByTrialStart(tid == TList,:,:)));
            %
            %                     AvgCorr.SpectByTarg_MO{f}{k,l} = fpSpectByTrialStart(tid == TList,:);
            %                     AvgCorr.SpectByTarg_MaxV{f}{k,l} = fpSpectByTrialMaxV(tid == TList,:);
            %                     AvgCorr.SpectByTarg_Rew{f}{k,l} = fpSpectByTrialEnd(tid == TList,:);
            %
            %                     STESpikeRateByTargStart = std(SpikeRatesByTrialStart)./size(SpikeRatesByTrialStart,1);
            %                     STEFPByTargStart = squeeze(std(fpByTrialStart))./size(fpByTrialStart,1);
            %
            %                     AvgCorr.FPTraceByTarg_MO{f}{k,l} = MeanFPByTargStart;
            %                     AvgCorr.SpTraceByTarg_MO{f}{k,l} = MeanSpikeRateByTargStart';
            %
            %                     AvgCorr.FPTraceByTarg_MO_STE{f}{k,l} = STEFPByTargStart;
            %                     AvgCorr.SpTraceByTarg_MO_STE{f}{k,l} = STESpikeRateByTargStart;
            %
            %                     [RhoVal Pval] = corr([MeanSpikeRateByTargStart' MeanFPByTargStart(:,3)],'type','Spearman');
            %                     AvgCorr.ByTargMO{l}{k,f}(bin) = RhoVal(1,2);
            %                     AvgP.ByTargMO{l}{k,f}(bin) = Pval(1,2);
            %
            %                     % Do this for period around maxiumum velocity
            % %                     MeanSpikeRateByTargMaxV = mean(SpikeRatesByTrialMaxV);
            % %                     MeanFPByTargMaxV = squeeze(mean(fpByTrialMaxV));
            % %                     AvgCorr.FPTraceMaxVByTarg{f}(:,k,:) = MeanFPByTargStart;
            % %                     AvgCorr.SpTraceMaxVByTarg{f}(:,k) = MeanSpikeRateByTargStart';
            % %                     [RhoVal Pval] = corr([MeanSpikeRateByTargMaxV' MeanFPByTargMaxV(:,3)],'type','Spearman');
            % %                     AvgCorr.MaximumVel{k,f}(bin) = RhoVal(1,2);
            % %                     AvgP.MaxiumumVel{k,f}(bin) = Pval(1,2);
            %
            %                     MeanSpikeRateByTargEnd = mean(SpikeRatesByTrialEnd(tid == TList,:));
            %                     MeanFPByTargEnd = squeeze(mean(fpByTrialEnd(tid == TList,:,:)));
            %                     AvgCorr.FPTraceByTarg_Rew{f}{k,l} = MeanFPByTargEnd;
            %                     AvgCorr.SpTraceByTarg_Rew{f}{k,l} = MeanSpikeRateByTargEnd';
            %                     [RhoVal Pval] = corr([MeanSpikeRateByTargEnd' MeanFPByTargEnd(:,3)],'type','Spearman');
            %                     AvgCorr.ByTargRew{l}{k,f}(bin) = RhoVal(1,2);
            %                     AvgP.ByTargRew{l}{k,f}(bin) = Pval(1,2);
            %
            % %                     [RhoVal Pval] = corr([MeanFPByTargEnd(:,1) MeanFPByTargEnd(:,2)],'type','Spearman');
            % %                     AvgCorr.LG_HG_PriorToReward{k,f}(bin) = RhoVal(1,2);
            % %                     AvgP.LG_HG_PriorToReward{k,f}(bin) = Pval(1,2);
            %
            %                     l = l + 1;
            %                     clear MeanSpikeRateByTarg* MeanFPByTarg*
            %
            %                 end
            
            clear Targs TList l
            %% Find correlation of trial averaged spike rate and gamma at go cue
            % FP power during 500 ms centered on movement onset
            
            % Average spike rates and gamma FP power over all trials
            if exist('SpikeRatesByTrialStart','var')
                if size(SpikeRatesByTrialStart,1) < 2
                    MeanSpikeRateByFileStart = SpikeRatesByTrialStart;
                    MeanFPByFileStart = reshape(fpByTrialStart,[501 3]);
                    STESpikeRateByFileStart = zeros(size(fpByTrialStart,2),1);
                    STEFPByFileStart = zeros(size(fpByTrialStart,2),1,3);
                else
                    MeanSpikeRateByFileStart = nanmean(SpikeRatesByTrialStart);
                    MeanFPByFileStart = squeeze(nanmean(fpByTrialStart));
                    STESpikeRateByFileStart = nanstd(SpikeRatesByTrialStart)./size(SpikeRatesByTrialStart,1);
                    STEFPByFileStart = squeeze(nanstd(fpByTrialStart))./size(fpByTrialStart,1);
                end
                AvgCorr.NumTrials{k,f}(bin) = size(SpikeRatesByTrialEnd_AllTrials,1);
                
                AvgCorr.FPTraceStart{f}(:,k,:) = MeanFPByFileStart;
                AvgCorr.SpTraceStart{f}(:,k) = MeanSpikeRateByFileStart';
                
                AvgCorr.FPTraceStartSTE{f}(:,k,:) = STEFPByFileStart;
                AvgCorr.SpTraceStartSTE{f}(:,k) = STESpikeRateByFileStart;
                
                [RhoVal Pval] = corr([MeanSpikeRateByFileStart' MeanFPByFileStart(:,3)],'type','Spearman');
                AvgCorr.MovementOnset{k,f}(bin) = RhoVal(1,2);
                
                AvgP.MovementOnset{k,f}(bin) = Pval(1,2);
                
                % Do this for period around maxiumum velocity
                %                 MeanSpikeRateByFileMaxV = mean(SpikeRatesByTrialMaxV);
                %                 MeanFPByFileMaxV = squeeze(mean(fpByTrialMaxV));
                %                 AvgCorr.FPTraceMaxV{f}(:,k,:) = MeanFPByFileStart;
                %                 AvgCorr.SpTraceMaxV{f}(:,k) = MeanSpikeRateByFileStart';
                %                 [RhoVal Pval] = corr([MeanSpikeRateByFileMaxV' MeanFPByFileMaxV(:,3)],'type','Spearman');
                %                 AvgCorr.MaximumVel{k,f}(bin) = RhoVal(1,2);
                %                 AvgP.MaxiumumVel{k,f}(bin) = Pval(1,2);
                
                % Now do Low-Gamma and High-Gamma around movement onset
                [RhoVal Pval] = corr([MeanFPByFileStart(:,1) MeanFPByFileStart(:,2)],'type','Spearman');
                AvgCorr.LG_HG_MovementOnset{k,f}(bin) = RhoVal(1,2);
                AvgP.LG_HG_MovementOnset{k,f}(bin) = Pval(1,2);
                
                clear SpikeRatesByTrialStart fpByTrialStart ...
                    MeanFPByFileStart MeanSpikeRateByFileStart...
                    STEFPByFileStart STESpikeRateByFileStart
            end
            %% Calculate correlations on period prior to reward with only successful trials
            if exist('SpikeRatesByTrialEnd','var')
                % Find correlation of trial averaged spike rate and gamma
                % FP power prior to reward
                if size(SpikeRatesByTrialEnd,1) < 2
                    MeanSpikeRateByFileEnd = SpikeRatesByTrialEnd;
                    MeanFPByFileEnd = reshape(fpByTrialEnd,[CorrWindow+1 3]);
                    STESpikeRateByFileEnd = zeros(size(fpByTrialEnd,2),1);
                    STEFPByFileEnd = zeros(size(fpByTrialEnd,2),1,3);
                else
                    MeanSpikeRateByFileEnd = nanmean(SpikeRatesByTrialEnd);
                    MeanFPByFileEnd = squeeze(nanmean(fpByTrialEnd));
                    STESpikeRateByFileEnd = nanstd(SpikeRatesByTrialEnd)./size(SpikeRatesByTrialEnd,1);
                    STEFPByFileEnd = squeeze(nanstd(fpByTrialEnd))./size(fpByTrialEnd,1);
                end
                
                AvgCorr.FPTraceEnd{f}(:,k,:) = MeanFPByFileEnd;
                AvgCorr.SpTraceEnd{f}(:,k,:) = MeanSpikeRateByFileEnd';
                
                AvgCorr.FPTraceEndSTE{f}(:,k,:) = STEFPByFileEnd;
                AvgCorr.SpTraceEndSTE{f}(:,k) = STESpikeRateByFileEnd;
                
                [RhoVal Pval] = corr([MeanSpikeRateByFileEnd' MeanFPByFileEnd(:,3)],'type','Spearman');
                AvgCorr.PriorToReward{k,f}(bin) = RhoVal(1,2);
                AvgP.PriorToReward{k,f}(bin) = Pval(1,2);
                
                [RhoVal Pval] = corr([MeanFPByFileEnd(:,1) MeanFPByFileEnd(:,2)],'type','Spearman');
                AvgCorr.LG_HG_PriorToReward{k,f}(bin) = RhoVal(1,2);
                AvgP.LG_HG_PriorToReward{k,f}(bin) = Pval(1,2);
                
                clear SpikeRatesByTrialEnd fpByTrialEnd ...
                    MeanFPByFileEnd MeanSpikeRateByFileEnd ...
                    STEFPByFileEnd STESpikeRateByFileEnd
            end
            %% Calculate correlation on period prior to reward with all trials included
            if exist('SpikeRatesByTrialEnd_AllTrials','var')
                if size(SpikeRatesByTrialEnd_AllTrials,1) < 2
                    MeanSpikeRateByFileEnd_AllTrials = SpikeRatesByTrialEnd_AllTrials;
                    MeanFPByFileEnd_AllTrials = reshape(fpByTrialEnd_AllTrials,[CorrWindow+1 3]);
                    STESpikeRateByFileEnd_AllTrials = zeros(size(fpByTrialEnd_AllTrials,2),1);
                    STEFPByFileEnd_AllTrials = zeros(size(fpByTrialEnd_AllTrials,2),1,3);
                else
                    MeanSpikeRateByFileEnd_AllTrials = nanmean(SpikeRatesByTrialEnd_AllTrials);
                    MeanFPByFileEnd_AllTrials = squeeze(nanmean(fpByTrialEnd_AllTrials));
                    STESpikeRateByFileEnd_AllTrials = nanstd(SpikeRatesByTrialEnd_AllTrials)./size(SpikeRatesByTrialEnd_AllTrials,1);
                    STEFPByFileEnd_AllTrials = squeeze(nanstd(fpByTrialEnd_AllTrials))./size(fpByTrialEnd_AllTrials,1);
                end
                
                AvgCorr.FPTraceEnd_AllTrials{f}(:,k,:) = MeanFPByFileEnd_AllTrials;
                AvgCorr.SpTraceEnd_AllTrials{f}(:,k,:) = MeanSpikeRateByFileEnd_AllTrials';
                
                AvgCorr.FPTraceEnd_AllTrialsSTE{f}(:,k,:) = STEFPByFileEnd_AllTrials;
                AvgCorr.SpTraceEnd_AllTrialsSTE{f}(:,k) = STESpikeRateByFileEnd_AllTrials;
                
                [RhoVal Pval] = corr([MeanSpikeRateByFileEnd_AllTrials' MeanFPByFileEnd_AllTrials(:,3)],'type','Spearman');
                AvgCorr.PriorToReward_AllTrials{k,f}(bin) = RhoVal(1,2);
                AvgP.PriorToReward_AllTrials{k,f}(bin) = Pval(1,2);
                
                [RhoVal Pval] = corr([MeanFPByFileEnd_AllTrials(:,1) MeanFPByFileEnd_AllTrials(:,2)],'type','Spearman');
                AvgCorr.LG_HG_PriorToReward_AllTrials{k,f}(bin) = RhoVal(1,2);
                AvgP.LG_HG_PriorToReward_AllTrials{k,f}(bin) = Pval(1,2);
                
                clear SpikeRatesByTrialEnd_AllTrials fpByTrialEnd_AllTrials...
                    MeanFPByFileEnd_AllTrials MeanSpikeRateByFileEnd_AllTrials...
                    STEFPByFileEnd_AllTrials STESpikeRateByFileEnd_AllTrials
            end
            %% Calculate correlation by target direction
            if exist('SpikeRatesByTrialEnd_64','var') && isempty(SpikeRatesByTrialEnd_64) == 0
                AvgCorr.NumTrials_64{k,f}(bin) = size(SpikeRatesByTrialEnd_64,1);
                if size(SpikeRatesByTrialEnd_64,1) < 2
                    MeanSpikeRateByFileEnd_64 = SpikeRatesByTrialEnd_64;
                    MeanFPByFileEnd_64 = reshape(fpByTrialEnd_64,[CorrWindow+1 3]);
                else
                    MeanSpikeRateByFileEnd_64 = nanmean(SpikeRatesByTrialEnd_64);
                    MeanFPByFileEnd_64 = squeeze(nanmean(fpByTrialEnd_64));
                end
                [RhoVal Pval] = corr([MeanSpikeRateByFileEnd_64' MeanFPByFileEnd_64(:,3)],'type','Spearman');
                AvgCorr.PriorToReward_64{k,f}(bin) = RhoVal(1,2);
                
                [RhoVal Pval] = corr([MeanFPByFileEnd_64(:,1) MeanFPByFileEnd_64(:,2)],'type','Spearman');
                AvgCorr.LG_HG_PriorToReward_64{k,f}(bin) = RhoVal(1,2);
                
                
                clear SpikeRatesByTrialEnd_64 fpByTrialEnd_64...
                    MeanFPByFileEnd_64 MeanSpikeRateByFileEnd_64
            end
            %% Calculate correlation to other target direction
            if exist('SpikeRatesByTrialEnd_65','var') && isempty(SpikeRatesByTrialEnd_65) == 0
                AvgCorr.NumTrials_65{k,f}(bin) = size(SpikeRatesByTrialEnd_65,1);
                if size(SpikeRatesByTrialEnd_65,1) < 2
                    MeanSpikeRateByFileEnd_65 = SpikeRatesByTrialEnd_65;
                    MeanFPByFileEnd_65 = reshape(fpByTrialEnd_65,[CorrWindow+1 3]);
                else
                    MeanSpikeRateByFileEnd_65 = nanmean(SpikeRatesByTrialEnd_65);
                    MeanFPByFileEnd_65 = squeeze(nanmean(fpByTrialEnd_65));
                end
                [RhoVal Pval] = corr([MeanSpikeRateByFileEnd_65' MeanFPByFileEnd_65(:,3)],'type','Spearman');
                AvgCorr.PriorToReward_65{k,f}(bin) = RhoVal(1,2);
                
                [RhoVal Pval] = corr([MeanFPByFileEnd_65(:,1) MeanFPByFileEnd_65(:,2)],'type','Spearman');
                AvgCorr.LG_HG_PriorToReward_65{k,f}(bin) = RhoVal(1,2);
                
                clear SpikeRatesByTrialEnd_65 fpByTrialEnd_65...
                    MeanFPByFileEnd_65 MeanSpikeRateByFileEnd_65
            end
            
            
            %% Ray Method
            % Spike-Gamma Prior To Reward
            %                 MeanSpikeRateByFileEnd_Ray = mean(SpikeRatesByTrialEnd,2);
            %                 MeanFPByFileEnd_Ray = squeeze(mean(fpByTrialEnd,2));
            %                 AvgCorr.FPTraceEnd_Ray{f}(:,k,:) = MeanFPByFileEnd_Ray;
            %                 AvgCorr.SpTraceEnd_Ray{f}(:,k,:) = MeanSpikeRateByFileEnd_Ray';
            %                 [RhoVal Pval] = corr([MeanSpikeRateByFileEnd_Ray MeanFPByFileEnd_Ray(:,3)],'type','Spearman');
            %                 AvgCorr.Ray_End{k,f}(bin) = RhoVal(1,2);
            %                 AvgP.Ray_End{k,f}(bin) = Pval(1,2);
            %
            %                 % Now Low-Gamma and High-Gamma Prior to Reward
            %                 [RhoVal Pval] = corr([MeanFPByFileEnd_Ray(:,1) MeanFPByFileEnd_Ray(:,2)],'type','Spearman');
            %                 AvgCorr.LG_HG_Ray_End{k,f}(bin) = RhoVal(1,2);
            %                 AvgP.LG_HG_Ray_End{k,f}(bin) = Pval(1,2);
            %
            %                 % Now Spike-High Gamma around Movement Onset
            %                 MeanSpikeRateByFileStart_Ray = mean(SpikeRatesByTrialStart,2);
            
            %                 MeanFPByFileStart_Ray = squeeze(mean(fpByTrialStart,2));
            %                 AvgCorr.FPTraceStart_Ray{f}(:,k,:) = MeanFPByFileStart_Ray;
            %                 AvgCorr.SpTraceStart_Ray{f}(:,k,:) = MeanSpikeRateByFileStart_Ray';
            %                 [RhoVal Pval] = corr([MeanSpikeRateByFileStart_Ray MeanFPByFileStart_Ray(:,3)],'type','Spearman');
            %                 AvgCorr.Ray_Start{k,f}(bin) = RhoVal(1,2);
            %                 AvgP.Ray_Start{k,f}(bin) = Pval(1,2);
            %
            %                 % Now Low-Gamma and High-Gamma around Movement Onset
            %                 [RhoVal Pval] = corr([MeanFPByFileStart_Ray(:,1) MeanFPByFileStart_Ray(:,2)],'type','Spearman');
            %                 AvgCorr.LG_HG_Ray_Start{k,f}(bin) = RhoVal(1,2);
            %                 AvgP.LG_HG_Ray_Start{k,f}(bin) = Pval(1,2);
            
            clear MeanSpikeRateByFileStart_Ray MeanSpikeRateByFile_Ray...
                MeanFPByFileStart_Ray MeanFPByFile_Ray RhoVal Pval...
                SpikeRatesByTrialEnd SpikeRatesByTrialStart fpByTrialEnd...
                fpByTrialStart
            %                 FileCAT_SpikeRate = reshape(SpikeRatesByTrial',size(SpikeRatesByTrial,1)*size(SpikeRatesByTrial,2),1);
            %                 FileCAT_FPs = reshape(fpByTrial',size(fpByTrial,1)*size(fpByTrial,2),1);
            
            %                 [RhoVal Pval] = corr([FileCAT_SpikeRate FileCAT_FPs],'type','Spearman');
            %                 AvgCorr_SpikeRate_FPPower_ByFileCAT(k,f) = RhoVal(1,2);
            %                 AvgP_SpikeRate_FPPower_ByFileCAT(k,f) = Pval(1,2);
            
            
            clear MeanSpikeRateByFile MeanFPByFile SpikeRatesByTrial fpByTrial...
                FileCAT_FPs FileCAT_SpikeRate
            
            f
            k
            clear SpikeRatesWholeFile fpWholeFile RhoVal Pval
        end
    end
end
clear f k bin FP_Trial_time binsize t a_gamma b_gamma RhoVal Pval

%% The remainder is plot code

if flag_EvalRbyTarg == 1
    
    for m = 1 : 4
        HC_MO_R_ByTargMean(m) = mean(AvgCorr.ByTargMO{m}(ControlCh,HC_I(1):HC_I(end)));
        HC_MO_R_ByTarg(:,m) = AvgCorr.ByTargMO{m}(ControlCh,HC_I(1):HC_I(end));
        HC_Rew_R_ByTargMean(m) = mean(AvgCorr.ByTargRew{m}(ControlCh,HC_I(1):HC_I(end)));
        HC_Rew_R_ByTarg(:,m) = AvgCorr.ByTargRew{m}(ControlCh,HC_I(1):HC_I(end));
        
    end
    figure
    boxplot([HC_MO_R_ByTarg' HC_Rew_R_ByTarg'])
    set(gca,'Xtick',[1,2],'XTicklabel',{'Movement Onset','Reward'})
    figure
    boxplot([HC_MO_R_ByTarg HC_Rew_R_ByTarg])
    set(gca,'Xtick',[1,2,3,4,5,6,7,8],'XTicklabel',{'MO Target 1','MO Target 2','MO Target 3','MO Target 4', 'Rew Target 1','Rew Target 2','Rew Target 3','Rew Target 4'})
    for m = 1 : 2
        BC_MO_R_ByTargMean(m) = mean(AvgCorr.ByTargMO{m}(ControlCh,BC_I(1):BC_I(end)));
        BC_MO_R_ByTarg(:,m) = AvgCorr.ByTargMO{m}(ControlCh,BC_I(1):BC_I(end));
        BC_Rew_R_ByTargMean(m) = mean(AvgCorr.ByTargRew{m}(ControlCh,BC_I(1):BC_I(end)));
        BC_Rew_R_ByTarg(:,m) = AvgCorr.ByTargRew{m}(ControlCh,BC_I(1):BC_I(end));
    end
    
    figure
    boxplot([BC_MO_R_ByTarg BC_Rew_R_ByTarg])
    set(gca,'Xtick',[1,2,3,4],'XTicklabel',{'MO Target 1','MO Target 2','Rew Target 1','Rew Target 2'})
end

if flag_HCcorr == 1
    
    HC_MO_LGHG_mat = AvgCorr.LG_HG_MovementOnset';
    HC_R_LGHG_mat = AvgCorr.LG_HG_PriorToReward';
    
    HC_MO_SpHG_mat = AvgCorr.MovementOnset';
    HC_R_SpHG_mat = AvgCorr.PriorToReward';
    
    figure
    subplot(2,1,1)
    boxplot(HC_MO_LGHG_mat)
    title('Low-High Gamma Correlations around Movement Onset')
    
    subplot(2,1,2)
    boxplot(HC_R_LGHG_mat)
    title('Low-High Gamma Correlations around Reward')
    
    figure
    subplot(2,1,1)
    boxplot(HC_MO_SpHG_mat)
    title('Spike-High Gamma Correlations around Movement Onset')
    
    subplot(2,1,2)
    boxplot(HC_R_SpHG_mat)
    title('Spike-High Gamma Correlations around Reward')
    
    for i = 1:size(HC_Corr_SpikeRate_FpPower_ByTrial,2)
        HC_elements = histc(HC_Corr_SpikeRate_FpPower_ByTrial(:,i),-1:.05:1);
        BC_elements = histc(BC_Corr_SpikeRate_FpPower_ByTrial(:,i),-1:.05:1);
        HC_sum_elements = sum(HC_elements);
        BC_sum_elements = sum(BC_elements);
        HC_percent_elements(:,i) = HC_elements/HC_sum_elements;
        BC_percent_elements(:,i) = BC_elements/BC_sum_elements;
    end; clear HC_elements BC_elements HC_sum_elements BC_sum_elements
    
    subplot(2,1,1)
    bar(-1:.05:1,HC_percent_elements,'BarWidth',1)
    title('Hand Control Correlations')
    
    subplot(2,1,2)
    bar(-1:.05:1,BC_percent_elements,'BarWidth',1)
    title('Brain Control Correlations')
    
    BC_P = reshape(AvgP_SpikeRate_FPPower_ByFile(:,BC_I(1):BC_I(2),:),96*(BC_I(2)-BC_I(1)+1),5)
    HC_P = reshape(AvgP_SpikeRate_FPPower_ByFile(:,HC_I(1):HC_I(2),:),96*(HC_I(2)-HC_I(1)+1),5)
    
    hist(BC_correlations,-1:.1:1)
    legend([{'50 ms'},{'20 ms'},{'10 ms'},{'5 ms'},{'1 ms'}])
    
    figure
    hist(HC_correlations)
    legend([{'50 ms'},{'20 ms'},{'10 ms'},{'5 ms'},{'1 ms'}])
end
beep
%% Check correlations when adjusting them
if AdjustCorr == 1
    if flag_LGHG == 1
        ControlCh_Correlations.Reward_IncCorr(:,1) = AvgCorr.LG_HG_PriorToReward(1:length(IncCorr),1);
        ControlCh_Correlations.Reward_DecCorr(:,1) = AvgCorr.LG_HG_PriorToReward(length(IncCorr)+1:end,1);
    elseif flag_SpHG ==  1
        ControlCh_Correlations.Reward_IncCorr(:,1) = AvgCorr.PriorToReward(1:length(IncCorr),1);
        ControlCh_Correlations.Reward_DecCorr(:,1) = AvgCorr.PriorToReward(length(IncCorr)+1:end,1);
    end
    figure
    plot(IncCorr,ControlCh_Correlations.Reward_IncCorr)
    hold on
    plot(flip(DecCorr)*-1,flip(ControlCh_Correlations.Reward_DecCorr),'r')
    
    legend('Inc Corr','Dec Corr')
    xlabel('Percent Adjustment')
    ylabel('Spike-Gamma Correlation')
end
%% Check movement onset correlations
if flag_LGHG == 1 & length(ControlCh) == 1
    if NumWindows > 1
        MaxNumWindows = max(cellfun(@length,AvgCorr.LG_HG_PriorToReward(ControlCh,:)))
        CorrSurface_Reward = nan(BC_I(end)-BC_I(1),MaxNumWindows);
        NumTrialSurface_Reward = nan(BC_I(end)-BC_I(1),MaxNumWindows);
        fi = 1;
        for bci = BC_I(1):BC_I(end)
            CorrSurface_Reward(fi,end-length(AvgCorr.LG_HG_PriorToReward...
                {ControlCh,bci})+1:end) = flip(cell2mat(AvgCorr.LG_HG_PriorToReward...
                (ControlCh,bci)));
            NumTrialSurface_Reward(fi,end-length(AvgCorr.NumTrials...
                {ControlCh,bci})+1:end) = flip(cell2mat(AvgCorr.NumTrials...
                (ControlCh,bci)));
            fi = fi +1;
        end
        figure;
        h = surface(CorrSurface_Reward,'EdgeLighting','gouraud',...
            'MeshStyle','row',...
            'Marker','<',...
            'LineWidth',2,...
            'FaceAlpha',0,...
            'EdgeColor','flat');
        
        figure; plotyy(1:MaxNumWindows,nanmean(CorrSurface_Reward),1:MaxNumWindows,nanmean(NumTrialSurface_Reward))
        figure; plotyy(1:fi-1,nanmean(CorrSurface_Reward(:,end-2:end),2),1:fi-1,nanmean(NumTrialSurface_Reward(:,end-2:end),2))
        
        
    end
    ControlCh_Correlations.MO = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,4);
    ControlCh_Correlations.MO(1:length(HC_I),1) = AvgCorr.LG_HG_MovementOnset(ControlCh,HC_I(1:end));
    ControlCh_Correlations.MO(1:BC_I(end)-BC_I(1)+1,2) = AvgCorr.LG_HG_MovementOnset(ControlCh,BC_I(1):BC_I(end));
    ControlCh_Correlations.MO(1:BC_1DG(end)-BC_1DG(1)+1,3) = AvgCorr.LG_HG_MovementOnset(ControlCh,BC_1DG(1):BC_1DG(end));
    ControlCh_Correlations.MO(1:BC_1DSp(end)-BC_1DSp(1)+1,4) = AvgCorr.LG_HG_MovementOnset(ControlCh,BC_1DSp(1):BC_1DSp(end)); % :BC_1DSp(end)-BC_1DSp(1)+1, BC_1DSp(1):BC_1DSp(end)
    
    ControlCh_Correlations.MO(ControlCh_Correlations.MO==0) = NaN;
    
    ControlCh_P = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,2);
    ControlCh_P(1:length(HC_I),1) = AvgP.LG_HG_MovementOnset(ControlCh,HC_I(1:end));
    ControlCh_P(1:BC_I(end)-BC_I(1)+1,2) = AvgP.LG_HG_MovementOnset(ControlCh,BC_I(1):BC_I(end));
    
    means.MO = nanmean(ControlCh_Correlations.MO)
    stes.MO = nanstd(ControlCh_Correlations.MO)./...
        [sqrt(nnz(~isnan(ControlCh_Correlations.MO(:,1)))),...
        sqrt(nnz(~isnan(ControlCh_Correlations.MO(:,2)))),...
        sqrt(nnz(~isnan(ControlCh_Correlations.MO(:,3)))),...
        sqrt(nnz(~isnan(ControlCh_Correlations.MO(:,4))))]
    figure
    barwitherr(stes.MO,means.MO)
    set(gca,'Xtick',[1,2,3,4],'XTicklabel',{['Hand Control (n = ',sprintf('%d',nnz(~isnan(ControlCh_Correlations.MO(:,1)))),')']...
        ,['ONF Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.MO(:,2)))),')'],...
        ['1D Gam2 Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.MO(:,3)))),')'],...
        ['1D Low Gam Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.MO(:,4)))),')']})
    ylabel('Correlation Coefficient (R)')
    ylim([-1 1])
    ah = findobj(gca,'TickDirMode','auto')
    set(ah,'Box','off')
    set(ah,'TickLength',[0,0])
    [h p] = ttest2(ControlCh_Correlations.MO(:,1),ControlCh_Correlations.MO(:,2))
    
    title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Low Gamma - High Gamma Correlations 500 ms Around Movement Onset in Hand Control vs Brain Control (P = ',sprintf('%f',p),')'])
    
    
    %% Now check reward correlations
    ControlCh_Correlations.Reward = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,4);
    ControlCh_Correlations.Reward(1:length(HC_I),1) = AvgCorr.LG_HG_PriorToReward(ControlCh,HC_I(1:end));
    ControlCh_Correlations.Reward(1:BC_I(end)-BC_I(1)+1,2) = AvgCorr.LG_HG_PriorToReward(ControlCh,BC_I(1):BC_I(end));
    ControlCh_Correlations.Reward(1:BC_1DG(end)-BC_1DG(1)+1,3) = AvgCorr.LG_HG_PriorToReward(ControlCh,BC_1DG(1):BC_1DG(end));
    ControlCh_Correlations.Reward(1:BC_1DSp(end)-BC_1DSp(1)+1,4) = AvgCorr.LG_HG_PriorToReward(ControlCh,BC_1DSp(1):BC_1DSp(end)); % :BC_1DSp(end)-BC_1DSp(1)+1, BC_1DSp(1):BC_1DSp(end)
    
    AvgCorr.LG_HG_PriorToReward_AllTrials(ControlCh,BC_I(1):BC_I(end),1) = nanmean(AvgCorr.LG_HG_PriorToReward_AllTrials(ControlCh,BC_I(1):BC_I(end),1:end),3);
    
    ControlCh_RewardP = NaN(max(HC_I(end)-HC_I(1),BC_I(end)-BC_I(1))+1,2);
    ControlCh_RewardP(1:HC_I(end)-HC_I(1)+1,1) = AvgP.LG_HG_PriorToReward(ControlCh,HC_I(1):HC_I(end));
    ControlCh_RewardP(1:BC_I(end)-BC_I(1)+1,2) = AvgP.LG_HG_PriorToReward(ControlCh,BC_I(1):BC_I(end));
    ControlCh_Correlations.Reward(ControlCh_Correlations.Reward==0) = NaN;
    
    figure
    means.Reward = nanmean(ControlCh_Correlations.Reward);
    stes.Reward = nanstd(ControlCh_Correlations.Reward)./...
        [sqrt(nnz(~isnan(ControlCh_Correlations.Reward(:,1)))),...
        sqrt(nnz(~isnan(ControlCh_Correlations.Reward(:,2)))),...
        sqrt(nnz(~isnan(ControlCh_Correlations.Reward(:,3)))),...
        sqrt(nnz(~isnan(ControlCh_Correlations.Reward(:,4))))]
    
    barwitherr(stes.Reward, means.Reward)
    set(gca,'Xtick',[1,2,3,4],'XTicklabel',{['Hand Control (n = ',sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,1)))),')']...
        ,['ONF Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,2)))),')']...
        ,['1D Gam2 Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,3)))),')']...
        ,['1D Low Gam Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,4)))),')']})
    ylabel('Correlation Coefficient (R)')
    ylim([-1 1])
    ah = findobj(gca,'TickDirMode','auto')
    set(ah,'Box','off')
    set(ah,'TickLength',[0,0])
    [h p] = ttest2(ControlCh_Correlations.Reward(:,1),ControlCh_Correlations.Reward(:,2))
    
    title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Low Gamma - High Gamma Correlations 500 ms Prior to Reward in Hand Control vs Brain Control (P = ',sprintf('%f',p),')'])
    
    clear Binsize FP_Trial_time t Pval RhoVal h exception q
elseif flag_SpHG == 1 && length(ControlCh) > 1
    
    HC_Ch_correlations = AvgCorr.MovementOnset(:,HC_I(1:end));
    BC_Ch_correlations = AvgCorr.MovementOnset(:,BC_I(1):BC_I(end));   
    
    HC_Ch_correlations_MAT = cell2mat(HC_Ch_correlations);    
    BC_Ch_correlations_MAT = cell2mat(BC_Ch_correlations);    
    
    HC_Ch_Correlations_Avg = nanmean(HC_Ch_correlations_MAT,2);
    BC_Ch_Correlations_Avg = nanmean(BC_Ch_correlations_MAT,2);
    
    [HC_Array_Activity_Map, HC_map_matrix] = map_array_activity(monkey_name, HC_Ch_Correlations_Avg, 'LFP',[], 'plx');
    imagesc(HC_Array_Activity_Map)
    title('HC Array Correlation Map')
    caxis([0 1])
    [BC_Array_Activity_Map, BC_map_matrix] = map_array_activity(monkey_name, BC_Ch_Correlations_Avg, 'LFP',[], 'plx');
    figure; 
    imagesc(BC_Array_Activity_Map)
    title('BC Array Correlation Map')
    MinC = floor(min(BC_Ch_Correlations_Avg)*10)/10;
    MaxC = ceil(max(BC_Ch_Correlations_Avg)*10)/10;
    caxis([MinC MaxC])
    
    figure; 
    [nelements,centers] = hist(BC_Ch_MeanCorrelations_Avg,[MinC:.1:MaxC])
    h = bar(centers,nelements);
    set(get(h,'Children'),'CData',centers,'LineWidth',.2);
    set(gca,'box','off')
    
elseif flag_SpHG == 1 && length(ControlCh) == 1
    if NumWindows > 1
        
        MaxNumWindows = max(cellfun(@length,AvgCorr.PriorToReward_64(ControlCh,:)));
        CorrSurface_Reward = nan(BC_I(end)-BC_I(1),MaxNumWindows);
        NumTrialSurface_Reward = nan(BC_I(end)-BC_I(1),MaxNumWindows);
        fi = 1;
        for bci = BC_I(1):BC_I(end)
            CorrSurface_Reward(fi,end-length(AvgCorr.PriorToReward_64...
                {ControlCh,bci})+1:end) = flip(cell2mat(AvgCorr.PriorToReward_64...
                (ControlCh,bci)));
            NumTrialSurface_Reward(fi,end-length(AvgCorr.NumTrials_64...
                {ControlCh,bci})+1:end) = flip(cell2mat(AvgCorr.NumTrials_64...
                (ControlCh,bci)));
            fi = fi +1;
        end
        
        figure;
        h = surface(CorrSurface_Reward,'EdgeLighting','gouraud',...
            'MeshStyle','row',...
            'Marker','<',...
            'LineWidth',2,...
            'FaceAlpha',0,...
            'EdgeColor','flat');
        title([sprintf('%s',monkey_name),' Ch. ',sprintf('%d',ControlCh)] )
        xlabel('Time bin (2 s window, 100 ms overlap)')
        ylabel('File #')
        zlabel('Gam3 Trials Only -- Spike-Gam3 Corr')
        
        figure;
        title([sprintf('%s',monkey_name),' Ch. ',sprintf('%d',ControlCh)] )
        [ax h1 h2] = plotyy(1:MaxNumWindows,nanmean(CorrSurface_Reward),1:MaxNumWindows,nanmean(NumTrialSurface_Reward))
        ylabel(ax(1),'Gam3 Trials Only -- Spike-Gam3 Corr')
        ylabel(ax(2),'Avg Number of Trials in Corr')
        xlabel('Time bin (2 s window, 100 ms overlap)')
        hold on
        plot([MaxNumWindows-21 MaxNumWindows-21],[-100 100],'k--') % This is when the reward ended
        plot([MaxNumWindows-22 MaxNumWindows-22],[-100 100],'k--') % This is when the reward began
        
        clear CorrSurface_Reward NumTrialSurface_Reward
        
        MaxNumWindows = max(cellfun(@length,AvgCorr.PriorToReward_65(ControlCh,:)));
        CorrSurface_Reward = nan(BC_I(end)-BC_I(1),MaxNumWindows);
        NumTrialSurface_Reward = nan(BC_I(end)-BC_I(1),MaxNumWindows);
        fi = 1;
        for bci = BC_I(1):BC_I(end)
            CorrSurface_Reward(fi,end-length(AvgCorr.PriorToReward_65...
                {ControlCh,bci})+1:end) = flip(cell2mat(AvgCorr.PriorToReward_65...
                (ControlCh,bci)));
            NumTrialSurface_Reward(fi,end-length(AvgCorr.NumTrials_65...
                {ControlCh,bci})+1:end) = flip(cell2mat(AvgCorr.NumTrials_65...
                (ControlCh,bci)));
            fi = fi +1;
        end
        
        figure;
        h = surface(CorrSurface_Reward,'EdgeLighting','gouraud',...
            'MeshStyle','row',...
            'Marker','<',...
            'LineWidth',2,...
            'FaceAlpha',0,...
            'EdgeColor','flat');
        title([sprintf('%s',monkey_name),' Ch. ',sprintf('%d',ControlCh)] )
        xlabel('Time bin (2 s window, 100 ms overlap)')
        ylabel('File #')
        zlabel('Spike Trials Only -- Spike-Gam3 Corr')
        
        figure;
        [ax h1 h2] = plotyy(1:MaxNumWindows,nanmean(CorrSurface_Reward),1:MaxNumWindows,nanmean(NumTrialSurface_Reward))
        title([sprintf('%s',monkey_name),' Ch. ',sprintf('%d',ControlCh)] )
        ylabel(ax(1),'Spike Trials Only -- Spike-Gam3 Corr')
        ylabel(ax(2),'Avg Number of Trials in Corr')
        xlabel('Time bin (2 s window, 100 ms overlap)')
        hold on
        plot([MaxNumWindows-21 MaxNumWindows-21],[-100 100],'k--') % This is when the reward ended
        plot([MaxNumWindows-22 MaxNumWindows-22],[-100 100],'k--') % This is when the reward began
        
        if exist('Exceptions','var') == 0
            Exceptions = [];
        end
        return
    end
%     ControlCh_Correlations.MO = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,4);
%     ControlCh_Correlations.MO(1:length(HC_I),1) = cell2mat(AvgCorr.MovementOnset(ControlCh,HC_I(1:end)));
%     ControlCh_Correlations.MO(1:BC_I(end)-BC_I(1)+1,2) = cell2mat(AvgCorr.MovementOnset(ControlCh,BC_I(1):BC_I(end)));
%     ControlCh_Correlations.MO(1:BC_1DG(end)-BC_1DG(1)+1,3) = cell2mat(AvgCorr.MovementOnset(ControlCh,BC_1DG(1):BC_1DG(end)));
%     ControlCh_Correlations.MO(1:BC_1DSp(end)-BC_1DSp(1)+1,4) = cell2mat(AvgCorr.MovementOnset(ControlCh,BC_1DSp(1):BC_1DSp(end))); % :BC_1DSp(end)-BC_1DSp(1)+1, BC_1DSp(1):BC_1DSp(end)
%     
%     ControlCh_Correlations.MO(ControlCh_Correlations.MO==0) = NaN;
%     
%     ControlCh_P.MO = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,2);
%     ControlCh_P.MO(1:length(HC_I),1) = AvgP.MovementOnset(ControlCh,HC_I(1:end));
%     ControlCh_P.MO(1:BC_I(end)-BC_I(1)+1,2) = AvgP.MovementOnset(ControlCh,BC_I(1):BC_I(end));
%     
%     figure
%     
%     means.MO = nanmean(ControlCh_Correlations.MO)
%     stes.MO = nanstd(ControlCh_Correlations.MO)./...
%         [sqrt(nnz(~isnan(ControlCh_Correlations.MO(:,1)))),...
%         sqrt(nnz(~isnan(ControlCh_Correlations.MO(:,2)))),...
%         sqrt(nnz(~isnan(ControlCh_Correlations.MO(:,3)))),...
%         sqrt(nnz(~isnan(ControlCh_Correlations.MO(:,4))))]
%     barwitherr(stes.MO,means.MO)
%     set(gca,'Xtick',[1,2,3,4],'XTicklabel',{['Hand Control (n = ',sprintf('%d',nnz(~isnan(ControlCh_Correlations.MO(:,1)))),')']...
%         ,['ONF Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.MO(:,2)))),')'],...
%         ['1D Gam3 Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.MO(:,3)))),')'],...
%         ['1D Spike Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.MO(:,4)))),')']})
%     ylabel('Correlation Coefficient (R)')
%     ylim([-1 1])
%     ah = findobj(gca,'TickDirMode','auto')
%     set(ah,'Box','off')
%     set(ah,'TickLength',[0,0])
%     [h p] = ttest2(ControlCh_Correlations.MO(:,1),ControlCh_Correlations.MO(:,2))
%     
%     title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Spike - High Gamma Correlations 500 ms Around Movement Onset in Hand Control vs Brain Control (P = ',sprintf('%f',p),')'])
%     
    %% Check Maximum Velocity correlations
    %     ControlCh_Correlations.MaxV = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,2);
    %     ControlCh_Correlations.MaxV(1:length(HC_I),1) = AvgCorr.MaximumVel(ControlCh,HC_I(1:end));
    %     ControlCh_Correlations.MaxV(1:BC_I(end)-BC_I(1)+1,2) = AvgCorr.MaximumVel(ControlCh,BC_I(1):BC_I(end));
    %     ControlCh_Correlations.MaxV(ControlCh_Correlations.MaxV==0) = NaN;
    %
    % %     ControlCh_P = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,2);
    % %     ControlCh_P(1:length(HC_I),1) = AvgP.MaximumVel(ControlCh,HC_I(1:end));
    % %     ControlCh_P(1:BC_I(end)-BC_I(1)+1,2) = AvgP.MaximumVel(ControlCh,BC_I(1):BC_I(end));
    % %
    %     figure
    %
    %     barwitherr([1,2],nanmean(ControlCh_Correlations.MaxV),nanstd(ControlCh_Correlations.MaxV)./[sqrt(nnz(~isnan(ControlCh_Correlations.MaxV(:,1)))),sqrt(nnz(~isnan(ControlCh_Correlations.MaxV(:,2))))],'o')
    %     set(gca,'Xtick',[1,4],'XTicklabel',{'Hand Control','ONF Control'})
    %     ylabel('Correlation (R)')
    %     ylim([-1 1])
    %     ah = findobj(gca,'TickDirMode','auto')
    %     set(ah,'Box','off')
    %     set(ah,'TickLength',[0,0])
    %     [h p] = ttest2(ControlCh_Correlations.MaxV(:,1),ControlCh_Correlations.MaxV(:,2))
    %
    %     title(['Low Gamma - High Gamma Correlations 500 ms Around Maximum Velocity in Hand Control vs Brain Control (P = ',sprintf('%f',p),')'])
    
    %% Now check reward correlations
    ControlCh_Correlations.Reward = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,4);
    ACPR_HC = AvgCorr.PriorToReward(ControlCh,HC_I(1:end));
    ACPR_HC(cellfun(@isempty,ACPR_HC)==1) = {nan};
    ControlCh_Correlations.Reward(1:HC_I(end)-HC_I(1)+1,1) = cell2mat(ACPR_HC);
    
    ACPR_BC_1DG = AvgCorr.PriorToReward(ControlCh,BC_1DG(1:end));
    ACPR_BC_1DG(cellfun(@isempty,ACPR_BC_1DG)==1) = {nan};
    ControlCh_Correlations.Reward(1:BC_1DG(end)-BC_1DG(1)+1,3) = cell2mat(ACPR_BC_1DG);
    
    ACPR_BC_1DSp = AvgCorr.PriorToReward(ControlCh,BC_1DSp(1:end));
    ACPR_BC_1DSp(cellfun(@isempty,ACPR_BC_1DSp)==1) = {nan};
    ControlCh_Correlations.Reward(1:BC_1DSp(end)-BC_1DSp(1)+1,4) = cell2mat(ACPR_BC_1DSp);
    
    ACPR_BC = AvgCorr.PriorToReward(ControlCh,BC_I(1):BC_I(end));
    ACPR_BC(cellfun(@isempty,ACPR_BC)==1) = {nan};
    ControlCh_Correlations.Reward(1:BC_I(end)-BC_I(1)+1,2) = cell2mat(ACPR_BC);
    
%     ControlCh_P.Reward = NaN(max(HC_I(end)-HC_I(1),BC_I(end)-BC_I(1))+1,2);
%     ControlCh_P.Reward(1:HC_I(end)-HC_I(1)+1,1) = AvgP.LG_HG_PriorToReward(ControlCh,HC_I(1):HC_I(end));
%     ControlCh_P.Reward(1:BC_I(end)-BC_I(1)+1,2) = AvgP.LG_HG_PriorToReward(ControlCh,BC_I(1):BC_I(end));
%     ControlCh_Correlations.Reward(ControlCh_Correlations.Reward==0) = NaN;
    
    figure
    means.Reward = nanmean(ControlCh_Correlations.Reward);
    stes.Reward = nanstd(ControlCh_Correlations.Reward)./...
        [sqrt(nnz(~isnan(ControlCh_Correlations.Reward(:,1)))),...
        sqrt(nnz(~isnan(ControlCh_Correlations.Reward(:,2)))),...
        sqrt(nnz(~isnan(ControlCh_Correlations.Reward(:,3)))),...
        sqrt(nnz(~isnan(ControlCh_Correlations.Reward(:,4))))]
    
    errorbar(means.Reward, stes.Reward,'kx')
    set(gca,'Xtick',[1,2,3,4],'XTicklabel',{['Hand Control (n = ',sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,1)))),')']...
        ,['ONF Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,2)))),')']...
        ,['1D Gam3 Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,3)))),')']...
        ,['1D Spike Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,4)))),')']})
      set(gca,'Xtick',[1,2,3,4],'XTicklabel',{['Before ONF Control (n = ',sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,1)))),')']...
        ,['After ONF Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,2)))),')']...
        ,['1D Gam3 Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,3)))),')']...
        ,['1D Spike Control (n = ', sprintf('%d',nnz(~isnan(ControlCh_Correlations.Reward(:,4)))),')']})
   
    ylabel('Correlation Coefficient (R)')
    ylim([-1 1])
    ah = findobj(gca,'TickDirMode','auto')
    set(ah,'Box','off')
    set(ah,'TickLength',[0,0])
    [h p] = ttest2(ControlCh_Correlations.Reward(:,1),ControlCh_Correlations.Reward(:,2))
    
    title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Spike - High Gamma Correlations 500 ms Prior to Reward in Hand Control vs Brain Control (P = ',sprintf('%f',p),')'])
    
    
    %     save([sprintf(monkey_name),sprintf(ControlCh),'SpHG' 'Jaco_Ch52_Gam3X_SpikeY_ParsedFiles','-v7.3')
    AvgCorr.Reward_AllCorr = ControlCh_Correlations.Reward;
    
    clear Binsize FP_Trial_time t Pval RhoVal h exception q
end

if exist('Exceptions','var') == 0
    Exceptions = [];
end
