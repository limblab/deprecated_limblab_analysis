% This file will compare the behavior of the same cell over as many days as
% possible
%
%   NOTE: Assumes that cells won't drop out to be replaced by a new cell
%   and then come back

clear;
clc;
close all;

rootDir = 'F:\';
saveData = true;
rewriteFiles = false;


monkey = 'Mihili';
useArray = 'M1';

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

% now do the tracking
if exist(fullfile(baseDir,'multiday_tracking.mat'),'file') || rewriteFiles
    load(fullfile(baseDir,'multiday_tracking.mat'))
else
    error('no file');
end


% load all of the data to get change in PDs for all cells in all days as
% well as cell classes
for iDay = 1:size(goodDates,1)
    
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
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
    
    % get the classes for the current cell
    sg = c.sg;
    c = c.classes;
    istuned = c.istuned;
    
    t_bl = t(classifierBlocks(1));
    t_ad = t(classifierBlocks(2));
    t_wo = t(classifierBlocks(3));
    
    getClasses = -1*ones(size(sg,1),1);
    getDPDs = zeros(size(sg,1),1);
    getPDs = zeros(size(sg,1),3);
    for unit = 1:size(sg,1);
        e = sg(unit,1);
        u = sg(unit,2);
        
        if all(istuned(unit,:))
            getClasses(unit) = c(unit);
        end
        
        ind = t_bl.sg(:,1)==e & t_bl.sg(:,2)==u;
        pd_bl = t_bl.pds(ind,1);
        ind = t_ad.sg(:,1)==e & t_ad.sg(:,2)==u;
        pd_ad = t_ad.pds(ind,1);
        ind = t_wo.sg(:,1)==e & t_wo.sg(:,2)==u;
        pd_wo = t_wo.pds(ind,1);
        
        getDPDs(unit) = angleDiff(pd_bl,pd_ad,true,true);
        getPDs(unit,:) = [pd_bl,pd_ad,pd_wo];
    end
    
    % filter out untuned cells here
    
    tuneInfo(iDay).sg = sg;
    tuneInfo(iDay).class = c(:,1);
    tuneInfo(iDay).adapt = adaptType;
    tuneInfo(iDay).task = taskType;
    tuneInfo(iDay).dpd = getDPDs;
    tuneInfo(iDay).pds = getPDs;
end

count = 0;
for iDay = 1:size(goodDates,1)
    
    comp = tracking.(useArray){iDay}.chan;
    comp = comp(:,dateInds);
    
    getClasses = -1.*ones(size(comp,1),size(comp,2)+1);
    getClasses(:,1) = comp(:,1);
    
    getTasks = cell(size(comp));
    getAdapts = cell(size(comp));
    getDPDs = zeros(size(comp));
    
    for unit = 1:size(comp,1)
        % make sure this unit hasn't been used in the past
        %   loop along all previous days and make sure it hasn't matched
        newCheck = zeros(1,iDay-1);
        for j = 1:iDay-1
            % get matching info and index of unit ID
            comp2 = tracking.(useArray){j}.chan;
            idx = find(comp2(:,j)==comp(unit,iDay));
            
            % if the cell has already matched with this or a later one
            if ~isempty(idx)
                newCheck(j) = any(comp2(idx,iDay:end) > 0);
            end
        end
        
        % if no previous day matched with this cell
        if ~any(newCheck)
            count = count+1;
            
            e = floor(comp(unit,iDay));
            u = int32(10*rem(comp(unit,iDay),e));
            
            ind = sg(:,1)==e & sg(:,2) == u;
            
            allClasses = [];
            allDPDs = [];
            allTasks = [];
            allAdapts = [];
            allPDs = [];
            for j = iDay:size(comp,2)
                if comp(unit,j)
                    
                    e = floor(comp(unit,j));
                    u = int32(10*rem(comp(unit,j),e));
                    
                    sg = tuneInfo(j).sg;
                    c = tuneInfo(j).class;
                    adaptType = tuneInfo(j).adapt;
                    taskType = tuneInfo(j).task;
                    dpds = tuneInfo(j).dpd;
                    pds = tuneInfo(j).pds;
                    
                    idx = sg(:,1)==e & sg(:,2)==u;
                    
                    % make sure it is tuned
                    if c(idx) ~= -1
                        allClasses = [allClasses; c(idx)];
                        allDPDs = [allDPDs; dpds(idx)];
                        allTasks = [allTasks; {taskType}];
                        allAdapts = [allAdapts; {adaptType}];
                        allPDs = [allPDs; pds(idx,:)];
                    end
                end
            end
            
            fuck(count).class = allClasses;
            fuck(count).dpd = allDPDs;
            fuck(count).task = allTasks;
            fuck(count).adapt = allAdapts;
            fuck(count).pds = allPDs;
        else
            % do nothing because cell previously matched
        end
        
    end
end


