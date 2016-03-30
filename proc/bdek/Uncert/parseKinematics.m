function parsed_table = parseKinematics(bdf)
%PARSETRAJS Summary of this function goes here
%   Quick and Dirty Kinematics Parser and Plotter for Jaco's Uncertainty
%   Data
%
%   Warning: This file automatically names and saves figure files!!!
%
%   last updated: 3/29/2012 - pwanda
%
%   to do: ultimately, this script will be divided into subfunctions
%      parseKinematics will return a table of parsed movements including
%      movement start and end timestamps, all kinematic data,
%      reward/failure information, perturbation, etc.
%
%      the plotting components will be folded into different plotting
%       specific functions
%
%
%


close all;
fn = bdf.meta.filename;
while ~isempty(fn)
    [tok fn]=strtok(fn,'\\');
end
fn=strtok(tok,'.');
fn(find(fn=='_'))='-';
fntag = [fn '- ']; % place in front of every title

%% Pull Kinematics and Correct for Offset
x_offset = -2;
y_offset = 33;

% Load and correct positions for center offset
pos_x = bdf.pos(:,2)+x_offset;
pos_y = bdf.pos(:,3)+y_offset;

% Load rest of Kinematics
vel_x = bdf.vel(:,2);
vel_y = bdf.vel(:,3);
acc_x = bdf.acc(:,2);
acc_y = bdf.acc(:,3);

% The time series of samples for kinematics
kin_ts = bdf.pos(:,1);

% Plot full trajectories
figure;
plot(pos_x,pos_y);
figtitle = [fntag 'Full Hand Paths'];
title(figtitle);
hgsave(figtitle);
% 
% figure;
% subplot(2,1,1);
% plot(vel_x);
% subplot(2,1,2);
% plot(vel_y);
% title(['Full Velocity (x and y)']);
% 
% figure;
% subplot(2,1,1);
% plot(acc_x);
% subplot(2,1,2);
% plot(acc_y);
% title(['Full Acceleration (x and y)']);

%% Pull the Databurst and get all the timestamps
db = bdf.databursts;
for dbi=1:length(db)
    db_ts(dbi) = db{dbi,1};
end
clear db;
%% Process Words and Find Truncation Spots
word_list = Words;

%Find first data burst and truncation index of words preceding it
fdb_t = db_ts(1);
wds_after_db_trunc_ind = find(bdf.words(:,1) > fdb_t,1,'first');

%Find last trial end code and truncation index of words following it
lwd_trunc_ind=find(bdf.words(:,2)==hex2dec('20')|bdf.words(:,2)==hex2dec('21')|bdf.words(:,2)==hex2dec('22')|bdf.words(:,2)==hex2dec('23'),1,'last');
lwd_t = bdf.words(lwd_trunc_ind,1);% last trial end time

% Truncate Words
words_all = bdf.words(wds_after_db_trunc_ind:lwd_trunc_ind,:);
word_ts    = words_all(:,1);
word_codes = words_all(:,2);

%% Process Full Databurst
% Truncate Databursts following the last end code time (if necessary)
db_truncated_inds = find(db_ts < lwd_t);
clear db_ts;

% Reload and truncate databurst
db = bdf.databursts;
for dbi=db_truncated_inds
    db_ts(dbi) = db{dbi,1};    
    db_perts(dbi) = bytes2float(db{dbi,2}(3:6));
end

%Plot Histogram of Perturbations
figure;
hist(db_perts,20);
figtitle = [fntag 'All Lateral Shifts (All Trials)'];
xlabel('Lateral Shift (cm)');
ylabel('Number of Trials');
title(figtitle);
hgsave(figtitle);


%% 

num_words = length(word_codes);

all_trial_words = find(word_codes>=32 & word_codes<=35);

% CENTER LOC   x30
% OUTER TARGET x40
% GO x31
%
% Reward       x20
% Abort        x21
% Failure      x22
% Incomplete   x23
%

center_code_inds     = find(word_codes==hex2dec('30'));
go_code_inds         = find(word_codes==hex2dec('31'));
reward_code_inds     = find(word_codes==hex2dec('20'));
abort_code_inds      = find(word_codes==hex2dec('21'));
failure_code_inds    = find(word_codes==hex2dec('22'));
incomplete_code_inds = find(word_codes==hex2dec('23'));

