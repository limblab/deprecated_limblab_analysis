%% ONF Physiology and Kinematics Analysis
monkey_name = 'Mini';
FileList = Mini_U41_SpikeX_Ch73_Gam3Y; 
 HC_I = [1];
 BC_1DG = [1];
 BC_1DSp = [1];
BC_I = [28:45];
ControlCh = 73;

% Use these vars if you want to split up files in to segments
segment = 0;
whole = 0;
WinLen = 300; % in seconds
overlap = 60; % in sec
segInd = 1;
flag_LGHG = 0;
flag_Sp_HG = 1;

%% Create the ONF trial format that parses all of the data
CreateONF_TrialFormat
% Rename Trials and AvgCorr variables here if doing multiple types of
% data segmentation
% Trials = [];
% AvgCorr = [];

%% Calculate correlations among signals of interest
AvgCorr = BinAndOrganizeSpikesAndFPsByTrial(Trials, ControlCh, HC_I, BC_I,...
    BC_1DG, BC_1DSp, flag_SpHG, flag_LGHG, monkey_name)

%% Aggregate and plot time to targets
[meanTTT steTTT] = plotTTT(HC_I, BC_I, ControlCh, flag_SpHG, flag_LGHG,...
    Trials, AvgCorr, FileList, segment, whole, WinLen, overlap, monkey_name)

%% Plot cursor paths
plotCursorPaths(HC_I, BC_I, ControlCh, flag_SpHG, flag_LGHG, Trials,...
    meanTTT, steTTT, segment) 

%% Calculate and plot cursor paths
plotPathLength(HC_I, BC_I, ControlCh, flag_SpHG, flag_LGHG, Trials, ...
    FileList, segment, monkey_name)
