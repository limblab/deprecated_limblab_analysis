function Performance
% Calculate performance metrics for robot tasks
% Currently: only explicitly implemented for RW (3.14.12)

%% Initialization
%-Word Values, from 'words.h'
% START_TRIAL:    16  0x10
% RW_TASK_CODE:   2   0x02      RW_START = RW_TASK_CODE | START_TRIAL
% END_TRIAL:      32  0x20      TRIAL_END = END_TRIAL | END_CODE
% RWD_CODE:       0   0x00  |
% ABT_CODE:       1   0x01  |- trial end codes
% FAIL_CODE:      2   0x02  |
% INC_CODE:       3   0x03  |
% ORIGIN_TARG_ON: 48  0x30
% CATCH_TRIAL:    50  0x32
% DEST_TARG_ON:   64  0x40
% MVMNT_ONSET:    128 0x80
% WORD_PICKUP:    144 0x90
% CT_HOLD:        160 0xA0
% TARG_HOLD:      160 0xA0
% OT_HOLD:        161 0xA1


%-Initialize word values
RW_START  = 18;     % 0x10 | 0x02
TARG_HOLD = 160;    % 0xA0
REWARD    = 32;     % 0x20 | 0x00

%-Initialize variables
words = binnedData.words;

%Trial information
trial_idcs = find(words(:,2)==RW_START);
trial_ts   = words(trial_idcs,1);
entry_idcs = find(words(trial_idcs(1):length(words),2)==TARG_HOLD)+trial_idcs(1)-1;
entry_ts   = words(entry_idcs,1);
num_trials = length(trial_idcs);
rwd_idcs   = find(words(entry_idcs(1):length(words),2)==REWARD);


%% Find initial time to target for each trial
time2target = zeros(num_trials-1,1);
count = 1;
for i = 2:length(words)-1
    if (words(i-1,2)==RW_START) && (words(i,2)==49) && (words(i+1,2)==TARG_HOLD)
        time2target(count) = words(i+1,1) - words(i,1);
        count = count + 1;
    end
end


%% Find number of target entries per trial
entrycount = zeros(num_trials,1);
% For each trial...
for trial = 1:num_trials-1
    
    % Count number of target entries in a given trial
    for i = trial_idcs(trial):trial_idcs(trial+1)
        if words(i,2)==TARG_HOLD
            entrycount(trial) = entrycount(trial) + 1;
        end
    end
    
end

% Plot entries/target
avgEntries = mean(entrycount);
x = min(entrycount):max(entrycount);
figure
hist(entrycount,x)
title('Histogram of Entries per Target')

time = 1:length(entrycount);
figure
plot(time,entrycount)
title('Entries per Target vs. Time')
%plot(entrycount)


%% Find path length to target
pathlength = zeros(sum(entrycount),4);
cursorstartstop = zeros(sum(entrycount),3);
for i = 1:sum(entrycount)
    %put this back in once "24" is figured out if words(entry_idcs(i)-1,2)==49,
        if mod(100*words(entry_idcs(i)-1,1),5)>=2.5
           cursorstartstop(i,1) = find((binnedData.timeframe)==single(round(10*words(entry_idcs(i)-1,1))/10+0.05));
        else
           cursorstartstop(i,1) = find((binnedData.timeframe)==single(floor(10*words(entry_idcs(i)-1,1))/10)); 
        end
        if mod(100*words(entry_idcs(i),1),5)>=2.5
            cursorstartstop(i,2) = find((binnedData.timeframe)==single(round(10*words(entry_idcs(i),1))/10+0.05));
        else
            cursorstartstop(i,2) = find((binnedData.timeframe)==single(round(10*words(entry_idcs(i),1))/10));
        end
        if words(entry_idcs(i)-2,2)==RW_START,
            cursorstartstop(i,3) = 1;
        end
    %end
end
pathlength(:,4) = cursorstartstop(:,3);

for i = 1:sum(entrycount)
    s = 0;
    for j = cursorstartstop(i,1):cursorstartstop(i,2)-1
       ds = sqrt(abs((binnedData.cursorposbin(j+1,1)-binnedData.cursorposbin(j,1))^2)+abs((binnedData.cursorposbin(j+1,2)-binnedData.cursorposbin(j,2))^2));
        s = s + ds;
    end
    pathlength(i,1) = s;
    pathlength(i,2) = sqrt(abs(binnedData.cursorposbin(cursorstartstop(i,2),1)-binnedData.cursorposbin(cursorstartstop(i,1),1))^2+abs(binnedData.cursorposbin(cursorstartstop(i,2),2)-binnedData.cursorposbin(cursorstartstop(i,1),2))^2);
    pathlength(i,3) = pathlength(i,1)/pathlength(i,2);
end

% Plot path length efficiency
firsttries = find(pathlength(:,4)==1);
firstpathlength = pathlength(firsttries,3);
figure
plot(firstpathlength)
title('Initial Path Length Efficiency vs. Time')

clear x
x = min(firstpathlength):max(firstpathlength);
figure
hist(firstpathlength,x)
title('Histogram of Initial Path Length Efficiency')

time2target(:,2) = time2target(:,1)./firstpathlength;
figure
hist(time2target(:,2))
title('Histogram of Time to Target/Min Path Length')


%% Find variance within target before reward
holddata = zeros(length(rwd_idcs),4);
for i = 1:length(rwd_idcs)
    % put back later if words(rwd_idcs(i)-1,2)==TARG_HOLD,
    if mod(100*words(rwd_idcs(i)-1,1),5)>=2.5
       holddata(i,1) = find((binnedData.timeframe)==single(round(10*words(rwd_idcs(i)-1,1))/10+0.05));
    else
       holddata(i,1) = find((binnedData.timeframe)==single(floor(10*words(rwd_idcs(i)-1,1))/10)); 
    end
    if mod(100*words(rwd_idcs(i),1),5)>=2.5
       holddata(i,2) = find((binnedData.timeframe)==single(round(10*words(rwd_idcs(i),1))/10+0.05));
    else
       holddata(i,2) = find((binnedData.timeframe)==single(round(10*words(rwd_idcs(i),1))/10));
    end
    %end
    xmean = mean(binnedData.cursorposbin(holddata(i,1):holddata(i,2),1));
    xvar = var(binnedData.cursorposbin(holddata(i,1):holddata(i,2),1));
    ymean = mean(binnedData.cursorposbin(holddata(i,1):holddata(i,2),2));
    yvar = var(binnedData.cursorposbin(holddata(i,1):holddata(i,2),2));
    j = holddata(i,1):holddata(i,2);
    r = sqrt((binnedData.cursorposbin(j,1)-xmean*ones(size(j'))).^2+(binnedData.cursorposbin(j,2)-ymean*ones(size(j'))).^2);
    rmean = mean(r);
    rvar = var(r);
end
