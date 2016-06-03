function delays = getNeuronLatency(units,vel)
% GETNEURONLATENCY finds the delay between neural activity and movement.
% Uses cross correlation between binned firing rate signal and binned
% velocity signal.
%
% INPUTS:
%   units: bdf.units
%   vel: bdf.vel
%
close all
% Find the magnitude of the velocity
speed = hypot(vel(:,2),vel(:,3));

dt = vel(2,1)-vel(1,1);
delays = zeros(length(units),1);

for unit = 1:length(units)
    ts = units(unit).ts;
    
    % Convolve neural spikes with Gaussian kernel to get continuous signal
    fr = spikes2fr( ts, vel(:,1), 0.1 );

    % Compute the cross correlation of firing rate with velocity
    [c,lags] = xcorr(fr,speed,5e4);

    c = c-mean(c);
    c=abs(c);
    b = c;
    
    % Find the location of the peak of the cross correlation
    [~,I] = max(c);
    
    delays(unit) = lags(I(1))*dt;
    delays(unit)
    
%     figure;
%     subplot1(2,1)
%     subplot1(1); plot(fr);
%     subplot1(2); plot(speed);
%     figure;
%     hold all;
%     plot(lags,b,'r');
%     plot(lags,c);
%     pause;
%     close all;
end

figure;
hist(delays,100);

keyboard

