% pdChangeSlowVsFast
%   Plots histograms of population PD change for slow movements and fast
%   movements. Intended for RT task only. Requires speedSlow and speedFast
%   parameter sets.

doAvg = slidingParams.doAvg; % do average across sessions (mainly for group scatter plot)
useVel = slidingParams.useVel; % use velocity instead of measured force
useMasterTuned = slidingParams.useMasterTuned; % whether to use tuning from standard 'movement' tuning method to see which are "well-tuned"
doAbs = slidingParams.doAbs; % take absolute of difference between epochs
doMD = slidingParams.doMD; % take absolute of difference between epochs
doMDNorm = slidingParams.doMDNorm; % whether to normalize by baseline modulation depth
metric = slidingParams.metric;

if ~doMD
    ymin = -30;
    ymax = 180;
    binSize = 10;
    x_lab = 'PD Change (Deg) ';
else
    if doMDNorm
        if doAbs
            ymin = 0;
            ymax = 1.5;
            binSize = 0.05;
        else
            ymin = -1.5;
            ymax = 1.5;
            binSize = 0.1;
        end
        x_lab = 'Normalized MD Change (Hz) ';
    else
        ymin = -30;
        ymax = 30;
        binSize = 2;
        x_lab = 'MD Change (Hz) ';
    end
end

%% Get the classification for each day for slow cells
paramSetName = 'speedSlow';

pertDir = zeros(1,size(doFiles,1));
cellPDs = cell(size(doFiles,1),1);
cellSG = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
    
        % get direction of perturbation to flip the clockwise ones to align
        if flipClockwisePerts && ~doAbs
            % gotta hack it
            dataPath = fullfile(root_dir,doFiles{iFile,1},'Processed',doFiles{iFile,2});
            expParamFile = fullfile(dataPath,[doFiles{iFile,2} '_experiment_parameters.dat']);
            t(1).params.exp = parseExpParams(expParamFile);
            pertDir(iFile) = t(1).params.exp.angle_dir;
        else
            pertDir(iFile) = 1;
        end
    
    classifierBlocks = c.params.classes.classifierBlocks;
    
    tunedCells = c.tuned_cells;
    
    % Only consider cells with significant changes
    changedCells = c.sg(c.classes(:,1)==1 | c.classes(:,1)==2 | c.classes(:,1)==3 | c.classes(:,1)==4 | c.classes(:,1)==5,:);
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
    cellSG{iFile} = sg_bl(idx_bl,:);
end

% find all dPDs
slow_dpd_ad = [];
slow_dpd_wo = [];
slow_sg = [];
for iFile = 1:size(doFiles,1)
    pds = cellPDs{iFile};
    sg = cellSG{iFile};
    if ~doMD
        slow_dpd_ad = [slow_dpd_ad; pertDir(iFile)*angleDiff(pds{1},pds{2},true,true).*(180/pi)];
        slow_dpd_wo = [slow_dpd_wo; pertDir(iFile)*angleDiff(pds{1},pds{3},true,true).*(180/pi)];
    else
        if doMDNorm
            slow_dpd_ad = [slow_dpd_ad; (pds{2}-pds{1})./pds{1}];
            slow_dpd_wo = [slow_dpd_wo; (pds{3}-pds{1})./pds{1}];
        else
            slow_dpd_ad = [slow_dpd_ad; pds{2}-pds{1}];
            slow_dpd_wo = [slow_dpd_wo; pds{3}-pds{1}];
        end
    end
    slow_sg = [slow_sg; sg];
end

%% Get the classification for each day for fast cells
paramSetName = 'speedFast';

pertDir = zeros(1,size(doFiles,1));
cellPDs = cell(size(doFiles,1),1);
cellSG = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
    
        % get direction of perturbation to flip the clockwise ones to align
        if flipClockwisePerts && ~doAbs
            % gotta hack it
            dataPath = fullfile(root_dir,doFiles{iFile,1},'Processed',doFiles{iFile,2});
            expParamFile = fullfile(dataPath,[doFiles{iFile,2} '_experiment_parameters.dat']);
            t(1).params.exp = parseExpParams(expParamFile);
            pertDir(iFile) = t(1).params.exp.angle_dir;
        else
            pertDir(iFile) = 1;
        end
    
    tunedCells = c.tuned_cells;
    
    % Only consider cells with significant changes
    changedCells = c.sg(c.classes(:,1)==1 | c.classes(:,1)==2 | c.classes(:,1)==3 | c.classes(:,1)==4 | c.classes(:,1)==5,:);
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
    cellSG{iFile} = sg_bl(idx_bl,:);
end

% find all dPDs
fast_dpd_ad = [];
fast_dpd_wo = [];
fast_sg = [];
for iFile = 1:size(doFiles,1)
    pds = cellPDs{iFile};
    sg = cellSG{iFile};
    if ~doMD
        fast_dpd_ad = [fast_dpd_ad; pertDir(iFile)*angleDiff(pds{1},pds{2},true,true).*(180/pi)];
        fast_dpd_wo = [fast_dpd_wo; pertDir(iFile)*angleDiff(pds{1},pds{3},true,true).*(180/pi)];
    else
        if doMDNorm
            fast_dpd_ad = [fast_dpd_ad; (pds{2}-pds{1})./pds{1}];
            fast_dpd_wo = [fast_dpd_wo; (pds{3}-pds{1})./pds{1}];
        else
            fast_dpd_ad = [fast_dpd_ad; pds{2}-pds{1}];
            fast_dpd_wo = [fast_dpd_wo; pds{3}-pds{1}];
        end
    end
    fast_sg = [fast_sg; sg];
end

%%
if doAbs
    slow_dpd_ad = abs(slow_dpd_ad);
    fast_dpd_ad = abs(fast_dpd_ad);
    slow_dpd_wo = abs(slow_dpd_wo);
    fast_dpd_wo = abs(fast_dpd_wo);
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
xlabel(x_lab,'FontSize',14);
ylabel('Count','FontSize',14);

% mean(slow_dpd_ad)
% std(slow_dpd_ad)/sqrt(length(slow_dpd_ad))
% mean(fast_dpd_ad)
% std(fast_dpd_ad)/sqrt(length(fast_dpd_ad))
%
% mean(slow_dpd_wo)
% std(slow_dpd_wo)/sqrt(length(slow_dpd_wo))
% mean(fast_dpd_wo)
% std(fast_dpd_wo)/sqrt(length(fast_dpd_wo))

%% Now if desired look at differences between the same cells
%  [~,slow_idx,fast_idx] = intersect(slow_sg,fast_sg,'rows');
%  fast_dpd_ad = fast_dpd_ad(fast_idx);
%   fast_dpd_wo = fast_dpd_wo(fast_idx);
%    slow_dpd_ad = slow_dpd_ad(slow_idx);
%   slow_dpd_wo = slow_dpd_wo(slow_idx);
%
%   binSize = 0.01;
%   histBins = (0+binSize/2):binSize:(0.5-binSize/2);
%
% fh = figure;
% hold all;
%
% % histograms of BL->AD for FF and VR
% [f,x]=hist(fast_dpd_ad-slow_dpd_ad,histBins);
% % plot(x,100.*f/sum(f),'r','LineWidth',2);
% bar(x,100.*f/sum(f));
%

