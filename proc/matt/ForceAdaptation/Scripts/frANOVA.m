% get firing rates for all trials in all epochs for all cells
metric = 'errors';

count = 0;
for iFile = 1:size(doFiles)
    a = loadResults(root_dir,doFiles(iFile,:),'adaptation');
    blErr{iFile} = a.BL.(metric).*(180/pi);
    adErr{iFile} = a.AD.(metric).*(180/pi);
    woErr{iFile} = a.WO.(metric).*(180/pi); % behavioral errors
    
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
    
    master_sg = c(1).sg;
    
    for unit = 1:size(master_sg,1)
        if all(c(1).istuned(unit,1:4))
            count = count + 1;
            
            % determine if this cell is tuned or not
            sg = t(1).sg;
            allTU(count) = all(c(1).istuned(unit,:));
            allMonk{count} = doFiles{iFile,1};
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            % Get the data
            getFR = []; % firing rate
            getTH = []; % theta
            getBL = []; % block number
            getNT = []; % trial number
            getPD = []; % preferred direction
            getMD = []; % modulation depth
            getBO = []; % baseline offset parameter
            numTrials = 0;
            blockFR = zeros(1,8);
            for iBlock = 1
                % find the current cell
                theta = t(iBlock).theta;
                utheta = unique(theta);
                
                % if -pi is one of the unique, make it pi
                if abs(utheta(1)) > utheta(end-1)
                    theta(theta==utheta(1)) = utheta(end);
                end
                
                sg = t(iBlock).sg;
                idx = sg(:,1)==master_sg(unit,1) & sg(:,2)==master_sg(unit,2);
                fr = t(iBlock).fr(:,idx);
                
                pd = t(iBlock).pds(idx,1);
                md = t(iBlock).mds(idx,1);
                bo = t(iBlock).bos(idx,1);
                
                % now get pre-movement activity
                %                 sg = t_pre(iBlock).sg;
                %                 idx = sg(:,1)==master_sg(unit,1) & sg(:,2)==master_sg(unit,2);
                %                 fr_pre = t_pre(iBlock).fr(:,idx);
                
                getFR = [getFR; fr];
                for iDir = 1:length(utheta)
                    idx = theta==utheta(iDir);
                    blockFR(iBlock,iDir) = mean(fr(idx));
                end
                %getFR = [getFR; fr];
                getTH = [getTH; theta];
                getBL = [getBL; iBlock*ones(size(fr))];
                getNT = [getNT; numTrials + (1:length(theta))'];
                numTrials = length(theta);
                
                % get tuning info for each cell
                getPD = [getPD, pd];
                getMD = [getMD, md];
                getBO = [getBO, bo];
            end
            
            blSG(count,:) = master_sg(unit,:);
            blFR{count} = getFR;
            blBlockFR{count} = blockFR;
            blTH{count} = getTH;
            blBL{count} = getBL;
            blNT{count} = getNT;
            blPD(count,:) = getPD.*(180/pi);
            blMD(count,:) = getMD;
            blBO(count,:) = getBO;
            
            %%%%%%%%%%%%%%%%%%%%%%%
            % Adaptation data
            getFR = []; % firing rate
            getTH = []; % theta
            getBL = []; % block number
            getNT = []; % trial number
            getPD = []; % preferred direction
            getMD = []; % modulation depth
            getBO = []; % baseline offset parameter
            
            numTrials = 0;
            blockFR = zeros(3,8);
            for iBlock = 2:4
                % find the current cell
                theta = t(iBlock).theta;
                utheta = unique(theta);
                
                % if -pi is one of the unique, make it pi
                if abs(utheta(1)) > utheta(end-1)
                    theta(theta==utheta(1)) = utheta(end);
                end
                
                sg = t(iBlock).sg;
                idx = sg(:,1)==master_sg(unit,1) & sg(:,2)==master_sg(unit,2);
                fr = t(iBlock).fr(:,idx);
                
                pd = t(iBlock).pds(idx,1);
                md = t(iBlock).mds(idx,1);
                bo = t(iBlock).bos(idx,1);
                
                % now get pre-movement activity
                %                 sg = t_pre(iBlock).sg;
                %                 idx = sg(:,1)==master_sg(unit,1) & sg(:,2)==master_sg(unit,2);
                %                 fr_pre = t_pre(iBlock).fr(:,idx);
                
                getFR = [getFR; fr];
                for iDir = 1:length(utheta)
                    idx = theta==utheta(iDir);
                    blockFR(iBlock-1,iDir) = mean(fr(idx));
                end
                %getFR = [getFR; fr];
                getTH = [getTH; theta];
                getBL = [getBL; iBlock*ones(size(fr))];
                
                getNT = [getNT; numTrials + (1:length(theta))'];
                numTrials = length(theta);
                
                % get tuning info for each cell
                getPD = [getPD, pd];
                getMD = [getMD, md];
                getBO = [getBO, bo];
            end
            
            % make sure cells meet certain criteria
            adSG(count,:) = master_sg(unit,:);
            adFR{count} = getFR;
            adBlockFR{count} = blockFR;
            adTH{count} = getTH;
            adBL{count} = getBL;
            adNT{count} = getNT;
            adPD(count,:) = getPD.*(180/pi);
            adMD(count,:) = getMD;
            adBO(count,:) = getBO;
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            % Washout data
            getFR = []; % firing rate
            getTH = []; % theta
            getBL = []; % block number
            getNT = []; % trial number
            getPD = []; % preferred direction
            getMD = []; % modulation depth
            getBO = []; % baseline offset parameter
            numTrials = 0;
            blockFR = zeros(3,8);
            for iBlock = 5:7
                % find the current cell
                theta = t(iBlock).theta;
                utheta = unique(theta);
                
                % if -pi is one of the unique, make it pi
                if abs(utheta(1)) > utheta(end-1)
                    theta(theta==utheta(1)) = utheta(end);
                end
                
                sg = t(iBlock).sg;
                idx = sg(:,1)==master_sg(unit,1) & sg(:,2)==master_sg(unit,2);
                fr = t(iBlock).fr(:,idx);
                
                pd = t(iBlock).pds(idx,1);
                md = t(iBlock).mds(idx,1);
                bo = t(iBlock).bos(idx,1);
                
                % now get pre-movement activity
                %                 sg = t_pre(iBlock).sg;
                %                 idx = sg(:,1)==master_sg(unit,1) & sg(:,2)==master_sg(unit,2);
                %                 fr_pre = t_pre(iBlock).fr(:,idx);
                
                getFR = [getFR; fr];
                for iDir = 1:length(utheta)
                    idx = theta==utheta(iDir);
                    blockFR(iBlock-4,iDir) = mean(fr(idx));
                end
                %getFR = [getFR; fr];
                getTH = [getTH; theta];
                getBL = [getBL; iBlock*ones(size(fr))];
                
                getNT = [getNT; numTrials + (1:length(theta))'];
                numTrials = length(theta);
                
                % get tuning info for each cell
                getPD = [getPD, pd];
                getMD = [getMD, md];
                getBO = [getBO, bo];
            end
            
            woSG(count,:) = master_sg(unit,:);
            woFR{count} = getFR;
            woBlockFR{count} = blockFR;
            woTH{count} = getTH;
            woBL{count} = getBL;
            woNT{count} = getNT;
            woPD(count,:) = getPD.*(180/pi);
            woMD(count,:) = getMD;
            woBO(count,:) = getBO;
        end
    end
end

p = ones(2,length(adFR));
p2 = ones(1,length(adFR));
for unit = 1:length(adFR)
    meanfr(unit) = mean(adFR{unit});
    p(:,unit) = anovan(adFR{unit},{adBL{unit},adTH{unit}},'display','off');
    p2(unit) = anovan(adFR{unit},{adBL{unit}},'display','off');
end

% p = ones(8,length(allFR));
% for unit = 1:length(allFR)
%     meanfr(unit) = mean(allFR{unit});
%
%     theta = allTH{unit};
%     utheta = unique(theta);
%     blocks = allBL{unit};
%     fr = allFR{unit};
%
%     for iTh = 1:length(utheta)
%         idx = theta == utheta(iTh);
%         p(iTh,unit) = anovan(fr(idx),{blocks(idx)},'display','off');
%     end
% end

p(isnan(p))=1;

disp(['Proportion of time-varying cells (p < 0.05): ' num2str(sum(p(1,:) < 0.05)/size(p,2))])
disp(['Proportion of direction-varying cells (p < 0.05): ' num2str(sum(p(2,:) < 0.05)/size(p,2))])

% find what proportion of significantly time-varying cells are cosine tuned
idx = p(1,:) < 0.05;
disp(['Proportion of time-varying cells that are cosine tuned: ' num2str(sum(allTU(idx))/sum(allTU)) ])

%% Plot change in firing rate relative to start (or baseline average?) over entire session
% clear cellFRDiff;
% % first, find the length of the shortest file and get baseline FR
% idx = find(p(1,:) <= 0.05);
% 
% blAv = zeros(1,length(idx));
% trialMins = zeros(length(idx),3);
% for i = 1:length(idx)
%     blfr = blFR{idx(i)};
%     adfr = adFR{idx(i)};
%     wofr = woFR{idx(i)};
%     
%     blAv(i) = nanmean(blfr);
%     trialMins(i,:) = [length(blfr), length(adfr), length(wofr)];
%     
% end
% numTrials = min(trialMins,[],1);
% 
% % now, find baseline averages for each neuron
% for i = 1:length(idx)
%     count = 0;
%     blfr = blFR{idx(i)};
%     adfr = adFR{idx(i)};
%     wofr = woFR{idx(i)};
%     
%     n = 10;
%     
%     % get baseline progression
%     trialBins = 1:n:numTrials(1);
%     for k = 1:length(trialBins)-1
%         count = count+1;
%         cellFRDiff(i,count) = abs(nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
%     end
%     epochMarkers(1) = count;
%     % get adaptation progression
%     trialBins = 1:n:numTrials(2);
%     for k = 1:length(trialBins)-1
%         count = count+1;
%         cellFRDiff(i,count) = abs(nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
%     end
%     epochMarkers(2) = count;
%     % get washout progression
%     trialBins = 1:n:numTrials(3);
%     for k = 1:length(trialBins)-1
%         count = count+1;
%         cellFRDiff(i,count) = abs(nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
%     end
%     epochMarkers(3) = count;
% end
% 
% figure;
% hold all;
% % Now plot
% plot(mean(cellFRDiff,1),'o','LineWidth',4,'Color','b');
% plot(mean(cellFRDiff,1),'--','LineWidth',1,'Color','b');
% plot(mean(cellFRDiff,1) + std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1)),'LineWidth',1,'Color','b');
% plot(mean(cellFRDiff,1) - std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1)),'LineWidth',1,'Color','b');
% 
% set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',1:n:size(cellFRDiff,2));
% xlabel('Bins of Trials','FontSize',14);
% ylabel('Mean FR Change','FontSize',14);
% 
% V = axis;
% % plot epoch divisions
% plot([0.5 0.5] + epochMarkers(1),V(3:4),'k--');
% plot([0.5 0.5] + epochMarkers(2),V(3:4),'k--');


%% Same as above but for different monkeys

% TO DO:
%   - Make trial bins the same as the behavior plot
%   - Do significance testing of FR changes

figure;
hold all;

n = 69;
ymin = 0;
ymax = 0.5;

pmax = 0.15;

% Chewie
clear cellFRDiff fileErr;
% first, find the length of the shortest file and get baseline FR
idx = find(p(1,:) < 2);
blAv = zeros(1,length(idx));
trialMins = zeros(length(idx),3);
for i = 1:length(idx)
    blfr = blFR{idx(i)};
    adfr = adFR{idx(i)};
    wofr = woFR{idx(i)};
    
    blAv(i) = nanmean(blfr);
    trialMins(i,:) = [length(blfr), length(adfr), length(wofr)];
    
end
numTrials = min(trialMins,[],1);

% now do the rest
idx = find(p(1,:) <= pmax & strcmpi(allMonk,'Chewie'));
blAv = zeros(1,length(idx));
for i = 1:length(idx)
    blfr = blFR{idx(i)};
    blAv(i) = nanmean(blfr);
end

% now, find baseline averages for each neuron
for i = 1:length(idx)
    count = 0;
    blfr = blFR{idx(i)};
    adfr = adFR{idx(i)};
    wofr = woFR{idx(i)};
    
    % get baseline progression
    trialBins = 1:n:numTrials(1);
    for k = 1:length(trialBins)-1
        count = count+1;
        cellFRDiff(i,count) = abs(nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
    end
    epochMarkers(1) = count;
    % get adaptation progression
    trialBins = 1:n:numTrials(2);
    for k = 1:length(trialBins)-1
        count = count+1;
        cellFRDiff(i,count) = abs(nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
    end
    epochMarkers(2) = count;
    % get washout progression
    trialBins = 1:n:numTrials(3);
    for k = 1:length(trialBins)-1
        count = count+1;
        cellFRDiff(i,count) = abs(nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
    end
    epochMarkers(3) = count;
end

chewieDiff = cellFRDiff;

% Now plot
plot(1:count,mean(cellFRDiff,1),'o','LineWidth',4,'Color','k');
plot([1:count;1:count], [mean(cellFRDiff,1) + std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1)); mean(cellFRDiff,1) - std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1))],'LineWidth',2,'Color','k');

% figure;
% hold all;
% plot(1:count,mean(fileErr,1),'o','LineWidth',4,'Color','k');
% plot([1:count;1:count], [mean(fileErr,1) + std(fileErr,0,1)./sqrt(size(fileErr,1)); mean(fileErr,1) - std(fileErr,0,1)./sqrt(size(fileErr,1))],'LineWidth',2,'Color','k');

% Mihili
clear cellFRDiff cellErr;
% first, find the length of the shortest file and get baseline FR
idx = find(p(1,:) <= pmax & strcmpi(allMonk,'Mihili'));

blAv = zeros(1,length(idx));
for i = 1:length(idx)
    blfr = blFR{idx(i)};
    blAv(i) = nanmean(blfr);
end

% now, find baseline averages for each neuron
for i = 1:length(idx)
    count = 0;
    blfr = blFR{idx(i)};
    adfr = adFR{idx(i)};
    wofr = woFR{idx(i)};
    
    % get baseline progression
    trialBins = 1:n:numTrials(1);
    for k = 1:length(trialBins)-1
        count = count+1;
        cellFRDiff(i,count) = abs(nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
    end
    epochMarkers(1) = count;
    % get adaptation progression
    trialBins = 1:n:numTrials(2);
    for k = 1:length(trialBins)-1
        count = count+1;
        cellFRDiff(i,count) = abs(nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
    end
    epochMarkers(2) = count;
    % get washout progression
    trialBins = 1:n:numTrials(3);
    for k = 1:length(trialBins)-1
        count = count+1;
        cellFRDiff(i,count) = abs(nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
    end
    epochMarkers(3) = count;
end

mihiliDiff = cellFRDiff;

% Now plot
plot((1:count)+0.1,mean(cellFRDiff,1),'o','LineWidth',4,'Color','b');
plot([1:count;1:count]+0.1, [mean(cellFRDiff,1) + std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1)); mean(cellFRDiff,1) - std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1))],'LineWidth',2,'Color','b');

