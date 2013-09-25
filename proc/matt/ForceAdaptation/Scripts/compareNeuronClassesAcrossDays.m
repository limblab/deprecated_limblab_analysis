% This file will compare how individual cells are classified across days to
% compare behavior under different experimental conditions

clear;
clc;

% useDates = {'2013-08-22','2013-09-04'};
useDates = {'2013-08-22','2013-09-04'};

tunePeriod = 'peak';
tuneMethod = 'regression';
useArray = 'PMd';

baseDir = 'Z:\MrT_9I4\Matt\ProcessedData\';

paramFiles = cell(1,length(useDates));
for iDay = 1:length(useDates)
    paramFiles{iDay} = fullfile(baseDir,useDates{iDay},[useDates{iDay} '_experiment_parameters.dat']);
end

tracking = trackNeuronsAcrossDays(paramFiles,false);

% find which cells are consistent for all of the days
comp = tracking.(useArray){1}.chan;

% first remove neurons that had no match
comp = comp(all(comp ~= 0,2),:);

allClasses = zeros(size(comp,1),size(comp,2)+1);
allClasses(:,1) = comp(:,1);

% get cell classification for each day
for iDay = 1:size(comp,2)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load some of the experimental parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    params = parseExpParams(paramFiles{iDay});
    baseDir = params.out_dir{1};
    useDate = params.date{1};
    arrays = params.arrays;
    monkey = params.monkey{1};
    taskType = params.task{1};
    adaptType = params.adaptation_type{1};
    clear params;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dataPath = fullfile(baseDir,useDate);
    
    % load the class data
    load(fullfile(dataPath,[taskType '_' adaptType '_classes_' useDate '.mat']));
    
    % get the classes for the current cell
    sg = classes.(useArray).(tuneMethod).(tunePeriod).unit_guide;
    c = classes.(useArray).(tuneMethod).(tunePeriod).classes;
    
    for unit = 1:size(comp,1);
        e = floor(comp(unit,iDay));
        u = int32(10*rem(comp(unit,iDay),e));
        
        ind = sg(:,1)==e & sg(:,2) == u;
        
        % so, allClasses is like
        %   unit1: [elec, unit, day1, day2.....]
        %   unit2: [elec, .....
        allClasses(unit,iDay+1) = c(ind);
        
    end
end

% filter out untuned cells
allClasses(any(allClasses==-1,2),:) = [];

% look for types of cells
%   NOTE: right now this is exclusively for two files, first is FF other VR
%   1) same function in both perturbations (diff = 0)
%   2) non-adapting in FF and adapting in VR (diff > 0)
%   3) adapting in FF and non-adapting in VR (diff < 0)
classDiff = diff(allClasses(:,2:end),[],2)~=0;
celltypes = zeros(size(classDiff));
inds = classDiff==0;
celltypes(classDiff == 0) = 1;
celltypes(classDiff > 0) = 2;
celltypes(classDiff < 0) = 3;

% how many of each type?
numSame = sum(celltypes==1);
numKin = sum(celltypes==2);
numDyn = sum(celltypes==3);


colors = {'k','r','b'};
% now do some kind of plotting
figure;
hold all;
for unit = 1:size(classDiff,1)
    useColor = colors{celltypes(unit)};
    plot([1 2],allClasses(unit,2:3),useColor);
    plot([1 2],allClasses(unit,2:3),[useColor 'd']);
end
axis([0 3 -1 4]);
