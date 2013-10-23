function [fr, theta, mt] = getFR(data,useArray,tuningPeriod,paramSetName)
% finds firing rates for each movement based on the windows identified in
% the data struct. returns firing rate matrix (each unit against trial
% number) and direction of each movement

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load all of the parameters
paramFile = fullfile(data.meta.out_directory, paramSetName, [data.meta.recording_date '_' paramSetName '_tuning_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
angleBinSize = str2double(params.angle_bin_size{1});
latency = str2double(params.([lower(useArray) '_latency']){1});
movementTime = str2double(params.movement_time{1});
tuneDir = params.tuning_direction{1};
binAngles = str2double(params.bin_angles{1});
clear params temp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get data
sg = data.(useArray).unit_guide;

% Get the movement table
mt = filterMovementTable(data, paramSetName);

if size(mt,1)==0
    keyboard
end

%% Get spike count for each channel in desired window
fr = zeros(size(mt,1),size(sg,1));
useWin = zeros(size(mt,1),2);

% mt is
% [ target angle, on_time, go cue, move_time, peak_time, end_time ]
for trial = 1:size(mt,1)
    % Time window for which to look for neural activity
    if strcmpi(tuningPeriod,'peak') % Use 0.5 sec period around peak speed
        % offset by 100msec from being centered on peak so it precedes move
        useWin(trial,:) = [mt(trial,5) - movementTime/2-0.1, mt(trial,5) + movementTime/2-0.1];
    elseif strcmpi(tuningPeriod,'initial') %Use initial movement period
        useWin(trial,:) = [mt(trial,4), mt(trial,4)+movementTime];
    elseif strcmpi(tuningPeriod,'final') % Use the final movement period
        useWin(trial,:) = [mt(trial,end)-movementTime, mt(trial,end)];
    elseif strcmpi(tuningPeriod,'pre') % Use pre-movement period
        useWin(trial,:) = [mt(trial,2), mt(trial,4)];
    elseif strcmpi(tuningPeriod,'full') % Use entire movement
        useWin(trial,:) = [mt(trial,3), mt(trial,end)];
    elseif strcmpi(tuningPeriod,'onpeak') % use from onset to peak
        useWin(trial,:) = [mt(trial,4), mt(trial,5)];
    elseif strcmpi(tuningPeriod,'befpeak') % window ending at peak
        useWin(trial,:) = [mt(trial,5)-movementTime, mt(trial,5)];
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
if strcmpi(tuneDir,'target')
    disp('Using target direction...')
    theta = mt(:,1);
elseif strcmpi(tuneDir,'movement')
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
else
    error('tuning direction not recognized');
end

% theta = wrapAngle(theta,0); % make sure it goes from [-pi,pi)

if binAngles % put in bins for regression
    theta = round(theta./angleBinSize).*angleBinSize;
    % -pi and pi are the same thing
    if length(unique(theta)) > int16(2*pi/angleBinSize)
        % probably true that -pi and pi both exist
        utheta = unique(theta);
        if utheta(1)==-utheta(end)
            % almost definitely true that -pi and pi both exist
            theta(theta==utheta(1)) = utheta(end);
        elseif abs(utheta(1)) > abs(utheta(end))
            theta(theta==utheta(1)) = -utheta(1);
            % probably means that -pi instead of pi
        else            
            disp('Something fishy is going on with this binning...')
            keyboard
        end
    end
    
end

