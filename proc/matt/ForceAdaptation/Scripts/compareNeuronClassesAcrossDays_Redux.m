% This file will compare how individual cells are classified across days to
% compare behavior under different experimental conditions

clear;
clc;

rootDir = 'C:\Users\Matt Perich\Desktop\lab\data\';
saveData = true;
rewriteFiles = false;

monkey = 'Mihili';
useArray = 'M1';

paramSetName = 'movement';
tuneMethod = 'regression';
tunePeriod = 'onpeak';
classifierBlocks = [1 4 7];

% paramSetName = 'glm';
% tuneMethod = 'glm';
% tunePeriod = 'file';
% classifierBlocks = [1 4 6];

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

for i = 1:length(goodDates)
    paramFiles{i} = fullfile(rootDir,monkey,goodDates{i},[goodDates{i} '_experiment_parameters.dat']);
end

% now do the tracking
if exist(fullfile(baseDir,'multiday_tracking.mat'),'file') || rewriteFiles
    load(fullfile(baseDir,'multiday_tracking.mat'))
else
    error('no file');
end

allClasses = [];
allAdapts = [];
allTasks = [];
allDPDs = [];

% loop over pairs of files
for iDay = 1:length(dateInds)-1
    compareDays = [iDay,iDay+1];
    % find which cells are consistent for all of the days
    comp = tracking.(useArray){iDay}.chan;
    
    % first remove neurons that had no match
    comp = comp(all(comp(:,compareDays) ~= 0,2),compareDays);
    
    getClasses = -1.*ones(size(comp,1),size(comp,2)+1);
    getClasses(:,1) = comp(:,1);
    
    getTasks = cell(size(comp));
    getAdapts = cell(size(comp));
    getDPDs = zeros(size(comp));
    for iComp = 1:length(compareDays)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load some of the experimental parameters
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        params = parseExpParams(paramFiles{compareDays(iComp)});
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
        
        
        
        for unit = 1:size(comp,1);
            e = floor(comp(unit,iComp));
            u = int32(10*rem(comp(unit,iComp),e));
            
            ind = sg(:,1)==e & sg(:,2) == u;
            
            % so, allClasses is like
            %   unit1: [elec, unit, day1, day2.....]
            %   unit2: [elec, .....
            
            % check if cell exists this day, in case I am not pre-filtering
            % and filter out untuned cells
            if sum(ind) > 0
                if all(istuned(ind,:))
                    getClasses(unit,iComp+1) = c(ind);
                end
            end
            
            ind = t_bl.sg(:,1)==e & t_bl.sg(:,2)==u;
            pd_bl = t_bl.pds(ind,1);
            ind = t_ad.sg(:,1)==e & t_ad.sg(:,2)==u;
            pd_ad = t_ad.pds(ind,1);
            
            getAdapts{unit,iComp} = adaptType;
            getTasks{unit,iComp} = taskType;
            getDPDs(unit,iComp) = angleDiff(pd_bl,pd_ad,true,true);
        end
    end
    
    % filter out untuned cells
    getAdapts(any(getClasses==-1,2),:) = [];
    getTasks(any(getClasses==-1,2),:) = [];
    getDPDs(any(getClasses==-1,2),:) = [];
    getClasses(any(getClasses==-1,2),:) = [];
    
    allClasses = [allClasses; getClasses(:,2:end)];
    allAdapts = [allAdapts; getAdapts];
    allTasks = [allTasks; getTasks];
    allDPDs = [allDPDs; getDPDs];
    
end

% % Remove "other" cells for now
% allAdapts(any(allClasses==5,2),:)=[];
% allTasks(any(allClasses==5,2),:)=[];
% allDPDs(any(allClasses==5,2),:) = [];
% allClasses(any(allClasses==5,2),:)=[];

% % Remove memory cells
% allAdapts(any(allClasses==4,2),:)=[];
% allTasks(any(allClasses==4,2),:)=[];
% allDPDs(any(allClasses==4,2),:)=[];
% allClasses(any(allClasses==4,2),:)=[];

% allAdapts(any(allClasses==3,2),:)=[];
% allTasks(any(allClasses==3,2),:)=[];
% allDPDs(any(allClasses==3,2),:)=[];
% allClasses(any(allClasses==3,2),:)=[];

% Non-adapting cells are 1,4
% Adapting cells are 2,3
%   Obviously this ignores the washout
% for temp, a 1 means it behaved the same way the next day
%   and a zero means it behaved differently
temp = zeros(size(allClasses,1),1);
for i = 1:size(allClasses,1)
    if allClasses(i,1)==2 || allClasses(i,1)==3 || allClasses(i,1)==5
        % cell changed during perturbation
        if allClasses(i,2)==2 || allClasses(i,2)==3 || allClasses(i,2)==5
            temp(i)=1;
        end
    elseif allClasses(i,1)==1 || allClasses(i,1)==4
        % cell did not change during perturbation
        if allClasses(i,2)==1 || allClasses(i,2)==4
            temp(i)=1;
        end
    end
end


% now group each classification based on adaptation type
%   find same condition vs different condition
inds_same = strcmpi(allAdapts(:,1),allAdapts(:,2));
inds_diff = ~strcmpi(allAdapts(:,1),allAdapts(:,2));

class_same = temp(inds_same);
class_diff = temp(inds_diff);

% now, for each plot percentage that are differently behaving
figure;
hold all;
bar([100*sum(class_same)/length(class_same); 100*sum(class_diff)/length(class_diff)],'BarWidth',1);
set(gca,'XTick',[1 2],'XTickLabel',{['Same (N=' num2str(length(class_same)) ')'],['Diff (N=' num2str(length(class_diff)) ')']},'YLim',[0 100],'FontSize',14);
ylabel('Percent','FontSize',14);
title('Percent of cells with same PD behavior day to day','FontSize',14);


% plot dPD for Day 1 against Day 2
%   First, for same perturbation
temp = allDPDs(inds_same,:);

ymin = -180;
ymax = 180;

% want to color based on perturbation
inds_ff = strcmpi(allAdapts,'ff');
inds_vr = strcmpi(allAdapts,'vr');

inds_ff = inds_ff(inds_same,1);
inds_vr = inds_vr(inds_same,1);

inds_adapt = allClasses(inds_same,:)==2 | allClasses(inds_same,:)==3 | allClasses(inds_same,:)==5;
inds_nonadapt = allClasses(inds_same,:)==1 | allClasses(inds_same,:)==4;


ff = temp(inds_ff,:);
vr = temp(inds_vr,:);

figure;
subplot1(1,2,'Gap',[0.05,0],'YTickL','Margin');
subplot1(1);
hold all;
plot(temp(inds_ff & all(inds_adapt,2),1).*(180/pi),temp(inds_ff & all(inds_adapt,2),2).*(180/pi),'+','LineWidth',2,'Color',ff_color);
plot(temp(inds_vr & all(inds_adapt,2),1).*(180/pi),temp(inds_vr & all(inds_adapt,2),2).*(180/pi),'+','LineWidth',2,'Color',vr_color);
plot(temp(inds_vr & all(inds_nonadapt,2),1).*(180/pi),temp(inds_vr & all(inds_nonadapt,2),2).*(180/pi),'.','LineWidth',2,'Color',vr_color);
legend({'Curl Field','Visual Rotation'},'FontSize',14);

plot(temp(inds_ff & sum(inds_adapt,2)==1,1).*(180/pi),temp(inds_ff & sum(inds_adapt,2)==1,2).*(180/pi),'d','LineWidth',2,'Color',ff_color);
plot(temp(inds_ff & all(inds_nonadapt,2),1).*(180/pi),temp(inds_ff & all(inds_nonadapt,2),2).*(180/pi),'.','LineWidth',2,'Color',ff_color);
plot(temp(inds_vr & sum(inds_adapt,2)==1,1).*(180/pi),temp(inds_vr & sum(inds_adapt,2)==1,2).*(180/pi),'d','LineWidth',2,'Color',vr_color);


plot([ymin ymax],[0 0],'k--','LineWidth',1);
plot([0 0],[ymin ymax],'k--','LineWidth',1);
set(gca,'XLim',[ymin,ymax],'YLim',[ymin,ymax],'FontSize',14);
xlabel('dPD on Day 1','FontSize',14);
ylabel('dPD on Day 2','FontSize',14);
title('Same Perturbation','FontSize',14);

axis('square');

% now for different perturbations
temp = allDPDs(inds_diff,:);
% color based on classification
inds_ff = strcmpi(allAdapts,'ff');
inds_vr = strcmpi(allAdapts,'vr');

inds_ff = inds_ff(inds_diff,:);
inds_vr = inds_vr(inds_diff,:);

inds_adapt = allClasses(inds_diff,:)==2 | allClasses(inds_diff,:)==3 | allClasses(inds_diff,:)==5;
inds_nonadapt = allClasses(inds_diff,:)==1 | allClasses(inds_diff,:)==4;

subplot1(2);
for unit = 1:size(temp,1)
    ff = find(inds_ff(unit,:));
    vr = find(inds_vr(unit,:));
    if inds_adapt(unit,1) && inds_adapt(unit,2)
        %purple
        useColor = [1 0 1];
    elseif inds_adapt(unit,ff)
        % blue
        useColor = 'b';
    elseif inds_adapt(unit,vr)
        % red
        useColor = 'r';
    else
        % black
        useColor = 'k';
    end
        
    
    plot(temp(unit,ff).*(180/pi),temp(unit,vr).*(180/pi),'+','LineWidth',2,'Color',useColor);
end
plot([ymin ymax],[0 0],'k--','LineWidth',1);
plot([0 0],[ymin ymax],'k--','LineWidth',1);
set(gca,'XLim',[ymin,ymax],'YLim',[ymin,ymax],'FontSize',14);
xlabel('dPD on FF day','FontSize',14);
ylabel('dPD on VR day','FontSize',14);
title('Different Perturbation','FontSize',14);
axis('square');




