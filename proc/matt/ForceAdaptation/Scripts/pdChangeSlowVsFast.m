% pdChangeSlowVsFast
%   Plots histograms of population PD change for slow movements and fast
%   movements. Intended for RT task only. Requires speedSlow and speedFast
%   parameter sets.

if ~doMD
    ymin = -50;
    ymax = 150;
    binSize = 10;
    y_lab = 'PD Change (Deg) ';
else
    ymin = -30;
    ymax = 30;
    binSize = 2;
    y_lab = 'MD Change (Hz) ';
end

%% Get the classification for each day for slow cells
paramSetName = 'speedSlow';

cellPDs = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
    
    classifierBlocks = c.params.classes.classifierBlocks;
    
    tunedCells = c.tuned_cells;
    
    % Only consider cells with significant changes
    changedCells = c.sg(c.classes(:,1)==1 | c.classes(:,1)==2 | c.classes(:,1)==3 | c.classes(:,1)==4,:);
    [~,idx] = intersect(changedCells, tunedCells,'rows');
    tunedCells = changedCells(idx,:);
    
    sg_bl = t(classifierBlocks(1)).sg;
    sg_ad = t(classifierBlocks(2)).sg;
    sg_wo = t(classifierBlocks(3)).sg;
    
    [~,idx_bl] = intersect(sg_bl, tunedCells,'rows');
    [~,idx_ad] = intersect(sg_ad, tunedCells,'rows');
    [~,idx_wo] = intersect(sg_wo, tunedCells,'rows');
    
    if ~doMD % do PDs
        pds_bl = t(classifierBlocks(1)).pds(idx_bl,1);
        pds_ad = t(classifierBlocks(2)).pds(idx_ad,1);
        pds_wo = t(classifierBlocks(3)).pds(idx_wo,1);
    else
        pds_bl = t(classifierBlocks(1)).mds(idx_bl,1);
        pds_ad = t(classifierBlocks(2)).mds(idx_ad,1);
        pds_wo = t(classifierBlocks(3)).mds(idx_wo,1);
    end
    
    cellPDs{iFile} = {pds_bl, pds_ad, pds_wo};
end

% find all dPDs
slow_dpd_ad = [];
slow_dpd_wo = [];
for iFile = 1:size(doFiles,1)
    pds = cellPDs{iFile};
    if ~doMD
        slow_dpd_ad = [slow_dpd_ad; angleDiff(pds{1},pds{2},true,true).*(180/pi)];
        slow_dpd_wo = [slow_dpd_wo; angleDiff(pds{1},pds{3},true,true).*(180/pi)];
    else
        slow_dpd_ad = [slow_dpd_ad; pds{2}-pds{1}];
        slow_dpd_wo = [slow_dpd_wo; pds{3}-pds{1}];
    end
end

%% Get the classification for each day for fast cells
paramSetName = 'speedFast';

cellPDs = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
    
    tunedCells = c.tuned_cells;
    
    % Only consider cells with significant changes
    changedCells = c.sg(c.classes(:,1)==1 | c.classes(:,1)==2 | c.classes(:,1)==3 | c.classes(:,1)==4,:);
    [~,idx] = intersect(changedCells, tunedCells,'rows');
    tunedCells = changedCells(idx,:);
    
    sg_bl = t(classifierBlocks(1)).sg;
    sg_ad = t(classifierBlocks(2)).sg;
    sg_wo = t(classifierBlocks(3)).sg;
    
    [~,idx_bl] = intersect(sg_bl, tunedCells,'rows');
    [~,idx_ad] = intersect(sg_ad, tunedCells,'rows');
    [~,idx_wo] = intersect(sg_wo, tunedCells,'rows');
    
    if ~doMD % do PDs
        pds_bl = t(classifierBlocks(1)).pds(idx_bl,1);
        pds_ad = t(classifierBlocks(2)).pds(idx_ad,1);
        pds_wo = t(classifierBlocks(3)).pds(idx_wo,1);
    else
        pds_bl = t(classifierBlocks(1)).mds(idx_bl,1);
        pds_ad = t(classifierBlocks(2)).mds(idx_ad,1);
        pds_wo = t(classifierBlocks(3)).mds(idx_wo,1);
    end
    
    cellPDs{iFile} = {pds_bl, pds_ad, pds_wo};
end

% find all dPDs
fast_dpd_ad = [];
fast_dpd_wo = [];
for iFile = 1:size(doFiles,1)
    pds = cellPDs{iFile};
    if ~doMD
        fast_dpd_ad = [fast_dpd_ad; angleDiff(pds{1},pds{2},true,true).*(180/pi)];
        fast_dpd_wo = [fast_dpd_wo; angleDiff(pds{1},pds{3},true,true).*(180/pi)];
    else
        fast_dpd_ad = [fast_dpd_ad; pds{2}-pds{1}];
        fast_dpd_wo = [fast_dpd_wo; pds{3}-pds{1}];
    end
end

%%
% Plot histograms of stuff
histBins = (ymin+binSize/2):binSize:(ymax-binSize/2);

fh = figure;
hold all;

% histograms of BL->AD for FF and VR
[f,x]=hist(fast_dpd_ad,histBins);
% plot(x,100.*f/sum(f),'r','LineWidth',2);
bar(x,100.*f/sum(f));
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w');

[f,x]=hist(slow_dpd_ad,histBins);
% plot(x,100.*f/sum(f),'b','LineWidth',2);
bar(x,100.*f/sum(f));
h = findobj(gca,'Type','patch');
set(h,'EdgeColor','w','facealpha',0.7,'edgealpha',0.7);

set(gca,'XLim',[ymin,ymax],'TickDir','out','FontSize',14);
box off;
xlabel('Change in PD','FontSize',14);
ylabel('Count','FontSize',14);

mean(slow_dpd_ad)
std(slow_dpd_ad)/sqrt(length(slow_dpd_ad))
mean(fast_dpd_ad)
std(fast_dpd_ad)/sqrt(length(fast_dpd_ad))

mean(slow_dpd_wo)
std(slow_dpd_wo)/sqrt(length(slow_dpd_wo))
mean(fast_dpd_wo)
std(fast_dpd_wo)/sqrt(length(fast_dpd_wo))

%
% figure;
% boxplot([slow_dpd_ad; fast_dpd_ad],[zeros(length(slow_dpd_ad),1); ones(length(fast_dpd_ad),1)])

