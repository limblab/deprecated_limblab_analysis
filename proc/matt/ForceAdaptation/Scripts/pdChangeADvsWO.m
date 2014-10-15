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


useArray = 'PMd';
classifierBlocks = [1 4 7];

switch lower(useArray)
    case 'm1'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'Chewie'),:);
    case 'pmd'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'MrT'),:);
end

dateInds = strcmpi(allFiles(:,3),'FF'); % & strcmpi(allFiles(:,4),'CO');
doFiles = allFiles(dateInds,:);

paramSetName = 'target';
tuningMethod = 'regression';
tuningPeriod = 'pre';

doMD = false;
reassignOthers = true;

if ~doMD
    ymin = -180;
    ymax = 180;
    binSize = 10;
    y_lab = 'PD Change (Deg) ';
else
    ymin = -30;
    ymax = 30;
    binSize = 2;
    y_lab = 'MD Change (Hz) ';
end


%% Get the classification for each day for tuned cells
cellClasses = cell(size(doFiles,1),1);
cellPDs = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    classFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_classes_' doFiles{iFile,2} '.mat']);
    classes = load(classFile);
    
    tuningFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_tuning_' doFiles{iFile,2} '.mat']);
    tuning = load(tuningFile);
    
    c = classes.(tuningMethod).(tuningPeriod).(useArray);
    % first column is PD, second column is MD
    cellClasses{iFile} = c.classes(all(c.istuned,2),1);
    
    tunedCells = c.tuned_cells;
    
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
    
    r2_bl = mean(t(classifierBlocks(1)).r_squared,2);
    r2_ad = mean(t(classifierBlocks(2)).r_squared,2);
    r2_wo = mean(t(classifierBlocks(3)).r_squared,2);
    
    cellPDs{iFile} = {pds_bl, pds_ad, pds_wo};
    cellR2{iFile} = {r2_bl(idx_bl), r2_ad(idx_ad), r2_wo(idx_wo)};
end

%%
% find all dPDs
dpd_ad = [];
dpd_wo = [];
classes = [];
r2s = [];
for iFile = 1:size(doFiles,1)
    pds = cellPDs{iFile};
    if ~doMD
        dpd_ad = [dpd_ad; angleDiff(pds{1},pds{2},true,true).*(180/pi)];
        dpd_wo = [dpd_wo; angleDiff(pds{1},pds{3},true,true).*(180/pi)];
    else
        dpd_ad = [dpd_ad; pds{2}-pds{1}];
        dpd_wo = [dpd_wo; pds{3}-pds{1}];
    end
    
    c = cellClasses{iFile};
    
    if reassignOthers
        pds_wo = pds{3};
        pds_ad = pds{2};
        pds_bl = pds{1};
        idx = find(c==5);
        
        for i = 1:length(idx)
            % calculate the memory cell index
            bl_wo = angleDiff( pds_wo(idx(i),1),pds_bl(idx(i),1),true,true );
            bl_ad = angleDiff( pds_ad(idx(i),1), pds_bl(idx(i),1),true,true );
            ad_wo = angleDiff(pds_wo(idx(i),1),pds_ad(idx(i),1),true,true);
            
            mem_ind = abs(bl_wo) / min( abs(bl_ad) , abs(ad_wo) );
            
            % we also want both BL->WO and BL->AD to be same direction for memory
            %   otherwise it's just dynamic
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
    end
    
    classes = [classes; c];
    
    r2 = cellR2{iFile};
    r2s = [r2s; r2{1}];
end

%%
% see if class correlates with R2
plot(r2s,classes,'o');

%%

classColors = {'k','b','r','m','g'};
classNames = {'Kinematic','Dynamic','Memory I','Memory II','Other'};

if reassignOthers
    classColors = classColors(1:end-1);
    classNames = classNames(1:end-1);
end
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
bins = ymin:binSize:ymax;
subplot1(1);
hist(dpd_ad,bins);

h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k','facealpha',1,'edgealpha',1);

set(gca,'YTick',[],'XTick',[],'XLim',[ymin,ymax]);
hold all;
V = axis(gca);

m = mean(dpd_ad);
plot([m m],V(3:4),'k','LineWidth',2);

box off;

% add mean to histogram

% now plot BL->WO histogram
subplot1(4);
hist(dpd_wo,bins);

h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k','facealpha',1,'edgealpha',1);

hold all;
V = axis(gca);
m = mean(dpd_wo);
plot([m m],V(3:4),'k','LineWidth',2);

set(gca,'XTick',[],'YTick',[],'XLim',[ymin,ymax]);
set(gca,'CameraUpVector',[-1,0,0]);
set(gca, 'Xdir', 'reverse')

box off;

% plot scatter of PD changes
subplot1(3);
hold all;
for i = 1:length(dpd_ad)
    plot(dpd_ad(i),dpd_wo(i),'d','LineWidth',2,'Color',classColors{classes(i)});
end

set(gca,'XLim',[ymin,ymax],'YLim',[ymin,ymax],'FontSize',14,'TickDir','out')

V = axis(gca);
plot([V(1) V(2)],[0 0],'k--');
plot([0 0],[V(3) V(4)],'k--');
plot([V(1) V(2)],[V(3) V(4)],'k-');

plot([mean(dpd_ad) mean(dpd_ad)],V(3:4),'k','LineWidth',2);
plot(V(1:2),[mean(dpd_wo) mean(dpd_wo)],'k','LineWidth',2);
xlabel([y_lab 'BL->AD'],'FontSize',14);
ylabel([y_lab 'BL->WO'],'FontSize',14);

box off;




