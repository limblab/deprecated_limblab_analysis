function [allMeans_bl,allMeans_ad,allMeans_wo] = plotPDShiftComparisonHistograms(varargin)
% possible inputs:
%   baseDir
%   *usedate (use cell, if multiple loop through and add them?)
%   *adaptType
%   *useTask
%   *useTitles
%   usePeriod
%   binSize
%   maxAngle
%   classColors
%
% *these ones should be cells of same length to allow for multiple files

doAD = 1;
doWO = 1;
doBar = 0;

useColors = {[0.7 0 0],[0 0 0.7],[0 0 1],[0 0.7 0],[1 1 1]};

% some defaults
binSize = 3; %degrees
maxAngle = 45; %degrees
useArray = 'PMd';
figurePosition = [200, 200, 800, 600];
tuneMethod = 'regression';
savePath = [];
histBins = [];
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'dir'
            baseDir = varargin{i+1};
        case 'dates'
            useDate = varargin{i+1};
        case 'period'
            usePeriod = varargin{i+1};
        case 'binsize'
            binSize = varargin{i+1};
        case 'maxangle'
            maxAngle = varargin{i+1};
        case 'figurepos'
            figurePosition = varargin{i+1};
        case 'array'
            useArray = varargin{i+1};
        case 'savepath'
            savePath = varargin{i+1};
        case 'tunemethod'
            tuneMethod = varargin{i+1};
        case 'histbins'
            histBins = varargin{i+1};
    end
end

% load plotting parameters
fontSize = 16;

if isempty(histBins)
    histBins = -(maxAngle-binSize/2):binSize:(maxAngle-binSize/2);
end

adaptingCount = cell(1,size(useDate,1));
nonadaptingCount = cell(1,size(useDate,1));
fileDiffPDs = cell(1,size(useDate,1));
fileErrs = cell(1,size(useDate,1));
for iFile = 1:size(useDate,1)
    
    % only load the needed array
    classes = load(fullfile(baseDir, useDate{iFile,1}, useDate{iFile,4}, [useDate{iFile,3} '_' useDate{iFile,2} '_classes_' useDate{iFile,1} '.mat']));
    tracking = load(fullfile(baseDir, useDate{iFile,1}, [useDate{iFile,3} '_' useDate{iFile,2} '_tracking_' useDate{iFile,1} '.mat']));
    tuning = load(fullfile(baseDir, useDate{iFile,1}, useDate{iFile,4}, [useDate{iFile,3} '_' useDate{iFile,2} '_tuning_' useDate{iFile,1} '.mat']));
    
    % histograms of BL->AD and AD->WO
    
    tune_idx = classes.(useArray).(tuneMethod).(usePeriod).tuned_cells;
    tune_sg = classes.(useArray).(tuneMethod).(usePeriod).unit_guide;
    tuned_cells = tune_sg(tune_idx,:);
    
    % get unit guides and pd matrices
    sg_bl = tuning.BL.(useArray).(tuneMethod).(usePeriod).unit_guide;
    sg_ad = tuning.AD.(useArray).(tuneMethod).(usePeriod).unit_guide;
    sg_wo = tuning.WO.(useArray).(tuneMethod).(usePeriod).unit_guide;
    
    pds_bl = tuning.BL.(useArray).(tuneMethod).(usePeriod).pds;
    pds_ad = tuning.AD.(useArray).(tuneMethod).(usePeriod).pds;
    pds_wo = tuning.WO.(useArray).(tuneMethod).(usePeriod).pds;
    
    % check to make sure the unit guides are okay
    badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
    sg_master = setdiff(sg_bl,badUnits,'rows');
    
    % third column is PD
    cellClasses = classes.(useArray).(tuneMethod).(usePeriod).classes(:,3);
    
    useComp = tracking.(useArray){1}.chan;
    
    allDiffPDs = [];
    allErrs = [];
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
                err(1) = (pds_bl(useInd,3)-pds_bl(useInd,2))/2;
                useInd = sg_ad(:,1)==sg_master(unit,1) & sg_ad(:,2)==sg_master(unit,2);
                pds(2) = pds_ad(useInd,1);
                err(2) = (pds_ad(useInd,3)-pds_ad(useInd,2))/2;
                useInd = sg_wo(:,1)==sg_master(unit,1) & sg_wo(:,2)==sg_master(unit,2);
                pds(3) = pds_wo(useInd,1);
                err(3) = (pds_wo(useInd,3)-pds_wo(useInd,2))/2;
                
                classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
                useClasses(unit) = cellClasses(classInd);
                
                % BL->AD, AD->WO, BL->WO
                allDiffPDs = [allDiffPDs; angleDiff(pds(1),pds(2),true,true), angleDiff(pds(2),pds(3),true,true), angleDiff(pds(1),pds(3),true,true)];
                allErrs = [allErrs; err];
            end
        end
    end
    
    % now count how many adapting and non-adapting cells there are
    useClasses = useClasses(useClasses~=-1);
    
    % store these for plotting later
    adaptingCount{iFile} = sum(useClasses == 2 | useClasses == 3);
    nonadaptingCount{iFile} = sum(useClasses == 1 | useClasses == 4);
    fileDiffPDs{iFile} = allDiffPDs;
    fileErrs{iFile} = allErrs;
