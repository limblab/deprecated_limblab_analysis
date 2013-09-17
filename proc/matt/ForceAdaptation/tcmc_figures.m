% code to throw some figures together for TCMC
%%
clear;
close all;
clc;

baseDir = 'Z:\MrT_9I4\Matt\ProcessedData';

xoffset = 5;
yoffset = -35;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1) Demonstrate task (CO vs RT, FF vs VR)
% random target trace example
close all;
useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_BL_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

n=50;
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

plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'LineWidth',2);

%%%% Now do an early adaptation example
useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_AD_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

n=8;
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

plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'LineWidth',2);

%%%% Now do a late adaptation example
useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_AD_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

n=209;
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

plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'LineWidth',2);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% center out trace example
% useDate = '2013-08-23';
% load(fullfile(baseDir,useDate,['CO_FF_BL_' useDate '.mat']));
% tt = data.trial_table;
% t = data.cont.t;
% pos = data.cont.pos;
% clear data;
%
% numMoves = 2;
% numTargs = 8;
% targDist = 8;
%
% figure;
% hold all;
% % plot target locations
% for i=1:numTargs
%     xcenter = targDist.*cos((i-1).*pi/4);
%     ycenter = targDist.*sin((i-1).*pi/4);
%
%     rectangle('Position',[xcenter-1, ycenter-1, 2, 2],'FaceColor','r');
% end
% rectangle('Position',[-1,-1,2,2],'FaceColor','g');
% axis('square');
%
% % pick first movements to each target
% for i=1:numTargs
%     useInds = find(tt(:,2)==i-1,numMoves,'first');
%     for j = 1:length(useInds)
%         trial = tt(useInds(j),:);
%         usePos = pos(t>=trial(8) & t<trial(end),:);
%         plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'b','LineWidth',2);
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
for j=1:numTargs
    useInds = find(tt(:,2)==j-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==j-1,numMoves,'last');
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
for j=1:numTargs
    useInds = find(tt(:,2)==j-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==j-1,numMoves,'last');
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
for j=1:numTargs
    useInds = find(tt(:,2)==j-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==j-1,numMoves,'last');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'b','LineWidth',2);
    end
end

% visual rotations
useDate = '2013-09-03';
numMoves = 1;
numTargs = 8;
targDist = 8;
xoffset = 5;
yoffset = -35;

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
for j=1:numTargs
    useInds = find(tt(:,2)==j-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==j-1,numMoves,'last');
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
for j=1:numTargs
    useInds = find(tt(:,2)==j-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1),usePos(:,2),'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==j-1,numMoves,'last');
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
for j=1:numTargs
    useInds = find(tt(:,2)==j-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'r','LineWidth',2);
    end
    
    useInds = find(tt(:,2)==j-1,numMoves,'last');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) Show tuning curves of individual neurons in each of three epochs

useDate = '2013-08-23';
elec = 20;
unit = 2;

load(fullfile(baseDir, useDate,['CO_FF_tuning_' useDate '.mat']));

sg = tuning.BL.PMd.nonparametric.peak.unit_guide;
utheta = tuning.BL.PMd.nonparametric.peak.utheta;
mFR = tuning.BL.PMd.nonparametric.peak.mfr;
sFR_l = tuning.BL.PMd.nonparametric.peak.cil;
sFR_h = tuning.BL.PMd.nonparametric.peak.cih;

useUnit = sg(:,1)==elec & sg(:,2)==unit;

% we went +pi to be the highest index, so if -pi is used...
if abs(utheta(1)) > utheta(end)
    utheta = [utheta; abs(utheta(1))];
    utheta(1) = [];
    
    mFR = [mFR mFR(:,1)];
    sFR_l = [sFR_l sFR_l(:,1)];
    sFR_h = [sFR_h sFR_h(:,1)];
    
    mFR(:,1) = [];
    sFR_l(:,1) = [];
    sFR_h(:,1) = [];
    
end

