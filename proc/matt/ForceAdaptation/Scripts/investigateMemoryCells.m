% plot charts and graphs summarizing classifications

reassignOthers = true;
doMD = false;
plotTCExamples = false;

numClasses = 5;
ymin = 0;
ymax = 100;
classLabels = {'Kin','Dyn','Mem I','Mem II','Other'};

groupLabels = {'Slow Movements','Fast Movements'};

% Do movement tuning
paramSetName = 'movement';

% doFiles = strcmpi(allFiles(:,4),'RT'),:);

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

% doFiles = strcmpi(allFiles(:,4),'CO'),:);

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

