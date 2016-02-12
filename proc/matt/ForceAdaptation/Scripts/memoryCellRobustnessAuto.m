clear
clc
close all;

% load each file and get cell classifications
root_dir = 'F:\';
useArray = 'M1';
pert = 'FF';
monkeys = {'Chewie','Mihili'};

dataSummary;

switch lower(useArray)
    case 'm1'
        allFiles = sessionList(strcmpi(sessionList(:,1),'Mihili') | strcmpi(sessionList(:,1),'Chewie'),:);
    case 'pmd'
        allFiles = sessionList(strcmpi(sessionList(:,1),'Mihili') | strcmpi(sessionList(:,1),'MrT'),:);
end

paramSetName = 'movement';
tuneWindow = 'onpeak';
tuneMethod = 'regression';

doFiles = allFiles(strcmpi(allFiles(:,3),pert),:);

for i = 1:3
    classifierBlocks = [1,(i-1)+2,6+(i-2)];
    processFFData_ClassOnly;
    
    getData = [];
    for iFile = 1:size(doFiles,1)
        [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
        
        tunedCells = c.tuned_cells;
        c =  c.classes(all(c.istuned,2));
        
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
c1 = allData{3}; % final third
c2 = allData{2}; % middle third
c3 = allData{1}; % first third

% Now, for each cell in 1, see what class it has in 2
totalCount1 = zeros(1,5);
for i = 1:5
    totalCount1(i) = sum(c1(:,4)==i);
end

getpds = [];
sameCount = zeros(1,5);
diffCount = zeros(1,5);
noCount = zeros(1,5);
yesCount = zeros(1,5);
sameCount2 = zeros(1,5);
diffCount2 = zeros(1,5);
noCount2 = zeros(1,5);
yesCount2 = zeros(1,5);
for i = 1:size(c1,1)
    iFile = c1(i,1);
    sg = c1(i,2:3);
    c = c1(i,4);
    
    [~,idx] = intersect(c2(:,1:3), [iFile, sg],'rows');
    if ~isempty(idx)
        if c2(idx,4)==c
            %             if (c==2 || c==5) && (c2(idx,4)==2 || c2(idx,4)==5)
            sameCount(c) = sameCount(c)+1;
            %             if c==2
            %             getpds = [getpds; angleDiff(c1(i,5),c1(i,7),true,true), angleDiff(c2(idx,5),c2(idx,7),true,true)];
            %             end
        else
            diffCount(c) = diffCount(c)+1;
            if c==2
                getpds = [getpds; angleDiff(c1(i,5),c1(i,7),true,true), angleDiff(c2(idx,5),c2(idx,7),true,true)];
            end
        end
        yesCount(c) = yesCount(c)+1;
    else
        noCount(c) = noCount(c)+1;
    end
    
    % now do first block
    [~,idx] = intersect(c3(:,1:3), [iFile, sg],'rows');
    if ~isempty(idx)
        if c3(idx,4)==c
            %             sameCount2(c) = sameCount2(c)+1;
        else
            %             diffCount2(c) = diffCount2(c)+1;
        end
        yesCount2(c) = yesCount2(c)+1;
    else
        noCount2(c) = noCount2(c)+1;
    end
end

%%
figure;
% bar([100*(sameCount'./yesCount'),100*(sameCount2'./yesCount2')]);
bar(100*(sameCount'./(yesCount)'));
set(gca,'YLim',[0,100],'XTickLabel',{'Kin','Dyn','Mem I','Mem II','Other'},'TickDir','out','FontSize',14);
box off;
ylabel('Percent Same','FontSize',14);

% figure;
% bins = 0:3:180;
% hold all;
% hist(getpds(:,1).*(180/pi),bins);
% set(gca,'TickDir','out','FontSize',14,'XLim',[0 180],'YLim',[0 6]);
% box off;


% now compare proportions in each group
totalCount2 = zeros(1,5);
for i = 1:5
    totalCount2(i) = sum(c2(:,4)==i);
end
totalCount3 = zeros(1,5);
for i = 1:5
    totalCount3(i) = sum(c3(:,4)==i);
end

figure;
bar([100*totalCount1'./sum(totalCount1),100*totalCount2'./sum(totalCount2),100*totalCount3'./sum(totalCount3)]);
set(gca,'YLim',[0,100],'XTickLabel',{'Kin','Dyn','Mem I','Mem II','Other'},'TickDir','out','FontSize',14);
box off;
ylabel('Percent With Classification','FontSize',14);
legend({'Final Third','Middle Third','First Third'},'FontSize',14);

