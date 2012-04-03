function stat_struct = BR_performance_stats(varargin)
% Calculate performance metrics for robot tasks
% Currently: only implemented for RW (March 2012)
% 
% INPUT: 'binnedData' struct. To analyze all trials instead
% of only successful trials, include the string 'all' as a 2nd argument.
% OUTPUT: 'stat_struct' struct, with fields...
%   *stat_struct.time2target
%   *stat_struct.num_entries
%   *stat_struct.pathlength
%   *stat_struct.firstpathlength (lengths for only initial reaches of each trial)
%   *stat_struct.holddata

%% Initialization
%-Word Values from 'words.h'
% START_TRIAL:    16  0x10
% RW_TASK_CODE:   2   0x02      RW_START  = RW_TASK_CODE | START_TRIAL
% END_TRIAL:      32  0x20      TRIAL_END =    END_TRIAL | END_CODE
% RWD_CODE:       0   0x00  |
% ABT_CODE:       1   0x01  |- trial end codes
% FAIL_CODE:      2   0x02  |
% INC_CODE:       3   0x03  |
% ORIGIN_TARG_ON: 48  0x30
% GO_CUE:         49  0x31
% CATCH_TRIAL:    50  0x32
% DEST_TARG_ON:   64  0x40
% MVMNT_ONSET:    128 0x80
% WORD_PICKUP:    144 0x90
% CT_HOLD:        160 0xA0
% TARG_HOLD:      160 0xA0
% OT_HOLD:        161 0xA1

%-Initialize word values
RW_START  = 18;     % 0x10 | 0x02
GO_CUE    = 49;     % 0x31
TARG_HOLD = 160;    % 0xA0
REWARD    = 32;     % 0x20 | 0x00

% Can later expand to include other behaviors, setting start_trial value
% based on what is in the words
if 1
    START_TRIAL = RW_START;
end

%-Parse input argument(s)
binnedData = varargin{1};
do_all_trials = 0;
if (nargin > 1) && strcmp('all',varargin{2})
    do_all_trials = 1;
end

%-Initialize variables... 
% ...give these suckers some shorter names
time  = binnedData.timeframe;
pos   = binnedData.cursorposbin;
words = binnedData.words;
% remove non-succesful trials if we desire (default=do this)
if ~do_all_trials
    words = remove_fails(words, START_TRIAL);
end
ts     = words(:,1); % we reference these often enough to give them their own arrays
events = words(:,2);

%-Session information by trial
start_idcs = find(events == START_TRIAL);
entry_idcs = find(events(start_idcs(1):end) == TARG_HOLD) + start_idcs(1) - 1; %correct for offset introduced by starting find index at 'start_idcs(1)'
rwd_idcs   = find(events(start_idcs(1):end) == REWARD) + start_idcs(1) - 1;
% start_ts   = ts(start_idcs);
% entry_ts   = ts(entry_idcs);
num_trials = length(start_idcs);

%% TO-DO
%
%-pull out all plotting functions, create 'plot_BR_performance' function
%-create 'Batch_BR_performance' function
%   *select files with uigetdir/uigetfile
%   *create cell array; each cell contains 'stat_struct' for a file
%   *create 2nd struct that mirrors structure of 'stat_struct' but with
%   combined stats for all files
%   *add field to 'stat_struct' containing the .mat file name

%% Find time to first target for each trial
% Pretty straightforward, yeah?
time2target = zeros(num_trials-1,1);
disp(sprintf('Number of trials: %i.', num_trials));
count = 1;
for i = 2:length(words)-1
    if ( (events(i-1) == START_TRIAL) && (events(i) == GO_CUE) && (events(i+1) == TARG_HOLD) )
        time2target(count) = ts(i+1) - ts(i);
        count = count + 1;
    end
end
disp(sprintf('Number of times-to-target calculated: %i.', count-1)); %check to make sure we're catching everything.
disp(sprintf('Mean time to initial target: %d seconds.',mean(time2target)));
stat_struct.time2target = time2target;


%% Find number of target entries per trial
% Is this metric useful for RW tasks? (beyond using it to calculate path
% lengths)

num_entries = zeros(num_trials,1);
for trial = 1:num_trials%-1
    
    %should be fine, but let's do a dummy check...
    if start_idcs(trial) < rwd_idcs(trial)
        % Count number of target entries in a given trial
        this_trial = events(start_idcs(trial):rwd_idcs(trial));%start_idcs(trial+1));
        holds      = find(this_trial == TARG_HOLD);
        num_entries(trial) = length(holds);
    else
        disp('Trial-start and -reward indices not appropriately lined up. Fix initialization.');
        num_entries(trial) = -1;
    end
    
