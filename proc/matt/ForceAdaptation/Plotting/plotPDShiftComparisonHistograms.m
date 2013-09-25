function plotPDShiftComparisonHistograms(varargin)
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
classColors = {[0.2,0.2,0.2],[0.2 0.6 1],[0.9 0.1 0.1],'r','g'};
epochs = {'BL','AD','WO'};
figurePosition = [200, 200, 1400, 800];
for i = 1:length(varargin)
    switch lower(varargin{i})
        case 'dir'
            baseDir = varargin{i+1};
        case 'date'
            useDate = varargin{i+1};
        case 'period'
            usePeriod = varargin{i+1};
        case 'type'
            adaptType = varargin{i+1};
        case 'titles'
            useTitles = varargin{i+1};
        case 'binsize'
            binSize = varargin{i+1};
        case 'maxangle'
            maxAngle = varargin{i+1};
        case 'classcolors'
            classColors = varargin{i+1};
        case 'figurepos'
            figurePosition = varargin{i+1};
    end
end

% load plotting parameters
fontSize = 16;

histBins = -(maxAngle-binSize/2):binSize:(maxAngle-binSize/2);

adaptingCount = cell(1,length(useDate));
nonadaptingCount = cell(1,length(useDate));
fileDiffPDs = cell(1,length(useDate));
for iFile = 1:length(useDate)

    load(fullfile(baseDir, useDate{iFile},[useTask{iFile} '_' adaptType{iFile} '_classes_' useDate '.mat']));
    load(fullfile(baseDir, useDate{iFile},[useTask{iFile} '_' adaptType{iFile} '_tracking_' useDate '.mat']));
    load(fullfile(baseDir, useDate{iFile},[useTask{iFile} '_' adaptType{iFile} '_tuning_' useDate '.mat']));

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

                classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
                useClasses(unit) = cellClasses(classInd);

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
end

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


