% This file will compare how individual cells are classified across days to
% compare behavior under different experimental conditions

clear;
clc;

tunePeriod = 'peak';
tuneMethod = 'regression';
useArray = 'PMd';

% list of parameter files for days to use
paramFiles = {'Z:\MrT_9I4\Matt\ProcessedData\2013-09-04\2013-09-04_experiment_parameters.dat', ...
    'Z:\MrT_9I4\Matt\ProcessedData\2013-09-06\2013-09-06_experiment_parameters.dat'};

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
