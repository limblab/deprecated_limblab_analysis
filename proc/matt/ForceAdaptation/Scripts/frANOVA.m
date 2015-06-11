% get firing rates for all trials in all epochs for all cells
metric = franova.metric;
doPeakFRPlot = franova.doPeakFRPlot;
doBehaviorPlot = franova.doBehaviorPlot;
doAbs = franova.doAbs;
pmax = franova.pmax;

plotPopMean = true;
plotOnlyPD = true;

%%
clear allWFWidths;
count = 0;
for iFile = 1:size(doFiles)
    if doWidthSeparation
        data = loadResults(root_dir,doFiles(iFile,:),'data',[],'BL');
    end
    
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
            
            % get width of waveform
            if doWidthSeparation
                u = data.(useArray).units;
                idx = data.(useArray).sg(:,1)==master_sg(unit,1) & sg(:,2)==master_sg(unit,2);
                allWF{count} = mean(u(idx).wf,2);
            else
                allWF{count} = 0;
            end
            
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
                    utheta = unique(theta);
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
p2 = zeros(2,length(adFR));
for unit = 1:length(adFR)
    meanfr(unit) = mean(adFR{unit});
    % AD only:
    p(:,unit) = anovan([adFR{unit}],{[adBL{unit}],[adTH{unit}]},'display','off');
    %WO only:
    p2(:,unit) = anovan([woFR{unit}],{[woBL{unit}],[woTH{unit}]},'display','off');
    %AD and WO:
    %p(:,unit) = anovan([adFR{unit};woFR{unit}],{[adBL{unit};woBL{unit}],[adTH{unit};woTH{unit}]},'display','off');
    %All three:
    %p(:,unit) = anovan([blFR{unit};adFR{unit};woFR{unit}],{[blBL{unit};adBL{unit};woBL{unit}],[blTH{unit};adTH{unit};woTH{unit}]},'display','off');
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

%%
% % look at PDs for the changing neurons
% idx = find(p(1,:) <= 0.05 & p(2,:) <= 0.05 & allTU);
% for i = 1:length(idx)
%     getPDs(i,:) = [blPD(idx(i),:), adPD(idx(i),:), woPD(idx(i),:)];
%     getDPDs(i,:) = [angleDiff(blPD(idx(i),:),blPD(idx(i),:),false,false), angleDiff(blPD(idx(i),:),adPD(idx(i),:),false,false), angleDiff(blPD(idx(i),:),woPD(idx(i),:),false,false)];
% end
%
% figure;
% hold all;
% plot(getDPDs','LineWidth',2);
% % plot(mean(getDPDs,1),'k','LineWidth',5)
% % plot(mean(getDPDs,1)+std(getDPDs,1)./sqrt(length(getDPDs)),'k--','LineWidth',3);
% % plot(mean(getDPDs,1)-std(getDPDs,1)./sqrt(length(getDPDs)),'k--','LineWidth',3);
% set(gca,'Box','off','TickDir','out','FontSize',14);
% xlabel('Blocks of Trials','FontSize',14);
% ylabel('Change in PD (Deg)','FontSize',14);


%%
p(isnan(p))=1;
p2(isnan(p2))=1;

idx = p(1,:) <= pmax;
disp(['Proportion of time-varying cells (p < ' num2str(pmax) '): ' num2str(sum(idx)/size(p,2))])
idx = p(2,:) <= pmax;
disp(['Proportion of direction-varying cells (p < ' num2str(pmax) '): ' num2str(sum(idx)/size(p,2))])
idx = p(1,:) <= pmax & p(2,:) <= pmax;
disp(['Proportion of both-varying cells (p < ' num2str(pmax) '): ' num2str(sum(idx)/size(p,2))])

% % find what proportion of significantly time-varying cells are cosine tuned
% idx = p(1,:) <= pmax;
% fidx = find(idx);
% % Get some more metrics for each time-varying neuron
% for i = 1:length(fidx)
%     % get mean firing rate of this neuron
%     mFR(i) = mean(blFR{fidx(i)});
%     % get waveform peak-to-peak of this neuron
%     %   currently hard-code the scaling factor which is 250 nV/LSB
%     p2p(i) = 0.25*(max(allWF{fidx(i)}) - min(allWF{fidx(i)}));
%     % get waveform width of this neuron
%     wf = allWF{fidx(i)};
%     inds = find(abs(wf) >= 0*std(wf));
%     wfw(i) = inds(end)-inds(1);
% end
%
% % get the stats for non-time-varying neurons
% fidx = find(~idx);
% for i = 1:length(fidx)
%     % get mean firing rate of this neuron
%     mFRn(i) = mean(blFR{fidx(i)});
%     % get waveform peak-to-peak of this neuron
%     %   currently hard-code the scaling factor which is 250 nV/LSB
%     p2pn(i) = 0.25*(max(allWF{fidx(i)}) - min(allWF{fidx(i)}));
%     % get waveform width of this neuron
%     wf = allWF{fidx(i)};
%     inds = find(abs(wf) >= 0*std(wf));
%     wfwn(i) = inds(end)-inds(1);
% end

disp(' ');
%   Of the time-varying cells:
%       1) How many are cosine tuned?
disp(['Proportion of time-varying cells that are cosine tuned: ' num2str(sum(allTU(idx))/sum(idx)) ])
disp(' ');
% %       2) What is firing rate compared to rest of population?
% disp(['Mean BL firing rate of time-varying cells: ' num2str(mean(mFR)) ' +/- ' num2str(std(mFR)./length(mFR))])
% disp(['Mean BL firing rate of the rest: ' num2str(mean(mFRn)) ' +/- ' num2str(std(mFRn)./length(mFRn))])
% disp(' ');
% %       3) What is the average peak-to-peak waveform amplitude
% disp(['Mean peak-to-peak waveform amplitude of time-varying cells: ' num2str(mean(p2p)) ' +/- ' num2str(std(p2p)./length(p2p))]);
% disp(['Mean peak-to-peak waveform amplitude of the rest: ' num2str(mean(p2pn)) ' +/- ' num2str(std(p2pn)./length(p2pn))]);
% disp(' ');
% %       4) What is the waveform width
% disp(['Mean waveform width of time-varying cells: ' num2str(mean(wfw)) ' +/- ' num2str(std(wfw)./length(wfw))]);
% disp(['Mean waveform width of the rest: ' num2str(mean(wfwn)) ' +/- ' num2str(std(wfwn)./length(wfwn))]);


