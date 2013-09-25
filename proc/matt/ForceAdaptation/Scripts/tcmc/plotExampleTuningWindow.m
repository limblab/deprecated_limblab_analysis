%% Show example movement with tuning window
useDate = '2013-09-03';
load(fullfile(baseDir, useDate,['CO_VR_BL_' useDate '.mat']));
mt = filterMovementTable(data);
t = data.cont.t;
pos = data.cont.pos;
vel = data.cont.vel;
clear data;

targDist = 8;
winSize = 0.5;
targNum = 1; %how many from end

fh = figure('Position', [200, 200, 600, 600]);
hold all;
% plot target locations
xcenter = targDist.*cos(pi/4);
ycenter = targDist.*sin(pi/4);

rectangle('Position',[xcenter, ycenter, 1, 1],'FaceColor','r');
rectangle('Position',[0,0,1,1],'FaceColor','g');
% axis('square');

% pick first movements to each target
useInds = find(mt(:,1)==pi/4,targNum,'last');
trial = mt(useInds(1),:);
usePos = pos(t>=trial(2) & t<trial(end),:);
plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'b','LineWidth',3);

% put a marker on the peak speed and draw window
tpeak = trial(5);
usePos = pos(t >= tpeak-winSize/2-.1 & t<tpeak+winSize/2-.1,:);
plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',3);
usePos = pos(find(t>=tpeak,1,'first'),:);
plot(usePos(1)-xoffset,usePos(2)-yoffset,'kd','LineWidth',3);

% now show direction
usePos = pos(t >= tpeak-winSize/2-0.1 & t<tpeak+winSize/2-0.1,:);
% plot([usePos(1,1) usePos(end,1)]-xoffset,[usePos(1,2) usePos(end,2)]-yoffset,'k--','LineWidth',2);
arrow('Start',[usePos(1,1)-xoffset usePos(1,2)-yoffset],'Stop',[usePos(end,1)-xoffset usePos(end,2)-yoffset],'Width',3);
plot([usePos(1,1) usePos(end,1)]-xoffset,[usePos(1,2) usePos(1,2)]-yoffset,'k--','LineWidth',2);

% add an arch
n = 1000; % The number of points in the arc

v1 = [1; 0];
v2 = [1; 1.2];
c = det([v1,v2]); % "cross product" of v1 and v2
a = linspace(0,atan2(abs(c),dot(v1,v2)),n); % Angle range
v3 = [0,-c;c,0]*v1; % v3 lies in plane of v1 and v2 and is orthog. to v1
v = v1*cos(a)+((norm(v1)/norm(v3))*v3)*sin(a); % Arc, center at (0,0)
plot(v(1,:)+0.5,v(2,:)+usePos(1,2)-yoffset,'k','LineWidth',2); % Plot arc, centered at P0

% add theta marker
usePos = pos(find(t>=tpeak,1,'first'),:);
text(usePos(1)-xoffset-0.5,1,'\theta','FontSize',24);

axis([-0.5 7 -0.5 7]);
set(gca,'YTick',[],'XTick',[],'FontSize',16);
