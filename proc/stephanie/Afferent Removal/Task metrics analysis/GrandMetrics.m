% Grand Metrics

% This piece of code gives the task metrics for the isometric wrist flexion
% task for the afferent removal project. Written by SNN | August 2012

% Center of the target
% Percentage of successful trials
% Time2Target
% Angles
% Path length

%--------------------------------------------------------------------------

% Initialize Variables
[out_struct Goodtrialtable xCenter yCenter GoCueIndex EndTrialIndex] = Initializations(out_struct);
 

%plotmin = 1; plotmax = 54;
%Plot Paths from go cue to the start of the hold period
%PlotTruncatedPaths(out_struct, plotmin, plotmax)

% Put data into a struct
IsoTaskMetrics.PercentofSuccessfulTrials =  TrialSuccessPercentage(out_struct);
IsoTaskMetrics.Time2Target = ComputeTime2Target(out_struct);
IsoTaskMetrics.PathLength = ComputePathLength(out_struct);
IsoTaskMetrics.AngleError = ComputeAngleError(out_struct);
IsoTaskMetrics.File_Info = out_struct.meta;

% Boxplots
PlotIsoMetrics(IsoTaskMetrics)


