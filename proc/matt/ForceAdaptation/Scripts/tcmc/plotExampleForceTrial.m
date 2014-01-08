

baseDir = 'Z:\MrT_9I4\Matt\ProcessedData';

paramSetName = 'late';

ffColor = 'b';
vrColor = 'r';

outTargColor = [0.7 0 0];
inTargColor = [0 0.7 0];

xoffset = 5;
yoffset = -35;



%% Show example force trial
useDate = '2013-08-23';

forceAng = -85.*pi/180;
forceScale = 0.33;
numArrows = 20;

% data = load(fullfile(baseDir, useDate,['CO_FF_AD_' useDate '.mat']));
% mt = filterMovementTable(data,paramSetName,false);
% t = data.cont.t;
% pos = data.cont.pos;
% vel = data.cont.vel;
% f = data.cont.force;
% clear data;

targDist = 8;
targAngle = pi/4;
targNum = 7; %how many from end

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
usePos = pos(t>=trial(2) & t<trial(end),:);
usePos(:,1) = usePos(:,1)-xoffset;
usePos(:,2) = usePos(:,2)-yoffset;
plot(usePos(:,1),usePos(:,2),'b','LineWidth',3);

useF = f(t>=trial(2) & t<trial(end),:);

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
arrow('Start',[4.6 0],'Stop',[4 0],'Width',3);
% text(5,0,[num2str(max(arrmag)/forceScale,2) ' N'],'FontSize',16)
text(4.8,0,'Force','FontSize',16)

plot([4 4.6],[0.7 0.7],'b','LineWidth',3);
text(4.8,0.7, 'Hand Position','FontSize',16);