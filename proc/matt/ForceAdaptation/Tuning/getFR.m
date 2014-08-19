function [fr, theta, mt, force, vel] = getFR(data,useArray,tuningPeriod,paramSetName,useBlock)
% finds firing rates for each movement based on the windows identified in
% the data struct. returns firing rate matrix (each unit against trial
% number) and direction of each movement
%
% useBlock is which block of trials to use. In parameter file, can do
% excludeAD, let's say it's 0 0.25 0.5 0.75 1, then there are 4 potential
% blocks. useBlock = 1 would be the first 25% of trials, useBlock = 4 would
% be the last 25%.

force = [];
vel = [];

if nargin < 5
    % no useBlock, assume only one block
    useBlock = -1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load all of the parameters
paramFile = fullfile(data.meta.out_directory, paramSetName, [data.meta.recording_date '_' paramSetName '_tuning_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
angleBinSize = str2double(params.angle_bin_size{1});
movementTime = str2double(params.movement_time{1});
tuneDir = params.tuning_direction{1};
doBinAngles = str2double(params.bin_angles{1});
clear params ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
latency = str2double(params.([lower(useArray) '_latency']){1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get data
sg = data.(useArray).sg;

% for now, assume a hold time of 0.5 s
holdTime = 0.5;

% Get the movement table
mt = filterMovementTable(data, paramSetName, true, useBlock);

if size(mt,1)==0
    keyboard
end

%% Get spike count for each channel in desired window
fr = zeros(size(mt,1),size(sg,1));
useWin = zeros(size(mt,1),2);

% amount of time to wait after go cue
timeDelay = 0.05; %seconds

% mt is
% [ target angle, on_time, go cue, move_time, peak_time, end_time ]
for trial = 1:size(mt,1)
    % Time window for which to look for neural activity
    if strcmpi(tuningPeriod,'peak') % Use period around peak speed
        useWin(trial,:) = [mt(trial,5) - movementTime/2, mt(trial,5) + movementTime/2];
    elseif strcmpi(tuningPeriod,'initial') %Use initial movement period
        useWin(trial,:) = [mt(trial,4), mt(trial,4)+movementTime];
    elseif strcmpi(tuningPeriod,'final') % Use the final movement period
        useWin(trial,:) = [mt(trial,6)-movementTime-holdTime, mt(trial,6)-holdTime];
    elseif strcmpi(tuningPeriod,'pre') % Use pre-movement period
        useWin(trial,:) = [mt(trial,2)+timeDelay, mt(trial,4)];
    elseif strcmpi(tuningPeriod,'full') % Use entire movement
        useWin(trial,:) = [mt(trial,4)-timeDelay, mt(trial,6)-holdTime];
    elseif strcmpi(tuningPeriod,'onpeak') % use from onset to peak
        useWin(trial,:) = [mt(trial,4), mt(trial,5)];
    elseif strcmpi(tuningPeriod,'befpeak') % window ending at peak
        useWin(trial,:) = [mt(trial,5)-movementTime, mt(trial,5)];
    
    % this is an odd case. It's for looking at progression over the
    % duration of the movement.
        
    % absolute time
    %     elseif strcmpi(tuningPeriod,'time0')
    %         % this is pre-movement
    %         useWin(trial,:) = [mt(trial,2)+timeDelay, mt(trial,3)];
    %     elseif strcmpi(tuningPeriod,'time1')
    %         tstart = mt(trial,4)-timeDelay;
    %         useWin(trial,:) = [tstart, tstart+0.2];
    %     elseif strcmpi(tuningPeriod,'time2')
    %         tstart = mt(trial,4)-timeDelay;
    %         useWin(trial,:) = [tstart+0.05, tstart+0.25];
    %     elseif strcmpi(tuningPeriod,'time3')
    %         tstart = mt(trial,4)-timeDelay;
    %         useWin(trial,:) = [tstart+0.1, tstart+0.3];
    %     elseif strcmpi(tuningPeriod,'time4')
    %         tstart = mt(trial,4)-timeDelay;
    %         useWin(trial,:) = [tstart+0.15, tstart+0.35];
    %     elseif strcmpi(tuningPeriod,'time5')
    %         tstart = mt(trial,4)-timeDelay;
    %         useWin(trial,:) = [tstart+0.2, tstart+0.4];
    %     elseif strcmpi(tuningPeriod,'time6')
    %         tstart = mt(trial,4)-timeDelay;
    %         useWin(trial,:) = [tstart+0.25, tstart+0.45];
    %     elseif strcmpi(tuningPeriod,'time7')
    %         tstart = mt(trial,4)-timeDelay;
    %         useWin(trial,:) = [tstart+0.3, tstart+0.5];
    %     elseif strcmpi(tuningPeriod,'time8')
    %         tstart = mt(trial,4)-timeDelay;
    %         useWin(trial,:) = [tstart+0.35, tstart+0.55];
    %     end
    
    % relative time
    elseif strcmpi(tuningPeriod,'time1')
        % this is an odd case. It's for looking at progression over the
        % duration of the movement.
        
        % find duration of movement (add a bit to end of target
        tstart = mt(trial,4)-timeDelay;
        tdur = ( mt(trial,6) - holdTime + timeDelay ) - tstart;
        
        useWin(trial,:) = [tstart+0*tdur, tstart+0.3*tdur];
    elseif strcmpi(tuningPeriod,'time2')
        tstart = mt(trial,4)-timeDelay;
        tdur = ( mt(trial,6) - holdTime + timeDelay ) - tstart;
        useWin(trial,:) = [tstart+0.1*tdur, tstart+0.4*tdur];
    elseif strcmpi(tuningPeriod,'time3')
        tstart = mt(trial,4)-timeDelay;
        tdur = ( mt(trial,6) - holdTime + timeDelay ) - tstart;
        useWin(trial,:) = [tstart+0.2*tdur, tstart+0.5*tdur];
    elseif strcmpi(tuningPeriod,'time4')
        tstart = mt(trial,4)-timeDelay;
        tdur = ( mt(trial,6) - holdTime + timeDelay ) - tstart;
        useWin(trial,:) = [tstart+0.3*tdur, tstart+0.6*tdur];
    elseif strcmpi(tuningPeriod,'time5')
        tstart = mt(trial,4)-timeDelay;
        tdur = ( mt(trial,6) - holdTime + timeDelay ) - tstart;
        useWin(trial,:) = [tstart+0.4*tdur, tstart+0.7*tdur];
    elseif strcmpi(tuningPeriod,'time6')
        tstart = mt(trial,4)-timeDelay;
        tdur = ( mt(trial,6) - holdTime + timeDelay ) - tstart;
        useWin(trial,:) = [tstart+0.5*tdur, tstart+0.8*tdur];
    elseif strcmpi(tuningPeriod,'time7')
        tstart = mt(trial,4)-timeDelay;
        tdur = ( mt(trial,6) - holdTime + timeDelay ) - tstart;
        useWin(trial,:) = [tstart+0.6*tdur, tstart+0.9*tdur];
    elseif strcmpi(tuningPeriod,'time8')
        tstart = mt(trial,4)-timeDelay;
        tdur = ( mt(trial,6) - holdTime + timeDelay ) - tstart;
        useWin(trial,:) = [tstart+0.7*tdur, tstart+1.0*tdur];
    end
    
    
    for unit = 1:size(sg,1)
        ts = data.(useArray).units(unit).ts;
        
        %  the latency to account for transmission delays
        ts = ts + latency;
        
        % how many spikes are in this window?
        spikeCounts = sum(ts > useWin(trial,1) & ts <= useWin(trial,2));
        fr(trial,unit) = spikeCounts./movementTime; % Compute a firing rate
    end
end

%% Now get direction for tuning
if strcmpi(tuneDir,'target')
    disp('Using target direction...')
    theta = mt(:,1);
elseif strcmpi(tuneDir,'movement')
    disp('Using movement direction...')
    
    if strcmpi(tuningPeriod,'pre') || strcmpi(tuningPeriod,'time0') % in this case, use target direction
        theta = mt(:,1);
    else % find the net direction in the window
        theta = zeros(size(mt,1),1);
        
        for trial = 1:size(mt,1)
            idx = data.cont.t > useWin(trial,1) & data.cont.t <= useWin(trial,2);
            usePos = data.cont.pos(idx,:);
            theta(trial) = atan2(usePos(end,2)-usePos(1,2),usePos(end,1)-usePos(1,1));
        end
        
        % get mean force and velocity in that window
        if isfield(data.cont,'force') && ~isempty(data.cont.force)
            force = zeros(size(mt,1),2);
            vel = zeros(size(mt,1),2);
            for trial = 1:size(mt,1)
                idx = data.cont.t > useWin(trial,1) & data.cont.t <= useWin(trial,2);
                useForce = data.cont.force(idx,:);
                force(trial,:) = rms(useForce,1);
                useVel = data.cont.vel(idx,:);
                vel(trial,:) = rms(useVel,1);
            end
        else
            force = [];
            vel = [];
        end
        clear t usePos movedir;
    end
else
    error('tuning direction not recognized');
end

% theta = wrapAngle(theta,0); % make sure it goes from [-pi,pi)

if doBinAngles % put in bins for regression
    theta = binAngles(theta,angleBinSize);
end

