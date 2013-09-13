function html = makeSummaryReport(expParamFile,useUnsorted,html)
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
tuningPeriods = {'initial','peak','full'};
tuningPeriods = {'peak'};
tuningMethods = {'regression','nonparametric'};
sigMethod = 'regression'; %what tuning method to look for for significance

imgWidth = 300; %pixels
cssLoc = 'Z:\MrT_9I4\Matt\mainstyle.css';
tableColors = {'#ff55ff','#55ffff','#ffff55','#55aaaa','#eeee77','#cccccc'};
classNames = {'kinematic','dynamic','memory I','memory II','other'};

newHTML = false;
if nargin < 3
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
paramFile = fullfile(baseDir, useDate, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
confLevel = str2double(params.confidence_level{1});
ciSig = str2double(params.ci_significance{1});
minFR = str2double(params.minimum_firing_rate{1});
clear params;

dataPath = fullfile(baseDir,useDate);
figPath = fullfile(dataPath,'figs');

dataFiles = cell(size(epochs));
for iEpoch = 1:length(epochs)
    dataFiles{iEpoch} = fullfile(dataPath,[taskType '_' adaptType '_' epochs{iEpoch} '_' useDate '.mat']);
end

if ~useUnsorted
    tuningFile = fullfile(dataPath,[taskType '_' adaptType '_tuning_' useDate '.mat']);
    load(tuningFile);
    t = tuning;
    clear tuning;
    
    % load the classification information
    load(fullfile(dataPath,[taskType '_' adaptType '_classes_' useDate '.mat']));
    
    % load neuron tracking data
    load(fullfile(dataPath,[taskType '_' adaptType '_tracking_' useDate '.mat']));
end

% load data for each epoch
disp('Loading data...')
for iEpoch = 1:length(epochs)
    load(dataFiles{iEpoch});
    d.(epochs{iEpoch}) = data;
    clear data;
end

disp('Done. Writing html...')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(tuningPeriods) || ~exist('tuningPeriods','var')
    tuningMethods = fieldnames(classes.(arrays{1}));
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


%% Write meta data
if newHTML
    html = strcat(html,['<html><head><title>' useDate '&nbsp; &nbsp;' taskType '&nbsp; &nbsp;' adaptType '</title><link rel="stylesheet" href="' cssLoc '" /></head><body>']);
end

html = strcat(html,['<div id="header"><h1>Data Summary:&nbsp;' monkey '&nbsp; | &nbsp' cell2mat(arrays) '&nbsp; | &nbsp' useDate '&nbsp; | &nbsp;' taskType '&nbsp; | &nbsp;' adaptType '</h1><hr></div>']);

%% Make table of contents links
report_tableOfContents;

%% Make summary, maybe with memory cells and stuff? link to the cell then
report_summary;

%% Make plot showing adaptation/deadaptation over time
report_adaptation;

%% Plot things for CO adaptation (pinwheel traces, etc)
if strcmpi(taskType,'CO')
    report_CO;
end

%% Make plot showing forces check out
if strcmpi(adaptType,'FF')
    report_forces;
end

%% Make plots of behavior metrics
report_behaviorMetrics;

%% Add a list of tuned cells with their classification
if ~useUnsorted
    report_classification;
end

if ~useUnsorted
    report_pdChanges;
end

%% Print out data for units
if ~useUnsorted
    report_units;
end

%% close up shop
if newHTML
    html = strcat(html,'</body></html>');
    
    if ~useUnsorted
        fn = fullfile(dataPath, [useDate '_summary_report.html']);
    else
        fn = fullfile(dataPath, [useDate '_unsorted_summary_report.html']);
    end
    
    fid = fopen(fn,'w+');
    fprintf(fid,'%s',html);
end