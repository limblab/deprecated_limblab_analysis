% This file will compare how individual cells are classified across days to
% compare behavior under different experimental conditions

clear;
clc;

rootDir = 'C:\Users\Matt Perich\Desktop\lab\data\';
saveData = true;
rewriteFiles = true;

monkey = 'Mihili';
useArray = 'M1';
paramSetName = 'movement';
tunePeriod = 'onpeak';
tuneMethod = 'regression';

% paramSetName = 'glm';
% tunePeriod = 'file';
% tuneMethod = 'glm';

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
if ~exist(fullfile(baseDir,'multiday_tracking.mat'),'file') || rewriteFiles
    tracking = trackNeuronsAcrossDays(paramFiles,baseDir,{'wf'},saveData);
else
    load(fullfile(baseDir,'multiday_tracking.mat'))
end
% 
% compareDays = 10:11;
% % find which cells are consistent for all of the days
% comp = tracking.(useArray){compareDays(1)}.chan;
% 
% % first remove neurons that had no match
% comp = comp(all(comp(:,compareDays) ~= 0,2),compareDays);
% 
% allClasses = -1.*ones(size(comp,1),size(comp,2)+1);
% allClasses(:,1) = comp(:,1);
% 
% % get cell classification for each day
% for iDay = 1:length(compareDays)
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Load some of the experimental parameters
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     params = parseExpParams(paramFiles{compareDays(iDay)});
%     useDate = params.date{1};
%     arrays = params.arrays;
%     monkey = params.monkey{1};
%     taskType = params.task{1};
%     adaptType = params.adaptation_type{1};
%     clear params;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     dataPath = fullfile(baseDir,useDate);
%     
%     % load the class data
%     classes = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_classes_' useDate '.mat']));
%     
%     % get the classes for the current cell
%     sg = classes.(tuneMethod).(tunePeriod).(useArray).sg;
%     c = classes.(tuneMethod).(tunePeriod).(useArray).classes;
%     istuned = classes.(tuneMethod).(tunePeriod).(useArray).istuned;
%     
%     for unit = 1:size(comp,1);
%         e = floor(comp(unit,iDay));
%         u = int32(10*rem(comp(unit,iDay),e));
%         
%         ind = sg(:,1)==e & sg(:,2) == u;
%         
%         % so, allClasses is like
%         %   unit1: [elec, unit, day1, day2.....]
%         %   unit2: [elec, .....
%         
%         % check if cell exists this day, in case I am not pre-filtering
%         % filter out untuned cells
%         
%         % quick check to make sure the cell exists
%         %   LOOK INTO WHY THIS IS NECESSARY OCCASIONALLY
%         if sum(ind) > 0
%             if all(istuned(ind,:))
%                 allClasses(unit,iDay+1) = c(ind);
%             end
%         end
%     end
% end
% 
% % filter out untuned cells
% allClasses(any(allClasses==-1,2),:) = [];
% 
% % look for types of cells
% %   NOTE: right now this is exclusively for two files, first is FF other VR
% %   1) same function in both perturbations (diff = 0)
% %   2) non-adapting in FF and adapting in VR (diff > 0)
% %   3) adapting in FF and non-adapting in VR (diff < 0)
% classDiff = diff(allClasses(:,2:end),[],2)~=0;
% celltypes = zeros(size(classDiff));
% inds = classDiff==0;
% celltypes(classDiff == 0) = 1;
% celltypes(classDiff > 0) = 2;
% celltypes(classDiff < 0) = 3;
% 
% % how many of each type?
% numSame = sum(celltypes==1);
% numKin = sum(celltypes==2);
% numDyn = sum(celltypes==3);
% 
% 
% colors = {'k','r','b'};
% % now do some kind of plotting
% figure;
% hold all;
% for unit = 1:size(classDiff,1)
%     useColor = colors{celltypes(unit)};
%     plot(1:size(allClasses,2)-1,allClasses(unit,2:end),useColor);
%     plot(1:size(allClasses,2)-1,allClasses(unit,2:end),[useColor 'd']);
% end
% axis([0 size(allClasses,2) -1 5]);
% 
% 
% 
% % Non-adapting cells are 1,4
% % Adapting cells are 2,3
% %   Obviously this ignores the washout
% 
% temp = zeros(size(allClasses,1),1);
% for i = 1:size(allClasses,1)
%     if allClasses(i,2)==2 || allClasses(i,2)==3 || allClasses(i,2)==5
%         % cell changed during perturbation
%         if allClasses(i,3)==2 || allClasses(i,3)==3 || allClasses(i,3)==5
%             temp(i)=1;
%         end
%     elseif allClasses(i,2)==1 || allClasses(i,2)==4
%         % cell did not change during perturbation
%         if allClasses(i,3)==1 || allClasses(i,3)==4
%             temp(i)=1;
%         end
%     end
% end
% 
% 
