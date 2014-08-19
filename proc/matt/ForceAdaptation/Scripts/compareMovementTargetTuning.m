% This file will compare how individual cells are classified across days to
% compare behavior under different experimental conditions

clear;
clc;

rootDir = 'C:\Users\Matt Perich\Desktop\lab\data\';
saveData = true;
rewriteFiles = false;

classifierBlocks = [1 4 6];

monkey = 'Mihili';
useArray = 'M1';
paramSetName = 'movement';
tuneMethod = 'regression';
tunePeriod = 'initial';

% paramSetName = 'glm';
% tuneMethod = 'glm';
% tunePeriod = 'full';

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
        dateInds = strcmpi(mihili_data(:,4),'co');
        dataDir = 'Z:\Mihili_12A3\Matt';
        goodDates = mihili_data(dateInds,2);
    otherwise
        error('Monkey not recognized');
end

baseDir = fullfile(rootDir,monkey);

for i = 1:length(goodDates)
    paramFiles{i} = fullfile(rootDir,monkey,goodDates{i},[goodDates{i} '_experiment_parameters.dat']);
end

moveClasses = [];
moveAdapts = [];
moveTasks = [];
moveDPDs = [];

% loop over files
for iDay = 1:length(goodDates)
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
    
    % get movement data
    paramSetName = 'movement';
    
    % load the class data
    classes = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_classes_' useDate '.mat']));
    tuning = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_tuning_' useDate '.mat']),tuneMethod);
    
    % get the classes for the current cell
    sg = classes.(tuneMethod).(tunePeriod).(useArray).sg;
    c = classes.(tuneMethod).(tunePeriod).(useArray).classes(:,1);
    istuned = classes.(tuneMethod).(tunePeriod).(useArray).istuned;
    
    t_bl = tuning.(tuneMethod).(tunePeriod).(useArray).tuning(classifierBlocks(1));
    t_ad = tuning.(tuneMethod).(tunePeriod).(useArray).tuning(classifierBlocks(2));
    
    getClasses = -1*ones(size(c));
    getAdapts = cell(size(c));
    getTasks = cell(size(c));
    getDPDs = zeros(size(c));
    for unit = 1:size(sg,1);
        if all(istuned(unit,:))
            getClasses(unit) = c(unit);
        end
        
        pd_bl = t_bl.pds(unit,1);
        pd_ad = t_ad.pds(unit,1);
        
        getAdapts{unit} = adaptType;
        getTasks{unit} = taskType;
        getDPDs(unit) = angleDiff(pd_bl,pd_ad,true,true);
    end
    
    
    % filter out untuned cells
%     getAdapts(any(getClasses==-1,2),:) = [];
%     getTasks(any(getClasses==-1,2),:) = [];
%     getDPDs(any(getClasses==-1,2),:) = [];
%     getClasses(any(getClasses==-1,2),:) = [];
    
    moveClasses = [moveClasses; getClasses];
    moveAdapts = [moveAdapts; getAdapts];
    moveTasks = [moveTasks; getTasks];
    moveDPDs = [moveDPDs; getDPDs];
end


targClasses = [];
targAdapts = [];
targTasks = [];
targDPDs = [];
for iDay = 1:length(goodDates)
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
    
    % get movement data
    paramSetName = 'target';
    
    % load the class data
    classes = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_classes_' useDate '.mat']));
    tuning = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_tuning_' useDate '.mat']),tuneMethod);
    
    % get the classes for the current cell
    sg = classes.(tuneMethod).(tunePeriod).(useArray).sg;
    c = classes.(tuneMethod).(tunePeriod).(useArray).classes(:,1);
    istuned = classes.(tuneMethod).(tunePeriod).(useArray).istuned;
    
    t_bl = tuning.(tuneMethod).(tunePeriod).(useArray).tuning(classifierBlocks(1));
    t_ad = tuning.(tuneMethod).(tunePeriod).(useArray).tuning(classifierBlocks(2));
    
    getClasses = -1*ones(size(c));
    getAdapts = cell(size(c));
    getTasks = cell(size(c));
    getDPDs = zeros(size(c));
    
    for unit = 1:size(c,1);
        if all(istuned(unit,:))
            getClasses(unit) = c(unit);
        end
        
        pd_bl = t_bl.pds(unit,1);
        pd_ad = t_ad.pds(unit,1);
        
        getAdapts{unit} = adaptType;
        getTasks{unit} = taskType;
        getDPDs(unit) = angleDiff(pd_bl,pd_ad,true,true);
    end
    
    
    % filter out untuned cells
