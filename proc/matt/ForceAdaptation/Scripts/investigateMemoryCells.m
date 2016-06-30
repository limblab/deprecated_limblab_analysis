% plot charts and graphs summarizing classifications

reassignOthers = false;
doMD = false;
plotTCExamples = false;

ymin = 0;
ymax = 100;
classLabels = {'Kin','Dyn','Mem I','Mem II','Other'};

groupLabels = {'First Block','Second Block'};

% Do movement tuning
paramSetName = 'movement';

numClasses = length(classLabels);

useFiles = doFiles;
% useFiles = doFiles(strcmpi(doFiles(:,4),'CO'),:);

% Get the classification and PDs for each day for tuned cells
[cellClasses1,cellPDs1,cellMDs,cellBOs] = getClassesAndPDs(root_dir,useFiles,paramSetName,useArray,classifierBlocks,tuneMethod,tuneWindow);

if reassignOthers
    cellClasses1 = assignOthers(cellClasses1,cellPDs1);
    classLabels = classLabels(1:end-1);
    numClasses = numClasses-1;
end

% Just some plotting for examples. Can ignore.
if plotTCExamples
    theta = 0:.1:2*pi;
    colors = {'b','r','g'};
    tot = 5;
    figure;
    count = 0;
    for iDay = 1:length(cellClasses1)
        c = cellClasses1{iDay};
        pds = cellPDs3{iDay};
        mds = cellMDs{iDay};
        bos = cellBOs{iDay};
        % plot 3-epoch tuning curves for memory cells
        idx = find(c == 3);
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
counts1 = getCounts(useFiles,cellClasses1,'none',numClasses);


%%% Now get the second set
% useFiles = doFiles(strcmpi(doFiles(:,4),'RT'),:);

[cellClasses2,cellPDs2] = getClassesAndPDs(root_dir,useFiles,paramSetName,useArray,classifierBlocks,tuneMethod,tuneWindow);
if reassignOthers
    cellClasses2 = assignOthers(cellClasses2,cellPDs2);
end
counts2 = getCounts(useFiles,cellClasses2,'none',numClasses);

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


% % % % For plotting the three blocks with saved data
% % % load('M1_CF_classes_firstBlock.mat');
% % % c1 = counts1;
% % % 
% % % load('M1_CF_classes_middleBlock.mat');
% % % c2 = counts1;
% % % 
% % % load('M1_CF_classes_lastBlock.mat');
% % % c3 = counts1;
% % % 
% % % groupLabels = {'First Block','Second Block','Third Block'};
% % % classLabels = {'Kin','Dyn','MemI','MemII','Oth'};
% % % % Now plot things!
% % % figure;
% % % hold all;
% % % h = barwitherr([(nanstd(c1,1)/sqrt(size(c1,1)))' (nanstd(c2,1)/sqrt(size(c2,1)))' (nanstd(c3,1)/sqrt(size(c3,1)))'],[nanmean(c1,1)' nanmean(c2,1)' nanmean(c3,1)'],'BarWidth',1);
% % % set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
% % % ylabel('Percent','FontSize',14);
% % % legend(groupLabels,'FontSize',14);



