%% prep
close all;
clear;
clc;

paramSetName = 'standard';
saveDir = 'F:\fr_results';
doParsing = false;
arrays = {'M1','PMd'}; % Monkey sessions are filtered by array

root_dir = 'F:\';

useMonkeys = {'Chewie','Mihili','MrT'};
usePerts = {'VR','FF'}; % which perturbations
useTasks = {'CO'}; % CO/RT here.
epochs = {'BL','AD','WO'};


% Now list the files to consider
dataSummary;

for iArray = 1:length(arrays)
    useArray = arrays{iArray};
    
    switch lower(useArray)
        case 'm1'
            allFiles = sessionList(strcmpi(sessionList(:,1),'Mihili') | strcmpi(sessionList(:,1),'Chewie'),:);
        case 'pmd'
            allFiles = sessionList(strcmpi(sessionList(:,1),'Mihili') | strcmpi(sessionList(:,1),'MrT'),:);
    end
    
    % Filter the files based on the tasks/monkeys/perturbations above
    dateInds = ismember(allFiles(:,1),useMonkeys) & ismember(allFiles(:,3),usePerts) & ismember(allFiles(:,4),useTasks);
    doFiles = allFiles(dateInds,:);
    
    dateInds = strcmpi(doFiles(:,4),'CO');
    doFiles = doFiles(dateInds,:);
    
    clear dateInds;
    
    
    if doParsing
        window = [0.7,0.7];
        glmWindow = [1,1];
        binSize = 0.001;
        
        % [ target angle, on_time, go cue, move_time, peak_time, end_time, ]
        alignInds = [2,3,4,6]; % all indices to align on for raster purposes
        glmAlign = [2,4]; % which indices to align on for GLM
        tuningBlocks = {[0 1],[0 0.5 1],[0.2 1]};
        
        % Which bins to average over, [event,start,stop] relative to each event
        % binRange = [1,0,30; ... 1
        %     1,10,40; ... 2
        %     1,20,50; ... 3
        %     2,-70,-40; ... 4
        %     2,-60,-30; ... 5
        %     2,-50,-20; ... 6
        %     2,-40,-10; ... 7
        %     2,-30,0; ... 8
        %     2,-20,10; ... 9
        %     2,-10,20]; % 10
        
        binRange = [1,0,30; ... 1
            1,5,35; ... 2
            1,10,40; ... 3
            1,15,45; ... 4
            1,20,50; ... 5
            2,-70,-40; ... 6
            2,-65,-35; ... 7
            2,-60,-30; ... 8
            2,-55,-25; ... 9
            2,-50,-20; ... 10
            2,-45,-15; ... 11
            2,-40,-10; ... 12
            2,-35,-5; ... 13
            2,-30,0; ... 14
            2,-25,5; ... 15
            2,-20,10; ... 16
            2,-15,15; ... 17
            2,-10,20]; % 18
        
        numBootIters = 1000;
        bootConfLevel = 0.95;
        
        
        % Parse apart the files
        compareEpochRasters_fileParse2;
        
    else
        load(fullfile(saveDir,paramSetName,[useArray '_otherVars.mat']));
    end
end

%% Do cosine fitting
compareEpochRasters_doCos2;

%% Do GLM fit for each cell
%   We have firing rate in small bins for each trial, as well as the time of each alignment event
% % compareEpochRasters_doGLM;

%% Do some PCA trajectory plotting
% % compareEpochRasters_doPCA;

%%
doCos = 1;
doGLM = 0;

dataSummary;

minR2_cos = 0.2;
sigAng = 40;
minFR = 3;
doAbs = false;
doMD = false;
useArray = 'M1';
usePert = 'VR';
useMonkeys = {'Mihili'};
anovaAlpha = 0.1;

doFiles = sessionList(strcmpi(sessionList(:,4),'CO'),:);

plotFiles = find( strcmpi(doFiles(:,3),usePert) & ismember(doFiles(:,1),useMonkeys) );
% plotFiles = plotFiles(7:end); % to get rid of Chewie's early data for FF

useBins = 1:18; % for cosine only for now
sigBlocks = [1,2,3,4];
eComp = [1 3]; %which epochs to compare
% plotLabels = {'Vis','Vis','Plan','Plan','Plan','Plan','Plan','Move','Move','Move'};
plotLabels = {'V','V','V','V','V','P','P','P','P','P','P','P','M','M','M','M','M','M'};

compareEpochRasters_reorganize2;

%% Make some plots for cosine stuff
compareEpochRasters_plotCos;

%%
useBins = 1:18;
% useBins = 1:9;
compBlocks = [1,2,3,4];
doNonParametricFR = true;
useMaxFR = false; % for alignment. Otherwise, PD

compareEpochRasters_plotFRs;

%% plot raster for each direction for each cell
close all;

plotPositions = [17,23,19,15,9,3,7,11];
plotGap = 0.1;
useBlocks = [1,3];
useBlocksTune = [1 3];
useBinsTune = [3 17];
useAligns = [1,2];
saveFiles = false;

minR2_glm = 0.1;
minR2_cos = 0.1;
binSize = 0.025;

iFile = 22;
% load parsed file for this day
load(fullfile(saveDir,paramSetName,'data',[useArray '_' doFiles{iFile,1} '_' doFiles{iFile,2} '.mat']),'spikes');

compareEpochRasters_plotRasters2;

