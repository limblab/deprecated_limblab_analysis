close all;

baseDir = 'Z:\MrT_9I4\Matt\ProcessedData';

paramSetName = 'late';

ffColor = 'b';
vrColor = 'r';

outTargColor = [0.7 0 0];
inTargColor = [0 0.7 0];

xoffset = 5;
yoffset = -35;




%% Show an example movement with a rotation
useDate = '2013-09-03';

rotAng = 30*pi/180;
barMag = 5;

% data = load(fullfile(baseDir, useDate,['CO_VR_AD_' useDate '.mat']));
% mt = filterMovementTable(data,paramSetName,false);
% t = data.cont.t;
% pos = data.cont.pos;
% vel = data.cont.vel;
% f = data.cont.force;
% clear data;

targDist = 8;
targAngle = pi/4;
targNum = 4; %how many from end

fh = figure('Position', [200, 200, 600, 600]);
hold all;
% plot target locations
xcenter = targDist.*cos(targAngle);
ycenter = targDist.*sin(targAngle);

rectangle('Position',[xcenter, ycenter, 1, 1],'FaceColor','r');
rectangle('Position',[0,0,1,1],'FaceColor','g');
% axis('square');

% pick movement
useInds = find(mt(:,1)==pi/4,targNum,'last');
trial = mt(useInds(1),:);
handPos = pos(t>=trial(2) & t<trial(end),:);
handPos(:,1) = handPos(:,1)-xoffset;
handPos(:,2) = handPos(:,2)-yoffset;

% rotate the position data to be what monkey sees
cursPos = zeros(size(handPos));
R = [cos(rotAng) -sin(rotAng); sin(rotAng) cos(rotAng)];
for j = 1:length(handPos)
    cursPos(j,:) = R*(handPos(j,:)');
end

% adjust for an offset from my math above
offset = [cursPos(1,1)-handPos(1,1), cursPos(1,2)-handPos(1,2)];
handPos(:,1) = handPos(:,1)+offset(1);
handPos(:,2) = handPos(:,2)+offset(2);

% 
% % add lines to show shift
% realDir = pi+atan2(handPos(int16(length(handPos)/10),2)-handPos(1,2),handPos(int16(length(handPos)/10),1)-handPos(1,1));
% plot([handPos(1,1) handPos(1,1)+barMag*cos(realDir)],[handPos(1,2) handPos(1,2)+barMag*sin(realDir)],'k','LineWidth',2);
% plot([handPos(1,1) handPos(1,1)+barMag*cos(realDir+rotAng)],[handPos(1,2) handPos(1,2)+barMag*sin(realDir+rotAng)],'k','LineWidth',2);
% 
% % draw arc to show perturbation
% % add an arch
% n = 1000; % The number of points in the arc
% 
% v1 = [handPos(1,1)+barMag/2*cos(realDir); handPos(1,2)+barMag/2*sin(realDir)];
% v2 = [handPos(1,1)+barMag/2*cos(realDir+rotAng); handPos(1,2)+barMag/2*sin(realDir+rotAng)];
% 
% c = det([v1,v2]); % "cross product" of v1 and v2
% a = linspace(0,atan2(abs(c),dot(v1,v2)),n); % Angle range
% v3 = [0,-c;c,0]*v1; % v3 lies in plane of v1 and v2 and is orthog. to v1
% v = v1*cos(a)+((norm(v1)/norm(v3))*v3)*sin(a); % Arc, center at (0,0)
% plot(v(1,:),v(2,:),'k','LineWidth',2); % Plot arc, centered at P0
% 
% text(1.4,3.5,[num2str(rotAng.*180/pi,2) char(176)],'FontSize',16);

% plot the trajectories
plot(handPos(:,1),handPos(:,2),'r--','LineWidth',3);
plot(cursPos(:,1),cursPos(:,2),'r','LineWidth',3);

axis([-0.5 8.5 -0.5 8]);
set(gca,'YTick',[],'XTick',[],'FontSize',16);

% add a legend to show how much force is applied
plot([4 5],[0.7 0.7],'r','LineWidth',3);
text(5.2,0.7, 'Cursor Position','FontSize',16);
plot([4 5],[0 0],'r--','LineWidth',3);
text(5.2,0, 'Hand Position','FontSize',16);
