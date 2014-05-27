% function [p ControlCh_BC_correlations ControlCh_HC_correlations BC_correlations...
%     HC_correlations AvgCorr_SpikeRate_FPPower_ByFile] = BinAndOrganizeSpikesAndFPsByTrial(Trials, data, LFPInds, SpikeInds)

BinsizeCorr = .05;
FP_Trial_time = [0:.001:1];
t = [0.5:BinsizeCorr:1];
samprate = 1000;
HC_I = [1 4];
BC_I = [13 21];

[b_gamma,a_gamma]=butter(2,[200 300]/(samprate/2));

for f = [BC_I(1):BC_I(2)]% size(Trial_tsendCELL,2)
    for k = 1:size(Trials,1)
        % If there are no spikes then put fill with all Nans and continue
        if isfield(Trials{k,f},'tsend') == 1  
            
            for i = 1:length(Trials{k,f}.tsend)
                % Bin spikes by trial
                try
                    SpikeRatesByTrial(i,:) = train2bins(Trials{k,f}.tsend(1,i).times,t);
                catch exception
                    Exceptions{f,k} = exception;
                    SpikeRatesByTrial(i,:) = zeros(1,length(t));
                    fpByTrial(i,:) = zeros(1,length(t));
                    continue
                end
                % BP filter gamma, Hilbert transform trial FP signal and then
                % interpolate
                Trial_Gamma = filtfilt(b_gamma,a_gamma,Trials{k,f}.FPend{1,i});
                fpByTrial(i,:) = interp1(FP_Trial_time,real(hilbert(Trial_Gamma)),t);
            end
            clear i Trial_Gamma
            % Average spike rates and gamma FP power over all trials
            MeanSpikeRateByFile = mean(SpikeRatesByTrial);
            MeanFPByFile = mean(fpByTrial);
            % Find correlation of trial averaged spike rate and gamma FP power
            [RhoVal Pval] = corr([MeanSpikeRateByFile' MeanFPByFile'],'type','Spearman');
            AvgCorr_SpikeRate_FPPower_ByFile(k,f) = RhoVal(1,2);
            AvgP_SpikeRate_FPPower_ByFile(k,f) = Pval(1,2);
            
            FileCAT_SpikeRate = reshape(SpikeRatesByTrial',size(SpikeRatesByTrial,1)*size(SpikeRatesByTrial,2),1); 
            FileCAT_FPs = reshape(fpByTrial',size(fpByTrial,1)*size(fpByTrial,2),1);
            
            [RhoVal Pval] = corr([FileCAT_SpikeRate FileCAT_FPs],'type','Spearman');
            AvgCorr_SpikeRate_FPPower_ByFileCAT(k,f) = RhoVal(1,2);
            AvgP_SpikeRate_FPPower_ByFileCAT(k,f) = Pval(1,2);
        else
            AvgCorr_SpikeRate_FPPower_ByFileCAT(k,f) = NaN;
            AvgP_SpikeRate_FPPower_ByFileCAT(k,f) = NaN;
            AvgCorr_SpikeRate_FPPower_ByFile(k,f) = NaN;
            AvgP_SpikeRate_FPPower_ByFile(k,f) = NaN;
        end
        
        clear MeanSpikeRateByFile MeanFPByFile SpikeRatesByTrial fpByTrial...
            FileCAT_FPs FileCAT_SpikeRate
        
%% Same thing now for the whole file instead of trial averaging
        % Get rid of NaNs from Robert's fpAssignScript2 for correcting FP matrix 
        NumNans = nnz(isnan(data(f).FPs(k,:)));
        data(f).FPs(k,isnan(data(f).FPs(k,:))) = 0;
        tFile = [1:BinsizeCorr:data(f).fptimes(end)];
        
        WholeFile_Gamma = filtfilt(b_gamma,a_gamma,data(f).FPs(k,:));
        fpWholeFile = interp1(data(f).fptimes,real(hilbert(WholeFile_Gamma)),tFile);
        
        if isempty(data(f).SpikeTimes{k}) == 0 
            SpikeRatesWholeFile = train2bins(data(f).SpikeTimes{k},tFile);
        else 
            AvgCorr_SpikeRate_FPPower_WholeFile(k,f) = NaN;
            AvgP_SpikeRate_FPPower_WholeFile(k,f) = NaN;
            continue
        end
        [RhoVal Pval] = corr([SpikeRatesWholeFile' fpWholeFile'],'type','Spearman');
        AvgCorr_SpikeRate_FPPower_WholeFile(k,f) = RhoVal(1,2);
        AvgP_SpikeRate_FPPower_WholeFile(k,f) = Pval(1,2);
        
        f
        k
        clear SpikeRatesWholeFile fpWholeFile RhoVal Pval
    end
end
clear f k FP_Trial_time binsize t a_gamma b_gamma RhoVal Pval
% figure
% hist(AvgCorr_SpikeRate_FPPower_WholeFile(:,11:14))
% title('Brain Control Distribution of Spike Rate and Gamma Power Correlations over Whole File')
% 
% figure
% hist(AvgCorr_SpikeRate_FPPower_ByFileCAT(:,11:14))
% title('Brain Control - Distribution of Spike Rate and Gamma Power Correlations when Trials are Concatenated')

figure
hist(AvgCorr_SpikeRate_FPPower_ByFile(:,HC_I(1):HC_I(2)))
title('Hand Control - Distribution of Spike Rate and Gamma Power Correlations when Trials are Averaged')

figure
hist(AvgCorr_SpikeRate_FPPower_ByFile(:,BC_I(1):BC_I(2)))
title('Brain Control - Distribution of Spike Rate and Gamma Power Correlations when Trials are Averaged')

BC_correlations = reshape(AvgCorr_SpikeRate_FPPower_ByFile(:,BC_I(1):BC_I(2)),96*(BC_I(2)-BC_I(1)+1),1)
HC_correlations = reshape(AvgCorr_SpikeRate_FPPower_ByFile(:,HC_I(1):HC_I(2)),96*(HC_I(2)-HC_I(1)+1),1)

ControlCh_BC_correlations = reshape(AvgCorr_SpikeRate_FPPower_ByFile(LFPInds{1}(1),BC_I(1):BC_I(end)),(BC_I(end)-BC_I(1)+1),1)
ControlCh_HC_correlations = reshape(AvgCorr_SpikeRate_FPPower_ByFile(SpikeInds{1}(1),HC_I(1):HC_I(end)),(HC_I(end)-HC_I(1)+1),1)

[h p] = ttest2(ControlCh_BC_correlations,ControlCh_HC_correlations)
% MeanR_trial = hist(AvgCorr_SpikeRate_FPPower_ByFile)
% title('Distribution of Spike Rate and Gamma Power Correlations when Averaged over Trials')

clear Binsize FP_Trial_time t Pval RhoVal
