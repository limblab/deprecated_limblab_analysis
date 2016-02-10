function [PLI] = Calc_PLI_by_FP(FileList, Trials, TrialsRawFP, ControlCh, numfp,...
    HC_I, BC_I, BC_1DG, BC_1DSp, flag_SpHG, flag_LGHG, LG_Phase, monkey_name)

FP_Trial_timeIndex_start = [1750:2250];
FP_Trial_timeIndex_MV = [1750:2250];
samprate = 1000;
KernelSize = 20;

SlideWin = 1;
SpikeWin = .5;
SpikeStep = .5;
SpikeStartTime = 2; % Since spikes include 2 seconds after reward, a spike time of 2 
                    % occurs 2 seconds after reward
FPStartIndex = 0; % Since FPs include 2 seconds after reward, 2000 needs to be subtracted to start at reward
WinStep_ms = 500; % in ms

CorrWindow = 500;
win=repmat(hanning(CorrWindow),1,1); %Put in matrix for multiplication compatibility
freqs=linspace(0,samprate/2,CorrWindow/2+1); % Frequencies calculated in fft
freqs=freqs(2:end);

ErrI = 1;
TimeThres = 30; % This is a threshold for what trial lengths will be considered when calculating the correlation
% % Flags
flag_EvalRbyTarg = 0;
flag_HCcorr = 0;