end

allMeans_ad = [];
allAdapt = [];
allMeans_wo = [];
allMeans_bl = [];




%%
% Make histograms
fh = figure('Position', figurePosition);
hold all;

% group together files with same title
titles = useDate(:,5);
uTitles = unique(titles);

allMeans_bl = zeros(2,length(uTitles));
% get error for baseline tuning
for iFile = 1:length(uTitles)
    groupBLErrs = [];
    for j = 1:size(useDate,1)
        if strcmp(useDate(j,5),uTitles{iFile})
            groupBLErrs = [groupBLErrs; fileErrs{j}(1)];
        end
    end
    
    allMeans_bl(1,iFile) = 0;
    allMeans_bl(2,iFile) = mean(groupBLErrs);
    
end



allMeans_ad = zeros(2,length(uTitles));
for iFile = 1:length(uTitles)
    
    % concatenate relevant data
    groupDiffPDs = [];
    groupDiffErrs = [];

    for j = 1:size(useDate,1)
        if strcmp(useDate(j,5),uTitles{iFile})
            groupDiffPDs = [groupDiffPDs; fileDiffPDs{j}(:,1)];
            groupDiffErrs = [groupDiffErrs; fileErrs{j}(:,1)+fileErrs{j}(:,2)];
            
        end
    end
   
        % if anything is less than -90 degrees, make positive
    groupDiffPDs(groupDiffPDs < -pi/2) = groupDiffPDs(groupDiffPDs < -pi/2)+2*pi;
    % readjust bins
%     histBins = histBins+90+binSize/2;

    % histograms of BL->AD for FF and VR
    [N,X] = hist(groupDiffPDs.*180/pi,histBins);
    hist(groupDiffPDs.*180/pi,histBins);
    h = findobj(gca,'Type','patch');
    

    
    % get mean
    allMeans_ad(1,iFile) = mean(groupDiffPDs);
    allMeans_ad(2,iFile) = (1/length(groupDiffPDs)).*sum(groupDiffErrs);
    
    if iFile == 1
        set(h,'FaceColor',useColors{iFile});
    else
        set(h,'EdgeColor','w','facealpha',0.7,'edgealpha',0.7);
    end
    
    arrow('Start',[mean(groupDiffPDs).*180/pi 6.5],'Stop',[mean(groupDiffPDs).*180/pi 6],'Width',3)
    
end


% add legend
for iFile = 1:length(uTitles)
    rectangle('Position',[16 7-0.7*(iFile-1) 5 0.5],'FaceColor',useColors{iFile});
    text(22,7.25-0.7*(iFile-1),uTitles{iFile},'FontSize',16);
end

% show perturbation
arrow('Start',[-30,7],'Stop',[-7 7],'Width',3);
text(-30,7.5,'Perturbation Direction','FontSize',16);


title('Baseline -> Adaptation','FontSize',18);
xlabel('Change in PD (Deg)','FontSize',16);
ylabel('Count','FontSize',16);
axis('tight');
V=axis;
axis([V(1) V(2) 0 V(4)]);
set(gca,'FontSize',16);

if ~isempty(savePath)
    fn = [savePath '_ad.png'];
    saveas(fh,fn,'png');
end



% print -depsc2 -adobecset -painter filename.eps

%%

fh = figure('Position', [200, 200, 800, 600]);
hold all;