%%

% TO DO:
%   - Do significance testing of FR changes

figure;
hold all;

n = franova.numBins; % number of bins
if doAbs
    ymin = 0;
    ymax = 0.5;
else
    ymin = -0.2;
    ymax = 0.3;
end
xmin = 0.8;

% Chewie
clear cellFRDiff fileErr cellFRDiff_ADWO cellFRDiff_BLAD;
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

% do mean of all other neurons
idx = find(p(1,:) > pmax & strcmpi(allMonk,'Chewie'));

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
    trialBins = [1,numTrials(1)];
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
    % get adaptation progression
    trialBins = 1:floor(numTrials(2)/n):numTrials(2);
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
    % get washout progression
    trialBins = 1:floor(numTrials(3)/n):numTrials(3);
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
end

if plotPopMean
    % plot mean of population
    bl = [mean(cellFRDiff(:,1)), std(cellFRDiff(:,1))./sqrt(size(cellFRDiff,1))];
    temp = cellFRDiff(:,2:1+n);
    temp = reshape(temp,n*length(temp),1);
    ad = [mean(temp), std(temp)./sqrt(size(temp,1))];
    temp = cellFRDiff(:,2+n:1+2*n);
    temp = reshape(temp,n*length(temp),1);
    wo = [mean(temp), std(temp)./sqrt(size(temp,1))];
    clear temp cellFRDiff;
    
    patch([xmin,1+0.5,1+0.5,xmin],[bl(1)-bl(2),bl(1)-bl(2),bl(1)+bl(2),bl(1)+bl(2)],'k','LineWidth',2)
    patch([1.5,1.5+n,1.5+n,1.5],[ad(1)-ad(2),ad(1)-ad(2),ad(1)+ad(2),ad(1)+ad(2)],'k','LineWidth',2)
    patch([n+1.5,1.5+2*n,1.5+2*n,n+1.5],[wo(1)-wo(2),wo(1)-wo(2),wo(1)+wo(2),wo(1)+wo(2)],'k','LineWidth',2)
end

% do mean of all neurons for mihili
idx = find(p(1,:) > pmax & strcmpi(allMonk,'Mihili'));

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
    trialBins = [1,numTrials(1)];
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
    % get adaptation progression
    trialBins = 1:floor(numTrials(2)/n):numTrials(2);
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
    % get washout progression
    trialBins = 1:floor(numTrials(3)/n):numTrials(3);
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
end

