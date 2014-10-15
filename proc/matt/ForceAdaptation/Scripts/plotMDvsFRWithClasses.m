clear
clc
close all;

% Script to plot modulation depth of each neuron against the firing rate
% and then color by class to see if memory cells are weakly modulated
% and/or low firing

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

dateInds = strcmpi(allFiles(:,3),'FF');
doFiles = allFiles(dateInds,:);

reassignOthers = true;

paramSetName = 'movement';
tuningMethod = 'regression';
tuningPeriod = 'onpeak';

nbins = 20;
xmin = 0;
xmax = 150;
x_lab = 'Firing Rate (Hz) ';

ymin = 0;
ymax = 100;
y_lab = 'Modulation Depth (Hz) ';

%% Get the classification for each day for tuned cells
cellClasses = cell(size(doFiles,1),1);
cellPDs = cell(size(doFiles,1),1);
cellFRs = cell(size(doFiles,1),1);
cellMDs = cell(size(doFiles,1),1);

cellIDs = [];
for iFile = 1:size(doFiles,1)
    classFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_classes_' doFiles{iFile,2} '.mat']);
    classes = load(classFile);
    
    tuningFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_tuning_' doFiles{iFile,2} '.mat']);
    tuning = load(tuningFile);
    
    c = classes.(tuningMethod).(tuningPeriod).(useArray);
    cellClasses{iFile} = c.classes(all(c.istuned,2),1);
    
    idx = find(cellClasses{iFile}==4);
    for i = 1:length(idx)
        cellIDs = [cellIDs; iFile,c.sg(idx(i),:)];
    end
    
    tunedCells = c.tuned_cells;
    
    t=tuning.(tuningMethod).(tuningPeriod).(useArray).tuning;
    
    sg_bl = t(classifierBlocks(1)).sg;
    sg_ad = t(classifierBlocks(2)).sg;
    sg_wo = t(classifierBlocks(3)).sg;
    
    [~,idx_bl] = intersect(sg_bl, tunedCells,'rows');
    [~,idx_ad] = intersect(sg_ad, tunedCells,'rows');
    [~,idx_wo] = intersect(sg_wo, tunedCells,'rows');
    
    pds_bl = t(classifierBlocks(1)).pds(idx_bl,1);
    pds_ad = t(classifierBlocks(2)).pds(idx_ad,1);
    pds_wo = t(classifierBlocks(3)).pds(idx_wo,1);
    
    
    cellPDs{iFile} = {pds_bl, pds_ad, pds_wo};
    
    mds_bl = t(classifierBlocks(1)).mds(idx_bl,1);
    mds_ad = t(classifierBlocks(2)).mds(idx_ad,1);
    mds_wo = t(classifierBlocks(3)).mds(idx_wo,1);
    
    cellMDs{iFile} = {mds_bl, mds_ad, mds_wo};
    
    fr_bl = mean(t(classifierBlocks(1)).fr(:,idx_bl),1)';
    fr_ad = mean(t(classifierBlocks(2)).fr(:,idx_ad),1)';
    fr_wo = mean(t(classifierBlocks(3)).fr(:,idx_wo),1)';
    
    cellFRs{iFile} = {fr_bl, fr_ad, fr_wo};
    
end

%%
% find all dPDs
md_bl = [];
fr_bl = [];
classes = [];
for iFile = 1:size(doFiles,1)
    pds = cellPDs{iFile};
    mds = cellMDs{iFile};
    frs = cellFRs{iFile};

%     md_bl = [md_bl; mds{3}-mds{1}];
%     fr_bl = [fr_bl; frs{3}-frs{1}];
    md_bl = [md_bl; mds{3}];
    fr_bl = [fr_bl; frs{3}];
    
    c = cellClasses{iFile};
    if reassignOthers
        idx = find(c==5);
        
        pds_bl = pds{1};
        pds_ad = pds{2};
        pds_wo = pds{3};
        
        for i = 1:length(idx)
            % calculate the memory cell index
            bl_wo = angleDiff( pds_wo(idx(i),1),pds_bl(idx(i),1),true,true );
            bl_ad = angleDiff( pds_ad(idx(i),1), pds_bl(idx(i),1),true,true );
            ad_wo = angleDiff(pds_wo(idx(i),1),pds_ad(idx(i),1),true,true);
            
            mem_ind = abs(bl_wo) / min( abs(bl_ad) , abs(ad_wo) );
            if mem_ind > 1
                if sign(bl_wo)==sign(bl_ad)
                    c(idx(i)) = 3;
                else
                    c(idx(i)) = 2;
                end
            elseif mem_ind > 1
                c(idx(i)) = 3;
            else
                disp('Hey! This one is exactly one.');
                c(idx(i)) = 2;
            end
        end
    end

    classes = [classes; c];
end

%%

classColors = {'k','b','r','m','g'};
classNames = {'Kinematic','Dynamic','Memory I','Memory II','Other'};

figure('Position',[300 50 950 950]);
subplot1(2,2,'Gap',[0 0],'Min',[0.08 0.08],'Max',[0.98 0.98]);

% make a legend here
subplot1(2);

set(gca,'XTick',[],'YTick',[],'XLim',[-0.1 4],'YLim',[-0.1 length(classColors)+1]);
V = axis(gca);
patch([V(1) V(2) V(2) V(1)],[V(3) V(3) V(4) V(4)],[0.8 0.8 0.8]);

for i=1:length(classColors)
    plot(1,i,'d','Color',classColors{i},'LineWidth',2);
    text(2,i,classNames{i},'FontSize',14);
end

box off;

% plot histogram of changes BL->AD
bins = xmin:floor((xmax-xmin)/nbins):xmax;
subplot1(1);
hist(fr_bl,bins);

h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k','facealpha',1,'edgealpha',1);

set(gca,'YTick',[],'XTick',[],'XLim',[xmin,xmax]);
hold all;
V = axis(gca);

m = mean(fr_bl);
plot([m m],V(3:4),'k','LineWidth',2);

box off;

% add mean to histogram

% now plot BL->WO histogram
subplot1(4);
bins = ymin:floor((ymax-ymin)/nbins):ymax;
hist(md_bl,bins);

h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k','facealpha',1,'edgealpha',1);

hold all;
V = axis(gca);
m = mean(md_bl);
plot([m m],V(3:4),'k','LineWidth',2);

set(gca,'XTick',[],'YTick',[],'XLim',[ymin,ymax]);
set(gca,'CameraUpVector',[-1,0,0]);
set(gca, 'Xdir', 'reverse')

box off;

% plot scatter of PD changes
subplot1(3);
hold all;
for i = 1:length(fr_bl)
    plot(fr_bl(i),md_bl(i),'d','LineWidth',2,'Color',classColors{classes(i)});
end

set(gca,'XLim',[xmin,xmax],'YLim',[ymin,ymax],'FontSize',14,'TickDir','out')

V = axis(gca);
plot([V(1) V(2)],[0 0],'k--');
plot([0 0],[V(3) V(4)],'k--');

plot([mean(fr_bl) mean(fr_bl)],V(3:4),'k','LineWidth',2);
plot(V(1:2),[mean(md_bl) mean(md_bl)],'k','LineWidth',2);
xlabel(x_lab,'FontSize',14);
ylabel(y_lab,'FontSize',14);

box off;

sum(classes==3), sum(classes==4), length(classes)
% close all
sum(classes==1), sum(classes==2),
