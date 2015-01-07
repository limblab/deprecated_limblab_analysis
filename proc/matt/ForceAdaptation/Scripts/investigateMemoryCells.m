function investigateMemoryCells()
close all;
clc;

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';

allFiles = {'MrT','2013-08-19','FF','CO'; ...   % S x
            'MrT','2013-08-20','FF','RT'; ...   % S x
            'MrT','2013-08-21','FF','CO'; ...   % S x - AD is split in two so use second but don't exclude trials
            'MrT','2013-08-22','FF','RT'; ...   % S x
            'MrT','2013-08-23','FF','CO'; ...   % S x
            'MrT','2013-08-30','FF','RT'; ...   % S x
            'MrT','2013-09-03','VR','CO'; ...   % S x
            'MrT','2013-09-04','VR','RT'; ...   % S x
            'MrT','2013-09-05','VR','CO'; ...   % S x
            'MrT','2013-09-06','VR','RT'; ...   % S x
            'MrT','2013-09-09','VR','CO'; ...   % S x
            'MrT','2013-09-10','VR','RT'; ...   % S x
            'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    %'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    %'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
    'Mihili','2014-03-03','VR','CO'; ...    %12 S(M-P)
    'Mihili','2014-03-04','VR','CO'; ...    %13 S(M-P)
    'Mihili','2014-03-06','VR','CO'; ...    %14 S(M-P)
    'Mihili','2014-03-07','FF','CO'; ...   % 15
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
classifierBlocks = [1 4 7];

switch lower(useArray)
    case 'm1'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'Chewie'),:);
    case 'pmd'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'MrT'),:);
end

reassignOthers = true;
doMD = false;
plotTCExamples = false;

numClasses = 5;
ymin = 0;
ymax = 100;
classLabels = {'Kin','Dyn','Mem I','Mem II','Other'};

groupLabels = {'Slow Movements','Fast Movements'};

% Do movement tuning
dateInds = strcmpi(allFiles(:,3),'FF'); % & strcmpi(allFiles(:,4),'CO');
doFiles = allFiles(dateInds,:);
paramSetName = 'movement';
tuneMethod = 'regression';
tuneWindow = 'onpeak';

% Get the classification and PDs for each day for tuned cells
[cellClasses,cellPDs,cellMDs,cellBOs] = getClassesAndPDs(root_dir,doFiles,paramSetName,useArray,classifierBlocks,tuneMethod,tuneWindow,doMD);

if reassignOthers
    cellClasses = assignOthers(cellClasses,cellPDs);
    classLabels = classLabels(1:end-1);
    numClasses = numClasses-1;
end

if plotTCExamples
    theta = 0:.1:2*pi;
    colors = {'b','r','g'};
    
    tot = 5;
    figure;
    count = 0;
    for iDay = 1:length(cellClasses)
        c = cellClasses{iDay};
        pds = cellPDs{iDay};
        mds = cellMDs{iDay};
        bos = cellBOs{iDay};
        % plot 3-epoch tuning curves for memory cells
        idx = find(c == 3);
        %         if ~isempty(idx)
        %             idx = idx(randi(round(length(idx)),1,1));
        %         end
        
        for i = 1:length(idx)
            count = count + 1;
            subplot(1,tot,count);
            hold all;
            for j = 1:length(pds)
                pd = pds{j};
                md = mds{j};
                bo = bos{j};
                
                plot(theta.*(180/pi)-180,bo(idx(i))+md(idx(i),1)*cos(theta - pd(idx(i),1)),'Color',colors{j});
                set(gca,'YLim',[-8,142],'XLim',[-180,180],'TickDir','out','FontSize',14);
                box off;
            end
        end
    end
    
    count
    
end


% Get the counts for plotting
counts1 = getCounts(doFiles,cellClasses,'none',numClasses);

