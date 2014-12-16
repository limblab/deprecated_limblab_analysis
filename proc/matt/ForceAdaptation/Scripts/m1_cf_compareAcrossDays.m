clear;
clc;
close all;

% rootDir = 'C:\Users\Matt Perich\Desktop\lab\data\';
rootDir = 'C:\Users\Matt Perich\Desktop\lab\data\m1_cf_paper_results\';

rewriteFiles = false;


monkeys = {'Mihili','Chewie'};
useArray = 'M1';

doMD = false;

classifierBlocks = [1 4 7];

paramSetName = 'movement';
tuneMethod = 'regression';
tunePeriod = 'onpeak';

% paramSetName = 'target';
% tuneMethod = 'regression';
% tunePeriod = 'full';

ff_color = [0.2 0.25 0.95];
vr_color = [0.95 0.25 0.2];

dataSummary;

cellCount = 0;
for iMonkey = 1:length(monkeys)
    monkey = monkeys{iMonkey};
    
    switch monkey
        case 'MrT'
            dateInds = 1:12;
            dataDir = 'Z:\MrT_9I4\Matt';
            goodDates = mrt_data(dateInds,2);
        case 'Chewie'
            dateInds = [2,3,4,7,8,13,14,15,16,17,18,19,20];
            dataDir = 'Z:\Chewie_8I2\Matt';
            goodDates = chewie_data(dateInds,2);
        case 'Mihili'
            dateInds = 1:15;
            dataDir = 'Z:\Mihili_12A3\Matt';
            goodDates = mihili_data(dateInds,2);
        otherwise
            error('Monkey not recognized');
    end
    
    
    
    baseDir = fullfile(rootDir,monkey);
    
    for i = 1:size(goodDates,1)
        paramFiles{i} = fullfile(rootDir,monkey,goodDates{i},[goodDates{i} '_experiment_parameters.dat']);
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
    
    for iDay = 1:length(tracking.(useArray))
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load some of the experimental parameters
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        params = parseExpParams(paramFiles{iDay});
        useDate = params.date{1};
        arrays = params.arrays;
        monkey = params.monkey{1};
        taskType = params.task{1};
        adaptType = params.adaptation_type{1};
        clear params;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        dataPath = fullfile(baseDir,useDate);
        
        % load the class data
        classes = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_classes_' useDate '.mat']));
        tuning = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_tuning_' useDate '.mat']),tuneMethod);
        
        % get the classes for the current cell
        sg = classes.(tuneMethod).(tunePeriod).(useArray).sg;
        c = classes.(tuneMethod).(tunePeriod).(useArray).classes;
        istuned = classes.(tuneMethod).(tunePeriod).(useArray).istuned;
        
        t_bl = tuning.(tuneMethod).(tunePeriod).(useArray).tuning(classifierBlocks(1));
        t_ad = tuning.(tuneMethod).(tunePeriod).(useArray).tuning(classifierBlocks(2));
        t_wo = tuning.(tuneMethod).(tunePeriod).(useArray).tuning(classifierBlocks(3));
        
        getClasses = -1*ones(size(sg,1),1);
        getDPDs = zeros(size(sg,1),1);
        getPDs = zeros(size(sg,1),3);
        getCIs = zeros(size(sg,1),1000);
        for unit = 1:size(sg,1);
            e = sg(unit,1);
            u = sg(unit,2);
            
            if all(istuned(unit,:))
                getClasses(unit) = c(unit);
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
                
                getDPDs(unit) = angleDiff(pd_bl(1),pd_ad(1),true,true);
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
                
                getDPDs(unit) = pd_ad(1) - pd_bl(1);
            end
            
            getPDs(unit,:) = [pd_bl(1),pd_ad(1),pd_wo(1)];
            
        end
        
        % filter out untuned cells here
        badInds = getClasses == -1;
        sg(badInds,:) = [];
        getPDs(badInds,:) = [];
        getDPDs(badInds) = [];
        getCIs(badInds,:) = [];
        
        tuneInfo(iDay).sg = sg;
        tuneInfo(iDay).class = c(:,1);
        tuneInfo(iDay).adapt = adaptType;
        tuneInfo(iDay).task = taskType;
        tuneInfo(iDay).dpd = getDPDs;
        tuneInfo(iDay).pds = getPDs;
        tuneInfo(iDay).cis = getCIs;
    end
    
    
    %% Get the data for each unique cell
    
    % loop along days
    % get all of the neurons that are new for that day
    
    
    for iDay = 1:length(tracking.(useArray))
        chan = tracking.(useArray){iDay}.chan;
        
        for unit = 1:size(chan,1)
            n = chan(unit,:);
            %check if that cell has matched any previous day
            if any(n(1:iDay-1) > 0)
                % ignore cell because it was found in previous days
            else
                cellCount = cellCount + 1;
                
                % get cell data
                count = 0;
                clear class adapt task dpd pds
                for iDay2 = iDay:length(tracking.(useArray))
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
dayLim = 80; % how many days can be separated by
figure;
hold all;