set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',1:n:size(cellFRDiff,2),'XLim',[0.8 count+0.2],'YLim',[ymin ymax]);
xlabel('Bins of Trials','FontSize',14);
ylabel('FR Change','FontSize',14);

V = axis;
% plot epoch divisions
plot([0.5 0.5] + epochMarkers(1),V(3:4),'k--');
plot([0.5 0.5] + epochMarkers(2),V(3:4),'k--');

% figure;
% hold all;
% hist([mihiliDiff(:,end); chewieDiff(:,end)],30)
% axis('tight');
% set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[-1.5,1.5]);
% xlabel('FR Change','FontSize',14);
% ylabel('Count','FontSize',14)


%%
figure;
hold all;

ymin = -15;
ymax = 5;

% Chewie
% first, find the length of the shortest file and get baseline FR
% idx = find(p(1,:) < 2);
% trialMins = zeros(length(idx),3);
% for i = 1:length(idx)
%     blfr = blFR{idx(i)};
%     adfr = adFR{idx(i)};
%     wofr = woFR{idx(i)};
%     
%     blAv(i) = nanmean(blfr);
%     trialMins(i,:) = [length(blfr), length(adfr), length(wofr)];
%     
% end
% numTrials = min(trialMins,[],1);

% find error in each bin
fileErr = [];
idx = find(strcmpi(doFiles(:,1),'Chewie'));
for iFile = 1:length(idx)
    count = 0;
    clear getErr;
    % get baseline progression
    err = blErr{idx(iFile)};
    trialBins = 1:n:numTrials(1);
    for k = 1:length(trialBins)-1
        count = count+1;
        getErr(:,count) = (err(trialBins(k):trialBins(k+1)));
    end
    epochMarkers(1) = count;
    % get adaptation progression
    err = adErr{idx(iFile)};
    trialBins = 1:n:numTrials(2);
    for k = 1:length(trialBins)-1
        count = count+1;
        getErr(:,count) = (err(trialBins(k):trialBins(k+1)));
    end
    epochMarkers(2) = count;
    % get washout progression
    err = woErr{idx(iFile)};
    trialBins = 1:n:numTrials(3);
    for k = 1:length(trialBins)-1
        count = count+1;
        getErr(:,count) = (err(trialBins(k):trialBins(k+1)));
    end
    epochMarkers(3) = count;
    fileErr = [fileErr; getErr];
