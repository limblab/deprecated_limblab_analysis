function html = makeSummaryReport(expParamFile,paramSetName,useUnsorted,html)
% NEURONREPORTS  Constructs html document to summarize a session's data
%
%   This function will load processed data and generate html for a summary
% report with data and figures.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   useUnsorted: (bool) will skip neuron stuff if file was not sorted
%   html: (string) can be used to stack up files
%
% OUTPUTS:
%   html: (string) giant piece of html code with everything included
%
% NOTES:
%   -This function requires several bits of pre-processing
%       1) Create a data struct from the Cerebus files (makeDataStruct)
%       2) Create adaptation metrics struct (getAdaptationMetrics)
%       3) Run empirical KS test to track stability of neurons (trackNeurons)
%       4) Fit tuning for neurons, regression and nonparametric recommended (fitTuningCurves)
%       5) Classify cells based on adaptation behavior (findMemoryCells)
%       6) Generate a variety of plots (makeFFPlots)
%   - This function will automatically write the html to a file, too
%   - See "experimental_parameters_doc.m" for documentation on expParamFile
%   - Analysis parameters file must exist (see "analysis_parameters_doc.m")

% set some parameters
tuningPeriods = '';
tuningMethods = {'regression','nonparametric'};
sigMethod = 'regression'; %what tuning method to look for for significance
adaptationMetric = 'angle_error';

imgWidth = 300; %pixels
cssLoc = 'Z:\MrT_9I4\Matt\mainstyle.css';
tableColors = {'#ff55ff','#55ffff','#ffff55','#55aaaa','#eeee77','#cccccc'};
classNames = {'non-adapting','adapting','memory I','memory II','other'};

newHTML = false;
if nargin < 4
    newHTML = true;
    html = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(expParamFile);
baseDir = params.out_dir{1};
useDate = params.date{1};
arrays = params.arrays;
monkey = params.monkey{1};
taskType = params.task{1};
adaptType = params.adaptation_type{1};
epochs = params.epochs;
forceMag = str2double(params.force_magnitude{1});
forceAng = str2double(params.force_angle{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load some more parameters
paramFile = fullfile(baseDir, useDate, paramSetName, [ useDate '_' paramSetName '_tuning_parameters.dat']);
params = parseExpParams(paramFile);
confLevel = str2double(params.confidence_level{1});
ciSig = str2double(params.ci_significance{1});
minFR = str2double(params.minimum_firing_rate{1});
clear params;

dataPath = fullfile(baseDir,useDate);
genFigPath = fullfile(dataPath,'general_figs');
figPath = fullfile(dataPath,paramSetName,'figs');

dataFiles = cell(size(epochs));
for iEpoch = 1:length(epochs)
    dataFiles{iEpoch} = fullfile(dataPath,[taskType '_' adaptType '_' epochs{iEpoch} '_' useDate '.mat']);
end

if ~useUnsorted
    tuningFile = fullfile(dataPath,paramSetName,[taskType '_' adaptType '_tuning_' useDate '.mat']);
    t = load(tuningFile);
    
    % load the classification information
    classes = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_classes_' useDate '.mat']));
    
    % load neuron tracking data
    tracking = load(fullfile(dataPath,[taskType '_' adaptType '_tracking_' useDate '.mat']));
end

% load data for each epoch
disp('Loading data...')
for iEpoch = 1:length(epochs)
    d.(epochs{iEpoch}) = load(dataFiles{iEpoch});
end

disp('Done. Writing html...')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(tuningMethods) || ~exist('tuningMethods','var')
    tuningMethods = fieldnames(classes.(arrays{1}));
end
if ~iscell(tuningMethods)
    tuningMethods = {tuningMethods};
end

% we don't really care about the nonparametric tuning atthis time
tuningMethods = setdiff(tuningMethods,'nonparametric');

if isempty(tuningMethods)
    error('Need to have at least one of glm/regression/vectorsum tuning to continue');
end

% if none are defined above, do them all
if isempty(tuningPeriods) || ~exist('tuningPeriods','var')
    tuningPeriods = fieldnames(classes.(arrays{1}).(tuningMethods{1}));
end
if ~iscell(tuningPeriods)
    tuningPeriods = {tuningPeriods};
end

%% Make parameter struct
%   Before writing more html, compile this info into a handy struct
p = struct('arrays',{arrays},'tuningPeriods',{tuningPeriods},'tuningMethods',{tuningMethods},'figPath',figPath,'genFigPath',genFigPath, 'sigMethod',sigMethod,'adaptationMetric',adaptationMetric, 'epochs', {epochs}, 'adaptType', adaptType, 'taskType', taskType, ...
           'forceMag',forceMag,'forceAng',forceAng,'confLevel',confLevel,'ciSig',ciSig,'minFR',minFR,'imgWidth',imgWidth,'tableColors',{tableColors},'classNames',{classNames},'useUnsorted',useUnsorted);
       
%% Write meta data
if newHTML
    html = strcat(html,['<html><head><title>' useDate '&nbsp; &nbsp;' taskType '&nbsp; &nbsp;' adaptType '&nbsp; &nbsp;' paramSetName '</title><link rel="stylesheet" href="' cssLoc '" /></head><body>']);
end

html = strcat(html,['<div id="header"><h1>Data Summary:&nbsp;' monkey '&nbsp; | &nbsp' cell2mat(arrays) '&nbsp; | &nbsp' useDate '&nbsp; | &nbsp;' taskType '&nbsp; | &nbsp;' adaptType '</h1><hr></div>']);


%% Make table of contents links
[html,uElecs,sg] = report_tableOfContents(html,d,tracking,p);

%% Make summary, maybe with memory cells and stuff? link to the cell then
html = report_summary(html,d,p);

%% Make plot showing adaptation/deadaptation over time
html = report_adaptation(html,p);

%% Plot things for CO adaptation (pinwheel traces, etc)
if strcmpi(taskType,'CO')
    html = report_CO(html,p);
end

%% Make plot showing forces check out
if strcmpi(adaptType,'FF')
    html = report_forces(html,p);
end

%% Make plots of behavior metrics
html = report_behaviorMetrics(html,p);

%% some neural stuff
if ~useUnsorted
    % Add a list of tuned cells with their classification
    html = report_classification(html,d,classes,tracking,p);

    % plots of pd changes
    html = report_pdChanges(html,p);

    % Print out data for units
    html = report_units(html,d,t,classes,tracking,uElecs,sg,p);
end

%% close up shop
if newHTML
    html = strcat(html,'</body></html>');
    
    if ~useUnsorted
        fn = fullfile(dataPath, paramSetName, [useDate '_' paramSetName '_summary_report.html']);
    else
        fn = fullfile(dataPath, paramSetName, [useDate '_' paramSetName '_unsorted_summary_report.html']);
    end
    
    fid = fopen(fn,'w+');
    fprintf(fid,'%s',html);
    fclose(fid);
end