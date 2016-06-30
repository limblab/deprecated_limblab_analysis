% plot charts and graphs summarizing classifications
classifierBlocks = [1 4 7];

reassignOthers = true;

ymin = 0;
ymax = 100;
classLabels = {'Kin','Dyn','Mem I','Mem II','Other'};

groupLabels = {'Chewie','Mihili'};

% Do movement tuning
paramSetName = 'movement';

numClasses = length(classLabels);

useFiles = doFiles(strcmpi(doFiles(:,1),'Chewie'),:);

% Get the classification and PDs for each day for tuned cells
[cellClasses1,cellSGs1,cellPDs1] = getClassesAndPDs(root_dir,useFiles,paramSetName,useArray,classifierBlocks,tuneMethod,tuneWindow);

if reassignOthers
    cellClasses1 = assignOthers(cellClasses1,cellPDs1);
    classLabels = classLabels(1:end-1);
    numClasses = numClasses-1;
end

% Get the counts for plotting
counts1 = getCounts(useFiles,cellClasses1,'none',numClasses);

%%% Now get the second set
useFiles = doFiles(strcmpi(doFiles(:,1),'Mihili'),:);
[cellClasses2,cellSGs2,cellPDs2] = getClassesAndPDs(root_dir,useFiles,paramSetName,useArray,classifierBlocks,tuneMethod,tuneWindow);
if reassignOthers
    cellClasses2 = assignOthers(cellClasses2,cellPDs2);
end
counts2 = getCounts(useFiles,cellClasses2,'none',numClasses);

% Now plot things!
figure;
hold all;
m1 = nanmean(counts1,1)';
m2 = nanmean(counts2,1)';
s1 = (nanstd(counts1,1)/sqrt(size(counts1,1)))';
s2 = (nanstd(counts2,1)/sqrt(size(counts2,1)))';
h = barwitherr_2015b([s1 s2],[m1 m2],'BarWidth',1);
set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
ylabel('Percent','FontSize',14);
legend(groupLabels,'FontSize',14);


% now make a plot of both monkeys
useFiles = doFiles;
[cellClasses,cellSGs,cellPDs] = getClassesAndPDs(root_dir,useFiles,paramSetName,useArray,classifierBlocks,tuneMethod,tuneWindow);
if reassignOthers
    cellClasses = assignOthers(cellClasses,cellPDs);
end
counts = getCounts(useFiles,cellClasses,'none',numClasses);

% plot a pie for the first one
figure;
% subplot1(1,2);
% subplot1(1);
data = nanmean(counts,1);

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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For plotting the three blocks with saved data
load('M1_CF_classes_firstBlock.mat');
c1 = counts;
cc1 = cellClasses;
sg1 = cellPDs;

load('M1_CF_classes_middleBlock.mat');
c2 = counts;
cc2 = cellClasses;
sg2 = cellPDs;

load('M1_CF_classes_lastBlock.mat');
c3 = counts;
cc3 = cellClasses;
sg3 = cellPDs;

groupLabels = {'First Block','Second Block','Third Block'};
classLabels = {'Kin','Dyn','MemI','MemII','Oth'};
% Now plot things!
figure;
hold all;
h = barwitherr_2015b([(nanstd(c1,1)/sqrt(size(c1,1)))' (nanstd(c2,1)/sqrt(size(c2,1)))' (nanstd(c3,1)/sqrt(size(c3,1)))'],[nanmean(c1,1)' nanmean(c2,1)' nanmean(c3,1)'],'BarWidth',1);
set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
ylabel('Percent','FontSize',14);
legend(groupLabels,'FontSize',14);

% get classes in second and third for common cells
all_classes = [];
for i = 1:length(sg1)
    [~,idx2,idx3] = intersect(sg2{i},sg3{i},'rows');
    all_classes = [all_classes; cc2{i}(idx2) cc3{i}(idx3)];
end