end

plot(1:count,nanmean(fileErr,1),'o','LineWidth',4,'Color','k');
plot([1:count;1:count], [nanmean(fileErr,1) + nanstd(fileErr,0,1)./sqrt(size(fileErr,1)); nanmean(fileErr,1) - nanstd(fileErr,0,1)./sqrt(size(fileErr,1))],'LineWidth',2,'Color','k');

% Mihili
% find error in each bin
fileErr = [];
idx = find(strcmpi(doFiles(:,1),'Mihili'));
for iFile = 1:length(idx)
    count = 0;
    % get baseline progression
    err = blErr{idx(iFile)};
    clear getErr
    trialBins = 1:n:numTrials(1);
    for k = 1:length(trialBins)-1
        count = count+1;
        getErr(:,count) = (err(trialBins(k):trialBins(k+1)));
    end
    epochMarkers(1) = count;
    % get adaptation progression
    err = adErr{idx(iFile)};
    trialBins = 1:n:numTrials(2);
    for k = 1:length(trialBins)-1
        count = count+1;
        getErr(:,count) = (err(trialBins(k):trialBins(k+1)));
    end
    % get washout progression
    err = woErr{idx(iFile)};
    trialBins = 1:n:numTrials(3);
    for k = 1:length(trialBins)-1
        count = count+1;
        getErr(:,count) = (err(trialBins(k):trialBins(k+1)));
    end
    fileErr = [fileErr; getErr];
