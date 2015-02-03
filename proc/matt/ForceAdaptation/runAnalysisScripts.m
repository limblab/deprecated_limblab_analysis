% Building a new wrapper function to do analysis scripts
% TO DO:
%   - Scatter doesn't check that Movement/Target/etc have the same tuned cells

clear
clc
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select which analysis to run
% KEY:
%   1: Scatter plot
%   2: metric changes over session
%   3: metric changes over CO movement
%   4: metric changes for slow and fast RT movements
%   5: histogram of metric changes
%   6: ANOVA for metrics
whichScript = 6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Now a bunch of parameters and necessary info

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';

useArray = 'M1'; % Monkey sessions are filtered by array
useMonkeys = {'MrT','Chewie','Mihili'};
usePerts = {'FF'}; % which perturbations
useTasks = {'CO'}; % CO/RT here.

% these are not relevant for scatter or over session, use struct below instead
paramSetName = 'movement';
tuneMethod = 'regression';
tuneWindow = 'onpeak';

whichBlock = 1; % if multiple classification block sets

% separate by waveform width (not all scripts support this)
%   0: don't do
%   1: use cells below median
%   2: use cells above median
%   3: use all but store widths
doWidthSeparation = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% for scatter plots. Should have to entries for each category
scatterCompare.metrics = {'PD', 'PD'};
scatterCompare.epochs  = {'BL_AD', 'BL_WO'};
scatterCompare.params  = {'movement', 'movement'};
scatterCompare.methods = {'regression', 'regression'};
scatterCompare.windows = {'onpeak', 'onpeak'};
scatterCompare.arrays  = {useArray, useArray};
scatterCompare.reassignOthers = true; % reassign "Other" type cell classes as Dynamic/Memory

%%%%%%%%%%%%%%%%%%%%%%%%%%
% for over-session by trial blocks. Can have as many entries as you want,
% though it probably gets cluttered above 2
sessionCompare.titles  = {'Movement', 'Movement'};
sessionCompare.metrics = {'FR', 'MD'};
sessionCompare.params  = {'movement', 'movement'};
sessionCompare.methods = {'regression', 'regression'};
sessionCompare.windows = {'onpeak', 'onpeak'};
sessionCompare.arrays  = {useArray, useArray};
sessionCompare.doAbs = false; %take absolute value of differences for each cell

%%%%%%%%%%%%%%%%%%%%%%%%%
% For sliding-window tuning in CO task
slidingParams.doAvg = false; % do average across sessions (mainly for group scatter plot)
slidingParams.useVel = false; % use velocity instead of measured force
slidingParams.useMasterTuned = false; % whether to use tuning from standard 'movement' tuning method to see which are "well-tuned"
slidingParams.doAbs = true; % take absolute of difference between epochs      


%% Now list the files to consider
allFiles = {'MrT','2013-08-19','FF','CO'; ...   % S x
    'MrT','2013-08-20','FF','RT'; ...   % S x
    'MrT','2013-08-21','FF','CO'; ...   % S x - AD is split in two so use second but don't exclude trials
    'MrT','2013-08-22','FF','RT'; ...   % S x
    'MrT','2013-08-23','FF','CO'; ...   % S x
    'MrT','2013-08-30','FF','RT'; ...   % S x
    'MrT','2013-09-03','VR','CO'; ...   % S x
    'MrT','2013-09-04','VR','RT'; ...   % S x
    'MrT','2013-09-05','VR','CO'; ...   % S x
    'MrT','2013-09-06','VR','RT'; ...   % S x
    'MrT','2013-09-09','VR','CO'; ...   % S x
    'MrT','2013-09-10','VR','RT'; ...   % S x
    'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    %'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    %'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
    'Mihili','2014-03-03','VR','CO'; ...    %12 S(M-P)
    'Mihili','2014-03-04','VR','CO'; ...    %13 S(M-P)
    'Mihili','2014-03-06','VR','CO'; ...    %14 S(M-P)
    'Mihili','2014-03-07','FF','CO'; ...   % 15
    'Chewie','2013-10-03','VR','CO'; ... %16  S ?
    'Chewie','2013-10-09','VR','RT'; ... %17  S x
    'Chewie','2013-10-10','VR','RT'; ... %18  S ?
    'Chewie','2013-10-11','VR','RT'; ... %19  S x
    'Chewie','2013-10-22','FF','CO'; ... %20  S ?
    'Chewie','2013-10-23','FF','CO'; ... %21  S ?
    'Chewie','2013-10-28','FF','RT'; ... %22  S x
    'Chewie','2013-10-29','FF','RT'; ... %23  S x
    'Chewie','2013-10-31','FF','CO'; ... %24  S ?
    'Chewie','2013-11-01','FF','CO'; ... %25 S ?
    'Chewie','2013-12-03','FF','CO'; ... %26 S
    'Chewie','2013-12-04','FF','CO'; ... %27 S
    'Chewie','2013-12-09','FF','RT'; ... %28 S
    'Chewie','2013-12-10','FF','RT'; ... %29 S
    'Chewie','2013-12-12','VR','RT'; ... %30 S
    'Chewie','2013-12-13','VR','RT'; ... %31 S
    'Chewie','2013-12-17','FF','RT'; ... %32 S
    'Chewie','2013-12-18','FF','RT'; ... %33 S
    'Chewie','2013-12-19','VR','CO'; ... %34 S
    'Chewie','2013-12-20','VR','CO'};    %35 S

switch lower(useArray)
    case 'm1'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'Chewie'),:);
    case 'pmd'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'MrT'),:);
end

% Filter the files based on the tasks/monkeys/perturbations above
dateInds = ismember(allFiles(:,1),useMonkeys) & ismember(allFiles(:,3),usePerts) & ismember(allFiles(:,4),useTasks);
doFiles = allFiles(dateInds,:);

%% Run the requested analysis
switch whichScript
    case 1 % scatter plot of any two parameters
        metricChangeScatterPlot;
        
    case 2 % bins of trials over sessions
        metricChangeOverSession;
        
    case 3 % different movement windows over CO movements
        % this one is hardcoded for time
        tuneWindow = 'time';
        
        % only CO task
        dateInds = strcmpi(allFiles(:,4),'CO');
        doFiles = doFiles(dateInds,:);
        
        pdChangeOverMovement;
        
    case 4 % compare slow and fast movement changes
        % only RT task
        dateInds = strcmpi(allFiles(:,4),'RT');
        doFiles = doFiles(dateInds,:);
        
        pdChangeSlowVsFast;
        
    case 5 % histograms of values or changes in any parameter
        metricChangeHists;
        
    case 6 % firing rate with ANOVA
        frANOVA;
        
    case 7 % show behavioral adaptation
end
