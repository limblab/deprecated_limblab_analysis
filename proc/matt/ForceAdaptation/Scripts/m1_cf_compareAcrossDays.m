clear;
clc;
close all;

root_dir = 'F:\';

rewriteFiles = false;
flipClockwisePerts = true;

monkeys = {'Mihili','Chewie'};
useArray = 'M1';

doMD = false;
doMDNorm = true;

classifierBlocks = [1 4 7];

paramSetName = 'movement';
tuneMethod = 'regression';
tuneWindow = 'onpeak';

ff_color = [0.2 0.25 0.95];
vr_color = [0.95 0.25 0.2];

dataSummary;

%%
if ~doMD
    xmin = -30;
    xmax = 120;
    ymin = -30;
    ymax = 120;
    ylab = 'Change in PD on FF Session 1';
else
    if doMDNorm
        xmin = -1.1;
        xmax = 1.1;
        ymin = -1.1;
        ymax = 1.1;
        ylab = 'Change in Normalized DOT on FF Session 1';
    else
        xmin = -70;
        xmax = 70;
        ymin = -70;
        ymax = 70;
        ylab = 'Change in DOT on FF Session 1';
    end
end

cellCount = 0;
monkeyFiles = cell(1,length(monkeys));
for iMonkey = 1:length(monkeys)
    monkey = monkeys{iMonkey};
    
    switch monkey
        case 'MrT'
            doFiles = sessionList(strcmpi(sessionList(:,1),'MrT'),:);
        case 'Chewie'
            doFiles = sessionList(strcmpi(sessionList(:,1),'Chewie') & strcmpi(sessionList(:,3),'FF'),:);
        case 'Mihili'
            doFiles = sessionList(strcmpi(sessionList(:,1),'Mihili') & strcmpi(sessionList(:,3),'FF'),:);
        otherwise
            error('Monkey not recognized');
    end
    
    monkeyFiles{iMonkey} = doFiles;
    baseDir = fullfile(root_dir,monkey,'Processed');
    
    for i = 1:size(doFiles,1)
        paramFiles{i} = fullfile(root_dir,monkey,'Processed',doFiles{i},[doFiles{i} '_experiment_parameters.dat']);
    end
    
    %% load the tracking
    if exist(fullfile(baseDir,'multiday_tracking.mat'),'file') || rewriteFiles
        load(fullfile(baseDir,'multiday_tracking.mat'))
    else
        error('no file');
    end
    
    %% load all of the data to get change in PDs for all cells in all days as
    % well as cell classes
    
    clear tuneInfo;
    
    pertDir = zeros(1,length(tracking.(useArray)));
    for iFile = 1:length(tracking.(useArray))
        
        dataPath = fullfile(baseDir,doFiles{iFile,2});
        
        % load the class data
        [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
        
        if flipClockwisePerts
            % gotta hack it
            expParamFile = fullfile(dataPath,[doFiles{iFile,2} '_experiment_parameters.dat']);
            t(1).params.exp = parseExpParams(expParamFile);
            pertDir(iFile) = t(1).params.exp.angle_dir;
        else
            pertDir(iFile) = 1;
        end
        
        % get the classes for the current cell
        sg = c.sg;
        istuned = c.istuned;
        
        t_bl = t(classifierBlocks(1));
        t_ad = t(classifierBlocks(2));
        t_wo = t(classifierBlocks(3));
        
        getClasses = -1*ones(size(sg,1),1);
        getDPDs = zeros(size(sg,1),1);
        getPDs = zeros(size(sg,1),3);
        getCIs = zeros(size(sg,1),1000);
        for unit = 1:size(sg,1);
            e = sg(unit,1);
            u = sg(unit,2);
            
            if all(istuned(unit,:))
                getClasses(unit) = c.classes(unit,1);
            end
            
            if ~doMD % do PDs
                plotMult = 180/pi;
                
                ind = t_bl.sg(:,1)==e & t_bl.sg(:,2)==u;
                pd_bl = t_bl.pds(ind,:);
                
                ind = t_ad.sg(:,1)==e & t_ad.sg(:,2)==u;
                pd_ad = t_ad.pds(ind,:);
                % get confidence intervals for adaptation only
                getCIs(unit,:) = t_ad.boot_pds(ind,:);
                
                ind = t_wo.sg(:,1)==e & t_wo.sg(:,2)==u;
                pd_wo = t_wo.pds(ind,:);
                
                getDPDs(unit) = pertDir(iFile).*angleDiff(pd_bl(1),pd_ad(1),true,true);
            else
                plotMult = 1;
                
                ind = t_bl.sg(:,1)==e & t_bl.sg(:,2)==u;
                pd_bl = t_bl.mds(ind,:);
                
                ind = t_ad.sg(:,1)==e & t_ad.sg(:,2)==u;
                pd_ad = t_ad.mds(ind,:);
                % get confidence intervals for adaptation only
                getCIs(unit,:) = t_ad.boot_mds(ind,:);
                
                ind = t_wo.sg(:,1)==e & t_wo.sg(:,2)==u;
                pd_wo = t_wo.mds(ind,:);
                
                if doMDNorm
                    getDPDs(unit) = (pd_ad(1) - pd_bl(1))/pd_bl(1);
                else
                    getDPDs(unit) = pd_ad(1) - pd_bl(1);
                end
            end
            
            getPDs(unit,:) = [pd_bl(1),pd_ad(1),pd_wo(1)];
            
        end
        
        % filter out untuned cells here
        badInds = getClasses == -1;
        sg(badInds,:) = [];
        getPDs(badInds,:) = [];
        getDPDs(badInds) = [];
        getCIs(badInds,:) = [];
        
        tuneInfo(iFile).sg = sg;
        tuneInfo(iFile).class = c.classes(:,1);
        tuneInfo(iFile).adapt = doFiles{iFile,3};
        tuneInfo(iFile).task = doFiles{iFile,4};
        tuneInfo(iFile).dpd = getDPDs;
        tuneInfo(iFile).pds = getPDs;
        tuneInfo(iFile).cis = getCIs;
    end
    
    
    %% Get the data for each unique cell
    
    % loop along days
    % get all of the neurons that are new for that day
    
    
    for iFile = 1:length(tracking.(useArray))
        chan = tracking.(useArray){iFile}.chan;
        
        for unit = 1:size(chan,1)
            n = chan(unit,:);
            %check if that cell has matched any previous day
            if any(n(1:iFile-1) > 0)
                % ignore cell because it was found in previous days
            else
                cellCount = cellCount + 1;
                
                % get cell data
                count = 0;
                clear class adapt task dpd pds
                for iDay2 = iFile:length(tracking.(useArray))
                    if n(iDay2)~=0
                        e = floor(n(iDay2));
                        u = round( (n(iDay2) - floor(n(iDay2))) * 10 );
                        idx = tuneInfo(iDay2).sg(:,1) == e & tuneInfo(iDay2).sg(:,2) == u;
                        
                        if sum(idx) > 0
                            count = count + 1;
                            allCells(cellCount).days(count) = iDay2;
                            allCells(cellCount).class(count) = tuneInfo(iDay2).class(idx);
                            allCells(cellCount).dpd(count) = tuneInfo(iDay2).dpd(idx);
                            allCells(cellCount).pds(count,:) = tuneInfo(iDay2).pds(idx,:);
                            allCells(cellCount).adapt{count} = tuneInfo(iDay2).adapt;
                            allCells(cellCount).task{count} = tuneInfo(iDay2).task;
                            allCells(cellCount).cis(count,:) = tuneInfo(iDay2).cis(idx,:);
                        end
                    end
                end
                allCells(cellCount).monkey = monkey;
            end
        end
    end
end

%% Now compile pd changes and plot Day 1 vs Day 2
pert = 'FF';
dayLim = 2000; % how many days can be separated by
figure;
hold all;

allPDs = [];
isdiff = []; % track which cells have different cf responses
markz = [];
for unit = 1:length(allCells)
    idx = find(strcmpi(allCells(unit).adapt,pert) & strcmpi(allCells(unit).task,'CO'));
    if length(idx) > 1
        % get change in PD for each day to plot against each other
        for iFile = 1:length(idx)-1
            % eliminate dates that are too far removed from the present
            % if ~strcmpi(allCells(unit).task(idx(iDay)), allCells(unit).task(idx(iDay+1)))
            if allCells(unit).days(idx(iFile+1))-allCells(unit).days(idx(iFile)) <= dayLim
                allPDs = [allPDs; allCells(unit).dpd(idx(iFile)) allCells(unit).dpd(idx(iFile+1))];
                
                % now, see if force PD is different on the two days
                out = compareTuningParameter('pd',{allCells(unit).cis(idx(iFile),:), allCells(unit).cis(idx(iFile+1),:)},[1 1],{'diff',0.95,1000});
                isdiff = [isdiff; out.elec1.unit1(1,2)];
                
                disp([allCells(unit).task(idx(iFile)) allCells(unit).task(idx(iFile+1))]);
                if iFile > 1
                    markz = [markz; 1];
                else
                    markz = [markz; 0];
                end
            end
        end
    end
end

allPDs = allPDs.*plotMult;
for unit = 1:size(allPDs,1)
    if isdiff(unit)
        plot(allPDs(unit,1),allPDs(unit,2),'bo','LineWidth',3);
    else
        plot(allPDs(unit,1),allPDs(unit,2),'bo','LineWidth',3);
    end
end

keepPDs = allPDs;

allPDs = [];
isdiff = [];
markz = [];
for unit = 1:length(allCells)
    idx = find(strcmpi(allCells(unit).adapt,pert) & strcmpi(allCells(unit).task,'RT'));
    if length(idx) > 1
        % get change in PD for each day to plot against each other
        for iFile = 1:length(idx)-1
            % eliminate dates that are too far removed from the present
            % if ~strcmpi(allCells(unit).task(idx(iDay)), allCells(unit).task(idx(iDay+1)))
            if allCells(unit).days(idx(iFile+1))-allCells(unit).days(idx(iFile)) <= dayLim
                allPDs = [allPDs; allCells(unit).dpd(idx(iFile)) allCells(unit).dpd(idx(iFile+1))];
                disp([allCells(unit).task(idx(iFile)) allCells(unit).task(idx(iFile+1))]);
                
                % now, see if force PD is different on the two days
                out = compareTuningParameter('pd',{allCells(unit).cis(idx(iFile),:), allCells(unit).cis(idx(iFile+1),:)},[1 1],{'diff',0.95,1000});
                isdiff = [isdiff; out.elec1.unit1(1,2)];
                
                if iFile > 1
                    markz = [markz; 1];
                else
                    markz = [markz; 0];
                end
            else
                %do nothing
            end
        end
    end
end

plot([-180,180],[-180,180],'k','LineWidth',2);
plot([0 0],[-180 180],'k--','LineWidth',1);
plot([-180 180],[0 0],'k--','LineWidth',1);

allPDs = allPDs.*plotMult;
for unit = 1:size(allPDs,1)
    if isdiff(unit)
        plot(allPDs(unit,1),allPDs(unit,2),'ro','LineWidth',3);
    else
        plot(allPDs(unit,1),allPDs(unit,2),'ro','LineWidth',3);
    end
end

keepPDs = [keepPDs; allPDs];

% plot(allPDs(:,1),allPDs(:,2),'o','LineWidth',3);
set(gca,'XLim',[xmin,xmax],'YLim',[ymin,ymax],'TickDir','out','FontSize',14);
box off;
ylabel('Change in PD on FF Session 2','FontSize',14);
xlabel('Change in PD on FF Session 1','FontSize',14);

%% Plot database representation
% sort cells by monkey and then by order of first appearance

count = 0;
for unit = 1:length(allCells)
    idx = find(strcmpi(allCells(unit).adapt,pert));
    if length(idx) > 1
        
        monkIdx = strcmpi(monkeys,allCells(unit).monkey);
        
        l = find(strcmpi(monkeyFiles{monkIdx}(:,3),pert));
        count = count + 1;
        getVals = [];
        getPDs = [];
        getTasks = [];
        for j = 1:length(idx)
            val = find(l==allCells(unit).days(idx(j)));
            bl = allCells(unit).pds(idx(j),1);
            % compile things for sorting and organizing
            getVals = [getVals, val];
            getPDs = [getPDs, bl.*180/pi];
            getTasks = [getTasks, allCells(unit).task(j)];
        end
        
        cellDB(count).sessionIDs = getVals;
        cellDB(count).monkey = allCells(unit).monkey;
        cellDB(count).pds = getPDs;
        clear getVals getPDs;
    end
end


figure;
for iMonkey = 1:length(monkeys)
    doFiles = monkeyFiles{iMonkey};
    
    subplot(length(monkeys),1,iMonkey);
    hold all;
    
    idx = find(cellfun(@(x) strcmpi(x,monkeys{iMonkey}),{cellDB.monkey}));
    [~,I] = sort(cellfun(@(x) min(x),{cellDB(idx).sessionIDs}));
    
    idx = idx(I);
    for unit = 1:length(idx)
        temp = cellDB(idx(unit));
        for i = 1:length(temp.sessionIDs)
            %             color_line([temp.sessionIDs(i),temp.sessionIDs(i)+1],[unit,unit],temp.pds(i),'LineWidth',3)
            patch([temp.sessionIDs(i),temp.sessionIDs(i)+1,temp.sessionIDs(i)+1,temp.sessionIDs(i)],[unit-1,unit-1,unit,unit],temp.pds(i));
        end
    end
    
    colormap(hsv);
    % colormap([abs(sin(0:0.1:pi))', zeros(size(0:0.1:pi,2),1), abs(sin(0:0.1:pi))']);
    colorbar;
    
    axis('tight');
    V = axis;
    idx = find(strcmpi(doFiles(:,4),'CO'));
    for j = 1:length(idx)
        %         plot([idx(j),idx(j)+1],[V(4)+1,V(4)+1],'b','LineWidth',6);
        patch([idx(j),idx(j)+1,idx(j)+1,idx(j)],[V(4)+1,V(4)+1,V(4)+2,V(4)+2],'b');
    end
    idx = find(strcmpi(doFiles(:,4),'RT'));
    for j = 1:length(idx)
        %         plot([idx(j),idx(j)+1],[V(4)+1,V(4)+1],'r','LineWidth',6);
        patch([idx(j),idx(j)+1,idx(j)+1,idx(j)],[V(4)+1,V(4)+1,V(4)+2,V(4)+2],'r');
    end
    
    set(gca,'Box','off','TickDir','out','FontSize',14);
    axis('tight');
    box off;
    xlabel('CF Sessions','FontSize',14);
    ylabel('Units');
    
    title(monkeys{iMonkey},'FontSize',16);
end
