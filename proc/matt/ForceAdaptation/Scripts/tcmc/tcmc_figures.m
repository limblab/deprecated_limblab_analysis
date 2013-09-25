% code to throw some figures together for TCMC
%%
clear;
close all;
clc;

% pds are calculated wrt hand motion
% in vr, i do nothing to directly change that at first
% but monkey with adaptation learns to compensate for that
% 
% in ff, perturbation instantly changes relationship between discharge and direction and hand motion
% thus get immediate change in PD that goes away as monkey adapts
% 
% most neurons thus are kinematic, relating discharge to direction of motion

baseDir = 'Z:\MrT_9I4\Matt\ProcessedData';

ffColor = 'b';
vrColor = 'r';

outTargColor = [0.7 0 0];
inTargColor = [0 0.7 0];

xoffset = 5;
yoffset = -35;

%%
plotRTTraceExample;

%%
plotCOTraceExample;

%%
plotPinwheelsFFVR;

%%
plotExampleTuningWindow;

%%
plotExampleTuningCurve;

%%
plotPDChangeSummary

%%
plotCurvatureOverTime;

%%
plotEpochFR;

%%
plotEpochFRIndex;

%%
plotArrayMapWithClasses;

%%
plotExampleForceAndRotation;

%%
% look at number of 
compareRTDayClassification;