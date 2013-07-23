function [pds,cis,sg,trialTable] = fitTuningCurves(filename,varargin)
% notes about inputs
% notes about outputs
% notes about providing M1 vs PMd files
%
%   varargin: specify more parameters as needed. Use a format
%               ...,'parameter_name',parameter_value,...
%       Options:
%           'trialtable': an existing trialtable... will not be overwritten
%           'tunetype': what part of each movement to use
%               Can be 'glm','pre','initial','peak','final'... (glm uses whole file)
%           'tunedir': 'targ' or 'move' (not relevant for glm)
%           'doplots': boolean to plot tuning in regressTuningCurves
%           'movetime': time for movement for regressTuningCurves
%           'sig': confidence level (default 0.95)
%           'numiters': number of bootstrapping iterations
%           'glmnumsamps': number of samples of bins to take in glm_bootstrap
%           'glmmodel': string for model to use (see glm_bootstrap.m)
%           'glmbin': size of bins for glm in msec
%       Note: can insert one cell array holding the above info as varargin

if nargin < 1
    error('must specify a filename')
end

%% Define parameters
% DEFAULT PARAMETERS
trialTable = [];
tuneType = 'glm';
tuneDir = 'move';
doPlots = false;
moveTime = 0.5; %seconds
sig = 0.95; %confidence interval
numIters = 500; %number iterations for bootstrapping
glmNumSamps = 15000; % number of samples to take for GLM bootstrapping
glmModel = 'posvel';
glmBin = 50; %ms

if length(varargin)==1
    %Then it is a cell containing the necessary info
    varargin = varargin{1};
end

% Overwrite from inputs if necessary
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'trialtable'
            trialTable = varargin{i+1};
        case 'tunetype'
            tuneType = varargin{i+1};
        case 'tunedir'
            tuneDir = varargin{i+1};
        case 'doplots'
            doPlots = varargin{i+1};
        case 'movetime'
            moveTime = varargin{i+1};
        case 'sig'
            sig = varargin{i+1};
        case 'numiters'
            numIters = varargin{i+1};
        case 'glmnumsamps'
            glmNumSamps = varargin{i+1};
        case 'glmmodel'
            glmModel = varargin{i+1};
        case 'glmbin'
            glmBin = varargin{i+1};
    end
end
%%%%%

%% Load data
% The PMd file may not have the kinematic data or target data
load(filename);
neural = out_struct.units;
sg = reshape([neural.id],2,length(neural))';

% We use 96 channel arrays so there should not be higher than 97
%  This is a hack to deal with a weird problem where seemingly meaningless
%  units were appended. Perhaps due to syncing?
goodCells = sg(:,1) < 97;
sg = sg(goodCells,:);
neural = neural(goodCells);

%% Now find the tuning
if strcmpi(tuneType,'glm') % use GLM for tuning
    [pds, ci_l, ci_h, moddepth] = glm_bootstrap(out_struct, 1, glmModel, numIters, glmNumSamps, glmBin);
    pds = pds(goodCells);
    ci_l = ci_l(goodCells);
    ci_h = ci_h(goodCells);
    mds = moddepth(goodCells);
    cis = [ci_l, ci_h];
    
    pds = pds.*180/pi;
    cis = cis.*180/pi;
    
