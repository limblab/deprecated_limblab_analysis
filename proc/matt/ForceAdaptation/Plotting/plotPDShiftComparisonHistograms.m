function [allMeans,allDiffPDs] = plotPDShiftComparisonHistograms(varargin)
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
binSize = 5; %degrees
maxAngle = 150; %degrees
useArray = 'PMd';
figurePosition = [200, 200, 800, 600];
tuneMethod = 'regression';
savePath = [];
histBins = [];
useBlocks = [1,4,6];
coordinates = 'movement';
titleIndex = 3;
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'dir'
            baseDir = varargin{i+1};
        case 'dates'
            doFiles = varargin{i+1};
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
        case 'useblocks'
            useBlocks = varargin{i+1};
        case 'coordinates'
            coordinates = varargin{i+1};
        case 'titleindex'
            titleIndex = varargin{i+1};
        case 'numblocksepoch'
            numBlocksEpoch = varargin{i+1};
    end
end


% load plotting parameters
fontSize = 16;

if isempty(histBins)
    histBins = -(maxAngle-binSize/2):binSize:(maxAngle-binSize/2);
end

fileDiffPDs = cell(length(useBlocks),size(doFiles,1));
fileErrs = cell(length(useBlocks),size(doFiles,1));

for iFile = 1:size(doFiles,1)
    
    % change the array optionally
    if size(doFiles,2) > 4
        useArray = doFiles{iFile,5};
    end
    
    % only load the needed array
    classes = load(fullfile(baseDir,doFiles{iFile,1}, doFiles{iFile,2}, coordinates, [doFiles{iFile,4} '_' doFiles{iFile,3} '_classes_' doFiles{iFile,2} '.mat']));
    tracking = load(fullfile(baseDir,doFiles{iFile,1}, doFiles{iFile,2}, [doFiles{iFile,4} '_' doFiles{iFile,3} '_tracking_' doFiles{iFile,2} '.mat']));
    tuning = load(fullfile(baseDir,doFiles{iFile,1}, doFiles{iFile,2}, coordinates, [doFiles{iFile,4} '_' doFiles{iFile,3} '_tuning_' doFiles{iFile,2} '.mat']));
    
    % histograms of BL->AD and AD->WO
    
    useClasses = classes.(tuneMethod).(usePeriod).(useArray);
    
    tuned_cells = useClasses.tuned_cells;
    tune_sg = useClasses.sg;
    
    % get unit guides and pd matrices
    t = tuning.(tuneMethod).(usePeriod).(useArray).tuning;
    
    % first one is baseline, let's assume
    sg_bl = t(1).sg;
    pds_bl = t(1).pds;
    
    for iBlock = 1:length(t)
        
        sg_t = t(iBlock).sg;
        pds_t = t(iBlock).pds;
        
        % check to make sure the unit guides are okay
        badUnits = checkUnitGuides(sg_bl,sg_t);
        sg_master = setdiff(sg_bl,badUnits,'rows');
        
        useComp = tracking.(useArray){1}.chan;
        
        allDiffPDs = [];
        allErrs = [];
        for unit = 1:size(sg_master,1)
            % if the cell meets the tuning criteria
            %   and also if the cell is tracked across epochs
            if ismember(sg_master(unit,:),tuned_cells,'rows')
                % don't include cell if it fails KS test
                relCompInd = useComp(:,1)==sg_master(unit,1)+.1*sg_master(unit,2);
                
                if ~any(diff(useComp(relCompInd,:)))
                    
                    useInd = sg_t(:,1)==sg_master(unit,1) & sg_t(:,2)==sg_master(unit,2);
                    pds = pds_t(useInd,1);
                    err = angleDiff(pds_t(useInd,3),pds_t(useInd,2),true,false)/2;
                    
                    blInd = sg_bl(:,1)==sg_master(unit,1) & sg_bl(:,2)==sg_master(unit,2);
                    
                    % find confidence bounds and difference from BL
                    allDiffPDs = [allDiffPDs; angleDiff(pds_bl(blInd,1),pds,true,true)];
                    allErrs = [allErrs; err];
                end
            end
        end
        
        % store these for plotting later
        fileDiffPDs{iBlock,iFile} = allDiffPDs;
        fileErrs{iBlock,iFile} = allErrs;
    end
