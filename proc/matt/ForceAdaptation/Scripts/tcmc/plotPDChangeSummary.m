%% 4) Summarize PD changes
useDate = '2013-09-24';

usePeriod = 'peak';

doNeg = 1; %-1 inverts VR histogram

binSize = 5;
maxAngle = 45;
histBins = -(maxAngle-binSize/2):binSize:(maxAngle-binSize/2);

classColors = {[0.2,0.2,0.2],[0.2 0.6 1],[0.9 0.1 0.1],'r','g'};
epochs = {'BL','AD','WO'};

load(fullfile(baseDir, useDate,['RT_VRFF_classes_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VRFF_tracking_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VRFF_tuning_' useDate '.mat']));

% histograms of BL->AD and AD->WO

tune_idx = classes.PMd.regression.(usePeriod).tuned_cells;
tune_sg = classes.PMd.regression.(usePeriod).unit_guide;
tuned_cells = tune_sg(tune_idx,:);

% get unit guides and pd matrices
sg_bl = tuning.BL.PMd.regression.(usePeriod).unit_guide;
sg_ad = tuning.AD.PMd.regression.(usePeriod).unit_guide;
sg_wo = tuning.WO.PMd.regression.(usePeriod).unit_guide;

pds_bl = tuning.BL.PMd.regression.(usePeriod).pds;
pds_ad = tuning.AD.PMd.regression.(usePeriod).pds;
pds_wo = tuning.WO.PMd.regression.(usePeriod).pds;

% check to make sure the unit guides are okay
badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
sg_master = setdiff(sg_bl,badUnits,'rows');

cellClasses = classes.PMd.regression.(usePeriod).classes;

useComp = tracking.PMd{1}.chan;

fh = figure('Position', [200, 200, 1400, 800]);
hold all;

allPDs_FF = [];
allDiffPDs_FF = [];
adaptDiffPDs_FF = [];
useClasses = -1*ones(size(cellClasses));
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
            
            diffPDs = [angleDiff(pds(1),pds(1),true,true), angleDiff(pds(1),pds(2),true,true), angleDiff(pds(1),pds(3),true,true)];
            
            classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
            
            if cellClasses(classInd)~=1
                adaptDiffPDs_FF = [adaptDiffPDs_FF pds(2)-pds(1)];
            end
            
            % color the traces based on the classification
            useColor = classColors{cellClasses(classInd)};
            useClasses(unit) = cellClasses(classInd);
            
            plot([0 1 2],diffPDs.*180/pi,'LineWidth',2,'Color',useColor);
            plot([0 1 2],diffPDs.*180/pi,'d','LineWidth',3,'Color',useColor);
            
            allPDs_FF = [allPDs_FF; pds];
            % BL->AD, AD->WO, BL->WO
            allDiffPDs_FF = [allDiffPDs_FF; pds(2)-pds(1), pds(3)-pds(2), pds(3)-pds(1)];
        end
    end
end

% now count how many adapting and non-adapting cells there are
useClasses = useClasses(useClasses~=-1);
adaptingCount_FF = sum(useClasses == 2 | useClasses == 3);
nonadaptingCount_FF = sum(useClasses == 1 | useClasses == 4);

%% now add visual rotation
useDate = '2013-09-24';

load(fullfile(baseDir, useDate,['RT_VRFF_classes_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VRFF_tracking_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VRFF_tuning_' useDate '.mat']));

tune_idx = classes.PMd.regression.(usePeriod).tuned_cells;
tune_sg = classes.PMd.regression.(usePeriod).unit_guide;
tuned_cells = tune_sg(tune_idx,:);

% get unit guides and pd matrices
sg_bl = tuning.BL.PMd.regression.(usePeriod).unit_guide;
sg_ad = tuning.AD.PMd.regression.(usePeriod).unit_guide;
sg_wo = tuning.WO.PMd.regression.(usePeriod).unit_guide;

pds_bl = tuning.BL.PMd.regression.(usePeriod).pds;
pds_ad = tuning.AD.PMd.regression.(usePeriod).pds;
pds_wo = tuning.WO.PMd.regression.(usePeriod).pds;

% check to make sure the unit guides are okay
badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
sg_master = setdiff(sg_bl,badUnits,'rows');

cellClasses = classes.PMd.regression.(usePeriod).classes;

useComp = tracking.PMd{1}.chan;