allMeans_wo = zeros(2,length(uTitles));
for iFile = 1:length(uTitles)
    
    % concatenate relevant data
    groupDiffPDs = [];
    groupDiffErrs = [];
    for j = 1:size(useDate,1)
        if strcmp(useDate(j,5),uTitles{iFile})
            groupDiffPDs = [groupDiffPDs; fileDiffPDs{j}(:,3)];
            groupDiffErrs = [groupDiffErrs; fileErrs{j}(:,1)+fileErrs{j}(:,3)];
        end
    end
    
    % if anything is less than -90 degrees, make positive
    groupDiffPDs(groupDiffPDs < -pi/2) = groupDiffPDs(groupDiffPDs < -pi/2)+2*pi;
    
    allMeans_wo(1,iFile) = mean(groupDiffPDs);
    allMeans_wo(2,iFile) = (1/length(groupDiffPDs)).*sum(groupDiffErrs);
    % allMeans_wo(2,iFile) = circular_std(groupDiffPDs)./sqrt(length(groupDiffPDs));
    
    % make any negative values positive
    
    % histograms of BL->AD for FF and VR
    hist(groupDiffPDs.*180/pi,histBins);
    h = findobj(gca,'Type','patch');
    if iFile == 1
        set(h,'FaceColor',useColors{iFile},'EdgeColor','w');
    else
        set(h,'EdgeColor','w','facealpha',0.7,'edgealpha',0.7);
    end
end

for iFile = 1:length(uTitles)
    arrow('Start',[mean(groupDiffPDs).*180/pi 6.5],'Stop',[mean(groupDiffPDs).*180/pi 6],'Width',3)
end

% add legend
for iFile = 1:length(uTitles)
    rectangle('Position',[16 7-0.7*(iFile-1) 5 0.5],'FaceColor',useColors{iFile});
    text(22,7.25-0.7*(iFile-1),uTitles{iFile},'FontSize',16);
end

% show perturbation
arrow('Start',[-30,7],'Stop',[-7 7],'Width',3);
text(-30,7.5,'Perturbation Direction','FontSize',16);


title('Baseline -> Washout','FontSize',18);
xlabel('Change in PD (Deg)','FontSize',16);
ylabel('Count','FontSize',16);
axis('tight');
V=axis;
axis([V(1) V(2) 0 V(4)]);
set(gca,'FontSize',16);

if ~isempty(savePath)
    fn = [savePath '_wo.png'];
    saveas(fh,fn,'png');
end

allMeans_bl = allMeans_bl.*180/pi;
allMeans_ad = allMeans_ad.*180/pi;
allMeans_wo = allMeans_wo.*180/pi;


%% Now plot bar of cell counts
% if doBar
%     xticks = [];
%     xticklabels = repmat({'Non-Adapting','Adapting'},1,length(useDate));
%
%         % group together files with same title
%     titles = useDate(:,5);
%     uTitles = unique(titles);
%
%     fh = figure('Position', [200, 200, 800, 600]);
%     hold all;
%
%     allAdapt = zeros(2,length(uTitles));
%     for iFile = 1:length(uTitles)
%
%         % concatenate relevant data
%         groupAdaptingCount = 0;
%         groupNonadaptingCount = 0;
%         for j = 1:size(useDate,1)
%             if strcmp(useDate(j,5),uTitles{iFile})
%                 groupAdaptingCount = groupAdaptingCount + adaptingCount{j};
%                 groupNonadaptingCount = groupNonadaptingCount + nonadaptingCount{j};
%             end
%         end
%
%         xPos = [1+3*(iFile-1), 2.3+3*(iFile-1)];
%         % histograms of BL->WO for FF and VR
%         bar(xPos,[groupNonadaptingCount, groupAdaptingCount]);
%         h = findobj(gca,'Type','patch');
%
%         allAdapt(1,iFile) = groupAdaptingCount;
%         allAdapt(2,iFile) = groupNonadaptingCount;
%
%         if iFile == 1
%             set(h,'FaceColor',useColors{iFile},'EdgeColor','w');
%         else
%             set(h,'EdgeColor','w','facealpha',0.7,'edgealpha',0.7);
%         end
%
%         xticks = [xticks xPos];
%     end
%
%     V = axis;
%     set(gca,'YTick',V(3):3:V(4),'XTick',xticks,'XTickLabel',xticklabels,'FontSize',fontSize);
%     ylabel('Count','FontSize',16);
%
%     if ~isempty(savePath)
%         fn = [savePath '_bar.png'];
%         saveas(fh,fn,'png');
%     end
% end
