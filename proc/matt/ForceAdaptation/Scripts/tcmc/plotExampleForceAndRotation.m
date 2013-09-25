%% Show example force trial
useDate = '2013-08-23';

forceAng = -85.*pi/180;
forceScale = 0.33;
numArrows = 20;

plotXShift = 8;

targDist = 8;
targAngle = pi/4;
targNum = 7; %how many from end

beginCut = 1;

load(fullfile(baseDir, useDate,['CO_FF_AD_' useDate '.mat']));
mt = filterMovementTable(data);
t = data.cont.t;
pos = data.cont.pos;
vel = data.cont.vel;
f = data.cont.force;
clear data;

fh = figure('Position', [200, 200, 1200, 600]);
hold all;
% plot target locations
xcenter = targDist.*cos(targAngle);
ycenter = targDist.*sin(targAngle);

rectangle('Position',[xcenter, ycenter, 1, 1],'FaceColor',outTargColor);
rectangle('Position',[0,0,1,1],'FaceColor',inTargColor);
% axis('square');

% pick movement
useInds = find(mt(:,1)==pi/4,targNum,'last');
trial = mt(useInds(1),:);
usePos = pos(t>=trial(2)+beginCut & t<trial(end),:);
usePos(:,1) = usePos(:,1)-xoffset;
usePos(:,2) = usePos(:,2)-yoffset;

plot(usePos(:,1),usePos(:,2),ffColor,'LineWidth',3);

useF = f(t>=trial(2)+beginCut & t<trial(end),:);

axis([-0.5 7 -0.5 7]);
set(gca,'YTick',[],'XTick',[],'FontSize',16);

% plot force arrows
useDist = sqrt((usePos(end,1)-usePos(1,1))^2 + (usePos(end,2)-usePos(1,2))^2);
useAng = atan2(usePos(end,2)-usePos(1,2),usePos(end,1)-usePos(1,1));
% find places along path to target to place arrows

origin = [usePos(1,1) usePos(1,2)];
arrvec = 0:useDist/1000:useDist;
arrvec = [arrvec'.*cos(useAng) arrvec'.*sin(useAng)];

arrpts = int16(linspace(1,length(arrvec)-1,numArrows));

% directional vector for projection
arrVec = [usePos(end,1)-origin(1), usePos(end,2)-origin(2)];
% find index where projection of pos onto line is  greater
temp = zeros(length(usePos),1);
for j = 1:length(usePos)
    % dx dy theta
    posVec = [usePos(j,1)-origin(1), usePos(j,2)-origin(2)];
    
    ang = dot(posVec,arrVec)/(norm(posVec)*norm(arrVec));
    tempProj = (dot(posVec,arrVec)/norm(arrVec)^2)*arrVec;
    
    temp(j) = norm(tempProj);
end

arrmag = zeros(numArrows,1);
for i = 1:numArrows
    arr = arrvec(arrpts(i),:);
    startPos = [arr(1)+origin(1) arr(2)+origin(2)];
    
    arrDist = sqrt( (startPos(1)-origin(1))^2 + (startPos(2)-origin(2))^2 );
    
    %     relPos = useF( find(temp > arrDist,1,'first') ,:);
    relPos = useF( find(temp > arrDist,1,'first') ,:);
    
    %     arrmag = forceScale*sqrt( (relPos(1)-startPos(1)).^2 + (relPos(2)-startPos(2)).^2 );
    arrmag(i) = forceScale*sqrt( (relPos(1)).^2 + (relPos(2)).^2 );
    
    endPos = [startPos(1)+arrmag(i)*cos(angleDiff(useAng,forceAng,true)) startPos(2)+arrmag(i)*sin(angleDiff(useAng,forceAng,true))];
    
    arrow('Start',startPos,'Stop',endPos,'Width',3);
end



% add a legend to show how much force is applied
arrow('Start',[4+max(arrmag) 0.5],'Stop',[4 0.5],'Width',3);
text(4,0.1,[num2str(max(arrmag)/forceScale,2) ' N'],'FontSize',14)

% add a title
text(2,7.5,'Force Field','FontSize',18);


%% Show an example movement with a rotation
useDate = '2013-09-03';

rotAng = 30*pi/180;
barMag = 5;

load(fullfile(baseDir, useDate,['CO_VR_AD_' useDate '.mat']));
mt = filterMovementTable(data);
t = data.cont.t;
pos = data.cont.pos;
vel = data.cont.vel;
f = data.cont.force;
clear data;

targDist = 8;
targAngle = pi/4;
targNum = 7; %how many from end

% plot target locations
xcenter = targDist.*cos(targAngle);
ycenter = targDist.*sin(targAngle);

rectangle('Position',[xcenter+plotXShift, ycenter, 1, 1],'FaceColor',outTargColor);
rectangle('Position',[0+plotXShift,0,1,1],'FaceColor',inTargColor);
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


% add lines to show shift
realDir = pi+atan2(handPos(int16(length(handPos)/10),2)-handPos(1,2),handPos(int16(length(handPos)/10),1)-handPos(1,1));
plot([handPos(1,1) handPos(1,1)+barMag*cos(realDir)]+plotXShift,[handPos(1,2) handPos(1,2)+barMag*sin(realDir)],'k','LineWidth',2);
plot([handPos(1,1) handPos(1,1)+barMag*cos(realDir+rotAng)]+plotXShift,[handPos(1,2) handPos(1,2)+barMag*sin(realDir+rotAng)],'k','LineWidth',2);

% draw arc to show perturbation
% add an arch
n = 1000; % The number of points in the arc

v1 = [handPos(1,1)+barMag/2*cos(realDir); handPos(1,2)+barMag/2*sin(realDir)];
v2 = [handPos(1,1)+barMag/2*cos(realDir+rotAng); handPos(1,2)+barMag/2*sin(realDir+rotAng)];

c = det([v1,v2]); % "cross product" of v1 and v2
a = linspace(0,atan2(abs(c),dot(v1,v2)),n); % Angle range
v3 = [0,-c;c,0]*v1; % v3 lies in plane of v1 and v2 and is orthog. to v1
v = v1*cos(a)+((norm(v1)/norm(v3))*v3)*sin(a); % Arc, center at (0,0)
plot(v(1,:)+plotXShift,v(2,:),'k','LineWidth',2); % Plot arc, centered at P0

text(1.4+plotXShift,3.5,[num2str(rotAng.*180/pi,2) char(176)],'FontSize',16);

% plot the trajectories
plot(handPos(:,1)+plotXShift,handPos(:,2),'Color',vrColor,'LineWidth',3);
plot(cursPos(:,1)+plotXShift,cursPos(:,2),'--','Color',vrColor,'LineWidth',3);

axis([-0.5 8.5+plotXShift -0.5 8]);
set(gca,'YTick',[],'XTick',[],'FontSize',16);

% add a legend
plot([3 4]+plotXShift,[0.7 0.7],'Color',vrColor,'LineWidth',3);
text(4.2+plotXShift,0.7, 'Hand Position','FontSize',16);
plot([3 4]+plotXShift,[0 0],'--','Color',vrColor,'LineWidth',3);
text(4.2+plotXShift,0, 'Cursor Position','FontSize',16);

% add a title
text(10,7.5,'Visual Rotation','FontSize',18);