%     getAdapts(any(getClasses==-1,2),:) = [];
%     getTasks(any(getClasses==-1,2),:) = [];
%     getDPDs(any(getClasses==-1,2),:) = [];
%     getClasses(any(getClasses==-1,2),:) = [];
    
    targClasses = [targClasses; getClasses];
    targAdapts = [targAdapts; getAdapts];
    targTasks = [targTasks; getTasks];
    targDPDs = [targDPDs; getDPDs];
end


% for cells that are significantly tuned in both, plot PD in target vs movement
bad_inds = targClasses==-1 | moveClasses==-1;
moveAdapts(bad_inds)=[];
moveTasks(bad_inds)=[];
moveDPDs(bad_inds) = [];
moveClasses(bad_inds)=[];

targAdapts(bad_inds)=[];
targTasks(bad_inds)=[];
targDPDs(bad_inds) = [];
targClasses(bad_inds)=[];


% plot dPD 
ymin = -90;
ymax = 90;

% want to color based on perturbation
inds_ff = strcmpi(moveAdapts,'ff');
inds_vr = strcmpi(moveAdapts,'vr');

figure;
hold all;
plot(moveDPDs(inds_ff).*(180/pi),targDPDs(inds_ff).*(180/pi),'b+','LineWidth',2);
plot(moveDPDs(inds_vr).*(180/pi),targDPDs(inds_vr).*(180/pi),'r+','LineWidth',2);

plot([ymin ymax],[0 0],'k--','LineWidth',1);
plot([0 0],[ymin ymax],'k--','LineWidth',1);
set(gca,'XLim',[ymin,ymax],'YLim',[ymin,ymax],'FontSize',14);
xlabel('dPD for movement','FontSize',14);
ylabel('dPD for target','FontSize',14);
title('Same Perturbation','FontSize',14);
legend({'Curl Field','Visual Rotation'},'FontSize',14);
axis('square');


% now, plot number of adapting cells by perturbation for target vs movement
figure;
hold all;
movetemp = moveClasses == 2 | moveClasses == 3 | moveClasses == 5;
targtemp = targClasses == 2 | targClasses == 3 | targClasses == 5;
bar([100*sum(movetemp(inds_ff))/sum(inds_ff), 100*sum(movetemp(inds_vr))/sum(inds_vr); 100*sum(targtemp(inds_ff))/sum(inds_ff), 100*sum(targtemp(inds_vr))/sum(inds_vr); ],'BarWidth',1);
axis('tight');
set(gca,'YLim',[0 100],'XTick',[1 2],'XTickLabel',{'Move','Targ'},'FontSize',14);
ylabel('Percent','FontSize',14);
title('Percent of adapting cells','FontSize',14);
legend({'Curl Field','Visual Rotation'},'FontSize',14);

figure;
hold all;
movetemp = moveClasses == 2 | moveClasses == 3 | moveClasses == 5 | targClasses == 2 | targClasses == 3 | targClasses == 5;
targtemp = ~movetemp;
bar([100*sum(movetemp(inds_ff))/sum(inds_ff), 100*sum(movetemp(inds_vr))/sum(inds_vr); 100*sum(targtemp(inds_ff))/sum(inds_ff), 100*sum(targtemp(inds_vr))/sum(inds_vr); ],'BarWidth',1);
axis('tight');
set(gca,'YLim',[0 100],'XTick',[1 2],'XTickLabel',{'Move','Targ'},'FontSize',14);
ylabel('Percent','FontSize',14);
title('Percent of adapting cells','FontSize',14);
legend({'Curl Field','Visual Rotation'},'FontSize',14);