%% now repeat Richardson/Bizzi plot
allPDs = nan(length(fuck),15);
for unit = 1:length(fuck)
    pds = fuck(unit).dpd;
    a = fuck(unit).adapt;
    t = fuck(unit).task;
    ff_inds = find(strcmpi(a,'ff'));
    
    if size(ff_inds,1) > 1 % if there is more than one day
        allPDs(unit,ff_inds) = pds(ff_inds,1);
    end
end

allPDs(all(isnan(allPDs),2),:) = [];
allPDs(:,all(isnan(allPDs),1)) = [];

% now, for each day take average difference from day before
ymin = -100;
ymax = 100;
figure;
hold all;
    
for i = 2:size(allPDs,2)
    dpds = angleDiff(allPDs(:,1),allPDs(:,i),true,true).*(180/pi);
    s = nanstd(dpds)/sqrt(sum(~isnan(dpds)));
%     plot(i-1,nanmean(dpds),'bd','LineWidth',2);
%     plot([i-1,i-1],[nanmean(dpds)+s,nanmean(dpds)-s],'b-','LineWidth',2);
    plot(repmat(i-1,1,length(dpds)),dpds,'bo','LineWidth',2);
end

plot(0,0,'bo','LineWidth',2);
set(gca,'XLim',[-0.5,size(allPDs,2)+1],'YLim',[ymin ymax],'TickDir','out');
box off;
ylabel('Change in PD from previous day (deg)','FontSize',14);
xlabel('Number of Days From Neuron Appearance','FontSize',14);

% % for each cell, plot average change in PD for VR days against average
% % change for FF days
% ymin = -180;
% ymax = 180;
% figure;
% hold all;
% for unit = 1:length(fuck)
%     dpd = fuck(unit).dpd;
%     a = fuck(unit).adapt;
%     ff_inds = strcmpi(a,'ff');
%     vr_inds = strcmpi(a,'vr');
%     
%     if any(ff_inds) && any(vr_inds)
%         plot(mean(dpd(ff_inds))/sqrt(sum(ff_inds)),mean(dpd(vr_inds))/sqrt(sum(vr_inds)),'k+','LineWidth',2);
%     end
% end
% 
% plot([ymin ymax],[0 0],'k--','LineWidth',1);
% plot([0 0],[ymin ymax],'k--','LineWidth',1);
% axis('square');
% set(gca,'XLim',[ymin,ymax],'YLim',[ymin,ymax],'FontSize',14);
% xlabel('dPD with FF','FontSize',14);
% ylabel('dPD with VR','FontSize',14);
% title('Average Change','FontSize',14);
% 
% ymin = -10;
% ymax = 150;
% figure;
% hold all;
% for unit = 1:length(fuck)
%     dpd = fuck(unit).dpd;
%     a = fuck(unit).adapt;
%     ff_inds = strcmpi(a,'ff');
%     vr_inds = strcmpi(a,'vr');
%     
%     if ~isempty(ff_inds) && ~isempty(vr_inds)
%         plot(std(dpd(ff_inds))/sqrt(sum(ff_inds)),std(dpd(vr_inds))/sqrt(sum(vr_inds)),'k+','LineWidth',2);
%     end
% end
% 
% plot([ymin ymax],[0 0],'k--','LineWidth',1);
% plot([0 0],[ymin ymax],'k--','LineWidth',1);
% axis('square');
% set(gca,'XLim',[ymin,ymax],'YLim',[ymin,ymax],'FontSize',14);
% xlabel('dPD with FF','FontSize',14);
% ylabel('dPD with VR','FontSize',14);
% title('Standard Error','FontSize',14);
% 
% 
% %% Now plot dpd over days
% ymin = -180;
% ymax = 180;
% figure;
% hold all;
% for unit = 1:length(fuck)
%     % generate random color
%     c = rand(1,3);
%     
%     dpd = fuck(unit).dpd;
%     a = fuck(unit).adapt;
%     t = fuck(unit).task;
%     ff_inds = find(strcmpi(a,'ff'));
%     
%     temp = dpd(ff_inds);
%     tasks = fuck(unit).task;
%     tasks = tasks(ff_inds);
%     
%     temp2 = zeros(1,length(temp)-1);
%     for i = 2:length(temp)
%         temp2(i-1) = angleDiff(temp(i-1),temp(i),false,true);
%     end
%     
%     if length(temp) > 1
%         for i = 1:length(temp2)-1
%             plot([i,i+1],[temp2(i) temp2(i+1)],'o','LineWidth',2,'Color',c);
%             if strcmpi(tasks{i},tasks{i+1})
%                 plot([i,i+1],[temp2(i) temp2(i+1)],'-','LineWidth',2,'Color',c);
%             else
%                 plot([i,i+1],[temp2(i) temp2(i+1)],'--','LineWidth',2,'Color',c);
%             end
%         end
%     end
% end
% 
% set(gca,'YLim',[ymin,ymax],'FontSize',14);
% xlabel('Days','FontSize',14);
% ylabel('dPD Relative to Day 1','FontSize',14);
% title('FF PD Changes over Days for Same Neurons','FontSize',14);

