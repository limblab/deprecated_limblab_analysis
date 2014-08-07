% function [p ControlCh_BC_correlations ControlCh_HC_correlations BC_correlations...
%     HC_correlations AvgCorr_SpikeRate_FPPower_ByFile] = BinAndOrganizeSpikesAndFPsByTrial(Trials, data, LFPInds, SpikeInds)

KernelSize = [20];
FP_Trial_timeIndex_start = [1750:2250];
FP_Trial_timeIndex_end = [1850:2000];

samprate = 1000;
HC_I = [1:6 17:20];
BC_I = [7 16];

ControlCh = 38;

for bin = 1:length(KernelSize)
    tstart = [-.25:.001:.25];
    tend = [1.85:.001:2];
    filestartindex = 0;
    for f = [HC_I(1):HC_I(end) BC_I(1):BC_I(end)]
        for k = ControlCh%1:size(Trials,1)
            % If there are no spikes then put fill with all Nans and continue
            if isfield(Trials{k,f},'tsend') == 1
                
                for i = 1:length(Trials{k,f}.tsend)
                    % Bin spikes by trial
                    try
                        SpikeCountsTempStart = train2bins(Trials{k,f}.tsstart(1,i).times,tstart);
                        SpikeCountsTempEnd = train2bins(Trials{k,f}.tsend(1,i).times,tend);
                        SpikeRatesByTrialStart(i,:) = train2cont(SpikeCountsTempStart,KernelSize(bin));
                        SpikeRatesByTrialEnd(i,:) = train2cont(SpikeCountsTempEnd,KernelSize(bin));
                    catch exception
                        Exceptions{f,k} = exception;
                        SpikeRatesByTrialStart(i,:) = zeros(1,length(tstart));
                        SpikeRatesByTrialEnd(i,:) = zeros(1,length(tend));
                        fpByTrialStart(i,:,:) = zeros(1,length(tstart),3);
                        fpByTrialEnd(i,:,:) = zeros(1,length(tend),1,3);
                        
                        continue
                    end

                    for C = 1:size(Trials{k,f}.FPstart,2)
                        if isempty(Trials{k,f}.FPstart{i,C}) == 0 
                            fpByTrialStart(i,:,C) = Trials{k,f}.FPstart{i,C}(FP_Trial_timeIndex_start);
                            fpByTrialEnd(i,:,C) = Trials{k,f}.FPend{i,C}(FP_Trial_timeIndex_end);
                        else
                            continue
                        end
                    
                    end
                end
                clear i Trial_GammaEnd Trial_GammaStart RhoValTrial PvalTrial...
                    SpikeCountsTempEnd SpikeCountsTempStart
                
                
                %% Find correlation of trial averaged spike rate and gamma
                %FP power during 500 ms centered on movement onset
                
                % Average spike rates and gamma FP power over all trials
                MeanSpikeRateByFileStart = mean(SpikeRatesByTrialStart);
                MeanFPByFileStart = squeeze(mean(fpByTrialStart));
                AvgCorr.FPTraceStart{f}(:,k,:) = MeanFPByFileStart;
                AvgCorr.SpTraceStart{f}(:,k) = MeanSpikeRateByFileStart';
                [RhoVal Pval] = corr([MeanSpikeRateByFileStart' MeanFPByFileStart(:,3)],'type','Spearman');
                AvgCorr.MovementOnset(k,f,bin) = RhoVal(1,2);
                AvgP.MovementOnset(k,f,bin) = Pval(1,2);
                
                % Now do Low-Gamma and High-Gamma around movement onset
                [RhoVal Pval] = corr([MeanFPByFileStart(:,1) MeanFPByFileStart(:,2)],'type','Spearman');
                AvgCorr.LG_HG_MovementOnset(k,f,bin) = RhoVal(1,2);
                AvgP.LG_HG_MovementOnset(k,f,bin) = Pval(1,2);
                
                % Find correlation of trial averaged spike rate and gamma
                % FP power during 150 ms prior to reward
                MeanSpikeRateByFileEnd = mean(SpikeRatesByTrialEnd);
                MeanFPByFileEnd = squeeze(mean(fpByTrialEnd));
                AvgCorr.FPTraceEnd{f}(:,k,:) = MeanFPByFileEnd;
                AvgCorr.SpTraceEnd{f}(:,k,:) = MeanSpikeRateByFileEnd';
                [RhoVal Pval] = corr([MeanSpikeRateByFileEnd' MeanFPByFileEnd(:,3)],'type','Spearman');
                AvgCorr.PriorToReward(k,f,bin) = RhoVal(1,2);
                AvgP.PriorToReward(k,f,bin) = Pval(1,2);
                
                [RhoVal Pval] = corr([MeanFPByFileEnd(:,1) MeanFPByFileEnd(:,2)],'type','Spearman');
                AvgCorr.LG_HG_PriorToReward(k,f,bin) = RhoVal(1,2);
                AvgP.LG_HG_PriorToReward(k,f,bin) = Pval(1,2);
                clear MeanSpikeRateByFile MeanSpikeRateByFileStart MeanFPByFile...
                    MeanFPByFileStart
                
                %% Ray Method
                % Spike-Gamma Prior To Reward
                MeanSpikeRateByFileEnd_Ray = mean(SpikeRatesByTrialEnd,2);
                MeanFPByFileEnd_Ray = squeeze(mean(fpByTrialEnd,2));
                AvgCorr.FPTraceEnd_Ray{f}(:,k,:) = MeanFPByFileEnd_Ray;
                AvgCorr.SpTraceEnd_Ray{f}(:,k,:) = MeanSpikeRateByFileEnd_Ray';
                [RhoVal Pval] = corr([MeanSpikeRateByFileEnd_Ray MeanFPByFileEnd_Ray(:,3)],'type','Spearman');
                AvgCorr.Ray_End(k,f,bin) = RhoVal(1,2);
                AvgP.Ray_End(k,f,bin) = Pval(1,2);
                
                % Now Low-Gamma and High-Gamma Prior to Reward
                [RhoVal Pval] = corr([MeanFPByFileEnd_Ray(:,1) MeanFPByFileEnd_Ray(:,2)],'type','Spearman');
                AvgCorr.LG_HG_Ray_End(k,f,bin) = RhoVal(1,2);
                AvgP.LG_HG_Ray_End(k,f,bin) = Pval(1,2);
                
                % Now Spike-High Gamma around Movement Onset
                MeanSpikeRateByFileStart_Ray = mean(SpikeRatesByTrialStart,2);
                MeanFPByFileStart_Ray = squeeze(mean(fpByTrialStart,2));
                AvgCorr.FPTraceStart_Ray{f}(:,k,:) = MeanFPByFileStart_Ray;
                AvgCorr.SpTraceStart_Ray{f}(:,k,:) = MeanSpikeRateByFileStart_Ray';
                [RhoVal Pval] = corr([MeanSpikeRateByFileStart_Ray MeanFPByFileStart_Ray(:,3)],'type','Spearman');
                AvgCorr.Ray_Start(k,f,bin) = RhoVal(1,2);
                AvgP.Ray_Start(k,f,bin) = Pval(1,2);
                
                % Now Low-Gamma and High-Gamma around Movement Onset
                [RhoVal Pval] = corr([MeanFPByFileStart_Ray(:,1) MeanFPByFileStart_Ray(:,2)],'type','Spearman');
                AvgCorr.LG_HG_Ray_Start(k,f,bin) = RhoVal(1,2);
                AvgP.LG_HG_Ray_Start(k,f,bin) = Pval(1,2);
                
                clear MeanSpikeRateByFileStart_Ray MeanSpikeRateByFile_Ray...
                    MeanFPByFileStart_Ray MeanFPByFile_Ray RhoVal Pval...
                    SpikeRatesByTrialEnd SpikeRatesByTrialStart fpByTrialEnd...
                    fpByTrialStart
                %                 FileCAT_SpikeRate = reshape(SpikeRatesByTrial',size(SpikeRatesByTrial,1)*size(SpikeRatesByTrial,2),1);
                %                 FileCAT_FPs = reshape(fpByTrial',size(fpByTrial,1)*size(fpByTrial,2),1);
                
                %                 [RhoVal Pval] = corr([FileCAT_SpikeRate FileCAT_FPs],'type','Spearman');
                %                 AvgCorr_SpikeRate_FPPower_ByFileCAT(k,f) = RhoVal(1,2);
                %                 AvgP_SpikeRate_FPPower_ByFileCAT(k,f) = Pval(1,2);
            end
            
            clear MeanSpikeRateByFile MeanFPByFile SpikeRatesByTrial fpByTrial...
                FileCAT_FPs FileCAT_SpikeRate
            
            f
            k
            clear SpikeRatesWholeFile fpWholeFile RhoVal Pval
        end
    end
end
clear f k bin FP_Trial_time binsize t a_gamma b_gamma RhoVal Pval

if 0
    BC_correlations = reshape(AvgCorr_SpikeRate_FPPower_ByFile(:,BC_I(1):BC_I(2),:),96*(BC_I(2)-BC_I(1)+1),5)
    HC_correlations = reshape(AvgCorr_SpikeRate_FPPower_ByFile(:,HC_I(1):HC_I(2),:),96*(HC_I(2)-HC_I(1)+1),5)
    
    figure
    subplot(2,1,1)
    hist(BC_Corr_SpikeRate_FpPower_ByTrial,-1:.05:1)
    legend([{'50 ms'},{'20 ms'},{'10 ms'},{'5 ms'},{'1 ms'}])
    
    subplot(2,1,2)
    hist(HC_Corr_SpikeRate_FpPower_ByTrial,-1:.05:1)
    legend([{'50 ms'},{'20 ms'},{'10 ms'},{'5 ms'},{'1 ms'}])
    
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
%% Check movement onset correlations
ControlCh_correlations = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,2);
ControlCh_correlations(1:length(HC_I),1) = AvgCorr.LG_HG_MovementOnset(LFPInds{1}(1),HC_I(1:end));
ControlCh_correlations(1:BC_I(end)-BC_I(1)+1,2) = AvgCorr.LG_HG_MovementOnset(LFPInds{1}(1),BC_I(1):BC_I(end));
ControlCh_correlations(ControlCh_correlations==0) = NaN;

ControlCh_P = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,2);
ControlCh_P(1:length(HC_I),1) = AvgP.LG_HG_MovementOnset(LFPInds{1}(1),HC_I(1:end));
ControlCh_P(1:BC_I(end)-BC_I(1)+1,2) = AvgP.LG_HG_MovementOnset(LFPInds{1}(1),BC_I(1):BC_I(end));

figure
% hist(ControlCh_correlations)
% boxplot(ControlCh_correlations)
H = errorbar([1,2],nanmean(ControlCh_correlations),nanstd(ControlCh_correlations)./[sqrt(nnz(~isnan(ControlCh_correlations(:,1)))),sqrt(nnz(~isnan(ControlCh_correlations(:,2))))],'o')
set(gca,'Xtick',[1,2],'XTicklabel',{'Hand Control','Brain Control'})
ylabel('Correlation (R)')
ylim([-1 .2])
set(H,'LineWidth',2.0)
legend('Hand Control','Brain Control')
% xlim([-1 1])
[h p] = ttest2(ControlCh_correlations(:,1),ControlCh_correlations(:,2))

title(['Low Gamma - High Gamma Correlations 500 ms Around Movement Onset in Hand Control vs Brain Control (P = ',sprintf('%f',p),')'])
figure
plot(ControlCh_correlations)
legend('Hand Control','Brain Control')

%% Now check reward correlations
ControlCh_RewardCorrelations = NaN(max(length(HC_I),BC_I(end)-BC_I(1))+1,2);
ControlCh_RewardCorrelations(1:length(HC_I),1) = AvgCorr.LG_HG_PriorToReward(LFPInds{1}(1),HC_I(1:end));
ControlCh_RewardCorrelations(1:BC_I(end)-BC_I(1)+1,2) = AvgCorr.LG_HG_PriorToReward(LFPInds{1}(1),BC_I(1):BC_I(end));

ControlCh_RewardP = NaN(max(HC_I(end)-HC_I(1),BC_I(end)-BC_I(1))+1,2);
ControlCh_RewardP(1:HC_I(end)-HC_I(1)+1,1) = AvgP.LG_HG_PriorToReward(LFPInds{1}(1),HC_I(1):HC_I(end));
ControlCh_RewardP(1:BC_I(end)-BC_I(1)+1,2) = AvgP.LG_HG_PriorToReward(LFPInds{1}(1),BC_I(1):BC_I(end));
ControlCh_RewardCorrelations(ControlCh_correlations==0) = NaN;

[h p] = ttest2(ControlCh_RewardCorrelations(:,1),ControlCh_RewardCorrelations(:,2))
figure
hist(ControlCh_RewardCorrelations)
H = errorbar([1,2],nanmean(ControlCh_RewardCorrelations),nanstd(ControlCh_RewardCorrelations)./[sqrt(nnz(~isnan(ControlCh_RewardCorrelations(:,1)))),sqrt(nnz(~isnan(ControlCh_RewardCorrelations(:,2))))],'o')
set(gca,'Xtick',[1,2],'XTicklabel',{'Hand Control','Brain Control'})
ylabel('Correlation (R)')
set(H,'LineWidth',2.0)
% legend('Hand Control','Brain Control')
title(['Low Gamma - High Gamma Correlations 150 ms Prior to Reward in Hand Control vs Brain Control (P = ',sprintf('%f',p),')'])
figure
plot(ControlCh_RewardCorrelations)
legend('Hand Control','Brain Control')

xlim([-1 1])

[h p] = ttest2(ControlCh_correlations)

clear Binsize FP_Trial_time t Pval RhoVal h exception q

%% Same thing now for the whole file instead of trial averaging
% Get rid of NaNs from Robert's fpAssignScript2 for correcting FP matrix
%         NumNans = nnz(isnan(data(f).FPs(k,:)));
%         data(f).FPs(k,isnan(data(f).FPs(k,:))) = 0;
%         tFile = [1:BinsizeCorr:data(f).fptimes(end)];
%
%         WholeFile_Gamma = filtfilt(b_gamma,a_gamma,data(f).FPs(k,:));
%         fpWholeFile = interp1(data(f).fptimes,real(hilbert(WholeFile_Gamma)),tFile);
%
%         if isempty(data(f).SpikeTimes{k}) == 0
%             SpikeRatesWholeFile = train2bins(data(f).SpikeTimes{k},tFile);
%         else
%             AvgCorr_SpikeRate_FPPower_WholeFile(k,f) = NaN;
%             AvgP_SpikeRate_FPPower_WholeFile(k,f) = NaN;
%             continue
%         end
%         [RhoVal Pval] = corr([SpikeRatesWholeFile' fpWholeFile'],'type','Spearman');
%         AvgCorr_SpikeRate_FPPower_WholeFile(k,f) = RhoVal(1,2);
%         AvgP_SpikeRate_FPPower_WholeFile(k,f) = Pval(1,2);

%% Extra code
%                     [RhoValTrial PvalTrial] = corr([SpikeRatesByTrial(i,:)' fpByTrial(i,:)'],'type','Spearman');
%                     if f <= HC_I(2)
%                         HC_Corr_SpikeRate_FpPower_ByTrial(i+length(Trials{k,f}.tsend)*(k-1)+filestartindex,bin) =  RhoValTrial(1,2);
%                         HC_P_SpikeRate_FpPower_ByTrial(i+length(Trials{k,f}.tsend)*(k-1)+filestartindex,bin) =  PvalTrial(1,2);
%                         if i =
%                     elseif k == 1 && f == BC_I(1) && i == 1
%                         filestartindex = 0;
%                         BC_Corr_SpikeRate_FpPower_ByTrial(i+length(Trials{k,f}.tsend)*(k-1)+filestartindex,bin) =  RhoValTrial(1,2);
%                         BC_P_SpikeRate_FpPower_ByTrial(i+length(Trials{k,f}.tsend)*(k-1)+filestartindex,bin) =  PvalTrial(1,2);
%                     else
%                         BC_Corr_SpikeRate_FpPower_ByTrial(i+(length(Trials{k,f}.tsend)*(k-1))+filestartindex,bin) =  RhoValTrial(1,2);
%                         BC_P_SpikeRate_FpPower_ByTrial(i+(length(Trials{k,f}.tsend)*(k-1))+filestartindex,bin) =  PvalTrial(1,2);
%                     end
%                     if k == 96 && i == length(Trials{k,f}.tsend)
%                          HC_Corr_SpikeRate_FpPower_ByTrial
%                          filestartindex = i+(length(Trials{k,f}.tsend)*(k-1))+filestartindex;
%                     end