fh = figure('Position', [200, 200, 800, 600]);
hold all;
h = area(utheta.*(180/pi),[sFR_l(useUnit,:)' sFR_h(useUnit,:)']);
set(h(1),'FaceColor',[1 1 1]);
set(h(2),'FaceColor',[0.8 0.9 1],'EdgeColor',[1 1 1]);
plot(utheta.*(180/pi),mFR(useUnit,:),'b--','LineWidth',2);
axis('tight');

V = axis;
axis([min(utheta)*180/pi max(utheta)*180/pi 0 V(4)]);

% now fit a cosine and plot it
fr = tuning.BL.PMd.regression.peak.fr(:,useUnit);
theta = tuning.BL.PMd.regression.peak.theta;

st = sin(theta);
ct = cos(theta);
X = [ones(size(theta)) st ct];

B = regress(fr,X);

theta = -pi:0.1:2*pi;
plot(theta.*180/pi,B(1)+B(2)*sin(theta)+B(3)*cos(theta),'r','LineWidth',3);

% find the PD and put a line
pd = atan2(B(2),B(3));
plot([pd pd].*180/pi,[0 V(4)],'k--','LineWidth',3);

% make a legend
plot([60 100],[45 45],'Color','b','LineWidth',3);
plot([60 100],[42 42],'Color','r','LineWidth',3);
text(105,45,'Mean Activity','FontSize',16);
text(105,42,'Cosine Fit','FontSize',16);

xlabel('Direction of Movement (Deg)','FontSize',18);
ylabel('Firing Rate (Hz)','FontSize',18);
set(gca,'FontSize',16);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4) Summarize PD changes
useDate = '2013-08-22';
classColors = {[0.2,0.2,0.2],[0.2 0.6 1],[0.9 0.1 0.1],'r','g'};
epochs = {'BL','AD','WO'};

load(fullfile(baseDir, useDate,['RT_FF_classes_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_FF_tracking_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_FF_tuning_' useDate '.mat']));

% histograms of BL->AD and AD->WO

tune_idx = classes.PMd.regression.peak.tuned_cells;
tune_sg = classes.PMd.regression.peak.unit_guide;
tuned_cells = tune_sg(tune_idx,:);

% get unit guides and pd matrices
sg_bl = tuning.BL.PMd.regression.peak.unit_guide;
sg_ad = tuning.AD.PMd.regression.peak.unit_guide;
sg_wo = tuning.WO.PMd.regression.peak.unit_guide;

pds_bl = tuning.BL.PMd.regression.peak.pds;
pds_ad = tuning.AD.PMd.regression.peak.pds;
pds_wo = tuning.WO.PMd.regression.peak.pds;

% check to make sure the unit guides are okay
badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
sg_master = setdiff(sg_bl,badUnits,'rows');

cellClasses = classes.PMd.regression.peak.classes;

useComp = tracking.PMd{1}.chan;

fh = figure('Position', [200, 200, 1400, 800]);
hold all;

allPDs_FF = [];
allDiffPDs_FF = [];
for unit = 1:size(sg_master,1)
    % if the cell meets the tuning criteria
    %   and also if the cell is tracked across epochs
    if ismember(sg_master(unit,:),tuned_cells,'rows')
        
        % don't include cell if it fails KS test
        relCompInd = useComp(:,1)==sg_master(unit,1)+.1*sg_master(unit,2);
        if ~any(diff(useComp(relCompInd,:)))
            
            useInd = sg_bl(:,1)==sg_master(unit,1) & sg_bl(:,2)==sg_master(unit,2);
            pds(1) = pds_bl(useInd,1);
            useInd = sg_ad(:,1)==sg_master(unit,1) & sg_ad(:,2)==sg_master(unit,2);
            pds(2) = pds_ad(useInd,1);
            useInd = sg_wo(:,1)==sg_master(unit,1) & sg_wo(:,2)==sg_master(unit,2);
            pds(3) = pds_wo(useInd,1);
            
            diffPDs = [pds(1)-pds(1), pds(2)-pds(1), pds(3)-pds(1)];
            
            classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
            
            % color the traces based on the classification
            useColor = classColors{cellClasses(classInd)};
            
            plot([0 1 2],diffPDs.*180/pi,'LineWidth',2,'Color',useColor);
            plot([0 1 2],diffPDs.*180/pi,'d','LineWidth',3,'Color',useColor);
            
            allPDs_FF = [allPDs_FF; pds];
            % BL->AD, AD->WO, BL->WO
            allDiffPDs_FF = [allDiffPDs_FF; pds(2)-pds(1), pds(3)-pds(2), pds(3)-pds(1)];
        end
    end