end

% so now for each block we have the difference from baseline for each PD as
% well as the confidence bounds on the PD estimates
%   Note that the first one will have a diff of zero, since its BL-BL, but
%   it's still useful to estimate the baseline error

% group together files with same title
titles = doFiles(:,titleIndex);
uTitles = unique(titles);
uTitles = fliplr(uTitles');

%%% get PDs and errors for all grouped files
allMeans = cell(1,length(t));
allDiffPDs = cell(length(t),length(uTitles));
for iBlock = 1:length(t)
    tempMeans = zeros(2,length(uTitles));
    for iTitle = 1:length(uTitles)
        groupDiffPDs = [];
        groupErrs = [];
        for iFile = 1:size(doFiles,1)
            % if the current file has the right title
            if strcmp(doFiles(iFile,titleIndex),uTitles{iTitle}) && ~isempty(fileDiffPDs{iBlock,iFile})
                groupDiffPDs = [groupDiffPDs; fileDiffPDs{iBlock,iFile}(:,1)];
                groupErrs = [groupErrs; fileErrs{iBlock,iFile}(1)];
            end
        end
        
        % if anything is less than -90 degrees, make positive
        if makePositive
            groupDiffPDs(groupDiffPDs < -pi/2) = groupDiffPDs(groupDiffPDs < -pi/2)+2*pi;
        end
        
        tempMeans(1,iTitle) = median(groupDiffPDs);
        tempMeans(2,iTitle) = mean(groupErrs);
        
        allMeans{iBlock} = tempMeans;
        allDiffPDs{iBlock,iTitle} = groupDiffPDs;
    end
end

%%% Now make the plots
% first, adaptation
for iFig = 2%:length(useBlocks)
    fh = figure('Position', figurePosition);
    hold all;
    for iTitle = 1:length(uTitles)
        % make any negative values positive
        groupDiffPDs = allDiffPDs{useBlocks(iFig),iTitle};
        
        % histograms of BL->AD for FF and VR
        hist(groupDiffPDs.*180/pi,histBins);
        h = findobj(gca,'Type','patch');
        if iTitle == 1
            set(h,'FaceColor',useColors{iTitle},'EdgeColor','w');
        else
            set(h,'EdgeColor','w','facealpha',0.7,'edgealpha',0.7);
        end
    end
    
    % for iTitle = 1:length(uTitles)
    %     arrow('Start',[circular_mean(groupDiffPDs).*180/pi 6.5],'Stop',[circular_mean(groupDiffPDs).*180/pi 6],'Width',3)
    % end
    
    % add legend
    for iTitle = 1:length(uTitles)
        rectangle('Position',[16 7-0.7*(iTitle-1) 5 0.5],'FaceColor',useColors{iTitle});
        text(22,7.25-0.7*(iTitle-1),uTitles{iTitle},'FontSize',16);
    end
    
    % show perturbation
    % arrow('Start',[-30,7],'Stop',[-7 7],'Width',3);
    % text(-30,7.5,'Perturbation Direction','FontSize',16);
    
    
%     title('Baseline -> Adaptation','FontSize',18);
    xlabel('Change in PD (Deg)','FontSize',16);
    ylabel('Count','FontSize',16);
    axis('tight');
    V=axis;
    axis([V(1) V(2) 0 V(4)]);
    set(gca,'FontSize',14,'TickDir','out');
    
    if ~isempty(savePath)
        fn = [savePath '_ad.png'];
        saveas(fh,fn,'png');
    end
    
    if closethem
        close;
    end
    
    % print -depsc2 -adobecset -painter filename.eps
end
