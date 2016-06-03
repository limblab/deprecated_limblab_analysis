% Calculating Performance Metrics

%Trial information
trialindices = find(binnedData.words(:,2)==18);
trialtimes = binnedData.words(trialindices,1);
entryindices = find(binnedData.words(trialindices(1):length(binnedData.words),2)==160)+trialindices(1)-1;
entrytimes = binnedData.words(entryindices,1);
trialcount = length(trialindices);
rewardindices = find(binnedData.words(entryindices(1):length(binnedData.words),2)==32);

%Find initial time to target for each trial
time2target = zeros(trialcount-1,1);
count = 1;
for i = 2:length(binnedData.words)-1
    if (binnedData.words(i-1,2)==18)&&(binnedData.words(i,2)==49)&&(binnedData.words(i+1,2)==160)
        time2target(count) = binnedData.words(i+1,1)-binnedData.words(i,1);
        count = count+1;
    end
end

%Find number of target entries per trial
entrycount = zeros(trialcount,1);
for trial = 1:trialcount-1
    for i = trialindices(trial):trialindices(trial+1)
        if binnedData.words(i,2)==160
            entrycount(trial) = entrycount(trial)+1;
        end
    end
end
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

%Find path length to target
pathlength = zeros(sum(entrycount),4);
cursorstartstop = zeros(sum(entrycount),3);
for i = 1:sum(entrycount)
    %put this back in once "24" is figured out if binnedData.words(entryindices(i)-1,2)==49,
        if mod(100*binnedData.words(entryindices(i)-1,1),5)>=2.5
           cursorstartstop(i,1) = find((binnedData.timeframe)==single(round(10*binnedData.words(entryindices(i)-1,1))/10+0.05));
        else
           cursorstartstop(i,1) = find((binnedData.timeframe)==single(floor(10*binnedData.words(entryindices(i)-1,1))/10)); 
        end
        if mod(100*binnedData.words(entryindices(i),1),5)>=2.5
            cursorstartstop(i,2) = find((binnedData.timeframe)==single(round(10*binnedData.words(entryindices(i),1))/10+0.05));
        else
            cursorstartstop(i,2) = find((binnedData.timeframe)==single(round(10*binnedData.words(entryindices(i),1))/10));
        end
        if binnedData.words(entryindices(i)-2,2)==18,
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

%Find variance within target before reward
holddata = zeros(length(rewardindices),4);
for i = 1:length(rewardindices)
    % put back later if binnedData.words(rewardindices(i)-1,2)==160,
    if mod(100*binnedData.words(rewardindices(i)-1,1),5)>=2.5
       holddata(i,1) = find((binnedData.timeframe)==single(round(10*binnedData.words(rewardindices(i)-1,1))/10+0.05));
    else
       holddata(i,1) = find((binnedData.timeframe)==single(floor(10*binnedData.words(rewardindices(i)-1,1))/10)); 
    end
    if mod(100*binnedData.words(rewardindices(i),1),5)>=2.5
       holddata(i,2) = find((binnedData.timeframe)==single(round(10*binnedData.words(rewardindices(i),1))/10+0.05));
    else
       holddata(i,2) = find((binnedData.timeframe)==single(round(10*binnedData.words(rewardindices(i),1))/10));
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