end

% now add visual rotation
useDate = '2013-09-04';

load(fullfile(baseDir, useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VR_tracking_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VR_tuning_' useDate '.mat']));

tune_idx = classes.PMd.regression.peak.tuned_cells;
tune_sg = classes.PMd.regression.peak.unit_guide;
tuned_cells = tune_sg(tune_idx,:);

% get unit guides and pd matrices
sg_bl = tuning.BL.PMd.regression.peak.unit_guide;
sg_ad = tuning.AD.PMd.regression.peak.unit_guide;
sg_wo = tuning.WO.PMd.regression.peak.unit_guide;

pds_bl = tuning.BL.PMd.regression.peak.pds;
pds_ad = tuning.AD.PMd.regression.peak.pds;
pds_wo = tuning.WO.PMd.regression.peak.pds;

% check to make sure the unit guides are okay
badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
sg_master = setdiff(sg_bl,badUnits,'rows');

cellClasses = classes.PMd.regression.peak.classes;

useComp = tracking.PMd{1}.chan;

allPDs_VR = [];
allDiffPDs_VR = [];
for unit = 1:size(sg_master,1)
    % if the cell meets the tuning criteria
    %   and also if the cell is tracked across epochs
    if ismember(sg_master(unit,:),tuned_cells,'rows')
        
        % don't include cell if it fails KS test
        relCompInd = useComp(:,1)==sg_master(unit,1)+.1*sg_master(unit,2);
        if ~any(diff(useComp(relCompInd,:)))
            
            useInd = sg_bl(:,1)==sg_master(unit,1) & sg_bl(:,2)==sg_master(unit,2);
            pds(1) = pds_bl(useInd,1);
            useInd = sg_ad(:,1)==sg_master(unit,1) & sg_ad(:,2)==sg_master(unit,2);
            pds(2) = pds_ad(useInd,1);
            useInd = sg_wo(:,1)==sg_master(unit,1) & sg_wo(:,2)==sg_master(unit,2);
            pds(3) = pds_wo(useInd,1);
            
            diffPDs = [pds(1)-pds(1), pds(2)-pds(1), pds(3)-pds(1)];
            
            classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
            
            % color the traces based on the classification
            useColor = classColors{cellClasses(classInd)};
            
            plot([2.4 3.4 4.4],diffPDs.*180/pi,'LineWidth',2,'Color',useColor);
            plot([2.4 3.4 4.4],diffPDs.*180/pi,'d','LineWidth',3,'Color',useColor);
            
            allPDs_VR = [allPDs_VR; pds];
            % BL->AD, AD->WO, BL->WO
            allDiffPDs_VR = [allDiffPDs_VR; pds(2)-pds(1), pds(3)-pds(2), pds(3)-pds(1)];
        end
    end
end

% fix labels
set(gca,'XTick',[0 1 1.9 2.5 3.4 4.4],'XTickLabel',{'Baseline','Adaptation','Washout','Baseline','Adaptation','Washout'},'FontSize',16,'TickLength',[0 0]);
ylabel('Change in PD (Deg)','FontSize',18);

axis('tight');

V = axis;
% define boundaries
axis([-0.1 4.6 V(3)-2 V(4)+2]);
V = axis;
% plot a separating line
plot([2.2 2.2],V(3:4),'k','LineWidth',1);

% make a legend
plot([3.4 3.9],[40 40],'Color',classColors{1},'LineWidth',3);
plot([3.4 3.9],[36 36],'Color',classColors{2},'LineWidth',3);
plot([3.4 3.9],[32 32],'Color',classColors{3},'LineWidth',3);
text(4,40,'Non-Adapting','FontSize',16);
text(4,36,'Adapting','FontSize',16);
text(4,32,'Memory','FontSize',16);

% add titles
set(gcf,'NextPlot','add');
axes('position',[0.05 0 0.5 0.92]);
h = title('Force Field','FontSize',18);
set(gca,'Visible','off');
set(h,'Visible','on');

set(gcf,'NextPlot','add');
axes('position',[0.45 0 0.5 0.92]);
h = title('Visual Rotation','FontSize',18);
set(gca,'Visible','off');
set(h,'Visible','on');

% Make histograms
fh = figure('Position', [200, 200, 800, 600]);
hold all;
% histograms of BL->AD for FF and VR
hist(allDiffPDs_VR(:,1).*180/pi);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75)
hist(allDiffPDs_FF(:,1).*180/pi)
h1 = findobj(gca,'Type','patch');
set(h1,'EdgeColor','w','facealpha',1);

% add legend
rectangle('Position',[16 6.4 5 0.5],'FaceColor','r');
text(22,6.65,'Rotation','FontSize',16);
rectangle('Position',[16 5.7 5 0.5],'FaceColor',[0 0 0.7]);
text(22,5.95,'Force Field','FontSize',16);

% show perturbation
arrow('Start',[-30,6],'Stop',[-7 6],'Width',3);
text(-30,6.5,'Perturbation Direction','FontSize',16);

title('Baseline -> Adaptation','FontSize',18);
xlabel('Change in PD (Deg)','FontSize',16);
ylabel('Count','FontSize',16);
axis('tight');
V=axis;
axis([V(1) V(2) 0 7]);
set(gca,'FontSize',16);

fh = figure('Position', [200, 200, 800, 600]);
hold all;
% histograms of BL->WO for FF and VR
hist(allDiffPDs_VR(:,3).*180/pi);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75)
hist(allDiffPDs_FF(:,3).*180/pi)
h1 = findobj(gca,'Type','patch');
set(h1,'EdgeColor','w','facealpha',1);

