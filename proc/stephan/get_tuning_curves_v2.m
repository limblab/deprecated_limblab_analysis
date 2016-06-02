
bdf = wed1010;
include_unsorted = 1;

chan = 47;
unit = 0;
offset = 0;

%% get speed and direction (in rad) 

% time_stamps = bdf.vel(:,1); % times at which velocity is recorded (ms intervals).
ts = 50; %[ms]

vt = bdf.vel(:,1);
t = vt(1):ts/1000:vt(end);
spike_times = get_unit(bdf,chan,unit)-offset;
spike_times = spike_times(spike_times>t(1) & spike_times<t(end)); % remove spike times that are not between start and end times

velx = bdf.vel(:,2); % x velocity
vely = bdf.vel(:,3);

velx_smooth = interp1(bdf.vel(:,1), bdf.vel(:,2), t);
vely_smooth = interp1(bdf.vel(:,1), bdf.vel(:,3), t);

[dir_unsmoothed,speed_unsmoothed]=cart2pol(velx,vely); % dir is direction in radians (between -PI and PI)
[dir, speed] = cart2pol(velx_smooth,vely_smooth);

%% make dir positive
dir(dir<0)=dir(dir<0)+2*pi;

%% get FR for one channel

FR = train2bins(spike_times, t); % Converts spike train timestamps to bins of spike counts
[dir_sorted, indices] = sort(dir);
FR_sorted = FR(indices);

figure, 
plot(dir_sorted*180/pi,FR_sorted)
xlabel('movement direction [degrees]')
ylabel(['firing rate, binned at ' num2str(ts) 'ms'])
title(['tuning curve for channel' num2str(chan) ', data wed1010'])

% figure,
% polar(dir_sorted,FR_sorted)