end
stat_struct.num_entries = num_entries;
disp(sprintf('Mean number of target entries per trial: %d.',mean(num_entries)));

% % Plot entries/target
% avgEntries = mean(num_entries);
% x = min(num_entries):max(num_entries);
% figure
% hist(num_entries,x)
% title('Histogram of Entries per Target')
% 
% t = 1:length(num_entries);
% figure
% plot(t,num_entries)
% title('Entries per Target vs. Time')
% %plot(num_entries)


%% Find path length to target

total_entries = sum(num_entries);
pathlength = zeros(total_entries,4);
start = zeros(total_entries,1);
stop  = zeros(total_entries,1);

ts_round = single(round(10*ts)/10 + 0.05);
ts_floor = single(floor(10*ts)/10);
for i = 1:total_entries

        if mod(100*ts(entry_idcs(i)-1),5) >= 2.5
           start(i) = find(time == ts_round(entry_idcs(i)-1));
        else
           start(i) = find(time == ts_floor(entry_idcs(i)-1));
        end
        if mod(100*ts(entry_idcs(i)),5) >= 2.5
            stop(i) = find(time == ts_round(entry_idcs(i)));
        else
            stop(i) = find(time == ts_floor(entry_idcs(i)));
        end
        if events(entry_idcs(i)-2) == START_TRIAL
            pathlength(i,4) = 1;
        end

end


qx = pos(:,1); %mind your p's and q's... (bad physics joke)
qy = pos(:,2);
for i = 1:sum(num_entries)
    s = 0;
    for j = start(i):stop(i)-1
       ds = distance( qx(j), qy(j), qx(j+1), qy(j+1) );
       s = s + ds;
    end
    pathlength(i,1) = s;
    pathlength(i,2) = distance( qx(start(i)), qy(start(i)), qx(stop(i)), qy(stop(i)) );
    pathlength(i,3) = pathlength(i,1)/pathlength(i,2);
end
stat_struct.pathlength = pathlength;

% Plot path length efficiency
firsts = find(pathlength(:,4));
firstpath = pathlength(firsts,3);
stat_struct.firstpathlength = firstpath;
% figure
% plot(firstpathlength)
% title('Initial Path Length Efficiency vs. Time')

% clear x
% x = min(firstpathlength):max(firstpathlength);
% figure
% hist(firstpathlength,x)
% title('Histogram of Initial Path Length Efficiency')

% time2target(:,2) = time2target(:,1)./firstpathlength;
% figure
% hist(time2target(:,2))
% title('Histogram of Time to Target/Min Path Length')


%% Find variance within target before reward
% Is it worth expanding this section to include all successful target
% holds? (this only gives data on the final target in a successful trial -
% it would be possible to also do all target holds that are successfully
% completed)

holddata = zeros(length(rwd_idcs),4);
for i = 1:length(rwd_idcs)
 
    % Get beginning and end indices of reward-yielding holds
    if mod(100*ts(rwd_idcs(i)-1),5) >= 2.5
       hold_start = find(time == ts_round(rwd_idcs(i)-1));
    else
       hold_start = find(time == ts_floor(rwd_idcs(i)-1)); 
    end
    if mod(100*ts(rwd_idcs(i)),5) >= 2.5
       hold_stop = find(time == ts_round(rwd_idcs(i)));
    else
       hold_stop = find(time == ts_floor(rwd_idcs(i)));
    end

    xmean = mean(qx(hold_start:hold_stop));
    ymean = mean(qy(hold_start:hold_stop));
%   xvar  =  var(qx(hold_start:hold_stop));
%   yvar  =  var(qy(hold_start:hold_stop));
    j = (hold_start:hold_stop)';
    r = sqrt( (qx(j) - xmean*ones(size(j))).^2 + (qy(j) - ymean*ones(size(j))).^2 );
    rmean = mean(r);
    rvar  =  var(r);
    
    holddata(i,:) = [ hold_start hold_stop rmean rvar ];

end
stat_struct.holddata = holddata;


%% Internal Functions

function ds = distance(x1,y1,x2,y2)

ds = sqrt( (x2-x1)^2 + (y2-y1)^2 );