if plotPopMean
    % plot mean of population
    bl = [mean(cellFRDiff(:,1)), std(cellFRDiff(:,1))./sqrt(size(cellFRDiff,1))];
    temp = cellFRDiff(:,2:1+n);
    temp = reshape(temp,n*length(temp),1);
    ad = [mean(temp), std(temp)./sqrt(size(temp,1))];
    temp = cellFRDiff(:,2+n:1+2*n);
    temp = reshape(temp,n*length(temp),1);
    wo = [mean(temp), std(temp)./sqrt(size(temp,1))];
    clear temp cellFRDiff;
    
    patch([xmin,1+0.5,1+0.5,xmin],[bl(1)-bl(2),bl(1)-bl(2),bl(1)+bl(2),bl(1)+bl(2)],'b','LineWidth',2)
    patch([1.5,1.5+n,1.5+n,1.5],[ad(1)-ad(2),ad(1)-ad(2),ad(1)+ad(2),ad(1)+ad(2)],'b','LineWidth',2)
    patch([n+1.5,1.5+2*n,1.5+2*n,n+1.5],[wo(1)-wo(2),wo(1)-wo(2),wo(1)+wo(2),wo(1)+wo(2)],'b','LineWidth',2)
    
    % make the patches slightly transparent
    h = findobj(gca,'Type','patch');
    set(h,'facealpha',0.7,'edgealpha',0);
    
end

% do the directionally tuned cells
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
    trialBins = [1,numTrials(1)];
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
    epochMarkers(1) = count;
    % get adaptation progression
    trialBins = 1:floor(numTrials(2)/n):numTrials(2);
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
    epochMarkers(2) = count;
    % get washout progression
    trialBins = 1:floor(numTrials(3)/n):numTrials(3);
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
    cellFRDiff_BLAD(i) = (nanmean(adfr(trialBins(end-1):trialBins(end))) - blAv(i))./blAv(i);
    cellFRDiff_ADWO(i) = (nanmean(wofr(trialBins(end-1):trialBins(end))) - nanmean(adfr(trialBins(end-1):trialBins(end))))./blAv(i);
    epochMarkers(3) = count;
end

chewieDiff = cellFRDiff;
allFRDiff_BLAD = cellFRDiff_BLAD;
allFRDiff_ADWO = cellFRDiff_ADWO;

