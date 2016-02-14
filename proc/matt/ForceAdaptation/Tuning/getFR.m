function [outFR, outTheta, blockMT, outForce_rms, outVel, outForce] = getFR(data,params,useArray,tuningPeriod)
% finds firing rates for each movement based on the windows identified in
% the data struct. returns firing rate matrix (each unit against trial
% number) and direction of each movement
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load all of the parameters
forceMag = params.exp.force_magnitude;
forceDir = params.exp.force_angle;
holdTime = params.exp.target_hold_high;
angleBinSize = params.tuning.angleBinSize;
movementTime = params.tuning.movementTime;
tuneDir = params.tuning.tuningCoordinates;
doBinAngles = params.tuning.binAngles;
latency = params.tuning.([lower(useArray) '_latency']);
timeDelay = params.tuning.timeDelay;
divideTime = params.tuning.divideTime;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get data
sg = data.(useArray).sg;

% Get the movement table
[blockMT,~] = filterMovementTable(data, params, true);

if ~strcmpi(tuningPeriod,'time')
    numBlocks = length(blockMT);
else
    % figure out how many blocks there should be, though here we are
    % blocking with all trials in different sliding windows over CO reach
    numBlocks = floor(( 1 + divideTime(2) - divideTime(1) ) / divideTime(2));
    blockMT = repmat(blockMT,numBlocks,1);
end

% mt will be a cell array, with multiple blocks if desired
outFR = cell(1,numBlocks);
outTheta = cell(1,numBlocks);
outForce = cell(1,numBlocks);
outForce_rms = cell(1,numBlocks);
outVel = cell(1,numBlocks);
outAcc = cell(1,numBlocks);

