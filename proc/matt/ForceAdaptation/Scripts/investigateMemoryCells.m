function investigateMemoryCells()
close all;

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';

allFiles = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
    'Mihili','2014-03-03','VR','CO'; ...    %12 S(M-P)
    'Mihili','2014-03-04','VR','CO'; ...    %13 S(M-P)
    'Mihili','2014-03-06','VR','CO'; ...    %14 S(M-P)
    'Mihili','2014-03-07','FF','CO'; ...    % 15
    'Chewie','2013-10-03','VR','CO'; ... %16  S ?
    'Chewie','2013-10-09','VR','RT'; ... %17  S x
    'Chewie','2013-10-10','VR','RT'; ... %18  S ?
    'Chewie','2013-10-11','VR','RT'; ... %19  S x
    'Chewie','2013-10-22','FF','CO'; ... %20  S ?
    'Chewie','2013-10-23','FF','CO'; ... %21  S ?
    'Chewie','2013-10-28','FF','RT'; ... %22  S x
    'Chewie','2013-10-29','FF','RT'; ... %23  S x
    'Chewie','2013-10-31','FF','CO'; ... %24  S ?
    'Chewie','2013-11-01','FF','CO'; ... %25 S ?
    'Chewie','2013-12-03','FF','CO'; ... %26 S
    'Chewie','2013-12-04','FF','CO'; ... %27 S
    'Chewie','2013-12-09','FF','RT'; ... %28 S
    'Chewie','2013-12-10','FF','RT'; ... %29 S
    'Chewie','2013-12-12','VR','RT'; ... %30 S
    'Chewie','2013-12-13','VR','RT'; ... %31 S
    'Chewie','2013-12-17','FF','RT'; ... %32 S
    'Chewie','2013-12-18','FF','RT'; ... %33 S
    'Chewie','2013-12-19','VR','CO'; ... %34 S
    'Chewie','2013-12-20','VR','CO'};    %35 S

useArray = 'M1';

reassignOthers = true;

classifierBlocks = [1 4 7];
numClasses = 5;
ymin = 0;
ymax = 100;
classLabels = {'Non-Adapt','Adapt','Mem I','Mem II','Other'};

groupLabels = {'Movement','Target'};

% Do movement tuning
doFiles = allFiles(strcmpi(allFiles(:,3),'FF'),:);
paramSetName = 'movement';
tuningMethod = 'regression';
tuningPeriod = 'onpeak';

% Get the classification and PDs for each day for tuned cells
[cellClasses,cellPDs] = getClassesAndPDs(root_dir,doFiles,paramSetName,useArray,classifierBlocks,tuningMethod,tuningPeriod);

if reassignOthers
    cellClasses = assignOthers(cellClasses,cellPDs);
    classLabels = classLabels(1:end-1);
    numClasses = numClasses-1;
end

% Get the counts for plotting
counts1 = getCounts(doFiles,cellClasses,'none',numClasses);

% why are some NaN?

paramSetName = 'target';
tuningMethod = 'regression';
tuningPeriod = 'onpeak';
[cellClasses,cellPDs] = getClassesAndPDs(root_dir,doFiles,paramSetName,useArray,classifierBlocks,tuningMethod,tuningPeriod);
counts2 = getCounts(doFiles,cellClasses,'none',numClasses);

% Now plot things!
figure;
hold all;
h = barwitherr([(nanstd(counts1,1)/sqrt(size(counts1,1)))' (nanstd(counts2,1)/sqrt(size(counts2,1)))'],[nanmean(counts1,1)' nanmean(counts2,1)'],'BarWidth',1);
set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
ylabel('Percent','FontSize',14);
legend(groupLabels,'FontSize',14);

% plot a pie for the first one
figure;
% subplot1(1,2);
% subplot1(1);
pie(nanmean(counts1,1),classLabels)
colormap jet;
set(gca,'XLim',[-1.5,1.5],'YLim',[-1.5,1.5],'FontSize',14);
% title(groupLabels{1},'FontSize',16);
% subplot1(2);
% pie(nanmean(counts2,1),classLabels);
% colormap jet;
% set(gca,'XLim',[-1.5,1.5],'YLim',[-1.5,1.5],'FontSize',14);
% title(groupLabels{2},'FontSize',16);


