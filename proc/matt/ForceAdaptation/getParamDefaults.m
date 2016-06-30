function params = getParamDefaults()
% would be great to have proper database
%   - could load monkey info

%% basic parameters
params.dataRoot = '';       % root directory where all of the raw data is kept (usually on the server)
params.dataDir = '';        % sub directory where the raw data for the current analysis is kept
params.outDir = '';         % directory where the processed data and results are kept (usually on the local machine)
params.paramSetName = '';   % name for this parameter set. Blank by default, to be filled in later. Good for keeping track of results.

params.useUnsorted = false; % include unsorted waveforms?
params.MonkeyID = 0;        % ID for animal-specific parameters. Default to 0, set later. 1=MrT, 2=Chewie, 3=Mihili

params.useTasks = {'CO','RT','FF','VR','CS'};       % some analysis methods only work on specific tasks (ie CO or RT, FF or VR)

%% showing behavioral adaptation
params.behavior.adaptationMetrics = {'angle_error', 'time_to_target', 'curvature'};
params.behavior.movementThreshold = 1.5; % threshold in cm/s for identifying movement onset
params.behavior.windowSize = 0.4;        % size of time window for doing adaptation
params.behavior.behaviorWindow = 1;      % number of trials in window for sliding average to smooth adaptation
params.behavior.behaviorStep = 1;        % number of trials to move with each step when smoothing adaptation metrics
params.behavior.filterWidth = 150;       % width of filter in msec to smooth out velocity

%% animal-specific trial filtration
%                                 MrT  Chewie  Mihili
params.trials.min_reactionTime = [0.03 , -1  , 0.05 ]; % minimum reaction time for each included trial
params.trials.max_reactionTime = [0.6  , -1  , 0.5  ]; % maximum reaction time
params.trials.min_time2target =  [0.2  , 0.2 , 0.2  ]; % minimum time to target
params.trials.max_time2target =  [1.2  , 1   , 1.2  ]; % maximum time to target
params.trials.min_time2peak =    [0.05 , 0.1 , 0.1  ]; % minimum time to peak speed
params.trials.max_time2peak =    [0.9  , 0.8 , 0.8  ]; % maximum time to peak speed
% give each monkey a unique MonkeyID to index monkey-specific parameters

%% tuning
params.tuning.tuningPeriods = {'onpeak'};       % what movement periods to use (see code for details)
params.tuning.tuningMethods = {'regression'};   % what tuning methods to use ('regression','glm','nonparametric'... 'vectorsum' not fully implemented yet)
params.tuning.tuningCoordinates = {'movement'}; % what coordinate systems to use ('target' or 'movement')

params.tuning.confidenceLevel = 0.95;               % confidence level for statistical tests
params.tuning.movementTime = 0.3;                   % size of movement bin for fixed-width movement periods (not relevant for periods like 'onpeak','full',etc
params.tuning.binAngles = true;                     % bin the movements when using movement direction?
params.tuning.angleBinSize = 0.7854;                % size of the bins for binning movements (must be 2pi divided by some integer)
params.tuning.blocks = {[0 1], ...                  % for breaking up BL/AD/WO files into multiple blocks, can be fraction (e.g. [0 0.25]) or number of trials (e.g. [1 100])
                        [0 0.33 0.66 1], ...        %    it's a cell array, each element corresponds to one of the epochs, in order
                        [0 0.33 0.66 1]};           %    so typically first is Baseline, second is Adaptation, third is Washout

params.tuning.m1_latency = 0.1;  % offset for M1 activity to movement
params.tuning.pmd_latency = 0.1; % offset for PMd activity to movement

params.tuning.tuningStatTest = 'bootstrap'; % what test to use for regression... 'bootstrap','regression','none'
params.tuning.numberBootIterations = 1000;  % how many iterations for bootstrapping
params.tuning.includeSpeed = false;         % include speed in tuning model (a la Moran/Schwartz 1999)?
params.tuning.doRandSubset = false;         % use a random subset of datapoints
params.tuning.numResamples = 100;           % how many resamples for random subset
params.tuning.numSamples = 32;              % how many data samples to use for each subset
params.tuning.divideTime = [0.3 0.05];      % for sliding window over course of CO movements... first number is fraction of total movement time for each bin, second number is how much to slide window
params.tuning.timeDelay = 0;     % amount of time to wait after go cue, or for sliding window analysis

params.tuning.glmModel = 'posvel';     % what model (stitch together as string). Options: 'pos','vel','force'. See code for more.
params.tuning.glmBinSize = 50;         % bin size in msec for GLM firing rates
params.tuning.glmRandomSample = false; % randomly sample data bins for GLM?
params.tuning.doGLMType = 'fit';       % how to get GLM confidence... 'fit' uses confidence from Matlab fit, 'subset' tries an empirical approach. See code for details.
    
%% cell classification
params.classes.sigCompareMethod = 'diff';  % which method to test significant differences... 'diff' compares bootstrapped difference between epochs, 'overlap' just looks at confidence bounds
params.classes.sigMethod = 'regression';   % which tuning method to use for cell significance
params.classes.classConfidenceLevel = 0.95;     % confidence level for statistical tests
params.classes.classifierBlocks = [1,4,7]; % which blocks to use for classification
params.classes.doBonferroni = false;       % do Bonferroni test during classification?
params.classes.numComparisons = 3;         % how many comparisons in Bonferroni
params.classes.doNoise = false;            % whether or not to add noise to boot PDs
params.classes.noiseVal = 0.12;            % amount of angular noise to add

%% cell tracking
params.tracking.trackingConfidenceLevel = 0.9;  % combined tracking level for cell tracking
params.tracking.criteria = {'wf','isi'}; % what to use for cell tracking. Will use all included. 'wf' for waveform, 'isi' for interspike interval

%% unit exclusion criteria
params.units.isiThreshold = 1.7;      % threshold for excluding multi-unit activity based on ISI (in milliseconds)
params.units.m1_isiPercent = 0.19;       % maximum percentage of ISI that is below threshold to be considered
params.units.pmd_isiPercent = 0.8;       % maximum percentage of ISI that is below threshold to be considered
params.units.waveformSNR = 3;         % minimum SNR for waveforms of well-tuned cells
params.units.m1_minFR = 1;            % minimum average firing rate for well-tuned cells
params.units.pmd_minFR = 1;           % minimum average firing rate for well-tuned cells
params.units.m1_r2Min = 0.5;          % the 95% confidence intervals for bootstrapped R2 must be above this number
params.units.pmd_r2Min = 0.2;         % the 95% confidence intervals for bootstrapped R2 must be above this number
params.units.ciSignificance = 0.6981; % maximum width of PD confidence interval to be "well-tuned"

%% report generation


%% plotting parameters
params.plotting.titleFontSize = 16; % font size for titles
params.plotting.labelFontSize = 14; % font size for labels

