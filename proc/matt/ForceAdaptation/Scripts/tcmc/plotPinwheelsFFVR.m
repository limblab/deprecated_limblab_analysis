%%%% 2) Show pinwheels for FF and VR
%% force fields

plotXshift = 22.5;
plotYshift = 23;

useDate = '2013-08-23';
numMoves = 1;
numTargs = 8;
targDist = 9;
xoffset = 5;
yoffset = -35;

% baseline
load(fullfile(baseDir,useDate,['CO_FF_BL_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

fh = figure('Position', [50, 50, 1300, 900]);
hold all;
% plot target locations
for j=1:numTargs
    xcenter = targDist.*cos((j-1).*pi/4);
    ycenter = targDist.*sin((j-1).*pi/4);
    
    rectangle('Position',[xcenter-1, ycenter-1, 2, 2],'FaceColor','r');
end
rectangle('Position',[-1,-1,2,2],'FaceColor','g');

% pick first movements to each target
for i=1:numTargs
    useInds = find(tt(:,2)==i-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==i-1,numMoves,'last');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'b','LineWidth',2);
    end
end

% adaptation
load(fullfile(baseDir, useDate,['CO_FF_AD_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

pos(:,1) = pos(:,1)+plotXshift;

% plot target locations
for j=1:numTargs
    xcenter = targDist.*cos((j-1).*pi/4)+plotXshift;
    ycenter = targDist.*sin((j-1).*pi/4);
    
    rectangle('Position',[xcenter-1, ycenter-1, 2, 2],'FaceColor','r');
end
rectangle('Position',[-1+plotXshift,-1,2,2],'FaceColor','g');

% pick first movements to each target
for i=1:numTargs
    useInds = find(tt(:,2)==i-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==i-1,numMoves,'last');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'b','LineWidth',2);
    end
end

% washout
load(fullfile(baseDir,useDate,['CO_FF_WO_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

pos(:,1) = pos(:,1)+2*plotXshift;

% plot target locations
for j=1:numTargs
    xcenter = targDist.*cos((j-1).*pi/4)+2*plotXshift;
    ycenter = targDist.*sin((j-1).*pi/4);
    
    rectangle('Position',[xcenter-1, ycenter-1, 2, 2],'FaceColor','r');
end
rectangle('Position',[-1+2*plotXshift,-1,2,2],'FaceColor','g');

% pick first movements to each target
for i=1:numTargs
    useInds = find(tt(:,2)==i-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==i-1,numMoves,'last');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'b','LineWidth',2);
    end
end

% visual rotations
useDate = '2013-09-03';

% baseline
load(fullfile(baseDir, useDate,['CO_VR_BL_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

pos(:,2) = pos(:,2) - plotYshift;

% plot target locations
for j=1:numTargs
    xcenter = targDist.*cos((j-1).*pi/4);
    ycenter = targDist.*sin((j-1).*pi/4) - plotYshift;
    
    rectangle('Position',[xcenter-1, ycenter-1, 2, 2],'FaceColor','r');
end
rectangle('Position',[-1,-1-plotYshift,2,2],'FaceColor','g');
% pick first movements to each target
for i=1:numTargs
    useInds = find(tt(:,2)==i-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==i-1,numMoves,'last');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'b','LineWidth',2);
    end
end

% adaptation
load(fullfile(baseDir,useDate,['CO_VR_AD_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

pos(:,1) = pos(:,1)-xoffset;
pos(:,2) = pos(:,2)-yoffset;
% rotate the position data to be what monkey sees
th = 30*pi/180;
R = [cos(th) -sin(th); sin(th) cos(th)];
for j = 1:length(pos)
    pos(j,:) = R*(pos(j,:)');
end

pos(:,1) = pos(:,1)+plotXshift;
pos(:,2) = pos(:,2)-plotYshift;

% plot target locations
for j=1:numTargs
    xcenter = targDist.*cos((j-1).*pi/4)+plotXshift;
    ycenter = targDist.*sin((j-1).*pi/4)-plotYshift;
    
    rectangle('Position',[xcenter-1, ycenter-1, 2, 2],'FaceColor','r');
end
rectangle('Position',[-1+plotXshift,-1-plotYshift,2,2],'FaceColor','g');

% pick first movements to each target
for i=1:numTargs
    useInds = find(tt(:,2)==i-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1),usePos(:,2),'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==i-1,numMoves,'last');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1),usePos(:,2),'b','LineWidth',2);
    end
end

% washout
load(fullfile(baseDir,useDate,['CO_VR_WO_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

pos(:,1) = pos(:,1) + 2*plotXshift;
pos(:,2) = pos(:,2) - plotYshift;
% plot target locations
for j=1:numTargs
    xcenter = targDist.*cos((j-1).*pi/4)+2*plotXshift;
    ycenter = targDist.*sin((j-1).*pi/4)-plotYshift;
    
    rectangle('Position',[xcenter-1, ycenter-1, 2, 2],'FaceColor','r');
end
rectangle('Position',[-1+2*plotXshift,-1-plotYshift,2,2],'FaceColor','g');

% pick first movements to each target
for i=1:numTargs
    useInds = find(tt(:,2)==i-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==i-1,numMoves,'last');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'b','LineWidth',2);
    end
end


% make a legend
plot([-10 -5],[13 13],'Color','r','LineWidth',3);
plot([7 12],[13 13],'Color','b','LineWidth',3);
text(-4,13,'First Movement','FontSize',16);
text(13,13,'Last Movement','FontSize',16);

set(gca,'XTick',[0 plotXshift 2*plotXshift],'XTickLabel',{'Baseline', 'Adaptation', 'Washout'},'YTick',[-plotYshift 0],'YTickLabel',{'Visual Rotation','Force Field'},'TickLength',[0 0],'FontSize',16)
axis([-11 11+2*plotXshift -11-plotYshift 16])
