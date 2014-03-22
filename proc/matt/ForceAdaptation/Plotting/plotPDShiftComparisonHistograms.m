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

closethem = false;
makePositive = false;

useColors = {[0.7 0 0],[0 0 0.7],[0 0 1],[0 0.7 0],[1 1 1]};

% some defaults
binSize = 3; %degrees
maxAngle = 360; %degrees
useArray = 'PMd';
figurePosition = [200, 200, 800, 600];
tuneMethod = 'regression';
savePath = [];
histBins = [];
useBlocks = 1:4;
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
        case 'plotMax'
            plotMax = varargin{i+1};
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
        case 'useblocks'
            useBlocks = varargin{i+1};
    end
end

% load plotting parameters
fontSize = 16;

if isempty(histBins)
    histBins = -(maxAngle-binSize/2):binSize:(maxAngle-binSize/2);
end

adaptingCount = cell(length(useBlocks),size(useDate,1));
nonadaptingCount = cell(length(useBlocks),size(useDate,1));
fileDiffPDs = cell(length(useBlocks),size(useDate,1));
fileErrs = cell(length(useBlocks),size(useDate,1));

for iFile = 1:size(useDate,1)
    
    % only load the needed array
    classes = load(fullfile(baseDir,useDate{iFile,1}, useDate{iFile,2}, useDate{iFile,5}, [useDate{iFile,4} '_' useDate{iFile,3} '_classes_' useDate{iFile,2} '.mat']));
    tracking = load(fullfile(baseDir,useDate{iFile,1}, useDate{iFile,2}, [useDate{iFile,4} '_' useDate{iFile,3} '_tracking_' useDate{iFile,2} '.mat']));
    tuning = load(fullfile(baseDir,useDate{iFile,1}, useDate{iFile,2}, useDate{iFile,5}, [useDate{iFile,4} '_' useDate{iFile,3} '_tuning_' useDate{iFile,2} '.mat']));
    
    % histograms of BL->AD and AD->WO
    
    allClasses = classes.(useArray).(tuneMethod).(usePeriod);
    
    for iBlock = 1:length(useBlocks)
        tune_idx = allClasses(useBlocks(iBlock)).tuned_cells;
        tune_sg = allClasses(useBlocks(iBlock)).sg;
        tuned_cells = tune_sg(tune_idx,:);
        
        % get unit guides and pd matrices
        allTuningBL = tuning.BL.(useArray).(tuneMethod).(usePeriod);
        allTuningAD = tuning.AD.(useArray).(tuneMethod).(usePeriod);
        allTuningWO = tuning.WO.(useArray).(tuneMethod).(usePeriod);
        
        sg_bl = allTuningBL.sg;
        sg_ad = allTuningAD(useBlocks(iBlock)).sg;
        sg_wo = allTuningWO.sg;
        
        pds_bl = allTuningBL.pds;
        pds_ad = allTuningAD(useBlocks(iBlock)).pds;
        pds_wo = allTuningWO.pds;
        
        % check to make sure the unit guides are okay
        badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
        sg_master = setdiff(sg_bl,badUnits,'rows');
        
        % second column is PD
        cellClasses = allClasses(useBlocks(iBlock)).classes(:,2);
        
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
                    err(1) = angleDiff(pds_bl(useInd,3),pds_bl(useInd,2),true,false)/2;
                    
                    useInd = sg_ad(:,1)==sg_master(unit,1) & sg_ad(:,2)==sg_master(unit,2);
                    pds(2) = pds_ad(useInd,1);
                    err(2) = angleDiff(pds_ad(useInd,3),pds_ad(useInd,2),true,false)/2;
                    
                    useInd = sg_wo(:,1)==sg_master(unit,1) & sg_wo(:,2)==sg_master(unit,2);
                    pds(3) = pds_wo(useInd,1);
                    err(3) = angleDiff(pds_wo(useInd,3),pds_wo(useInd,2),true,false)/2;
                    
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
        adaptingCount{iBlock,iFile} = sum(useClasses == 2 | useClasses == 3);
        nonadaptingCount{iBlock,iFile} = sum(useClasses == 1 | useClasses == 4);
        fileDiffPDs{iBlock,iFile} = allDiffPDs;
        fileErrs{iBlock,iFile} = allErrs;
    end