% add legend
rectangle('Position',[-30 7 3 0.7],'FaceColor','r');
text(-26,7.35,'Rotation','FontSize',16);
rectangle('Position',[-30 6 3 0.7],'FaceColor',[0 0 0.7]);
text(-26,6.35,'Force Field','FontSize',16);

title('Baseline -> Washout','FontSize',18);

xlabel('Change in PD (Deg)','FontSize',16);
ylabel('Count','FontSize',16);
axis('tight');
V=axis;
axis([V(1) V(2) 0 8]);
set(gca,'FontSize',16);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make plots to show adaptation over time

%% Now want to make some plots showing metrics over ti
doFiltering = true;
filtWidth = 5;

useDate = '2013-08-22';

load(fullfile(baseDir,useDate,['RT_FF_adaptation_' useDate '.mat']));

% BASELINE
a = adaptation.BL;
moveCounts = a.movement_counts;
mC = a.curvature_mean(:,1);
if doFiltering
    f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
    mC = filter(f, 1, mC);
end

dividers(1) = moveCounts(end);
allMoveCounts = moveCounts;
allMC = mC;

% ADAPTATION
a = adaptation.AD;
moveCounts = a.movement_counts+moveCounts(end);
mC = a.curvature_mean(:,1);
if doFiltering
    f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
    mC = filter(f, 1, mC);
end

dividers(2) = moveCounts(end);
allMoveCounts = [allMoveCounts moveCounts];
allMC = [allMC; mC];

% WASHOUT
a = adaptation.WO;
moveCounts = a.movement_counts+moveCounts(end);
mC = a.curvature_mean(:,1);
if doFiltering
    f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
    mC = filter(f, 1, mC);
