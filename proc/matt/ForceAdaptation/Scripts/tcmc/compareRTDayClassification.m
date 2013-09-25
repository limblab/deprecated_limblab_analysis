
useDate = '2013-09-04';
load(fullfile(baseDir, useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VR_tracking_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VR_tuning_' useDate '.mat']));

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
            
            diffPDs = [pds(1)-pds(1), pds(2)-pds(1), pds(3)-pds(1)];
            
            classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
            
            useClasses(unit) = cellClasses(classInd);
            
        end
    end
end

% now count how many adapting and non-adapting cells there are
useClasses = useClasses(useClasses~=-1);
adaptingCount_1 = sum(useClasses ~= 1);
nonadaptingCount_1 = sum(useClasses == 1);

useDate = '2013-09-06';
load(fullfile(baseDir, useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VR_tracking_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VR_tuning_' useDate '.mat']));

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
            
            diffPDs = [pds(1)-pds(1), pds(2)-pds(1), pds(3)-pds(1)];
            
            classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
            
            useClasses(unit) = cellClasses(classInd);
            
            
        end
    end
end

% now count how many adapting and non-adapting cells there are
useClasses = useClasses(useClasses~=-1);
adaptingCount_2 = sum(useClasses ~= 1);
nonadaptingCount_2 = sum(useClasses == 1);

useDate = '2013-09-10';
load(fullfile(baseDir, useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VR_tracking_' useDate '.mat']));
load(fullfile(baseDir, useDate,['RT_VR_tuning_' useDate '.mat']));

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
            
            diffPDs = [pds(1)-pds(1), pds(2)-pds(1), pds(3)-pds(1)];
            
            classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
            
            useClasses(unit) = cellClasses(classInd);
            
        end
    end
end

% now count how many adapting and non-adapting cells there are
useClasses = useClasses(useClasses~=-1);
adaptingCount_3 = sum(useClasses ~= 1);
nonadaptingCount_3 = sum(useClasses == 1);

%%
fh = figure('Position', [200, 200, 800, 600]);
hold all;
% histograms of BL->WO for FF and VR
bar([1 2 3],[nonadaptingCount_1, nonadaptingCount_2, nonadaptingCount_3]);
h = findobj(gca,'Type','patch');
set(h,'EdgeColor','w','facealpha',1,'edgealpha',1)

bar([5, 6, 7],[adaptingCount_1, adaptingCount_2, adaptingCount_3]);
h1 = findobj(gca,'Type','patch');
set(h1,'EdgeColor','w','facealpha',1,'edgealpha',1);

V = axis;

set(gca,'YTick',V(3):3:V(4),'XTick',[1 2.3 4 5.3],'XTickLabel',{'Non-Adapting','Adapting','Non-Adapting','Adapting'},'FontSize',14);
ylabel('Count','FontSize',16);


