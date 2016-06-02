function plot_trial_recruitment(data,stimparam,labels,chNum,EMG_enable,calMat,sample_rate,platON,platOFF,numPulses,mode,baseline)

% Define min # pulses to be a train
min_pulses = 10;

% Determine which elements in data are forces (extract stimuli)
stim_temp = find(EMG_enable(1:15));

% Loop across multiple recordings at current stim param but same muscle (if necessary)
for trig = 1:size(data,3)
    % Transform data using calibration matrix
    dataNEW = data(:,length(stim_temp)+1:end,trig)*calMat;

    % Remove offset from calibrated force data
    dataNEW = remove_offset(dataNEW,sample_rate);
    
    if numPulses(1) > min_pulses
        % Steady-state step response
        % Average steady-state force magnitude (x-y plane) during pulse train
        [magForce,stdForce,fX,fY] = steady_state_force_mag(dataNEW,platON,platOFF);
    else
        % Pulses for recruitment curve
        [~,indfX] = max(abs(dataNEW(:,1)));
        [~,indfY] = max(abs(dataNEW(:,2)));
        if indfX == 0; indfX = 1; end
        if indfY == 0; indfY = 1; end
        fX = dataNEW(indfX);
        fY = dataNEW(indfY);
        magForce = mean(sqrt(fX.^2+fY.^2));
    end

    % Average direction of steady-state force in x-y plane (positive Fx
    % is to the right when facing rat, positive Fy is vertical)
    [dirForce,dirForceStd] = steady_state_force_dir(fY,fX);        
end

% Plot point on recruitment curve for each muscle
figure(100+chNum);

% Plot force magnitude
subplot(2,1,1)
title(strcat('Recruitment curve: ',labels(chNum)));
plot(stimparam,magForce,'.','MarkerSize',8);
hold on;
if numPulses(1) > min_pulses
    errorbar(stimparam,magForce,stdForce,'Marker','.');
end
% Add Labels
if (strcmp(mode,'mod_pw'))
    xlabel('pulsewidth (msec)')
else
    xlabel('pulse amplitude (mA)')
end
ylabel('Force (N)')

% Plot force direction
subplot(2,1,2)
plot(stimparam,dirForce*180/pi,'.','MarkerSize',8);
hold on;
if numPulses(1) >min_pulses
    errorbar(stimparam,dirForce*180/pi,dirForceStd*180/pi,'Marker','.');
end
% Add Labels
if (strcmp(mode,'mod_pw'))
    xlabel('pulsewidth (msec)')
else
    xlabel('pulse amplitude (mA)')
end
ylabel('Direction (deg)')