end

% Now plot
plot(1:count,nanmean(fileErr,1),'o','LineWidth',4,'Color','b');
plot([1:count;1:count], [nanmean(fileErr,1) + nanstd(fileErr,0,1)./sqrt(size(fileErr,1)); nanmean(fileErr,1) - nanstd(fileErr,0,1)./sqrt(size(fileErr,1))],'LineWidth',2,'Color','b');

set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',1:n:size(cellFRDiff,2),'XLim',[0.8 count+0.2],'YLim',[ymin ymax]);
xlabel('Bins of Trials','FontSize',14);
ylabel('Behavior Error','FontSize',14);

V = axis;
% plot epoch divisions
plot([0.5 0.5] + epochMarkers(1),V(3:4),'k--');
plot([0.5 0.5] + epochMarkers(2),V(3:4),'k--');



%% Plot change in FR as a function of distance from peak FR
% idx = find(p(1,:) <= 0.05);
% % figure;
% % subplot1(1,2);
% % subplot1(1);
% % hold all;
% allFRad = [];
% allFRbl = [];
% allFRwo = [];
% for i = 1:length(idx)
%     % get baseline firing rate
%     blfr = blBlockFR{idx(i)};
%     adfr = adBlockFR{idx(i)};
%     wofr = woBlockFR{idx(i)};
%     
%     [~,I] = max(blfr(1,:)); % find direction of maximum
%     
%     blfr = circshift(blfr',4-I)';
%     adfr = circshift(adfr',4-I)';
%     wofr = circshift(wofr',4-I)';
%     %plot(1:8,abs(fr(end,:)-fr(1,:)),'b');
%     allFRbl = [allFRbl; abs(adfr(end,:)./mean(blfr)-blfr./mean(blfr))];
%     allFRad = [allFRad; abs(adfr(end,:)./mean(blfr)-adfr(1,:)./mean(blfr))];
%     allFRwo = [allFRwo; abs(wofr(end,:)./mean(blfr)-adfr(end,:)./mean(blfr))];
% end
% 
% figure;
% hold all;
% plot(nanmean(allFRbl,1),'LineWidth',3,'Color','b');
% plot(nanmean(allFRad,1),'LineWidth',3,'Color','r');
% plot(nanmean(allFRwo,1),'LineWidth',3,'Color','g');
% legend({'Adapt - Base','Late Adapt - Early Adapt','Wash - Base'},'FontSize',14);
% 
% plot(nanmean(allFRbl,1) - nanstd(allFRbl,0,1)./sqrt(size(allFRbl,1)),'LineWidth',1,'Color','b');
% plot(nanmean(allFRbl,1) + nanstd(allFRbl,0,1)./sqrt(size(allFRbl,1)),'LineWidth',1,'Color','b');
% 
% plot(nanmean(allFRad,1) - nanstd(allFRad,0,1)./sqrt(size(allFRad,1)),'LineWidth',1,'Color','r');
% plot(nanmean(allFRad,1) + nanstd(allFRad,0,1)./sqrt(size(allFRad,1)),'LineWidth',1,'Color','r');
% 
% plot(nanmean(allFRwo,1) - nanstd(allFRwo,0,1)./sqrt(size(allFRwo,1)),'LineWidth',1,'Color','g');
% plot(nanmean(allFRwo,1) + nanstd(allFRwo,0,1)./sqrt(size(allFRwo,1)),'LineWidth',1,'Color','g');
% 
% set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[0 1],'XLim',[1,8],'XTickLabel',-135:45:180,'XTick',1:8);
% xlabel('Distance from PD (Deg)','FontSize',14);
% ylabel('Mean FR Change','FontSize',14);





%% Same plot as above but for three different levels of p-values
% figure;
% hold all;
% 
% 
% % idx = find(p(1,:) > 0.05 & p(1,:) <= 0.6);
% % allFRad = [];
% % for i = 1:length(idx)
% %     % get baseline firing rate
% %     blfr = blBlockFR{idx(i)};
% %     adfr = adBlockFR{idx(i)};
% %     
% %     [~,I] = max(blfr(1,:)); % find direction of maximum
% %     
% %     adfr = circshift(adfr',4-I)';
% %     allFRad = [allFRad; abs(adfr(end,:)./mean(blfr)-adfr(1,:)./mean(blfr))];
% % end
% % 
% % plot(nanmean(allFRad,1),'LineWidth',3,'Color','b');
% % plot(nanmean(allFRad,1) - nanstd(allFRad,0,1)./sqrt(size(allFRad,1)),'LineWidth',1,'Color','b');
% % plot(nanmean(allFRad,1) + nanstd(allFRad,0,1)./sqrt(size(allFRad,1)),'LineWidth',1,'Color','b');
% 
% idx = find(p(1,:) > 0.05);
% allFRad = [];
% for i = 1:length(idx)
%     % get baseline firing rate
%     blfr = blBlockFR{idx(i)};
%     adfr = adBlockFR{idx(i)};
%     
%     [~,I] = max(blfr(1,:)); % find direction of maximum
%     
%     adfr = circshift(adfr',4-I)';
% 
%     allFRad = [allFRad; (adfr(end,:)./mean(blfr)-adfr(1,:)./mean(blfr))];
% end
% 
% plot(nanmean(allFRad,1),'LineWidth',3,'Color','k');
% plot(nanmean(allFRad,1) - nanstd(allFRad,0,1)./sqrt(size(allFRad,1)),'LineWidth',1,'Color','k');
% plot(nanmean(allFRad,1) + nanstd(allFRad,0,1)./sqrt(size(allFRad,1)),'LineWidth',1,'Color','k');
% 
% idx = find(p(1,:) <= 0.05);
% allFRad = [];
% for i = 1:length(idx)
%     % get baseline firing rate
%     blfr = blBlockFR{idx(i)};
%     adfr = adBlockFR{idx(i)};
%     
%     [~,I] = max(blfr(1,:)); % find direction of maximum
%     
%     adfr = circshift(adfr',4-I)';
%     allFRad = [allFRad; (adfr(end,:)./mean(blfr)-adfr(1,:)./mean(blfr))];
% end
% 
% plot(nanmean(allFRad,1),'LineWidth',3,'Color','b');
% plot(nanmean(allFRad,1) - nanstd(allFRad,0,1)./sqrt(size(allFRad,1)),'LineWidth',1,'Color','b');
% plot(nanmean(allFRad,1) + nanstd(allFRad,0,1)./sqrt(size(allFRad,1)),'LineWidth',1,'Color','b');
% 
% % legend({'Adapt - Base','Late Adapt - Early Adapt','Wash - Base'},'FontSize',14);
% set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[-0.25 0.25],'XLim',[1,8],'XTickLabel',-135:45:180,'XTick',1:8);
% xlabel('Distance from PD (Deg)','FontSize',14);
% ylabel('Mean FR Change','FontSize',14);
% 


%% Plot change in firing rate relative to start (or baseline average?) over entire session (split by direction)
% clear cellFRDiff trialMins;
% % first, find the length of the shortest file and get baseline FR
% idx = find(p(1,:) < 0.05);
% 
% for i = 1:length(idx)
%     blfr = blFR{idx(i)};
%     blth = blTH{idx(i)};
%     adth = adTH{idx(i)};
%     woth = woTH{idx(i)};
%     
%     utheta = unique(blth);
%     
%     for j = 1:length(utheta)
%         inds = blth == utheta(j);
%         blAv(i,j) = nanmean(blfr(inds));
%         trialMins(i,j,:) = [sum(blth == utheta(j)), sum(adth == utheta(j)), sum(woth == utheta(j))];
%     end
% end
% trialMins = squeeze(min(trialMins,[],1));
% 
% % now, find baseline averages for each neuron
% figure;
% hold all;
% for j = 1:length(utheta)
%     clear cellFRDiff
%     c = rand(1,3);
%     numTrials = trialMins(j,:);
%     for i = 1:length(idx)
%         count = 0;
%         blfr = blFR{idx(i)};
%         adfr = adFR{idx(i)};
%         wofr = woFR{idx(i)};
%         
%         blth = blTH{idx(i)};
%         adth = adTH{idx(i)};
%         woth = woTH{idx(i)};
%         
%         blfr = blfr(blth == utheta(j));
%         blfr = blfr(1:numTrials(1));
%         adfr = adfr(adth == utheta(j));
%         adfr = adfr(1:numTrials(2));
%         wofr = wofr(woth == utheta(j));
%         wofr = wofr(1:numTrials(3));
%         
%         n = 3;
%         
%         % get baseline progression
%         inds = blth == utheta(j);
%         trialBins = 1:n:numTrials(1);
%         for k = 1:length(trialBins)-1
%             count = count+1;
%             cellFRDiff(i,count) = (nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i,j)));
%         end
%         % get adaptation progression
%         trialBins = 1:n:numTrials(2);
%         for k = 1:length(trialBins)-1
%             count = count+1;
%             cellFRDiff(i,count) = (nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i,j)));
%         end
%         % get washout progression
%         trialBins = 1:n:numTrials(3);
%         for k = 1:length(trialBins)-1
%             count = count+1;
%             cellFRDiff(i,count) = (nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i,j)));
%         end
%     end
%     
%     
%     % Now plot
%     plot(mean(cellFRDiff,1),'LineWidth',3,'Color',c);
%     plot(mean(cellFRDiff,1) + std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1)),'LineWidth',1,'Color',c);
%     plot(mean(cellFRDiff,1) - std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1)),'LineWidth',1,'Color',c);
% end
% 
% set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',1:n:size(cellFRDiff,2));
% xlabel('Number of Trials','FontSize',14);
% ylabel('Mean FR Change','FontSize',14);

