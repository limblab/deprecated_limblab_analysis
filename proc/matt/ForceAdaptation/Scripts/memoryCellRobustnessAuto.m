clear
clc
close all;

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';
% root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\m1_cf_paper_results\';

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
paramSetNames = {'movement'};
paramSetName = 'movement';
tuningPeriod = 'onpeak';
tuningMethod = 'regression';

doFiles = allFiles(strcmpi(allFiles(:,3),'FF'),:);

for i = 1:2
    classifierBlocks = [1,i+2,6+(i-1)];
    processFFData2;
    
    getData = [];
    for iFile = 1:size(doFiles,1)
        classFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_classes_' doFiles{iFile,2} '.mat']);
        classes = load(classFile);
        
        classes = classes.(tuningMethod).(tuningPeriod).(useArray);
        c =  classes.classes(all(classes.istuned,2));
        
        tuningFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_tuning_' doFiles{iFile,2} '.mat']);
        tuning = load(tuningFile);
        
        tunedCells = classes.tuned_cells;
        
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
        
        
        allC(iFile).pds{i} = {pds_bl, pds_ad, pds_wo};
        
        % build array for each cell
        for j = 1:size(pds_bl,1)
            getData = [getData; iFile, sg_bl(j,1), sg_bl(j,2), c(j),pds_bl(j),pds_ad(j),pds_wo(j)];
        end
    end
    allData{i} = getData;
end

%%
c1 = allData{2}; % final third
c2 = allData{1}; % middle third

% Now, for each cell in 1, see what class it has in 2
totalCount1 = zeros(1,5);
for i = 1:5
    totalCount1(i) = sum(c1(:,4)==i);
end

getpds = [];
sameCount = zeros(1,5);
diffCount = zeros(1,5);
noCount = zeros(1,5);
for i = 1:size(c1,1)
    iFile = c1(i,1);
    sg = c1(i,2:3);
    c = c1(i,4);
    
    [~,idx] = intersect(c2(:,1:3), [iFile, sg],'rows');
    if ~isempty(idx)
        if c2(idx,4)==c
%         if (c==2 || c==3 || c==5) && (c2(idx,4)==2 || c2(idx,4)==3 || c2(idx,4)==5)
            sameCount(c) = sameCount(c)+1;
            if c==2 
%             getpds = [getpds; angleDiff(c1(i,5),c1(i,7),true,true), angleDiff(c2(idx,5),c2(idx,7),true,true)];
            end
        else
            diffCount(c) = diffCount(c)+1;
            if c==2
               getpds = [getpds; angleDiff(c1(i,5),c1(i,7),true,true), angleDiff(c2(idx,5),c2(idx,7),true,true)];
            end
        end
    else
        noCount(c) = noCount(c)+1;
    end
end

%%
figure;
bar(100*(sameCount./(totalCount1-noCount)));
set(gca,'YLim',[0,100],'XTickLabel',{'Kin','Dyn','Mem I','Mem II','Other'},'TickDir','out','FontSize',14);
box off;
ylabel('Percent Same','FontSize',14);

figure;
bins = 0:3:180;
hold all;
hist(getpds(:,1).*(180/pi),bins);
set(gca,'TickDir','out','FontSize',14,'XLim',[0 180],'YLim',[0 6]);
box off;


% now compare proportions in each group
totalCount2 = zeros(1,5);
for i = 1:5
    totalCount2(i) = sum(c2(:,4)==i);
end

figure;
bar([100*totalCount1'./sum(totalCount1),100*totalCount2'./sum(totalCount2)]);
set(gca,'YLim',[0,100],'XTickLabel',{'Kin','Dyn','Mem I','Mem II','Other'},'TickDir','out','FontSize',14);
box off;
ylabel('Percent With Classification','FontSize',14);
legend({'Middle Third','Final Third'},'FontSize',14);