else % use regression of cosines for tuning
    
    % Get the trial table if one is not provided. This only applies to CO task
    %   For RT, as of now, you must use GLM
    if isempty(trialTable)
        % exclude anticipated movements or outliers (Xiao et al 2006)
        %   Mr T moves real slowly...
        excludeTimeRange = [0.2 1.2];
        
        holdTime = 0.5; %used hold time in these trials
        
        % Angles of targets
        targAngs = [0, pi/4, pi/2, 3*pi/4, pi, -3*pi/4, -pi/2, -pi/4];
        
        
        % moveTime is for angle of movement... if positive, use initial
        % period... if negative, use final period of moveTime length... if
        % zero, use window around peak velocity. This is kind of a "hack"
        % solution but it's okay for now
        if strcmpi(tuneType,'peak') % use period around peak speed
            moveTime = 0;
        elseif strcmpi(tuneType,'initial') % use initial movement period
            %do nothing
        elseif strcmpi(tuneType,'final') % use final movement period
            moveTime = -moveTime;
        end
        
        trialTable = ff_trial_table(out_struct,targAngs,moveTime);
        %    1: Start time
        %    2: Target                  -- -1 for none
        %    3: OT on time
        %    4: Go cue
        %    5: Movement start time
        %    6: Peak speed time
        %    7: End of movement window (for pd purposes)
        %    8: Trial End time
        %    9: Angle of target
        %   10: Angle of movement
        
        % exclude anticipated movements or outliers
        moveTimes = trialTable(:,8)-trialTable(:,5)-holdTime;
        goodTrials = moveTimes >= excludeTimeRange(1) & moveTimes <= excludeTimeRange(2);
        trialTable = trialTable(goodTrials,:);
    else
        % for adaptation and washout, we want to ignore trials where the monkey
        % is adapting.
        %   Currently assume that this happens if a trialTable is passed in, and
        %   assume that I should exclude the first 30% of trials
        trialTable = trialTable(floor(0.3*size(trialTable,1)):end,:);
    end

    % % Plot force traces
    % figure;
    % for iTrial = 1:size(trialTable,1)
    %     hold all;
    %     useWin = [trialTable(iTrial,4), trialTable(iTrial,8)];
    %     idx = out_struct.pos(:,1) >= useWin(1) & out_struct.pos(:,1) < useWin(2);
    %     plot(out_struct.pos(idx,2),out_struct.pos(idx,3));
    % end
    
    % calculate the latencies
    % latency
    
    % Get spike count for each channel in each hold period
    spikeCounts = zeros(size(trialTable,1),length(neural));
    fr = zeros(size(trialTable,1),length(neural));
    for unit = 1:length(neural)
        ts = neural(unit).ts;
        for iTrial = 1:size(trialTable,1)
            
            % Time window for which to look for neural activity
            if strcmpi(tuneType,'peak') % Use 0.5 sec period around peak speed
                useWin = [trialTable(iTrial,6)-0.25, trialTable(iTrial,6)+0.25];
            elseif strcmpi(tuneType,'initial') %Use initial movement period
                useWin = [trialTable(iTrial,4), trialTable(iTrial,4)+moveTime];
            elseif strcmpi(tuneType,'final') % Use the final movement period
                useWin = [trialTable(iTrial,4), trialTable(iTrial,4)+moveTime];
            elseif strcmpi(tuneType,'pre') % Use pre-movement period
                useWin = [trialTable(iTrial,3), trialTable(iTrial,5)];
                moveTime = trialTable(iTrial,5)-trialTable(iTrial,3);
            end
            
            %   subtract the latency to account for transmission delays
            % DO THIS
            
            % how many spikes are in this window?
            spikeCounts(iTrial,unit) = length(ts(ts > useWin(1) & ts <= useWin(2) ));
            fr(iTrial,unit) = spikeCounts(iTrial,unit)./moveTime; % Compute a firing rate
        end
    end
    
    %%% Here is the data we need
    if strcmpi(tuneDir,'targ')    % Regress to target
        disp('Regressing to target direction')
        theta = trialTable(:,9); % Get angles at each trial's target ID
    else    % Regress to movement direction
        disp('Regressing to movement direction')
        theta = trialTable(:,10);
    end
    theta = wrapAngle(theta,0); % make sure it goes from [-pi,pi)
    
    % Do bootstrapping
    [tcs,cis] = regressTuningCurves(fr,theta,{'bootstrapping',numIters,sig},'doplots',doPlots);
    pds = tcs(:,3);
    mds = 2*tcs(:,2);
    % [pds,cis] = vectorSumPDs(fr,theta,{'none'},'doplots',doPlots);
end