for f = [BC_I(1):BC_I(end) HC_I(1):HC_I(end)]% BC_1DG(1):BC_1DG(end) BC_1DSp(1):BC_1DSp(end)]
    %This loop iterates over files
    % BC_1DG(1):BC_1DG(end) BC_1DSp(1):BC_1DSp(end)]
    for k = in(ControlCh,[1 96])
        
        fpByTrialEnd_64 = [];
        fpByTrialEnd_65 = [];
        SpikeRatesByTrialEnd_64 = [];
        SpikeRatesByTrialEnd_65 = [];
        i64 = 1;
        i65 = 1;
        
        %This loop iterates over channels
        % Inside it, each channel has spikes and fps binned and then
        % correlations calculated on trial averaged traces.
        TrialInd = 1;
        
        if isfield(Trials{k,f},'tsend') == 1
            
            for i = 1:length(Trials{k,f}.tsend) %This loop bins spikes and FPs over trials
                
                if isfield(Trials{k,f},'FPend') == 1
                    MaxTrialLength(1) = max(cellfun(@length,Trials{k,f}.FPend(i,1)));
                elseif isfield(Trials{k,f},'Incomplete_FPend') == 1
                    MaxTrialLength(2) = max(cellfun(@length,Trials{k,f}.Incomplete_FPend(i,1)));
                elseif isfield(Trials{k,f},'Fail_FPend') == 1
                    MaxTrialLength(3) = max(cellfun(@length,Trials{k,f}.Fail_FPend(i,1)));
                else
                    continue
                end
                
                MaxTL = max(MaxTrialLength);
                if SlideWin == 1
                    NumWindows = floor((MaxTL)/WinStep_ms);
                else
                    NumWindows = 1;
                end
                
                for bin = 1:NumWindows%length(KernelSize) %This loop is for calculating corr across sliding window
                    % Bin spikes by trial
                    % Skip trials where the binning window goes past the
                    % length of the trial itself
                    tend = [(SpikeStartTime-SpikeWin)-(bin-1)*SpikeStep+.001:.001:SpikeStartTime-(bin-1)*SpikeStep];
                    FP_Trial_timeIndex_end = (bin-1)*WinStep_ms;
                    
                    if length(Trials{k,f}.FPend{i,1}) <= (FPStartIndex + FP_Trial_timeIndex_end + CorrWindow)
                        continue
                    end
                    if Trials{k,f}.TTT(i) > TimeThres
                        continue
                    end
                    try
                        SpikeCountsTempEnd(TrialInd,:) = train2bins(Trials{k,f}.tsend(1,i).times,tend);
                        SpikeRatesByTrialEnd(TrialInd,:) = train2cont(SpikeCountsTempEnd(TrialInd,:),KernelSize);
                        
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
                            fpByTrialEnd(TrialInd,:,C) = Trials{k,f}.FPend{i,C}(end-FPStartIndex-CorrWindow-FP_Trial_timeIndex_end+1:end-FPStartIndex-FP_Trial_timeIndex_end);
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
                            
                            if C == 1
                                tmp=TrialsRawFP{k,f}.FPend{i,C}(end-FPStartIndex-CorrWindow-FP_Trial_timeIndex_end+1:end-FPStartIndex-FP_Trial_timeIndex_end);    %Make tmp samples X channels
                                tmp=win.*tmp;
      
                                tfmatByTrialEnd(TrialInd,:) = fft(tmp);
                                
                                % Remove DC component, multiply by
                                % conjugate to get power
                                fpSpectByTrialEnd(TrialInd,:) = log( tfmatByTrialEnd(TrialInd,2:length(freqs)).* conj(tfmatByTrialEnd(TrialInd,2:length(freqs))));
                                % Consider subtracting the mean from the
                                %                                 Pmean=mean(Pmat,3); %take mean over all times
                                %                                 PA=10.*(log10(Pmat)-repmat(log10(Pmean),[1,1,numbins]));
                            end
                        else
                            continue
                        end
                        
                        
                    end
                    TrialInd = TrialInd + 1;
                end
            end
        end
        
        LG = (freqs>30)&(freqs<=44);
        HG3 = (freqs>200)&(freqs<=300);
        if LG_Phase == 1
            FB = LG;
            FreqBand = 'Low Gamma';
            FreqBandPhases = fpByTrialEnd(:,:,1);
        else
            FB = HG3
            FreqBand = '200-300 Hz';
            FreqBandPhases = fpByTrialEnd(:,:,3);
        end
        FB_Pow = fpSpectByTrialEnd(:,FB);
        AvgFB_Pow = mean(FB_Pow,2);
        
        
        FreqBandPhases(SpikeCountsTempEnd==0) = nan;
        Spike_FreqBandPhases = [FreqBandPhases AvgFB_Pow];
        clear FreqBandPhases
        
        Spike_FreqBandPhases = sortrows(Spike_FreqBandPhases,-size(Spike_FreqBandPhases,2));
        AvgFB_PowSORT = Spike_FreqBandPhases(:,end);
        Spike_FreqBandPhases = Spike_FreqBandPhases(:,1:end-1);
        
        % Power Level Step - step for power increments
        PLS = floor(size(Spike_FreqBandPhases,1)/5);
        
        for p = 1:5
            Spike_FBPh_temp = Spike_FreqBandPhases((p-1)*PLS+1:PLS*p,:);
            AvgFB_PowLvls(p) = mean(AvgFB_PowSORT((p-1)*PLS+1:PLS*p))
            SpikeFBPhases_PowLvls{p} = Spike_FBPh_temp(isnan(Spike_FBPh_temp)==0);
        end
        
        PLI = zeros(5,10000);
        tic
        for a = 1:5
            for r = 1:10000
                ri = randi(size(SpikeFBPhases_PowLvls{a},1),100,1);
                for n = 1:100
                    PLI(a,r) = PLI(a,r) + exp(1i*SpikeFBPhases_PowLvls{a}(ri(n)));
                end
                PLI(a,r) = abs(PLI(a,r))*.01;
                clear ri
            end
        end
        toc
        
        NumSpikePerPowLvl = cellfun(@length,SpikeFBPhases_PowLvls);
        PLI_Pow{1,f} = [real(mean(PLI,2))' AvgFB_PowLvls];
        
        
    end
    
    
end

figure
[hAx,hLine1,hLine2] = plotyy([1:5],real(mean(PLI,2))',[1:5],NumSpikePerPowLvl)
title([sprintf('%s',FileList{1}),' Ch ',sprintf('%d',ControlCh),' Phase Locking'])
ylabel(hAx(1),[sprintf('%s',FreqBand),' Locking Index'])
ylabel(hAx(2),'Total # Spikes in pow lvl')
xlabel(['Average ',sprintf('%s',FreqBand),' Power'])
set(hAx(1),'Xtick',[1,2,3,4,5],'XTicklabel',{sprintf('%2.1f',AvgFB_PowLvls(1))...
    sprintf('%2.1f',AvgFB_PowLvls(2)),sprintf('%2.1f',AvgFB_PowLvls(3)),...
    sprintf('%2.1f',AvgFB_PowLvls(4)),sprintf('%2.1f',AvgFB_PowLvls(5))})
set(hAx(2),'Xtick',[1,2,3,4,5],'XTicklabel',{sprintf('%2.1f',AvgFB_PowLvls(1))...
    sprintf('%2.1f',AvgFB_PowLvls(2)),sprintf('%2.1f',AvgFB_PowLvls(3)),...
    sprintf('%2.1f',AvgFB_PowLvls(4)),sprintf('%2.1f',AvgFB_PowLvls(5))})
beep
keyboard
