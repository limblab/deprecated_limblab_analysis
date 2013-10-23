function plotPDShiftCellClasses(varargin)
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

% some defaults
binSize = 5; %degrees
maxAngle = 45; %degrees
useArray = 'PMd';
classColors = {[0.2,0.2,0.2],[0.2 0.6 1],[0.9 0.1 0.1],'r','g'};
figurePosition = [200, 200, 1400, 800];
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
        case 'classcolors'
            classColors = varargin{i+1};
        case 'figurepos'
            figurePosition = varargin{i+1};
        case 'array'
            useArray = varargin{i+1};
    end
end

% load plotting parameters
fontSize = 16;

histBins = -(maxAngle-binSize/2):binSize:(maxAngle-binSize/2);

xticklabels = repmat({'Baseline','Adaptation','Washout'},1,length(useDate));

xticks = [];

fh = figure('Position', figurePosition);
hold all;

adaptingCount = cell(1,size(useDate,1));
nonadaptingCount = cell(1,size(useDate,1));
fileDiffPDs = cell(1,size(useDate,1));
for iFile = 1:size(useDate,1)

    classes = load(fullfile(baseDir, useDate{iFile,1}, useDate{iFile,4}, [useDate{iFile,3} '_' useDate{iFile,2} '_classes_' useDate{iFile,1} '.mat']));
    tracking = load(fullfile(baseDir, useDate{iFile,1}, [useDate{iFile,3} '_' useDate{iFile,2} '_tracking_' useDate{iFile,1} '.mat']));
    tuning = load(fullfile(baseDir, useDate{iFile,1}, useDate{iFile,4}, [useDate{iFile,3} '_' useDate{iFile,2} '_tuning_' useDate{iFile,1} '.mat']));

    % histograms of BL->AD and AD->WO

    tune_idx = classes.(useArray).regression.(usePeriod).tuned_cells;
    tune_sg = classes.(useArray).regression.(usePeriod).unit_guide;
    tuned_cells = tune_sg(tune_idx,:);

    % get unit guides and pd matrices
    sg_bl = tuning.BL.(useArray).regression.(usePeriod).unit_guide;
    sg_ad = tuning.AD.(useArray).regression.(usePeriod).unit_guide;
    sg_wo = tuning.WO.(useArray).regression.(usePeriod).unit_guide;

    pds_bl = tuning.BL.(useArray).regression.(usePeriod).pds;
    pds_ad = tuning.AD.(useArray).regression.(usePeriod).pds;
    pds_wo = tuning.WO.(useArray).regression.(usePeriod).pds;

    % check to make sure the unit guides are okay
    badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
    sg_master = setdiff(sg_bl,badUnits,'rows');

    cellClasses = classes.(useArray).regression.(usePeriod).classes;

    useComp = tracking.(useArray){1}.chan;
    
    % x position for this file (putting all files on same plot)
    xPos = 0.4*(iFile-1) + [2*(iFile-1), 1+2*(iFile-1), 2+2*(iFile-1)];

    allDiffPDs = [];
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

                % color the traces based on the classification
                useColor = classColors{cellClasses(classInd)};
                useClasses(unit) = cellClasses(classInd);
                    
                plot(xPos,diffPDs.*180/pi,'LineWidth',2,'Color',useColor);
                plot(xPos,diffPDs.*180/pi,'d','LineWidth',3,'Color',useColor);

                % BL->AD, AD->WO, BL->WO
                allDiffPDs = [allDiffPDs; angleDiff(pds(1),pds(2),true,true), angleDiff(pds(2),pds(3),true,true), angleDiff(pds(1),pds(3),true,true)];
            end
        end
    end

    % now count how many adapting and non-adapting cells there are
    useClasses = useClasses(useClasses~=-1);
    
    % store these for plotting later
    adaptingCount{iFile} = sum(useClasses == 2 | useClasses == 3);
    nonadaptingCount{iFile} = sum(useClasses == 1 | useClasses == 4);
    fileDiffPDs{iFile} = allDiffPDs;
    
    % build arrays for labeling axes
    xticks = [xticks xPos];
end

% now add labeling and info to the plot
% fix labels
set(gca,'XTick',xticks,'XTickLabel',xticklabels,'FontSize',fontSize,'TickLength',[0 0]);
ylabel('Change in PD (Deg)','FontSize',fontSize);

axis('tight');
V = axis;
% define boundaries
axis([-0.1 max(xticks)+0.2 -45 45]);
V = axis;
% plot a separating line
plot([max(xticks)/2 max(xticks)/2],V(3:4),'k','LineWidth',1);

% make a legend
plot([3.4 3.9],[40 40],'Color',classColors{1},'LineWidth',3);
plot([3.4 3.9],[36 36],'Color',classColors{2},'LineWidth',3);
plot([3.4 3.9],[32 32],'Color',classColors{3},'LineWidth',3);
text(4,40,'Non-Adapting','FontSize',16);
text(4,36,'Adapting','FontSize',16);
text(4,32,'Memory','FontSize',16);

% add titles
for iFile = 1:size(useDate,1)
    set(gcf,'NextPlot','add');
    axes('position',[0.05+0.4*(iFile-1), 0, 0.5, 0.92]);
    h = title(useDate{iFile,5},'FontSize',fontSize);
    set(gca,'Visible','off');
    set(h,'Visible','on');
end
