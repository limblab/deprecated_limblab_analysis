% Buildi.ng a new wrapper function to do analysis scripts
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
%   6: ANOVA for firing rate
%   7: Behavioral adaptation
%   8: Cell classification summary
%   9: trial number
%  10: PD change periods for SfN
whichScript = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now a bunch of parameters and necessary info
root_dir = 'F:\';

useArray = 'M1'; % Monkey sessions are filtered by array
useMonkeys = {'Chewie','Mihili'};
usePerts = {'FF'}; % which perturbations
useTasks = {'CO'}; % CO/RT here.
useControl = false;
epochs = {'BL','AD','WO'};

% these are not relevant for scatter or over session, use struct below instead
paramSetName = 'movement';
tuneMethod = 'regression';
tuneWindow = 'onpeak';

classifierBlocks = [1 4 7];
whichBlock = 1; % if multiple classification block sets
whichTuned = 1:6; %which columns in istuned to use

% separate by waveform width (not all scripts support this)
%   0: don't do
%   1: use cells below median
%   2: use cells above median
%   3: use all but store widths
doWidthSeparation = 0;

% make all PD changes same direction regardless of perturbation direction
flipClockwisePerts = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% for scatter plots and over-session plots. Should have to entries for each category Note: can also do more than 2
% titles/metrics etc for the over-session script
sComp.titles  = {'CO', 'RT'};
sComp.metrics = {'PD', 'PD'};
sComp.epochs  = {'BL_AD', 'BL_WO'}; % only used for over-session
sComp.params  = {paramSetName, paramSetName};
sComp.methods = {tuneMethod, tuneMethod};
sComp.windows = {tuneWindow, tuneWindow};
sComp.arrays  = {useArray, useArray};
sComp.reassignOthers = true; % reassign "Other" type cell classes as Dynamic/Memory (only for scatter)
sComp.doAbs = false; %take absolute value of differences for each cell
sComp.doPercent = true; %whether to do MD/BO/FR as a percentage

%%%%%%%%%%%%%%%%%%%%%%%%%
% For sliding-window tuning in CO task and also slow/fast movements
slidingParams.metric = 'MD';
slidingParams.doAvg = true; % do average across sessions (mainly for group scatter plot)
slidingParams.useVel = false; % use velocity instead of measured force
slidingParams.useMasterTuned = true; % whether to use tuning from standard 'movement' tuning method to see which are "well-tuned"
slidingParams.doAbs = true; % take absolute of difference between epochs
slidingParams.doMD = true;
slidingParams.doMDNorm = true;
slidingParams.plotClasses = [1,2,3,4,5];

%%%%%%%%%%%%%%%%%%%%%%%%%
% For FR ANOVA analysis
franova.metric = 'errors';
franova.doPeakFRPlot = true;
franova.doBehaviorPlot = false;
franova.doAbs = false;
franova.pmax = 0.05;
franova.numBins = 3;

% Now list the files to consider
dataSummary;

if whichScript ~= 7 % for behavioral adaptation, doesn't matter what array
    switch lower(useArray)
        case 'm1'
            allFiles = sessionList(strcmpi(sessionList(:,1),'Mihili') | strcmpi(sessionList(:,1),'Chewie'),:);
        case 'pmd'
            allFiles = sessionList(strcmpi(sessionList(:,1),'Mihili') | strcmpi(sessionList(:,1),'MrT'),:);
    end
else
    allFiles = sessionList;
end

% Filter the files based on the tasks/monkeys/perturbations above
dateInds = ismember(allFiles(:,1),useMonkeys) & ismember(allFiles(:,3),usePerts) & ismember(allFiles(:,4),useTasks);
doFiles = allFiles(dateInds,:);

%%
% % % % outR1 = [];
% % % % outR2 = [];
% % % % outFR = [];
% % % % for i = [1,4,7]
% % % %     temp = [];
% % % %     temp1 = [];
% % % %     temp2 = [];
% % % %     for iFile = 1:size(doFiles,1)
% % % %         [tuning,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,'movement','regression','onpeak');
% % % %         
% % % %         temp = [temp; tuning(i).bos(:,1)];
% % % %         
% % % %         r=sort(tuning(i).r_squared,2);
% % % %         temp1 = [temp1; r(all(c.istuned(:,1:4),2),50)];
% % % %         
% % % %         theta = tuning(i).theta;
% % % %         utheta = unique(theta);
% % % %         fr = zeros(length(utheta),size(tuning(i).fr,2));
% % % %         for iDir = 1:length(utheta)
% % % %             fr(iDir,:) = mean(tuning(i).fr(theta==utheta(iDir),:),1);
% % % %         end
% % % %         
% % % %         fr = fr(:,all(c.istuned(:,1:4),2));
% % % %         
% % % %         %
% % % %         for unit = 1:size(fr,2)
% % % %             [~,~,~,~,s] = regress(fr(:,unit),[ones(size(utheta)) cos(utheta) sin(utheta)]);
% % % %             temp2 = [temp2; s(1)];
% % % %         end
% % % %     end
% % % %     outR1 = [outR1 temp1];
% % % %     outR2 = [outR2 temp2];
% % % %     outFR = [outFR temp];
% % % % end
% % % % 
% % % % outT = [];
% % % % for iFile = 1:size(doFiles,1)
% % % %     c = loadResults(root_dir,doFiles(iFile,:),'tuning',{'classes'},useArray,'movement','regression','onpeak');
% % % %     outT = [outT; c.istuned(all(c.istuned(:,1:4),2),5)];
% % % % end
% % % % 
% % % % outR1 = outR1(all(outT,2),:);
% % % % outR2 = outR2(all(outT,2),:);
% % % % outFR = outFR(all(outT,2),:);

%% Run the requested analysis
switch whichScript
    case 1 % scatter plot of any two parameters
        metricChangeScatterPlot;
        
    case 2 % bins of trials over sessions
        metricChangeOverSession;
        
    case 3 % different movement windows over CO movements
        % this one is hardcoded for time
        tuneWindow = 'time';
        paramSetName = 'moveTime';
        
        % only CO task
        dateInds = strcmpi(doFiles(:,4),'CO');
        doFiles = doFiles(dateInds,:);
        
        pdChangeOverMovement;
        
    case 4 % compare slow and fast movement changes
        % only RT task
        dateInds = strcmpi(doFiles(:,4),'RT');
        doFiles = doFiles(dateInds,:);
        
        pdChangeSlowVsFast;
        
    case 5 % histograms of values or changes in any parameter
        metricChangeHists;
        
    case 6 % firing rate with ANOVA
        % only CO task
        dateInds = strcmpi(doFiles(:,4),'CO');
        doFiles = doFiles(dateInds,:);
        
        frANOVA;
        
    case 7 % show behavioral adaptation
        makeAdaptationPlots3;%_firstlast;
        
    case 8 % make plots summarizing cell classifications
        investigateMemoryCells;
        
    case 9 % analyze number of trials for significance
        tuningConfidenceWithTrialNumber;
        
    case 10 % looking at PD changes in specific bins
        % only CO task
        dateInds = strcmpi(doFiles(:,4),'CO');
        doFiles = doFiles(dateInds,:);
        sfn_plot_pd_change_periods;
            case 11 % looking at PD changes in specific bins
        % only CO task
        dateInds = strcmpi(doFiles(:,4),'CO');
        doFiles = doFiles(dateInds,:);
        sfn_plot_tuning_changes;
end