%% Plot the distribution of firing rate changes for each direction
%%%%%%%%%%%%%%%%%
% figure;
% hold all;
% idx = find(p(1,:) < 0.05);
% finalChanges = [];
% for i = 1:length(idx)
%     fr = adBlockFR{idx(i)};
%     for j = 1:size(fr,2)
%         finalChanges = [finalChanges; fr(end,j)-fr(1,j)];
%     end
% end
% hist(finalChanges,50);
% xlabel('Change in FR After Adaptation (Hz)','FontSize',14)
% ylabel('Count','FontSize',14);
% set(gca,'Box','off','TickDir','out','FontSize',14);
% axis('tight');
%
% %%%%%%%%%%%%%%%%%%%%
% plotInds = [15,9,3,7,11,17,23,19];
% figure;
% subplot1(5,5);
% idx = find(idx);
% for j = 1:25
%     if ~any(plotInds==j)
%         subplot1(j);
%         set(gca,'Box','off','TickDir','out','FontSize',14,'Visible','off');
%     end
% end
%
% for j = 1:length(plotInds)
%     subplot1(plotInds(j));
%     finalChanges = [];
%     for i = 1:length(idx)
%         fr = adBlockFR{i};
%         finalChanges = [finalChanges; fr(end,j)-fr(1,j)];
%     end
%     hist(finalChanges,25);
%     set(gca,'Box','off','TickDir','out','FontSize',14);
%     axis('tight');
% end









