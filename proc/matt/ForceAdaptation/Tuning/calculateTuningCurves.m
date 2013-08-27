function data = calculateTuningCurves(expParamFile, tuningPeriods, tuningMethod)
%% get parameters from file
params = parseExpParams(expParamFile);
baseDir = params.outDir{1};
useDate = params.useDate{1};
taskType = params.taskType{1};
adaptType = params.adaptType{1};
epochs = params.epochs;
clear params

if ~iscell(tuningMethod)
    tuningMethod = {tuningMethod};
end

%% 
dataPath = fullfile(baseDir,useDate);

for iEpoch = 1:length(epochs)
    getFile = fullfile(dataPath,[taskType '_' adaptType '_' epochs{iEpoch} '_' useDate '.mat']);
    load(getFile);
    
    % first try with regression
    data = fitTuningCurves(data,tuningPeriods,tuningMethod);
    
    % save the new file with tuning info
    save(fullfile(dataPath,[taskType '_' adaptType '_' epochs{iEpoch} '_' useDate '.mat']),'data');
end