end

allMoveCounts = [allMoveCounts moveCounts];
allMC = [allMC; mC];

% % do additional filtering
% if doFiltering
%     f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
%     allMC = filter(f, 1, allMC);
% end

dividers_FF = dividers;
allMoveCounts_FF = allMoveCounts;
allMC_FF = allMC;


% now do visual rotation
useDate = '2013-09-04';
load(fullfile(baseDir,useDate,['RT_VR_adaptation_' useDate '.mat']));

% BASELINE
a = adaptation.BL;
moveCounts = a.movement_counts;
mC = a.curvature_mean(:,1);
if doFiltering
    f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
    mC = filter(f, 1, mC);
end

dividers(1) = moveCounts(end);
allMoveCounts = moveCounts;
allMC = mC;

% ADAPTATION
a = adaptation.AD;
moveCounts = a.movement_counts+moveCounts(end);
mC = a.curvature_mean(:,1);
if doFiltering
    f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
    mC = filter(f, 1, mC);
end

dividers(2) = moveCounts(end);
allMoveCounts = [allMoveCounts moveCounts];
allMC = [allMC; mC];

% WASHOUT
a = adaptation.WO;
moveCounts = a.movement_counts+moveCounts(end);
mC = a.curvature_mean(:,1);

if doFiltering
    f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
    mC = filter(f, 1, mC);
end

allMoveCounts = [allMoveCounts moveCounts];
allMC = [allMC; mC];

% % do additional filtering
% if doFiltering
%     f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
%     allMC = filter(f, 1, allMC);
% end

dividers_VR = dividers;
allMoveCounts_VR = allMoveCounts;
allMC_VR = allMC;

