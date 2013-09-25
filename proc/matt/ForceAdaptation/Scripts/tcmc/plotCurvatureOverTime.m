%% Make curvature plots to show adaptation over time
useDate = '2013-08-22';
traceWidth = 3;

doFiltering = true;
filtWidth = 4;

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
plot(allMoveCounts_FF,allMC_FF','b','LineWidth',traceWidth);
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
plot(allMoveCounts_VR,allMC_VR','r','LineWidth',traceWidth);
axis('tight');

axis([0 1000 -0.4 0.4]);
V = axis;

plot([dividers_VR(1) dividers_VR(1)],[-0.4 0.28],'k--','LineWidth',1);
plot([dividers_VR(2) dividers_VR(2)],[-0.4 0.28],'k--','LineWidth',1);

set(h2,'YAxisLocation','right','Color','none','XTickLabel',[],'YTickLabel',[],'TickLength',[0 0],'FontSize',16,'XTick',[])