center_ts       = floor(1000*word_ts(center_code_inds))/1000;
go_ts           = floor(1000*word_ts(go_code_inds))/1000;
reward_ts       = floor(1000*word_ts(reward_code_inds))/1000;
failure_ts      = floor(1000*word_ts(failure_code_inds))/1000;
abort_ts        = floor(1000*word_ts(abort_code_inds))/1000;
incomplete_ts   = floor(1000*word_ts(incomplete_code_inds))/1000;


for ri=1:length(center_ts)
    kin_center_inds(ri) = find(kin_ts<center_ts(ri),1,'last');
end

for ri=1:length(go_ts)
    kin_go_inds(ri) = find(kin_ts<go_ts(ri),1,'last');
end

for ri=1:length(reward_ts)
    kin_reward_inds(ri) = find(kin_ts<reward_ts(ri),1,'last');
        db_rw_trial_inds(ri) = find(db_ts<reward_ts(ri),1,'last');
end
rw_trial_perts = db_perts(db_rw_trial_inds);
for ri=1:length(failure_ts)
    kin_failure_inds(ri) = find(kin_ts<failure_ts(ri),1,'last');
            db_fl_trial_inds(ri) = find(db_ts<failure_ts(ri),1,'last');
end
fl_trial_perts = db_perts(db_fl_trial_inds);


all_trial_ts = [reward_ts; failure_ts];
all_trial_inds = [kin_reward_inds kin_failure_inds];

for ri=1:length(all_trial_ts)
    kin_all_trial_inds(ri) = find(kin_ts<all_trial_ts(ri),1,'last');
    db_all_trial_inds(ri) = find(db_ts<all_trial_ts(ri),1,'last');
end

all_startpoint_x = pos_x(kin_go_inds)';
all_startpoint_y = pos_y(kin_go_inds)';

all_rw_endpoint_x = pos_x(kin_reward_inds)';
all_rw_endpoint_y = pos_y(kin_reward_inds)';
all_fl_endpoint_x = pos_x(kin_failure_inds)';
all_fl_endpoint_y = pos_y(kin_failure_inds)';

all_trial_endpoint_x = pos_x(all_trial_inds)';
all_trial_endpoint_y = pos_y(all_trial_inds)';
all_trial_perts = db_perts(db_all_trial_inds);


% Plot Error vs Perturbation
figure;
plot(all_trial_perts,all_trial_endpoint_x+all_trial_perts,'bo');
xlabel('True Lateral Shift (cm)');
ylabel('Deviation from Target Center (cm)');
figtitle = [fntag 'Error vs Shift (all completed)'];
title(figtitle);
hgsave(figtitle);

%Plot Histogram of Perturbations
figure;
hist(all_trial_perts,20);
figtitle = [fntag 'All Lateral Shifts for Completed'];
xlabel('Lateral Shift (cm)');
ylabel('Number of Trials');
title(figtitle);
hgsave(figtitle);



% Plot Error vs Perturbation (by outcome)
figure;
% plot(all_trial_endpoint_x+all_trial_perts,all_trial_perts,'bo');
hold on;
plot(rw_trial_perts,all_rw_endpoint_x+rw_trial_perts,'gx');
hold on;
plot(fl_trial_perts,all_fl_endpoint_x+fl_trial_perts,'rx');
xlabel('True Lateral Shift (cm)');
ylabel('Deviation from Target Center (cm)');
legend('Reward','Failure');
figtitle = [fntag 'Error vs Shift (organized by outcome)'];
title(figtitle);
hgsave(figtitle);

% Put Endpoint and Start Information on the Full Trajectory Plot
figure;
plot(pos_x,pos_y);
hold on;
plot(all_startpoint_x,all_startpoint_y,'m^');
% plot(all_rw_endpoint_x,all_rw_endpoint_y,'kx');
% plot(all_fl_endpoint_x,all_fl_endpoint_y,'rx');
plot(all_trial_endpoint_x,all_trial_endpoint_y,'bo');
figtitle = [fntag 'Full Hand Paths with endpoints'];
title(figtitle);
hgsave(figtitle);

% Plot Just the Endpoints and Go Points
figure;
hold on;
plot(all_startpoint_x,all_startpoint_y,'m^');
% plot(all_rw_endpoint_x,all_rw_endpoint_y,'kx');
% plot(all_fl_endpoint_x,all_fl_endpoint_y,'rx');
plot(all_trial_endpoint_x,all_trial_endpoint_y,'bo');
figtitle = [fntag 'Go Positions and Endpoints (true position)'];
title(figtitle);
hgsave(figtitle);