%%

%

% numBins = 75;
%
% figure;
% subplot1(2,2);
% subplot1(1);
% hist(p(1,allTU),numBins);
% set(gca,'Box','off','TickDir','out','FontSize',14);
% ylabel('Time','FontSize',16);
% subplot1(2);
% hist(p(1,~allTU),numBins);
% set(gca,'Box','off','TickDir','out','FontSize',14);
%
% subplot1(3);
% hist(p(2,allTU),numBins);
% ylabel('Direction','FontSize',16);
% xlabel('p-value of ANOVA','FontSize',16);
% set(gca,'Box','off','TickDir','out','FontSize',14);
% subplot1(4);
% hist(p(2,~allTU),numBins);
% xlabel('p-value of ANOVA','FontSize',16);
% set(gca,'Box','off','TickDir','out','FontSize',14);
%
% figure;
% barwitherr([std(p(1, allTU))/sum(allTU), std(p(1, ~allTU))/sum(~allTU); std(p(2, allTU))/sum(allTU),std(p(2, ~allTU))/sum(~allTU)],[mean(p(1, allTU)), mean(p(1, ~allTU)); mean(p(2, allTU)),mean(p(2, ~allTU))]);
% ylabel('p-value','FontSize',16);
% legend({'Well-Tuned','Not-Tuned'},'FontSize',16);
% set(gca,'XTickLabels',{'Time','Direction'},'FontSize',14,'Box','off','TickDir','out');