end

allMeans_ad = cell(1,1);
allMeans_wo = cell(1,length(useBlocks));
allMeans_bl = cell(1,1);

% group together files with same title
titles = useDate(:,6);
uTitles = unique(titles);
uTitles = fliplr(uTitles');

tempMeans_bl = zeros(2,length(uTitles));
tempMeans_ad = zeros(2,length(uTitles));
tempMeans_wo = zeros(2,length(uTitles));

%%% get error for baseline tuning
for iFile = 1:length(uTitles)
    groupBLErrs = [];
    for j = 1:size(useDate,1)
        if strcmp(useDate(j,6),uTitles{iFile}) && ~isempty(fileDiffPDs{iBlock,j})
            groupBLErrs = [groupBLErrs; fileErrs{iBlock,j}(1)];
        end
    end
    
    tempMeans_bl(1,iFile) = 0;
    tempMeans_bl(2,iFile) = mean(groupBLErrs);
    
end


%%% DO THE ADAPTATION PERIOD
for iBlock = 1:length(useBlocks)
fh = figure('Position', figurePosition);
hold all;
    for iFile = 1:length(uTitles)
        % concatenate relevant data
        groupDiffPDs = [];
        groupDiffErrs = [];
        
        for j = 1:size(useDate,1)
            if strcmp(useDate{j,6},uTitles{iFile}) && ~isempty(fileDiffPDs{iBlock,j})
                groupDiffPDs = [groupDiffPDs; fileDiffPDs{iBlock,j}(:,1)];
%                 groupDiffErrs = [groupDiffErrs; fileErrs{iBlock,j}(:,1)+fileErrs{iBlock,j}(:,2)];
                groupDiffErrs = [groupDiffErrs; fileErrs{iBlock,j}(:,2)];
            end
        end
        
        % if anything is less than -90 degrees, make positive
        if makePositive
            groupDiffPDs(groupDiffPDs < -pi/2) = groupDiffPDs(groupDiffPDs < -pi/2)+2*pi;
        end
        % readjust bins
        %     histBins = histBins+90+binSize/2;
        
        % histograms of BL->AD for FF and VR
        [N,X] = hist(groupDiffPDs.*180/pi,histBins);
        hist(groupDiffPDs.*180/pi,histBins);
        h = findobj(gca,'Type','patch');
        
        % get mean
        tempMeans_ad(1,iFile) = median(groupDiffPDs);
%         tempMeans_ad(1,iFile) = circular_mean(groupDiffPDs);
%         tempMeans_ad(2,iFile) = circular_std(groupDiffPDs)./sqrt(length(groupDiffPDs));
        tempMeans_ad(2,iFile) = mean(groupDiffErrs);
        
        if iFile == 1
            set(h,'FaceColor',useColors{iFile});
        else
            set(h,'EdgeColor','w','facealpha',0.7,'edgealpha',0.7);
        end
        
        arrow('Start',[circular_mean(groupDiffPDs).*180/pi 6.5],'Stop',[circular_mean(groupDiffPDs).*180/pi 6],'Width',3)
        
    end
    
    
    % add legend
    for iFile = 1:length(uTitles)
        rectangle('Position',[16 7-0.7*(iFile-1) 5 0.5],'FaceColor',useColors{iFile});
        text(22,7.25-0.7*(iFile-1),uTitles{iFile},'FontSize',16);
    end
    
    % show perturbation
%     arrow('Start',[-30,7],'Stop',[-7 7],'Width',3);
%     text(-30,7.5,'Perturbation Direction','FontSize',16);
    
    
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
    
    if closethem
        close;
    end
    
    tempMeans_ad = tempMeans_ad.*180/pi;
    allMeans_ad{iBlock} = tempMeans_ad;
end


% print -depsc2 -adobecset -painter filename.eps

%%% NOW DO THE WASHOUT
fh = figure('Position', [200, 200, 800, 600]);
hold all;
for iFile = 1:length(uTitles)
    
    % concatenate relevant data
    groupDiffPDs = [];
    groupDiffErrs = [];
    for j = 1:size(useDate,1)
        if strcmp(useDate(j,6),uTitles{iFile}) && ~isempty(fileDiffPDs{iBlock,j})
            groupDiffPDs = [groupDiffPDs; fileDiffPDs{iBlock,j}(:,3)];
%             groupDiffErrs = [groupDiffErrs; fileErrs{iBlock,j}(:,1)+fileErrs{iBlock,j}(:,3)];
            groupDiffErrs = [groupDiffErrs; fileErrs{iBlock,j}(:,3)];
        end
    end
    
    % if anything is less than -90 degrees, make positive
    if makePositive
        groupDiffPDs(groupDiffPDs < -pi/2) = groupDiffPDs(groupDiffPDs < -pi/2)+2*pi;
    end
    tempMeans_wo(1,iFile) = median(groupDiffPDs);
%     tempMeans_wo(1,iFile) = circular_mean(groupDiffPDs);
%     tempMeans_wo(2,iFile) = circular_std(groupDiffPDs)./sqrt(length(groupDiffPDs));
    tempMeans_wo(2,iFile) = mean(groupDiffErrs);
    
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
    arrow('Start',[circular_mean(groupDiffPDs).*180/pi 6.5],'Stop',[circular_mean(groupDiffPDs).*180/pi 6],'Width',3)
end

% add legend
for iFile = 1:length(uTitles)
    rectangle('Position',[16 7-0.7*(iFile-1) 5 0.5],'FaceColor',useColors{iFile});
    text(22,7.25-0.7*(iFile-1),uTitles{iFile},'FontSize',16);
end

% show perturbation
% arrow('Start',[-30,7],'Stop',[-7 7],'Width',3);
% text(-30,7.5,'Perturbation Direction','FontSize',16);


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

if closethem
    close;
end

tempMeans_bl = tempMeans_bl.*180/pi;
tempMeans_wo = tempMeans_wo.*180/pi;

allMeans_bl{1} = tempMeans_bl;
allMeans_wo{1} = tempMeans_wo;



% Now plot bar of cell counts
if 0
    xticks = [];
    xticklabels = repmat({'Non-Adapting','Adapting'},1,length(useDate));

    % group together files with same title
    titles = useDate(:,6);
    uTitles = unique(titles);

    fh = figure('Position', [200, 200, 800, 600]);
    hold all;

    allAdapt = zeros(2,length(uTitles));
    for iFile = 1:length(uTitles)

        % concatenate relevant data
        groupAdaptingCount = 0;
        groupNonadaptingCount = 0;
        for j = 1:size(useDate,1)
            if strcmp(useDate(j,6),uTitles{iFile})
                groupAdaptingCount = groupAdaptingCount + adaptingCount{j};
                groupNonadaptingCount = groupNonadaptingCount + nonadaptingCount{j};
            end
        end

        xPos = [1+3*(iFile-1), 2.3+3*(iFile-1)];
        % histograms of BL->WO for FF and VR
        bar(xPos,[groupNonadaptingCount, groupAdaptingCount]);
        h = findobj(gca,'Type','patch');

        allAdapt(1,iFile) = groupAdaptingCount;
        allAdapt(2,iFile) = groupNonadaptingCount;

        if iFile == 1
            set(h,'FaceColor',useColors{iFile},'EdgeColor','w');
        else
            set(h,'EdgeColor','w','facealpha',0.7,'edgealpha',0.7);
        end

        xticks = [xticks xPos];
    end

    V = axis;
    set(gca,'YTick',V(3):3:V(4),'XTick',xticks,'XTickLabel',xticklabels,'FontSize',fontSize);
    ylabel('Count','FontSize',16);

    if ~isempty(savePath)
        fn = [savePath '_bar.png'];
        saveas(fh,fn,'png');
    end
end
