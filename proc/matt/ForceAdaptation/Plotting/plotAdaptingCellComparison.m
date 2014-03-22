function [adaptPercent,nonPercent,adaptingCount,nonAdaptingCount] = plotAdaptingCellComparison(varargin)
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

useColors = {[0.7 0 0],[0 0 0.7],[0 0 1],[0 0.7 0],[1 1 1]};

% some defaults
binSize = 3; %degrees
maxAngle = 45; %degrees
useArray = 'PMd';
figurePosition = [200, 200, 800, 600];
tuneMethod = 'regression';
savePath = [];
useBlocks = 1:3;
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
        case 'useblocks'
            useBlocks = varargin{i+1};
    end
end

% load plotting parameters
fontSize = 16;

adaptingCount = cell(length(useBlocks),size(useDate,1));
nonAdaptingCount = cell(length(useBlocks),size(useDate,1));
for iFile = 1:size(useDate,1)
    
    % only load the needed array
    classes = load(fullfile(baseDir, useDate{iFile,1}, useDate{iFile,2}, useDate{iFile,5}, [useDate{iFile,4} '_' useDate{iFile,3} '_classes_' useDate{iFile,2} '.mat']));
    tracking = load(fullfile(baseDir, useDate{iFile,1}, useDate{iFile,2}, [useDate{iFile,4} '_' useDate{iFile,3} '_tracking_' useDate{iFile,2} '.mat']));
    tuning = load(fullfile(baseDir, useDate{iFile,1}, useDate{iFile,2}, useDate{iFile,5}, [useDate{iFile,4} '_' useDate{iFile,3} '_tuning_' useDate{iFile,2} '.mat']));
    
    % histograms of BL->AD and AD->WO
    allClasses = classes.(useArray).(tuneMethod).(usePeriod);
    
    % get unit guides and pd matrices
    allTuningBL = tuning.BL.(useArray).(tuneMethod).(usePeriod);
    allTuningAD = tuning.AD.(useArray).(tuneMethod).(usePeriod);
    allTuningWO = tuning.WO.(useArray).(tuneMethod).(usePeriod);
    
    for iBlock = 1:length(useBlocks)
        
        tune_idx = allClasses(useBlocks(iBlock)).tuned_cells;
        tune_sg = allClasses(useBlocks(iBlock)).sg;
        tuned_cells = tune_sg(tune_idx,:);
        
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
        
        useClasses = -1*ones(size(cellClasses));
        for unit = 1:size(sg_master,1)
            % if the cell meets the tuning criteria
            %   and also if the cell is tracked across epochs
            if ismember(sg_master(unit,:),tuned_cells,'rows')
                
                % don't include cell if it fails KS test
                relCompInd = useComp(:,1)==sg_master(unit,1)+.1*sg_master(unit,2);
                if ~any(diff(useComp(relCompInd,:)))
                    classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
                    useClasses(unit) = cellClasses(classInd);
                end
            end
        end
        
        % now count how many adapting and non-adapting cells there are
        useClasses = useClasses(useClasses~=-1);
        
        % store these for plotting later
        adaptingCount{iBlock,iFile} = sum(useClasses == 2 | useClasses == 3);
        nonAdaptingCount{iBlock,iFile} = sum(useClasses == 1 | useClasses == 4);
    end
end


%% Now plot bar of cell counts
% group together files with same title
titles = useDate(:,6);
uTitles = unique(titles);
uTitles = fliplr(uTitles');

nonPercent = zeros(length(useBlocks),length(uTitles));
adaptPercent = zeros(length(useBlocks),length(uTitles));

for iBlock = 1:length(useBlocks)
    xticks = [];
%     xticklabels = repmat({[uTitles{iFile} ' Non-Adapting'],'Adapting'},1,length(useDate));
    xticklabels = {};
    
    fh = figure('Position', figurePosition);
    hold all;
    
    for iFile = 1:length(uTitles)
        xticklabels = [xticklabels {[uTitles{iFile} ' Non-Adapting'],'Adapting'}];
        % concatenate relevant data
        groupAdaptingCount = 0;
        groupNonadaptingCount = 0;
        for j = 1:size(useDate,1)
            if strcmp(useDate(j,6),uTitles{iFile})
                groupAdaptingCount = groupAdaptingCount + adaptingCount{iBlock,j};
                groupNonadaptingCount = groupNonadaptingCount + nonAdaptingCount{iBlock,j};
            end
        end
        
        totalCount = groupAdaptingCount + groupNonadaptingCount;
        nonPercent(iBlock,iFile) = 100*groupNonadaptingCount/totalCount;
        adaptPercent(iBlock,iFile) = 100*groupAdaptingCount/totalCount;
        
        xPos = [1+3*(iFile-1), 2.3+3*(iFile-1)];
        % histograms of BL->WO for FF and VR
        h = bar(xPos,[groupNonadaptingCount.*100./(groupNonadaptingCount+groupAdaptingCount), groupAdaptingCount.*100./(groupNonadaptingCount+groupAdaptingCount)]);
        h = findobj(gca,'Type','patch');
        
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
        fn = [savePath '_block' num2str(useBlocks(iBlock)) '_bar.png'];
        saveas(fh,fn,'png');
    end
    
    if closethem
        close;
    end
end