allPDs = [];
isdiff = []; % track which cells have different cf responses
markz = [];
for unit = 1:length(allCells)
    idx = find(strcmpi(allCells(unit).adapt,pert) & strcmpi(allCells(unit).task,'CO'));
    if length(idx) > 1
        % get change in PD for each day to plot against each other
        for iDay = 1:length(idx)-1
            % eliminate dates that are too far removed from the present
            % if ~strcmpi(allCells(unit).task(idx(iDay)), allCells(unit).task(idx(iDay+1)))
            if allCells(unit).days(idx(iDay+1))-allCells(unit).days(idx(iDay)) <= dayLim
                allPDs = [allPDs; allCells(unit).dpd(idx(iDay)) allCells(unit).dpd(idx(iDay+1))];
                
                % now, see if force PD is different on the two days
                out = compareTuningParameter('pd',{allCells(unit).cis(idx(iDay),:), allCells(unit).cis(idx(iDay+1),:)},[1 1],{'diff',0.95,1000});
                isdiff = [isdiff; out.elec1.unit1(1,2)];
                
                disp([allCells(unit).task(idx(iDay)) allCells(unit).task(idx(iDay+1))]);
                if iDay > 1
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

allPDs = [];
isdiff = [];
markz = [];
for unit = 1:length(allCells)
    idx = find(strcmpi(allCells(unit).adapt,pert) & strcmpi(allCells(unit).task,'RT'));
    if length(idx) > 1
        % get change in PD for each day to plot against each other
        for iDay = 1:length(idx)-1
            % eliminate dates that are too far removed from the present
            % if ~strcmpi(allCells(unit).task(idx(iDay)), allCells(unit).task(idx(iDay+1)))
            if allCells(unit).days(idx(iDay+1))-allCells(unit).days(idx(iDay)) <= dayLim
                allPDs = [allPDs; allCells(unit).dpd(idx(iDay)) allCells(unit).dpd(idx(iDay+1))];
                disp([allCells(unit).task(idx(iDay)) allCells(unit).task(idx(iDay+1))]);
                
                % now, see if force PD is different on the two days
                out = compareTuningParameter('pd',{allCells(unit).cis(idx(iDay),:), allCells(unit).cis(idx(iDay+1),:)},[1 1],{'diff',0.95,1000});
                isdiff = [isdiff; out.elec1.unit1(1,2)];
               
                
                if iDay > 1
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

allPDs = allPDs.*plotMult;
for unit = 1:size(allPDs,1)
    if isdiff(unit)
        plot(allPDs(unit,1),allPDs(unit,2),'ro','LineWidth',3);
    else
        plot(allPDs(unit,1),allPDs(unit,2),'ro','LineWidth',3);
    end
end


% plot(allPDs(:,1),allPDs(:,2),'o','LineWidth',3);
plot([-180,180],[-180,180],'k--');
set(gca,'XLim',[-70,70],'YLim',[-70,70],'TickDir','out','FontSize',14);
box off;
ylabel('Change in PD on FF Session 2','FontSize',14);
xlabel('Change in PD on FF Session 1','FontSize',14);

%% Plot
sdict.Mihili = find(strcmpi(mihili_data(:,3),pert));
sdict.Chewie = find(strcmpi(chewie_data(:,3),pert));

figure;
hold all;
count = 0;
for unit = 1:length(allCells)
    idx = find(strcmpi(allCells(unit).adapt,pert));
    if length(idx) > 1
        l = sdict.(allCells(unit).monkey);
        count = count + 1;
        for j = 1:length(idx)
            val = find(l==allCells(unit).days(idx(j)));
            bl = allCells(unit).pds(idx(j),1);
            color_line([val,val+1],[count,count],bl.*180/pi)
            %plot([val,val+1],[count,count],'k','LineWidth',3);
        end
    end
end
colormap(hsv);
% colormap([abs(sin(0:0.1:pi))', zeros(size(0:0.1:pi,2),1), abs(sin(0:0.1:pi))']);
colorbar;

% now, for each monkey, add lines showing what task
V = axis;
l = sdict.Mihili;
idx = find(strcmpi(mihili_data(:,3),'FF') & strcmpi(mihili_data(:,4),'CO'));
for j = 1:length(idx)
    val = find(l==idx(j));
    plot([val,val+1],[V(3)-1,V(3)-1],'b','LineWidth',6);
end
idx = find(strcmpi(mihili_data(:,3),'FF') & strcmpi(mihili_data(:,4),'RT'));
for j = 1:length(idx)
    val = find(l==idx(j));
    plot([val,val+1],[V(3)-1,V(3)-1],'r','LineWidth',6);
end

l = sdict.Chewie;
idx = find(strcmpi(chewie_data(:,3),'FF') & strcmpi(chewie_data(:,4),'CO'));
for j = 1:length(idx)
    val = find(l==idx(j));
    plot([val,val+1],[V(4)+1,V(4)+1],'b','LineWidth',6);
end
idx = find(strcmpi(chewie_data(:,3),'FF') & strcmpi(chewie_data(:,4),'RT'));
for j = 1:length(idx)
    val = find(l==idx(j));
    plot([val,val+1],[V(4)+1,V(4)+1],'r','LineWidth',6);
end

set(gca,'TickDir','out','FontSize',14);
box off;
xlabel('CF Sessions','FontSize',14);
ylabel('Units');

