%% load file
folder = 'C:\Users\rhc307\Documents\Data\experiment_20151117_actpas\';
prefix = 'Chips_20151117_COactpas';
bdf = get_nev_mat_data([folder prefix],6,'ignore_jumps');

%% load color tracking
load([folder 'ct_chips_CO_actpass_151117.mat'])

%% find start time of KinectSyncPulse
analog_ts = bdf.analog.ts';
KinectSyncPulse = bdf.analog.data;
start_ind = find(KinectSyncPulse>2000,1,'first');
t_start = analog_ts(start_ind);

%% line up things
plot(analog_ts-t_start,KinectSyncPulse/max(KinectSyncPulse),'-b',times-led_start,led_square/max(led_square),'-r')

%% change kinect times
kinect_times = times-led_start+t_start;

%% put Kinect data into bdf