% Now plot
plot(1:count,mean(cellFRDiff,1),'o','LineWidth',4,'Color','k');
plot([1:count;1:count], [mean(cellFRDiff,1) + std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1)); mean(cellFRDiff,1) - std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1))],'LineWidth',2,'Color','k');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mihili
clear cellFRDiff cellErr cellFRDiff_ADWO cellFRDiff_BLAD;

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
    trialBins = [1,numTrials(1)];
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(blfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
    epochMarkers(1) = count;
    % get adaptation progression
    trialBins = 1:floor(numTrials(2)/n):numTrials(2);
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(adfr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
    epochMarkers(2) = count;
    % get washout progression
    trialBins = 1:floor(numTrials(3)/n):numTrials(3);
    for k = 1:length(trialBins)-1
        count = count+1;
        if doAbs
            cellFRDiff(i,count) = abs(nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        else
            cellFRDiff(i,count) = (nanmean(wofr(trialBins(k):trialBins(k+1)) - blAv(i)))./blAv(i);
        end
    end
    cellFRDiff_BLAD(i) = (nanmean(adfr(trialBins(end-1):trialBins(end))) - blAv(i))./blAv(i);
    cellFRDiff_ADWO(i) = (nanmean(wofr(trialBins(end-1):trialBins(end))) - nanmean(adfr(trialBins(end-1):trialBins(end))))./blAv(i);
    epochMarkers(3) = count;
end

mihiliDiff = cellFRDiff;
allFRDiff_BLAD = [allFRDiff_BLAD cellFRDiff_BLAD];
allFRDiff_ADWO = [allFRDiff_ADWO cellFRDiff_ADWO];

% Now plot
plot((1:count)+0.1,mean(cellFRDiff,1),'o','LineWidth',4,'Color','b');
plot([1:count;1:count]+0.1, [mean(cellFRDiff,1) + std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1)); mean(cellFRDiff,1) - std(cellFRDiff,0,1)./sqrt(size(cellFRDiff,1))],'LineWidth',2,'Color','b');

set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',1:n:size(cellFRDiff,2),'XLim',[xmin count+0.2],'YLim',[ymin ymax]);
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


%% Plot distribution of changes from end of AD to beginning of WO
% figure;
% hold all;
% [N,X] = hist(allFRDiff_ADWO,[-1:1/6:1]);
% bar(X,N./sum(N),1);
% axis('tight');
% plot([mean(allFRDiff_ADWO),mean(allFRDiff_ADWO)],[0 7],'r-','LineWidth',2);
% set(gca,'Box','off','TickDir','out','FontSize',14);
% xlabel('Normalized Change in FR (Adaptation to Washout)','FontSize',14);
% ylabel('Percent','FontSize',14);
%
% figure;
% hold all;
% [N,X] = hist(allFRDiff_BLAD,[-1:1/6:1]);
% bar(X,N./sum(N),1);
% axis('tight');
% plot([mean(allFRDiff_BLAD),mean(allFRDiff_BLAD)],[0 7],'r-','LineWidth',2);
% set(gca,'Box','off','TickDir','out','FontSize',14);
% xlabel('Normalized Change in FR (Baseline to Adaptation)','FontSize',14);
% ylabel('Percent','FontSize',14);

%%
if doBehaviorPlot
    figure;
    hold all;
    
    if ~doAbs
        ymin = -15;
        ymax = 5;
    else
        ymin = 0;
        ymax = 20;
    end
    
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
    
    nTot = 1+2*n; % how many total bins
    
    for iFile = 1:length(idx)
        count = 0;
        clear getErr;
        % get baseline progression
        err = blErr{idx(iFile)};
        trialBins = [1,numTrials(1)];
        for k = 1:length(trialBins)-1
            count = count+1;
            getErr{count} = [getErr{count}; (err(trialBins(k):trialBins(k+1)))];
        end
        epochMarkers(1) = count;
        % get adaptation progression
        err = adErr{idx(iFile)};
        trialBins = 1:floor(numTrials(2)/n):numTrials(2);
        for k = 1:length(trialBins)-1
            count = count+1;
            getErr{count} = [getErr{count}; (err(trialBins(k):trialBins(k+1)))];
        end
        epochMarkers(2) = count;
        % get washout progression
        err = woErr{idx(iFile)};
        trialBins = 1:floor(numTrials(3)/n):numTrials(3);
        for k = 1:length(trialBins)-1
            count = count+1;
            getErr{count} = [getErr{count}; (err(trialBins(k):trialBins(k+1)))];
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
        trialBins = [1,numTrials(1)];
        for k = 1:length(trialBins)-1
            count = count+1;
            getErr(:,count) = (err(trialBins(k):trialBins(k+1)));
        end
        epochMarkers(1) = count;
        % get adaptation progression
        err = adErr{idx(iFile)};
        trialBins = 1:floor(numTrials(2)/n):numTrials(2);
        for k = 1:length(trialBins)-1
            count = count+1;
            getErr(:,count) = (err(trialBins(k):trialBins(k+1)));
        end
        % get washout progression
        err = woErr{idx(iFile)};
        trialBins = 1:floor(numTrials(3)/n):numTrials(3);
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
    
end


%% Plot change in FR as a function of distance from peak FR
if doPeakFRPlot
    idx = find(p(1,:) <= 0.05);
    % figure;
    % subplot1(1,2);
    % subplot1(1);
    % hold all;
    allFRad = [];
    allFRbl = [];
    allFRwo = [];
    for i = 1:length(idx)
        % get baseline firing rate
        blfr = blBlockFR{idx(i)};
        adfr = adBlockFR{idx(i)};
        wofr = woBlockFR{idx(i)};
        
        [~,I] = max(blfr(1,:)); % find direction of maximum
        
        blfr = circshift(blfr',4-I)';
        adfr = circshift(adfr',4-I)';
        wofr = circshift(wofr',4-I)';
        %plot(1:8,abs(fr(end,:)-fr(1,:)),'b');
        allFRbl = [allFRbl; abs( (adfr(end,:)-blfr)./mean(blfr) )];
        allFRad = [allFRad; abs( (adfr(end,:)-adfr(1,:))./mean(blfr) )];
        allFRwo = [allFRwo; abs( (wofr(end,:)-blfr)./mean(blfr) )];
    end
    
    figure;
    hold all;
    plot(nanmean(allFRbl,1),'LineWidth',3,'Color','b');
    plot(nanmean(allFRad,1),'LineWidth',3,'Color','r');
    plot(nanmean(allFRwo,1),'LineWidth',3,'Color','g');
    legend({'Adapt - Base','Late Adapt - Early Adapt','Wash - Base'},'FontSize',14);
    
    plot(nanmean(allFRbl,1) - nanstd(allFRbl,0,1)./sqrt(size(allFRbl,1)),'LineWidth',1,'Color','b');
    plot(nanmean(allFRbl,1) + nanstd(allFRbl,0,1)./sqrt(size(allFRbl,1)),'LineWidth',1,'Color','b');
    
    plot(nanmean(allFRad,1) - nanstd(allFRad,0,1)./sqrt(size(allFRad,1)),'LineWidth',1,'Color','r');
    plot(nanmean(allFRad,1) + nanstd(allFRad,0,1)./sqrt(size(allFRad,1)),'LineWidth',1,'Color','r');
    
    plot(nanmean(allFRwo,1) - nanstd(allFRwo,0,1)./sqrt(size(allFRwo,1)),'LineWidth',1,'Color','g');
    plot(nanmean(allFRwo,1) + nanstd(allFRwo,0,1)./sqrt(size(allFRwo,1)),'LineWidth',1,'Color','g');
    
    set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[0 1],'XLim',[1,8],'XTickLabel',-135:45:180,'XTick',1:8);
    xlabel('Distance from PD (Deg)','FontSize',14);
    ylabel('Mean FR Change','FontSize',14);
end

