LearnAdaptAnalysisList
% This script is just so I have an idea of an order for processing my data
% and making figures


% 1. Copy files to the server from Lacie
% 2. Use convertCerebusToBDF(dataPath,convertFolders,0) to convert your
% cerebus files to BDF. Go into the script and make sure the dataPath,
% convertFolders dirCB, dirBDF

% Compute task metrics
[T2TfirstStruct T2TlastStruct DialInTimeStruct TargetEntriesStruct TrialsStruct] = ComputeTaskTimeMetrics(out_struct);