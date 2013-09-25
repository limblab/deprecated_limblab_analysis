%% 1) Demonstrate task (CO vs RT, FF vs VR)
% random target trace example
close all;
useDate = '2013-08-20';
filePre = 'RT_FF';

%%
close all
load(fullfile(baseDir,useDate,[filePre '_BL_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

% n=8;
% n=16;
n=26;
useTrials = n:n+1;

usePos = [];
xcenters = [];
ycenters = [];
for i =1:length(useTrials)
    trial = tt(useTrials(i),:);
    usePos = [usePos; pos(t>=trial(1) & t<trial(end-1),:)];
    xcenters = [xcenters; tt(useTrials(i),[5,10,15,20])'];
    ycenters = [ycenters; tt(useTrials(i),[6,11,16,21])'];
end


figure;
hold all;
% now plot red squares at target locations
for i = 1:2:length(xcenters)
    rectangle('Position',[xcenters(i)-1, ycenters(i)-1, 2, 2],'FaceColor','r');
end
axis('square');

plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'LineWidth',3);
set(gca,'XTick',[],'YTick',[]);

%% Now do an early adaptation example
load(fullfile(baseDir,useDate,[filePre '_AD_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

n=2;
useTrials = n:n+1;

usePos = [];
xcenters = [];
ycenters = [];
for i =1:length(useTrials)
    trial = tt(useTrials(i),:);
    usePos = [usePos; pos(t>=trial(13) & t<trial(end-1),:)];
    xcenters = [xcenters; tt(useTrials(i),[5,10,15,20])'];
    ycenters = [ycenters; tt(useTrials(i),[6,11,16,21])'];
end


figure;
hold all;
% now plot red squares at target locations
for i = 3:2:length(xcenters)
    rectangle('Position',[xcenters(i)-1, ycenters(i)-1, 2, 2],'FaceColor','r');
end
axis('square');


plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'LineWidth',3);

%% Now do a late adaptation example
load(fullfile(baseDir,useDate,[filePre '_AD_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

n=190;
useTrials = n:n+1;

usePos = [];
xcenters = [];
ycenters = [];
for i =1:length(useTrials)
    trial = tt(useTrials(i),:);
    usePos = [usePos; pos(t>=trial(13) & t<trial(end-1),:)];
    xcenters = [xcenters; tt(useTrials(i),[5,10,15,20])'];
    ycenters = [ycenters; tt(useTrials(i),[6,11,16,21])'];
end


figure;
hold all;
% now plot red squares at target locations
for i = 3:2:length(xcenters)
    rectangle('Position',[xcenters(i)-1, ycenters(i)-1, 2, 2],'FaceColor','r');
end
axis('square');


plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'LineWidth',3);