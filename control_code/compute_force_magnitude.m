function [magForce,calibForces,dirForce,stdForce,forceCloud,pulseamps,pulsewidths,stdDir] = compute_force_magnitude(data_struct,calmat,emg_enable,platON,platOFF)

%% Determine which channels are the forces and extract data
numEMGs = sum(emg_enable(1:15));
if iscell(data_struct.data)
    % Raw force data
    [nr,nc] = size(data_struct.data);
    for ii = 1:nr % parameters
        for jj = 1:nc % muscles
            forcesTEMP = data_struct.data{ii,jj}(:,numEMGs+1:numEMGs+6);
            rawForces(ii,jj).forces = forcesTEMP*calmat;
        end
    end
else
    nr = 1; nc = 1;
    rawForces.forces = data_struct.data(:,numEMGs+1:numEMGs+6)*calmat;
end

%% Determine modulated parameters and their values
pulseamps_temp = zeros(length(data_struct.modulation_channel_multipliers),16);
pulsewidths_temp = pulseamps_temp;
for ii = 1:length(data_struct.modulation_channel_multipliers)
    if strcmp(data_struct.mode,'mod_amp')
        % Amplitdue modulation
        pulseamps_temp(ii,:) = data_struct.base_amp + (data_struct.base_amp.*repmat(data_struct.modulation_channel_multipliers(ii)-1,1,16).*data_struct.is_channel_modulated);
        pulsewidths_temp(ii,:) = data_struct.base_pw;
        pulsewidths = pulsewidths_temp(:,data_struct.is_channel_modulated>0);
        pulseamps = pulseamps_temp(:,data_struct.is_channel_modulated>0);
    elseif strcmp(data_struct.mode,'mod_pw')
        % Pulsewidth modulation
        pulsewidths_temp(ii,:) = data_struct.base_pw + (data_struct.base_pw.*repmat(data_struct.modulation_channel_multipliers(ii)-1,1,16).*data_struct.is_channel_modulated);
        pulseamps_temp(ii,:) = data_struct.base_amp;
        pulsewidths = pulsewidths_temp(:,data_struct.is_channel_modulated>0);
        pulseamps = pulseamps_temp(:,data_struct.is_channel_modulated>0);
    else
        % No modulation
        indAmp = find(data_struct.base_amp>0);
        pulseamps = data_struct.base_amp(indAmp);
        pulsewidths = data_struct.base_pw(indAmp);
    end
end

%% Determine force magnitude for each parameter value
numsamples = size(rawForces(1,1).forces,1);
% Onsets ~0.17sec
bline_end = 0.10;
calibForces = rawForces;
magForce = zeros(size(rawForces)); dirForce = magForce; stdForce = magForce; stdDir = magForce; %forceCloud = magForce;
for ii = 1:nr
    for jj = 1:nc
        % Remove baseline from forces/moments
        calibForces(ii,jj).forces = remove_offset(rawForces(ii,jj).forces,data_struct.daq_freq);
    
        if data_struct.pulses > 10
            % Average steady-state force magnitude (x-y plane) during pulse train
            [magForce(ii,jj),stdForce(ii,jj),fX,fY] = steady_state_force_mag(calibForces(ii,jj).forces,platON,platOFF);
            forceCloud(ii,jj).fX = fX;
            forceCloud(ii,jj).fY = fY;
        else
            [c,indfX] = max(abs(calibForces(ii,jj).forces(:,1)));   % CAN ADD RANGES TO THESE!!!!!
            [c,indfY] = max(abs(calibForces(ii,jj).forces(:,2)));
            if indfX == 0; indfX = 1; end
            if indfY == 0; indfY = 1; end
            fX = calibForces(ii,jj).forces(indfX,1);
            fY = calibForces(ii,jj).forces(indfY,1);
            magForce(ii,jj) = mean(sqrt(fX.^2+fY.^2));
            stdForce(ii,jj) = std(sqrt(fX.^2+fY.^2));
            forceCloud(ii,jj).fX = fX;
            forceCloud(ii,jj).fY = fY;
        end
        
        % Average direction of steady-state force in x-y plane (positive Fx
        % is to the right when facing rat, positive Fy is vertical)
        [dirForce(ii,jj),stdDir(ii,jj)] = steady_state_force_dir(fY,fX);
    end
end