for iBlock = 1:numBlocks
    mt = blockMT{iBlock};
    %% Get spike count for each channel in desired window
    fr = zeros(size(mt,1),size(sg,1));
    useWin = zeros(size(mt,1),2);
    
    % mt is the movement table
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
        elseif strcmpi(tuningPeriod,'peakend') % use from peak to end
            useWin(trial,:) = [mt(trial,5), mt(trial,6)-holdTime];
        elseif strcmpi(tuningPeriod,'befpeak') % window ending at peak
            useWin(trial,:) = [mt(trial,5)-movementTime, mt(trial,5)];
        elseif strcmpi(tuningPeriod,'time') % sliding time windows over reaches
            tstart = mt(trial,4)-timeDelay; % time that reach starts
            tdur = ( mt(trial,6) - holdTime + timeDelay ) - tstart; % time duration of reach
            useWin(trial,:) = [tstart + (iBlock-1)*divideTime(2)*tdur, tstart + (divideTime(1)+(iBlock-1)*divideTime(2)) * tdur];
        elseif strcmpi(tuningPeriod,'baseline') % baseline activity movementTime msec before target presentation
            useWin(trial,:) = [mt(trial,2) - movementTime, mt(trial,2)];
        elseif strcmpi(tuningPeriod,'afton') % window after target presentation
            useWin(trial,:) = [mt(trial,2), mt(trial,2)+movementTime];
        elseif strcmpi(tuningPeriod,'befgo') % window ending on go cue
            useWin(trial,:) = [mt(trial,3)-movementTime, mt(trial,3)];
        elseif strcmpi(tuningPeriod,'aftgo') % window after go cue
            useWin(trial,:) = [mt(trial,3), mt(trial,3)+movementTime];
        elseif strcmpi(tuningPeriod,'gomove') % window from go cue to movement onset
            useWin(trial,:) = [mt(trial,3), mt(trial,4)];
        elseif strcmpi(tuningPeriod,'go') %window surrounding go
            useWin(trial,:) = [mt(trial,3) - 2*movementTime/3, mt(trial,3) + movementTime/3];
        end
        
        for unit = 1:size(sg,1)
            ts = data.(useArray).units(unit).ts;
            
            %  the latency to account for transmission delays
            ts = ts + latency;
            
            % how many spikes are in this window?
            spikeCounts = sum(ts > useWin(trial,1) & ts <= useWin(trial,2));
            fr(trial,unit) = spikeCounts./(useWin(trial,2)-useWin(trial,1)); % Compute a firing rate
        end
    end
    
    %% Now get direction for tuning
    if strcmpi(tuneDir,'target')
        theta = mt(:,1);
    elseif strcmpi(tuneDir,'movement')
        if strcmpi(tuningPeriod,'pre') || strcmpi(tuningPeriod,'time0') % in this case, use target direction
            theta = mt(:,1);
        else % find the net direction in the window
            % compute force vector of hand
            % - have net force and net velocity
            % - use velocity from ~10 msec in past to compute present force vector
            % - use these to find hand force vector
            % - find angle and regress to that
            
            % calculate perturbation force
            if strcmpi(data.meta.epoch,'ad') && strcmpi(data.meta.perturbation,'ff')
                f_p = zeros(length(data.cont.t),2);
                f_h = zeros(length(data.cont.t),2);
                for i = 13:length(data.cont.t)
                    v = data.cont.vel(i-11,:);
                    t = atan2(data.cont.vel(i-11,2)-data.cont.vel(i-12,2),data.cont.vel(i-11,1)-data.cont.vel(i-12,1));
                    f_p(i,1) = forceMag.*sqrt(v(1).^2 + v(2).^2)*cos(t+(forceDir*pi/180));
                    f_p(i,2) = forceMag.*sqrt(v(1).^2 + v(2).^2)*sin(t+(forceDir*pi/180));
                    f_h(i,1) = data.cont.force(i,1)-f_p(i,1);
                    f_h(i,2) = data.cont.force(i,2)-f_p(i,2);
                end
            else
                f_h = data.cont.force;
            end
            
            theta = zeros(size(mt,1),1);
            theta_hand = zeros(size(mt,1),1);
            for trial = 1:size(mt,1)
                try
                    idx = data.cont.t > useWin(trial,1) & data.cont.t <= useWin(trial,2);
                    usePos = data.cont.pos(idx,:);
                    theta(trial) = atan2(usePos(end,2)-usePos(1,2),usePos(end,1)-usePos(1,1));
                    
                    useHand = f_h(idx,:);
                    theta_hand(trial) = atan2(mean(useHand(:,2)),mean(useHand(:,1)));
                catch
                    theta_hand(trial) = NaN;
                end
            end
        end
        
    else
        error('tuning direction not recognized');
    end
    % get mean force and velocity in that window
    if isfield(data.cont,'force') && ~isempty(data.cont.force)
        force = zeros(size(mt,1),2);
        force_rms = zeros(size(mt,1),2);
        vel = zeros(size(mt,1),2);
        for trial = 1:size(mt,1)
            idx = data.cont.t > useWin(trial,1) & data.cont.t <= useWin(trial,2);
            useForce = data.cont.force(idx,:);
            force(trial,:) = mean(useForce,1);
            force_rms(trial,:) = rms(useForce,1);
            
            % THIS IS A SHIFT
            %                 disp(' ');
            %                 disp('%%%%%%%%%%%%%');
            %                 disp(' HEY BITCHES! IN getFR! THERES A SHIFT! ');
            %                 disp(' %%%%%%%%%%%%');
            %                 disp(' ');
            %                 idx = find(idx) - 20;
            useVel = data.cont.vel(idx,:);
            vel(trial,:) = mean(useVel,1);
        end
    else
        force = [];
        force_rms = [];
        vel = [];
    end
    clear t usePos movedir;
    
    % theta = wrapAngle(theta,0); % make sure it goes from [-pi,pi)
    
    if doBinAngles % put in bins for regression
        theta = binAngles(theta,angleBinSize);
    end
    
    outFR{iBlock} = fr;
    outTheta{iBlock} = theta;
    outForce{iBlock} = force;
    outForce_rms{iBlock} = force_rms;
    outVel{iBlock} = vel;
end

