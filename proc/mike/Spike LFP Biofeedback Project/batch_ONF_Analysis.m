%% ONF Physiology and Kinematics Analysis
monkey_name = 'Mini';
FileList = {'Mini_Spike_LFPL_05012013003'};

%% File Index for each type of file
HC_I = [1];
BC_1DG = [1];
BC_1DSp = [1];
BC_I = [1];
ControlCh = 91;

%% Use these vars for phase locking index calc
% If you want to calculate Phase locking index
PhasorOn = 1;

% 1 If you want to calculate PLI on parsed trials
% 0 if you want to calculate PLI on whole file
Parsed = 1;

% 1 If you want to calculate LG PLI
% 0 if you want to calculate 200-300 Hz PLI
LG_Phase = 0;

%% Use these vars if you want to split up files in to segments
segment = 0;
whole = 1;
WinLen = 300; % in seconds
overlap = 60; % in sec
segInd = 1;
flag_LGHG = 0;
flag_SpHG = 1;

%% Use these vars to adjust the correlations of the signals for BC
% simulation
AdjustCorr = 0;
RunSim = 0;
IncCorr = [0.1: .1: 1];
DecCorr = [0.1: .1: 1];
iters = 30;
ACFInd =  1; % using this to properly index files in AdjustCorr_bdf struct

% Need this because the scaling is off with Mini's
% decoder
% H_temp(:,1) = H(:,1) * 4;
% H_temp(:,2) = H(:,2) * 40;

%% Variable for processing fps (CreateONF_TrialFormat)
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
numfp = 96;
folds = 10;

bandstarts = [30, 130, 200];
bandends   = [50, 200, 300];

%% Create the ONF trial format that parses all of the data
if PhasorOn == 1 && Parsed == 0
    Calc_PLI_by_wholeFileFP
else
    CreateONF_TrialFormat
end
% Rename Trials and AvgCorr variables here if doing multiple types of
% data segmentation
% Trials = [];
% AvgCorr = [];

% Added this as a simple way to index correlation adjustment iterations
if AdjustCorr == 1
    ControlCh = 1:length(IncCorr)+length(DecCorr);
    BC_I = 1:nnz(~cellfun(@isempty,Trials(1,:))); % set index to appropriate length
end
%% Run simulations
if RunSim == 1
    for q = 1:size(CorrAdj_bdf,2)
        for iter = 1:iters
            for ci = 1:length(ControlCh)
                ci
                iter
                [Task{ci,iter,q}]= reconstruct_CenterOut_TaskPerformance(CorrAdj_bdf{ci,q},0,0);
            end
        end
    end
end
%% Calculate Phase locking index
if PhasorOn == 1
    [PLI] = Calc_PLI_by_FP(FileList, Trials, TrialsRawFP, ControlCh, numfp,...
        HC_I, BC_I, BC_1DG, BC_1DSp, flag_SpHG, flag_LGHG, LG_Phase, monkey_name)
else
    %% Calculate correlations among signals of interest
    [AvgCorr, Exceptions] = BinAndOrganizeSpikesAndFPsByTrial(Trials, ControlCh, HC_I, BC_I,...
        BC_1DG, BC_1DSp, flag_SpHG, flag_LGHG, monkey_name, AdjustCorr, IncCorr, DecCorr, iters)
    %% Aggregate and plot time to targets
    [meanTTT steTTT] = plotTTT(HC_I, BC_I, ControlCh, flag_SpHG, flag_LGHG,...
        Trials, AvgCorr, FileList, segment, whole, WinLen, overlap, monkey_name,Num)
    %% Plot cursor paths
    plotCursorPaths(HC_I, BC_I, ControlCh, flag_SpHG, flag_LGHG, Trials,...
        meanTTT, steTTT, segment)
    %% Calculate and plot cursor paths
    plotPathLength(HC_I, BC_I, ControlCh, flag_SpHG, flag_LGHG, Trials, AvgCorr,...
        FileList, segment, monkey_name)
end