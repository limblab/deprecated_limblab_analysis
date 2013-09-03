function classes = findMemoryCells(expParamFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(expParamFile);
baseDir = params.out_dir{1};
useDate = params.date{1};
taskType = params.task{1};
adaptType = params.adaptation_type{1};
clear params

dataPath = fullfile(baseDir,useDate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(dataPath, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
tuningPeriods = params.tuning_periods;
tuningMethods = params.tuning_methods;
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

saveFile = fullfile(dataPath,[taskType '_' adaptType '_classes_' useDate '.mat']);

disp('Loading data to classify cells...')
load(fullfile(dataPath,[taskType '_' adaptType '_BL_' useDate '.mat']));
arrays = data.meta.arrays;
blt = tuning;
load(fullfile(dataPath,[taskType '_' adaptType '_AD_' useDate '.mat']));
adt = tuning;
load(fullfile(dataPath,[taskType '_' adaptType '_WO_' useDate '.mat']));
wot = tuning;
clear data tuning;

for iArray = 1:length(arrays)
    useArray = arrays{iArray};
    for iMethod = 1:length(tuningMethods)
        if strcmpi(tuningMethods{iMethod},'nonparametric')
            warning('Skipping nonparametric... not supported');
        else
            for iTune = 1:length(tuningPeriods)
                
                [cellClass,sg] = classifyCells(blt,adt,wot,useArray,tuningPeriods{iTune},tuningMethods{iMethod});
                
                % get cells that are significantly tuned in all epochs
                tunedCells = find(cellClass(:,1)~=-1);
                disp(['There are ' num2str(length(tunedCells)) ' cells tuned in all epochs...']);
                
                classes.(useArray).(tuningMethods{iMethod}).(tuningPeriods{iTune}).classes = cellClass;
                classes.(useArray).(tuningMethods{iMethod}).(tuningPeriods{iTune}).unit_guide = sg;
                classes.(useArray).(tuningMethods{iMethod}).(tuningPeriods{iTune}).tuned_cells = tunedCells;
            end
        end
    end
end

% save the new file with classification info
disp(['Saving data to ' saveFile]);
save(saveFile,'classes');