allPDs_VR = [];
allDiffPDs_VR = [];
adaptDiffPDs_VR = [];
useClasses = -1*ones(size(cellClasses));
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
            
            diffPDs = [angleDiff(pds(1),pds(1),true,true), angleDiff(pds(2),pds(1),true,true), angleDiff(pds(3),pds(1),true,true)];
            
            classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
            
            if cellClasses(classInd)~=1
                adaptDiffPDs_VR = [adaptDiffPDs_VR pds(2)-pds(1)];
            end
            
            % color the traces based on the classification
            useColor = classColors{cellClasses(classInd)};
            useClasses(unit) = cellClasses(classInd);
            
            plot([2.4 3.4 4.4],diffPDs.*180/pi,'LineWidth',2,'Color',useColor);
            plot([2.4 3.4 4.4],diffPDs.*180/pi,'d','LineWidth',3,'Color',useColor);
            
            allPDs_VR = [allPDs_VR; pds];
            % BL->AD, AD->WO, BL->WO
            allDiffPDs_VR = [allDiffPDs_VR; pds(2)-pds(1), pds(3)-pds(2), pds(3)-pds(1)];
        end
    end
end

% get cell counts
useClasses = useClasses(useClasses~=-1);
adaptingCount_VR = sum(useClasses == 2 | useClasses == 3);
nonadaptingCount_VR = sum(useClasses == 1 | useClasses == 4);

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

%%
% Make histograms
fh = figure('Position', [200, 200, 800, 600]);
hold all;
% histograms of BL->AD for FF and VR
hist(doNeg*allDiffPDs_VR(:,1).*180/pi,histBins);
h = findobj(gca,'Type','patch');
set(h,'FaceColor',vrColor,'EdgeColor',vrColor,'facealpha',0.7,'edgealpha',0.7)
hist(allDiffPDs_FF(:,1).*180/pi,histBins)
h1 = findobj(gca,'Type','patch');
set(h1,'EdgeColor','w','facealpha',0.7,'edgealpha',0.7);

% add arrows to mark means
arrow('Start',[mean(doNeg*allDiffPDs_VR(:,1)).*180/pi 6.5],'Stop',[mean(doNeg*allDiffPDs_VR(:,1)).*180/pi 6],'Width',3)
arrow('Start',[mean(allDiffPDs_FF(:,1)).*180/pi 6.5],'Stop',[mean(allDiffPDs_FF(:,1)).*180/pi 6],'Width',3)

% add legend
rectangle('Position',[16 7 5 0.5],'FaceColor','r');
text(22,7.25,'Rotation','FontSize',16);
rectangle('Position',[16 6.3 5 0.5],'FaceColor',[0 0 0.7]);
text(22,6.55,'Force Field','FontSize',16);

% show perturbation
arrow('Start',[-30,7],'Stop',[-7 7],'Width',3);
text(-30,7.5,'Perturbation Direction','FontSize',16);

title('Baseline -> Adaptation','FontSize',18);
xlabel('Change in PD (Deg)','FontSize',16);
ylabel('Count','FontSize',16);
axis('tight');
V=axis;
axis([V(1) V(2) 0 8]);
set(gca,'FontSize',16);

% print -depsc2 -adobecset -painter filename.eps
%%
fh = figure('Position', [200, 200, 800, 600]);
hold all;
% histograms of BL->WO for FF and VR
hist(doNeg*allDiffPDs_VR(:,3).*180/pi,histBins);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w','facealpha',0.7,'edgealpha',0.7)
hist(allDiffPDs_FF(:,3).*180/pi,histBins)
h1 = findobj(gca,'Type','patch');
set(h1,'EdgeColor','w','facealpha',0.7,'edgealpha',0.7);

arrow('Start',[mean(doNeg*allDiffPDs_VR(:,3)).*180/pi 6.5],'Stop',[mean(doNeg*allDiffPDs_VR(:,3)).*180/pi 6],'Width',3)
arrow('Start',[mean(allDiffPDs_FF(:,3)).*180/pi 6.5],'Stop',[mean(allDiffPDs_FF(:,3)).*180/pi 6],'Width',3)

% add legend
rectangle('Position',[16 7 5 0.5],'FaceColor','r');
text(22,7.25,'Rotation','FontSize',16);
rectangle('Position',[16 6.3 5 0.5],'FaceColor',[0 0 0.7]);
text(22,6.55,'Force Field','FontSize',16);

title('Baseline -> Washout','FontSize',18);

xlabel('Change in PD (Deg)','FontSize',16);
ylabel('Count','FontSize',16);
axis('tight');
V=axis;
axis([V(1) V(2) 0 8]);
set(gca,'FontSize',16);

%% Now plot bar of cell counts
fh = figure('Position', [200, 200, 800, 600]);
hold all;
% histograms of BL->WO for FF and VR
bar([4, 5.3],[nonadaptingCount_VR, adaptingCount_VR]);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w','facealpha',1,'edgealpha',1)
bar([1, 2.3],[nonadaptingCount_FF, adaptingCount_FF]);
h1 = findobj(gca,'Type','patch');
set(h1,'EdgeColor','w','facealpha',1,'edgealpha',1);

V = axis;

set(gca,'YTick',V(3):3:V(4),'XTick',[1 2.3 4 5.3],'XTickLabel',{'Non-Adapting','Adapting','Non-Adapting','Adapting'},'FontSize',14);
ylabel('Count','FontSize',16);