doFiles = allFiles(strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO'),:);
% paramSetName = 'target';
% tuningMethod = 'regression';
% tuningPeriod = 'full';

[cellClasses,cellPDs] = getClassesAndPDs(root_dir,doFiles,paramSetName,useArray,classifierBlocks,tuneMethod,tuneWindow,doMD);
if reassignOthers
    cellClasses = assignOthers(cellClasses,cellPDs);
end
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
data = nanmean(counts1,1);


for i = 1:length(classLabels)
    classLabels{i} = [classLabels{i} ' ' num2str(data(i))];
end
disp(' NOTE THIS PIE IS AVERAGE ACROSS SESSIONS ');
% I did this code in plotMDvsFRWithClasses to get the right pie chart
% counts(1) = sum(classes==1); counts(2) = 0; counts(3) = sum(classes==3); counts(4) = sum(classes==4); counts(2) = length(classes)-sum(counts);
% labels = {'Kinematic','Dynamic','Memory I','Memory II'};
% pie(counts,labels)
pie(data,classLabels)
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
function [cellClasses,cellPDs,cellMDs,cellBOs] = getClassesAndPDs(root_dir,doFiles,paramSetName,useArray,classifierBlocks,tuningMethod,tuningWindow,doMD)

cellClasses = cell(size(doFiles,1),1);
cellPDs = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    % load tuning and classification data
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuningMethod,tuningWindow);

    cellClasses{iFile} = c.classes(all(c.istuned,2),1);
    
    tunedCells = c.tuned_cells;

    disp([length(t(1).theta),length(t(2).theta),length(t(3).theta)])
    
    sg_bl = t(classifierBlocks(1)).sg;
    sg_ad = t(classifierBlocks(2)).sg;
    sg_wo = t(classifierBlocks(3)).sg;
    
    [~,idx_bl] = intersect(sg_bl, tunedCells,'rows');
    [~,idx_ad] = intersect(sg_ad, tunedCells,'rows');
    [~,idx_wo] = intersect(sg_wo, tunedCells,'rows');
    
    if ~doMD
        pds_bl = t(classifierBlocks(1)).pds(idx_bl,:);
        pds_ad = t(classifierBlocks(2)).pds(idx_ad,:);
        pds_wo = t(classifierBlocks(3)).pds(idx_wo,:);
        mds_bl = t(classifierBlocks(1)).mds(idx_bl,:);
        mds_ad = t(classifierBlocks(2)).mds(idx_ad,:);
        mds_wo = t(classifierBlocks(3)).mds(idx_wo,:);
        bos_bl = mean(t(classifierBlocks(1)).fr(:,idx_bl),1);
        bos_ad = mean(t(classifierBlocks(2)).fr(:,idx_ad),1);
        bos_wo = mean(t(classifierBlocks(3)).fr(:,idx_wo),1);
    else
        pds_bl = t(classifierBlocks(1)).mds(idx_bl,:);
        pds_ad = t(classifierBlocks(2)).mds(idx_ad,:);
        pds_wo = t(classifierBlocks(3)).mds(idx_wo,:);
    end
    
    cellPDs{iFile} = {pds_bl, pds_ad, pds_wo};
    cellMDs{iFile} = {mds_bl, mds_ad, mds_wo};
    cellBOs{iFile} = {bos_bl, bos_ad, bos_wo};
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
            % counts1(:,j) = cellfun(@(x) sum(x==j),cellClasses);
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
        
        bl_wo = angleDiff( pds_bl(idx(i),1),pds_wo(idx(i),1),true,true );
        bl_ad = angleDiff( pds_bl(idx(i),1), pds_ad(idx(i),1),true,true );
        ad_wo = angleDiff(pds_ad(idx(i),1),pds_wo(idx(i),1),true,true);
        
        mem_ind = abs(bl_wo) / min( abs(bl_ad) , abs(ad_wo) );
        
        if mem_ind > 1
            if sign(bl_wo)==sign(bl_ad)
                c(idx(i)) = 3;
            else
                c(idx(i)) = 2;
            end
        elseif mem_ind < 1
            c(idx(i)) = 2;
        else
            disp('Hey! This one is exactly one.');
            c(idx(i)) = 3;
        end
    end
    
    cellClasses{iFile} = c;
end

end


