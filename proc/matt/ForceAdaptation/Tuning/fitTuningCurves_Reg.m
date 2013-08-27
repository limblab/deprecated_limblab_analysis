function out = fitTuningCurves_Reg(data,tuningPeriod,tuningMethod,useArray,doPlots)
% notes about inputs
% notes about outputs
% can pass tuning method in as cell array with multiple types
%
% NOTE: right now, target direction or 'pre' window for movement don't work with RT

paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
binAngles = str2double(params.bin_angles{1});
excludeTrials = str2double(params.exclude_trials{1});
excludeFraction = str2double(params.exclude_fraction{1});
clear params;

if nargin < 4
    doPlots = false;
end

if ~iscell(tuningMethod)
    tuningMethod = {tuningMethod};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load all of the parameters
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
angleBinSize = str2double(params.angle_bin_size{1});
latency = str2double(params.([lower(useArray) '_latency']){1});
confLevel = str2double(params.confidence_level{1});
movementTime = str2double(params.movement_time{1});
bootNumIters = str2double(params.number_iterations{1});
tuneDir = params.tuning_direction{1};
temp = params.exclude_time_range;
excludeTimeRange = zeros(size(temp));
for i = 1:length(temp) % hack to make this work... do it better someday
    excludeTimeRange(i) = str2double(temp{i});
end
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp([tuningPeriod ' movement, ' num2str(movementTime) ' second window...']);

%% Get data
sg = data.(useArray).unit_guide;

% Get the movement table
mt = data.movements.movement_table;

% exclude anticipated movements or outliers (Xiao et al 2006)
moveTimes = mt(:,5) - mt(:,3);
goodTrials = moveTimes >= excludeTimeRange(1) & moveTimes <= excludeTimeRange(2);
mt = mt(goodTrials,:);

% for adaptation, exclude first set of trials
if excludeTrials && (strcmp(data.meta.epoch,'AD') || strcmp(data.meta.epoch,'WO'));
    % remove the first however many trials
    mt = mt(floor(excludeFraction*size(mt,1)):end,:);
end

%% Get spike count for each channel in desired window
fr = zeros(size(mt,1),size(sg,1));
useWin = zeros(size(mt,1),2);

for trial = 1:size(mt,1)
    % Time window for which to look for neural activity
    if strcmpi(tuningPeriod,'peak') % Use 0.5 sec period around peak speed
        useWin(trial,:) = [mt(trial,4) - movementTime/2, mt(trial,4) + movementTime/2];
    elseif strcmpi(tuningPeriod,'initial') %Use initial movement period
        useWin(trial,:) = [mt(trial,3), mt(trial,3)+movementTime];
    elseif strcmpi(tuningPeriod,'final') % Use the final movement period
        useWin(trial,:) = [mt(trial,end)-movementTime, mt(trial,end)];
    elseif strcmpi(tuningPeriod,'pre') % Use pre-movement period
        useWin(trial,:) = [mt(trial,3)-movementTime, mt(trial,3)];
    elseif strcmpi(tuningPeriod,'full') % Use entire movement
        useWin(trial,:) = [mt(trial,2), mt(trial,end)];
    end
    
    for unit = 1:size(sg,1)
        ts = data.(useArray).units.(['elec' num2str(sg(unit,1))]).(['unit' num2str(sg(unit,2))]).ts;
        
        %  the latency to account for transmission delays
        ts = ts + latency;
        
        % how many spikes are in this window?
        spikeCounts = sum(ts > useWin(trial,1) & ts <= useWin(trial,2));
        fr(trial,unit) = spikeCounts./movementTime; % Compute a firing rate
    end
end


%% Now get direction for tuning
if strcmpi(tuneDir,'targ')
    disp('Using target direction...')
    theta = mt(:,1);
else
    disp('Using movement direction...')
    
    if strcmpi(tuningPeriod,'pre') % in this case, use target direction
        theta = mt(:,1);
    else % find the net direction in the window
        theta = zeros(size(mt,1),1);
        for trial = 1:size(mt,1)
            idx = data.cont.t > useWin(trial,1) & data.cont.t <= useWin(trial,2);
            usePos = data.cont.pos(idx,:);
            theta(trial) = atan2(usePos(end,2)-usePos(1,2),usePos(end,1)-usePos(1,1));
        end
        
        clear t usePos movedir;
    end
end

theta = wrapAngle(theta,0); % make sure it goes from [-pi,pi)

if binAngles % put in bins for regression
    theta = round(theta./angleBinSize).*angleBinSize;
end

% Here would be a good place to look at directional tuning anova
% see if direction is a significant factor on firing with one way anova
% istuned = zeros(1,size(fr,2));
% for unit = 1:size(fr,2)
%     pval = anova1(fr(:,unit),theta,'off');
%     istuned(unit) = pval < confLevel;
% end

% Do bootstrapping with regression
statTestParams = {'bootstrap',bootNumIters,confLevel};

for iMethod = 1:length(tuningMethod)
    disp(['Using ' tuningMethod{iMethod} ' method...']);
    
    switch lower(tuningMethod{iMethod})
        case 'regression'
            [tcs,pd_cis,md_cis,bo_cis] = regressTuningCurves(fr,theta,statTestParams,'doplots',doPlots);
            pds = tcs(:,3);
            mds = tcs(:,2);
            bos = tcs(:,1);
        case 'vectorsum'
            [pds, pd_cis] = vectorSumPDs(fr,theta,statTestParams,'doplots',doPlots);
            mds = [];
            md_cis = [];
            bos = [];
            bo_cis = [];
    end
    
    out.(tuningMethod{iMethod}).pds = [pds pd_cis];
    out.(tuningMethod{iMethod}).mds = [mds md_cis];
    out.(tuningMethod{iMethod}).bos = [bos bo_cis];
    out.(tuningMethod{iMethod}).pd_cis = pd_cis;
    out.(tuningMethod{iMethod}).md_cis = md_cis;
    out.(tuningMethod{iMethod}).bo_cis = bo_cis;
    
    out.(tuningMethod{iMethod}).unit_guide = sg;
    out.(tuningMethod{iMethod}).fr = fr;
    out.(tuningMethod{iMethod}).theta = theta;
    out.(tuningMethod{iMethod}).mt = mt;
    out.(tuningMethod{iMethod}).params.stats = statTestParams;
    out.(tuningMethod{iMethod}).params.exclude_trials = excludeTrials;
    out.(tuningMethod{iMethod}).params.bin_angles = binAngles;
    out.(tuningMethod{iMethod}).params.movement_time = movementTime;
end
