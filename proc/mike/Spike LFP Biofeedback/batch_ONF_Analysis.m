%% ONF Physiology and Kinematics Analysis
monkey_name = 'Chewie';
FileList = Chewie_U10_SpikeX_Gam3Y_Ch42;
% HC_I = [1:21];
% BC_1DG = [23:25];
% BC_1DSp = [26:28];
BC_I = [1:73];
ControlCh = 42;

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

%% Create the ONF trial format that parses all of the data
CreateONF_TrialFormat
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
