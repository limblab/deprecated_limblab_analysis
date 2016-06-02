function draw_rw_trial(bdf, trial_num, target_size)
% DRAW_RW_TRIAL( BDF, TRIAL_NUM ) - Draws an image of the requested trial
%   DRAW_RW_TRIAL(BDF, TRIAL_NUM) creates a new figure showing the hand
%   position over the duration of a single random walk trial.  
%
%   Trials are numbered from 1-N by databurst.  Targets are drawn at the 
%   specified size and circles are placed where targets were hit and to 
%   indicate the beginning and end of the of the trial

% $Id$

addpath lib

if trial_num > size(bdf.databursts, 1) || trial_num <= 0
    error('The requested trial number does not exist');
end

sc = hex2dec('12'); % start code
ec = hex2dec('20'); % end code
tc = hex2dec('31'); % target hit code
cm = hex2dec('F0'); % code mask

trial_start_events = find( bitand(bdf.words(:,2), cm) == bitand(cm, sc) );
trial_start_times  = bdf.words(trial_start_events, 1);

trial_end_events = bitand(bdf.words(:,2), cm) == bitand(cm, ec);
trial_end_times  = bdf.words(trial_end_events, 1);

% Confirm that all trials are random walk trials
if ~isempty( find( bdf.words(trial_start_events, 2) ~= sc , 1) )
    error('Non-random walk trials found');
end

db_time = bdf.databursts{trial_num, 1};
start_time = trial_start_times( find( trial_start_times < db_time, 1, 'last' ) );
end_time = trial_end_times( find( trial_start_times > db_time, 1, 'first' ) );

start_idx = find(bdf.pos(:,1) > start_time, 1, 'first');
end_idx = find(bdf.pos(:,1) > end_time, 1, 'first');

target_hit_times = bdf.words( bdf.words(:,2) == tc , 1);
target_hit_times = target_hit_times( target_hit_times > start_time & target_hit_times < end_time);
[trash, target_hit_idx] = min( abs(repmat(bdf.pos(:,1),1,size(target_hit_times,1)) - repmat(target_hit_times',size(bdf.pos,1),1)) );

% Adjust position signal for offset
offset = [2, -33.5];
pos = bdf.pos(:,2:3) - repmat(offset, length(bdf.pos), 1);

bytes = bdf.databursts{trial_num, 2};
target_coords = bytes2float( bytes(3:end) ); 
target_coords = reshape(target_coords, 2, [])';

% Plotting routines follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
hold on;

% plot hand coords
plot(pos(start_idx:end_idx,1), pos(start_idx:end_idx,2), 'k-'); % Position trace
plot(pos(start_idx,1),         pos(start_idx,2),         'go'); % Start position
plot(pos(end_idx,1),           pos(end_idx,2),           'ro'); % End position
plot(pos(target_hit_idx,1),    pos(target_hit_idx,2),    'ko'); % Target positions

% Draw targets
d = target_size / 2;
for i = 1:size(target_coords, 1)
    tx = target_coords(i,1);
    ty = target_coords(i,2);
    x = [tx-d, tx+d, tx+d, tx-d, tx-d];
    y = [ty+d, ty+d, ty-d, ty-d, ty+d];
    plot(x, y);
end

rmpath lib




