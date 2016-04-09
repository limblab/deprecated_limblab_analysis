
%% Consider making these variables inputs to the function
binsize = .05;
wsz = 256;
samplerate = 1000;
pri = 1;
fi =1;
ind = 1;

numlags  = 1; % Number of lags used online
Offlinelags = 1; % Number of lags to use offline
numsides = 1;
lambda   = 1;
binsamprate = floor(1/binsize);
numfp = 1;
folds = 10;

% FileList = {Mini_Spike_LFPL_06092014006};
bandstarts = [30, 130, 200];
bandends   = [50, 200, 300];

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
    % Robert's fpassign puts NaNs in the matrix and this throws everything
    % off, remove them here.
    fp(isnan(fp)==1)= 0;
    [b,a]=butter(2,[58 62]/(samprate/2),'stop');
    fpf=filtfilt(b,a,fp')';
    
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
end
%% Now calculate PLI across whole file
% FP_Trial_timeIndex_start = [1750:2250];
% FP_Trial_timeIndex_MV = [1750:2250];
samprate = 1000;
KernelSize = 20;

SlideWin = 1;
SpikeWin = .5;
SpikeStep = .5;
% SpikeStartTime = 2;
% FPStartIndex = 0; % Since FPs include 2 seconds after reward, 2000 needs to be subtracted to start at reward
WinStep_ms = 500; % in ms

CorrWindow = 500;
% Create hanning window for fft
win=repmat(hanning(CorrWindow),1,numfp); %Put in matrix for multiplication compatibility
freqs=linspace(0,samprate/2,CorrWindow/2+1); % Frequencies calculated in fft
freqs=freqs(2:end);

ErrI = 1;
TimeThres = 30; % This is a threshold for what trial lengths will be considered when calculating the correlation
% % Flags
flag_EvalRbyTarg = 0;
flag_HCcorr = 0;

TrialInd = 1;
NumWindows = floor(size(fp,2)/WinStep_ms);

FPstartTime = fptimes(1); % Need this in order to properly index the FPs,
% since FP recording doesn't start exactly at 0, they are slightly offset
% with respect to spikes and this corrects for that offset when indexing
% the fp, fpf etc. matrices.

for bin = 1:NumWindows%length(KernelSize) %This loop is for calculating corr across sliding window
    % Bin spikes by trial
    % Skip trials where the binning window goes past the
    % length of the trial itself
    tend = 0.05+[(bin-1)*SpikeStep+.001:.001:(bin)*SpikeStep];
    FP_Trial_timeIndex_end = 50+(bin-1)*WinStep_ms-round(FPstartTime*1000);
    if length(fp) <= FP_Trial_timeIndex_end + CorrWindow
        continue
    end
    
    try
        SpikeCountsTempEnd(TrialInd,:) = train2bins(tsFPorder{ControlCh},tend);
        SpikeRatesByTrialEnd(TrialInd,:) = train2cont(SpikeCountsTempEnd(TrialInd,:),KernelSize);
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
    for C = 1:size(BPh,3)
        if isempty(BPh) == 0
            fpByTrialEnd(TrialInd,:,C) = BPh(FP_Trial_timeIndex_end+1:FP_Trial_timeIndex_end+CorrWindow,ControlCh,1);
            
            if C == 1
                tmp=fpf(ControlCh,FP_Trial_timeIndex_end+1:FP_Trial_timeIndex_end+CorrWindow)';    %Make tmp samples X channels
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

LG = (freqs>30)&(freqs<=44);
HG3 = (freqs>200)&(freqs<=300);
if LG_Phase == 1
    FB = LG;
    FreqBand = 'Low Gamma';
else
    FB = HG3
    FreqBand = '200-300 Hz';
end
FB_Pow = fpSpectByTrialEnd(:,FB);
AvgFB_Pow = mean(FB_Pow,2);

FreqBandPhases = fpByTrialEnd(:,:,1);
FreqBandPhases(SpikeCountsTempEnd==0) = nan;
Spike_FreqBandPhases = [FreqBandPhases AvgFB_Pow];
clear FreqBandPhases

Spike_FreqBandPhases = sortrows(Spike_FreqBandPhases,size(Spike_FreqBandPhases,2));
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
    if isempty(SpikeFBPhases_PowLvls{a})
        continue
    end
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

figure
[hAx,hLine1,hLine2] =plotyy([1:5],real(mean(PLI,2))',[1:5],NumSpikePerPowLvl)
title([sprintf('%s',FileList{1}),' Ch ',sprintf('%d',ControlCh),' Spike-',sprintf('%s',FreqBand),' Phase Locking'])
ylabel(hAx(1),'Phase Locking Index')
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
