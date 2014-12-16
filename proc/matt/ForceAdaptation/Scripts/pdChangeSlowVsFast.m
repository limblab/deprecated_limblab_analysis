clear
clc
close all;

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
classifierBlocks = [1 2 3];

switch lower(useArray)
    case 'm1'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'Chewie'),:);
    case 'pmd'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'MrT'),:);
end

doFiles = allFiles(strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'RT'),:);

tuningMethod = 'regression';
tuningPeriod = 'onpeak';

doMD = false;

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
paramSetName = 'speed_slow';

cellClasses = cell(size(doFiles,1),1);
cellPDs = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    classFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_classes_' doFiles{iFile,2} '.mat']);
    classes = load(classFile);
    
    tuningFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_tuning_' doFiles{iFile,2} '.mat']);
    tuning = load(tuningFile);
    
    c = classes.(tuningMethod).(tuningPeriod).(useArray);
    
    tunedCells = c.tuned_cells;
    
    % Only consider cells with significant changes
    changedCells = c.sg(c.classes(:,1)==1 | c.classes(:,1)==2 | c.classes(:,1)==3 | c.classes(:,1)==4,:);
    [~,idx] = intersect(changedCells, tunedCells,'rows');
    tunedCells = changedCells(idx,:);
    
    t=tuning.(tuningMethod).(tuningPeriod).(useArray).tuning;
    
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
paramSetName = 'speed_fast';

cellClasses = cell(size(doFiles,1),1);
cellPDs = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    classFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_classes_' doFiles{iFile,2} '.mat']);
    classes = load(classFile);
    
    tuningFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_tuning_' doFiles{iFile,2} '.mat']);
    tuning = load(tuningFile);
    
    c = classes.(tuningMethod).(tuningPeriod).(useArray);
    
    tunedCells = c.tuned_cells;
    
    % Only consider cells with significant changes
    changedCells = c.sg(c.classes(:,1)==1 | c.classes(:,1)==2 | c.classes(:,1)==3 | c.classes(:,1)==4,:);
    [~,idx] = intersect(changedCells, tunedCells,'rows');
    tunedCells = changedCells(idx,:);
    
    t=tuning.(tuningMethod).(tuningPeriod).(useArray).tuning;
    
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