% % correlate p-values with things
% figure;
%
% % time vs direction
% subplot(2,2,1);
% plot(p(1,:),p(2,:),'k.');
% set(gca,'Box','off','TickDir','out','FontSize',14);
% xlabel('Time p-value','FontSize',14);
% ylabel('Direction p-value','FontSize',14);
%
% % direction vs mean fr
% subplot(2,2,2);
% plot(meanfr,p(1,:),'k.');
% xlabel('Mean Firing Rate','FontSize',14);
% ylabel('Time p-value','FontSize',14);
% set(gca,'Box','off','TickDir','out','FontSize',14);
%
% % time vs mean fr
% subplot(2,2,3);
% plot(meanfr,p(2,:),'k.');
% xlabel('Mean Firing Rate','FontSize',14);
% ylabel('Direction p-value','FontSize',14);
% set(gca,'Box','off','TickDir','out','FontSize',14);
%
% %% Now, for the most significant cells, plot PD/MD over time
%
% % get IDs of well-tuned cells
% [~,I] = sort(p(1,:));
% tuned_I = I(allTU);
%
% numCells = ceil(0.2*length(tuned_I));
% idx = tuned_I(1:numCells);
%
% pd_diff = zeros(size(allPD));
% for i = 1:size(allPD,2)
%     pd_diff(:,i) = angleDiff(allPD(:,i),allPD(:,1),false,true);
% end
%
% figure;
% subplot1(3,1);
% subplot1(1);
% hold all;
% plot(pd_diff(idx,:)','LineWidth',2);
% axis tight;
% set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0.5 3.5]);
% ylabel('| dPD | (deg)','FontSize',14);
% subplot1(2);
% hold all;
% plot(abs(allMD(idx,:)' - repmat(allMD(idx,1),1,size(allMD,2))'),'LineWidth',2);
% axis tight;
% set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0.5 3.5]);
% ylabel('| dDOT | (Hz)','FontSize',14);
%
% subplot1(3);
% hold all;
% plot(abs(allBO(idx,:)' - repmat(allBO(idx,1),1,size(allBO,2))'),'LineWidth',2);
% axis tight;
% set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0.5 3.5]);
% ylabel('| dBO | (Hz)','FontSize',14);
% xlabel('Bins of Trials over Adaptation','FontSize',14);
%
% %%
% figure; hold all;
% numCells = ceil(0.05*length(I));
% idx = I(1:numCells);
% for i=1:length(idx)
%     plot((allFR{idx(i)}));
% end