end

%% Get the classification and PDs for each day for tuned cells
function [cellClasses,cellPDs] = getClassesAndPDs(root_dir,doFiles,paramSetName,useArray,classifierBlocks,tuningMethod,tuningPeriod)

cellClasses = cell(size(doFiles,1),1);
cellPDs = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    classFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_classes_' doFiles{iFile,2} '.mat']);
    classes = load(classFile);
    
    tuningFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_tuning_' doFiles{iFile,2} '.mat']);
    tuning = load(tuningFile);
    
    c = classes.(tuningMethod).(tuningPeriod).(useArray);
    cellClasses{iFile} = c.classes(all(c.istuned,2),1);
    
    tunedCells = c.tuned_cells;
    
    t=tuning.(tuningMethod).(tuningPeriod).(useArray).tuning;
    
    sg_bl = t(classifierBlocks(1)).sg;
    sg_ad = t(classifierBlocks(2)).sg;
    sg_wo = t(classifierBlocks(3)).sg;
    
    [~,idx_bl] = intersect(sg_bl, tunedCells,'rows');
    [~,idx_ad] = intersect(sg_ad, tunedCells,'rows');
    [~,idx_wo] = intersect(sg_wo, tunedCells,'rows');
    
    pds_bl = t(classifierBlocks(1)).pds(idx_bl,:);
    pds_ad = t(classifierBlocks(2)).pds(idx_ad,:);
    pds_wo = t(classifierBlocks(3)).pds(idx_wo,:);
    
    cellPDs{iFile} = {pds_bl, pds_ad, pds_wo};
end

end

%% Make the plots
function [counts1,counts2] = getCounts(doFiles,cellClasses,doType,numClasses)

switch lower(doType)
    case 'task'
        % break down by file type
        counts1 = zeros(sum(strcmpi(doFiles(:,4),'co')),numClasses);
        counts2 = zeros(sum(strcmpi(doFiles(:,4),'rt')),numClasses);
        for j = 1:numClasses % loop along the classes
            counts1(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,4),'co'),:));
            counts2(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,4),'rt'),:));
        end
        
    case 'perturbation'
        % break down by perturbation
        counts1 = zeros(sum(strcmpi(doFiles(:,3),'ff')),numClasses);
        counts2 = zeros(sum(strcmpi(doFiles(:,3),'vr')),numClasses);
        for j = 1:numClasses % loop along the classes
            counts1(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,4),'ff'),:));
            counts2(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,4),'vr'),:));
        end
        
    case 'none'
        % just give all percentages
        counts1 = zeros(size(doFiles),numClasses);
        for j = 1:numClasses % loop along the classes
            counts1(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses);
        end
end

end

function cellClasses = assignOthers(cellClasses,cellPDs)
% compute an index for "other" type cells to assign them to memory cells or
% adapting cells

for iFile = 1:length(cellClasses)
    pds = cellPDs{iFile};
    c = cellClasses{iFile};
    
    pds_bl = pds{1};
    pds_ad = pds{2};
    pds_wo = pds{3};
    
    % find "other" type cells
    idx = find(c==5);
    
    for i = 1:length(idx)
        % calculate the memory cell index
        mem_ind = angleDiff( pds_wo(idx(i),1),pds_bl(idx(i),1),true,false ) / min( angleDiff( pds_bl(idx(i),1), pds_ad(idx(i),1),true,false ) , angleDiff(pds_wo(idx(i),1),pds_ad(idx(i),1),true,false) );
        if mem_ind < 1
            c(idx(i)) = 2;
        elseif mem_ind > 1
            c(idx(i)) = 3;
        else
            disp('Hey! This one is exactly one.');
        end
    end
    
    cellClasses{iFile} = c;
end

end