fh = figure('Position', [200, 200, 800, 600]);
hold all;
plot(allMoveCounts_FF,allMC_FF','b','LineWidth',2);
axis('tight');

axis([90 1450 -0.4 0.4]);
V = axis;

plot([dividers_FF(1) dividers_FF(1)],[-0.4 0.28],'k--','LineWidth',1);
plot([dividers_FF(2) dividers_FF(2)],[-0.4 0.28],'k--','LineWidth',1);

set(gca,'TickLength',[0 0],'FontSize',16,'XTick',[]);

% xlabel('Movements','FontSize',16);
ylabel('Curvature (cm^-^1)','FontSize',16);

% add labels and legend
plot([950 1100],[0.38 0.38],'b','LineWidth',3);
plot([950 1100],[0.33 0.33],'r','LineWidth',3);
text(1150,0.38,'Force Field','FontSize',16);
text(1150,0.33,'Rotation','FontSize',16);

text(150,-0.35,'Baseline','FontSize',16);
text(600,-0.35,'Adaptation','FontSize',16);
text(1150,-0.35,'Washout','FontSize',16);

% now add rotation traces
h1=gca;
h2=axes('position',get(h1,'position'));
hold all;
plot(allMoveCounts_VR,allMC_VR','r','LineWidth',2);
axis('tight');

axis([0 1000 -0.4 0.4]);
V = axis;

plot([dividers_VR(1) dividers_VR(1)],[-0.4 0.28],'k--','LineWidth',1);
plot([dividers_VR(2) dividers_VR(2)],[-0.4 0.28],'k--','LineWidth',1);

set(h2,'YAxisLocation','right','Color','none','XTickLabel',[],'YTickLabel',[],'TickLength',[0 0],'FontSize',16,'XTick',[])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compare firing rate of different cell classes in adaptation period
useDate = '2013-09-04';
load(fullfile(baseDir,useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_VR_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.AD.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.AD.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR,I] = sort(c);
fr_VR = fr(:,I);

useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_FF_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.AD.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.AD.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF,I] = sort(c);
fr_FF = fr(:,I);

fh = figure('Position',[200 200 800 600]);
hold all;

uclass=unique([c_VR; c_FF]);

firstcount = 1;
count = 0;
for i = 1:length(uclass)
    inds = c_FF==uclass(i);
    fr = fr_FF(:,inds);
%     [~,I] = sort(mean(fr,1));
%     fr = fr(:,I);
    
    for j = 1:size(fr,2)
        count = count + 1;
        plot(count,mean(fr(:,j)),'bd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'b','LineWidth',2);
    end
    
    inds = c_VR==uclass(i);
    fr = fr_VR(:,inds);
%     [~,I] = sort(mean(fr,1));
%     fr = fr(:,I);
    
    for j = 1:size(fr,2)
        count = count+1;
        plot(count,mean(fr(:,j)),'rd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'r','LineWidth',2);
    end
    
    plot([firstcount count],[-7 -7],'k','LineWidth',3);
    count = count+4;
    firstcount = count+1;
end

% add legend and labels
V = axis;
set(gca,'YTick',0:10:V(4),'YTickLabels',0:10:V(4),'XTick',[],'FontSize',16);
ylabel('Firing Rate (Hz)','FontSize',16);

axis([-2 V(2)+2 -20 V(4)+20]);
% add labels for cell types
text(7,-13,'Non-Adapting','FontSize',16);
text(32.5,-13,'Adapting','FontSize',16);
text(45,-13,'Memory','FontSize',16);

% add legend for colors
plot([2 8],[105 105],'b','LineWidth',3);
plot([2 8],[97 97],'r','LineWidth',3);
text(9,105,'Force Field','FontSize',16);
text(9,97,'Visual Rotation','FontSize',16);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate a firing rate index (change from baseline to adaptation)
useDate = '2013-09-04';
load(fullfile(baseDir,useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_VR_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.AD.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.AD.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR_AD,I] = sort(c);
fr_VR_AD = fr(:,I);

% get the baseline
sg = tuning.BL.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.BL.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR_BL,I] = sort(c);
fr_VR_BL = fr(:,I);

% now find an index for how firing rate changes
fri_VR = mean(fr_VR_AD,1)./mean(fr_VR_BL,1);


%%%%%%%%%%%%
% now the force field
useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_FF_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.AD.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.AD.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_AD,I] = sort(c);
fr_FF_AD = fr(:,I);

%%%%
% now the baseline
sg = tuning.BL.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.BL.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_BL,I] = sort(c);
fr_FF_BL = fr(:,I);

fri_FF = mean(fr_FF_AD,1)./mean(fr_FF_BL,1);

fh = figure('Position',[200 200 800 600]);
hold all;

uclass=unique([c_VR; c_FF]);

firstcount = 1;
count = 0;
for i = 1:length(uclass)
    inds = c_FF==uclass(i);
    fr = fri_FF(:,inds);
    
    for j = 1:size(fr,2)
        count = count + 1;
        plot(count,mean(fr(:,j)),'bd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'b','LineWidth',2);
    end
    
    inds = c_VR==uclass(i);
    fr = fri_VR(:,inds);
    
    for j = 1:size(fr,2)
        count = count+1;
        plot(count,mean(fr(:,j)),'rd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'r','LineWidth',2);
    end
    
    plot([firstcount count],[-0.2 -0.2],'k','LineWidth',3);
    count = count+4;
    firstcount = count+1;
end


% add legend and labels
V = axis;
plot([V(1) V(2)],[1 1],'k--','LineWidth',1);
set(gca,'YTick',0:0.2:2,'YTickLabels',0:0.2:2,'XTick',[],'FontSize',16);
ylabel('Adaptation / Baseline','FontSize',16);

axis([-2 V(2)+2 -0.4 2]);
% add labels for cell types
text(7,-0.3,'Non-Adapting','FontSize',16);
text(32.5,-0.3,'Adapting','FontSize',16);
text(45,-0.3,'Memory','FontSize',16);

% add legend for colors
plot([2 8],[1.9 1.9],'b','LineWidth',3);
plot([2 8],[1.8 1.8],'r','LineWidth',3);
text(9,1.9,'Force Field','FontSize',16);
text(9,1.8,'Visual Rotation','FontSize',16);

%% do same but with washout relative to baseline
useDate = '2013-09-04';
load(fullfile(baseDir,useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_VR_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.WO.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.WO.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR_WO,I] = sort(c);
fr_VR_WO = fr(:,I);

% get the baseline
sg = tuning.BL.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.BL.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR_BL,I] = sort(c);
fr_VR_BL = fr(:,I);

% now find an index for how firing rate changes
fri_VR = mean(fr_VR_WO,1)./mean(fr_VR_BL,1);


%%%%%%%%%%%%
% now the force field
useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_FF_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.WO.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.WO.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_WO,I] = sort(c);
fr_FF_WO = fr(:,I);

%%%%
% now the baseline
sg = tuning.BL.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.BL.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_BL,I] = sort(c);
fr_FF_BL = fr(:,I);

fri_FF = mean(fr_FF_WO,1)./mean(fr_FF_BL,1);

fh = figure('Position',[200 200 800 600]);
hold all;

uclass=unique([c_VR; c_FF]);

firstcount = 1;
count = 0;
for i = 1:length(uclass)
    inds = c_FF==uclass(i);
    fr = fri_FF(:,inds);
    
    for j = 1:size(fr,2)
        count = count + 1;
        plot(count,mean(fr(:,j)),'bd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'b','LineWidth',2);
    end
    
    inds = c_VR==uclass(i);
    fr = fri_VR(:,inds);
    
    for j = 1:size(fr,2)
        count = count+1;
        plot(count,mean(fr(:,j)),'rd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'r','LineWidth',2);
    end
    
    plot([firstcount count],[-0.2 -0.2],'k','LineWidth',3);
    count = count+4;
    firstcount = count+1;
end


% add legend and labels
V = axis;
plot([V(1) V(2)],[1 1],'k--','LineWidth',1);
set(gca,'YTick',0:0.2:2,'YTickLabels',0:0.2:2,'XTick',[],'FontSize',16);
ylabel('Washout / Baseline','FontSize',16);

axis([-2 V(2)+2 -0.4 2]);
% add labels for cell types
text(7,-0.3,'Non-Adapting','FontSize',16);
text(32.5,-0.3,'Adapting','FontSize',16);
text(45,-0.3,'Memory','FontSize',16);

% add legend for colors
plot([2 8],[1.9 1.9],'b','LineWidth',3);
plot([2 8],[1.8 1.8],'r','LineWidth',3);
text(9,1.9,'Force Field','FontSize',16);
text(9,1.8,'Visual Rotation','FontSize',16);

% we want to compare with t test washout and baseline
H = ttest2(mean(fr_VR_WO,1),mean(fr_VR_BL,1))
H = ttest2(mean(fr_FF_WO,1),mean(fr_FF_BL,1))

%% do same but with washout relative to adaptation

useDate = '2013-09-04';
load(fullfile(baseDir,useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_VR_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.WO.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.WO.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR_WO,I] = sort(c);
fr_VR_WO = fr(:,I);

% get the baseline
sg = tuning.AD.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.AD.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR_AD,I] = sort(c);
fr_VR_AD = fr(:,I);

% now find an index for how firing rate changes
fri_VR = mean(fr_VR_WO,1)./mean(fr_VR_AD,1);


%%%%%%%%%%%%
% now the force field
useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_FF_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.WO.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.WO.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_WO,I] = sort(c);
fr_FF_WO = fr(:,I);

%%%%
% now the baseline
sg = tuning.AD.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.AD.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_AD,I] = sort(c);
fr_FF_AD = fr(:,I);

fri_FF = mean(fr_FF_WO,1)./mean(fr_FF_AD,1);

fh = figure('Position',[200 200 800 600]);
hold all;

uclass=unique([c_VR; c_FF]);

firstcount = 1;
count = 0;
for i = 1:length(uclass)
    inds = c_FF==uclass(i);
    fr = fri_FF(:,inds);
    
    for j = 1:size(fr,2)
        count = count + 1;
        plot(count,mean(fr(:,j)),'bd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'b','LineWidth',2);
    end
    
    inds = c_VR==uclass(i);
    fr = fri_VR(:,inds);
    
    for j = 1:size(fr,2)
        count = count+1;
        plot(count,mean(fr(:,j)),'rd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'r','LineWidth',2);
    end
    
    plot([firstcount count],[-0.2 -0.2],'k','LineWidth',3);
    count = count+4;
    firstcount = count+1;
end


% add legend and labels
V = axis;
plot([V(1) V(2)],[1 1],'k--','LineWidth',1);
set(gca,'YTick',0:0.2:2,'YTickLabels',0:0.2:2,'XTick',[],'FontSize',16);
ylabel('Washout / Adaptation','FontSize',16);

axis([-2 V(2)+2 -0.4 2]);
% add labels for cell types
text(7,-0.3,'Non-Adapting','FontSize',16);
text(32.5,-0.3,'Adapting','FontSize',16);
text(45,-0.3,'Memory','FontSize',16);

% add legend for colors
plot([2 8],[1.9 1.9],'b','LineWidth',3);
plot([2 8],[1.8 1.8],'r','LineWidth',3);
text(9,1.9,'Force Field','FontSize',16);
text(9,1.8,'Visual Rotation','FontSize',16);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot array maps with classes
useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_classes_' useDate '.mat']));

inds = classes.PMd.regression.peak.tuned_cells;
cells = classes.PMd.regression.peak.unit_guide(inds);
classes = classes.PMd.regression.peak.classes(inds);

% load the array map
MrT_PMd_arraymap;

% loop along the cells
class_map = -1*ones(size(array_map));

for unit = 1:length(inds)
    currElec = cells(unit,1);
    ind = array_map==currElec;
    
    if class_map(ind) == -1
        class_map(ind) = classes(unit);
    elseif class_map(ind) == classes(unit)
        % do nothing
    elseif class_map(ind) ~= classes(unit)
        class_map(ind) = 0; % quick hack to fill in... fix it
    else
        error('something seems to be wrong here...');
    end
end

fh = figure('Position',[200 200 1200 600]);
subplot1(1,2);
subplot1(1);
% plot the array map
imagesc(-class_map,[-3 1]); colormap('hot');
ylabel(leftside,'FontSize',14);
xlabel(bottomside,'FontSize',14);
set(gca,'XTick',[],'YTick',[]);
title('Force Field','FontSize',16);

% now for a visual rotation day
useDate = '2013-09-04';
load(fullfile(baseDir,useDate,['RT_VR_classes_' useDate '.mat']));

inds = classes.PMd.regression.peak.tuned_cells;
cells = classes.PMd.regression.peak.unit_guide(inds);
classes = classes.PMd.regression.peak.classes(inds);

% load the array map
MrT_PMd_arraymap;

% loop along the cells
class_map = -1*ones(size(array_map));

for unit = 1:length(inds)
    currElec = cells(unit,1);
    ind = array_map==currElec;
    
    if class_map(ind) == -1
        class_map(ind) = classes(unit);
    elseif class_map(ind) == classes(unit)
        % do nothing
    elseif class_map(ind) ~= classes(unit)
        class_map(ind) = 0; % quick hack to fill in... fix it
    else
        error('something seems to be wrong here...');
    end
end

subplot1(2);
ax = gca;
% plot the array map
imagesc(-class_map,[-3 1]); colormap('hot');
xlabel(bottomside,'FontSize',14);
set(gca,'XTick',[],'YTick',[]);
title('Visual Rotation','FontSize',16);

c = colorbar('East');
set(c,'YTick',[-3 -2 -1 0 1],'YTickLabel',{'Memory','Adapting','Non-adapting','Mix','None'},'FontSize',14);


