%process batch of psychometric data:

function_name='quickscript_function_looped';
input_data.matchstring='Chips';
input_data.labnum=6;
input_data.stimcodes=[0 1 2 3];
input_data.num_stim_cases=4;
input_data.currents=[5 10 15 20];


%% chips
%48deg:
folderpath='E:\local processing\chips\experiment_20150520-25_BD_48degPD';
run_data_processing(function_name,folderpath,input_data)
%% 216deg:
folderpath='E:\local processing\chips\experiment_20150528-0601_BD_216degPD';
run_data_processing(function_name,folderpath,input_data)
%% 79deg:
folderpath='E:\local processing\chips\experiment_20150604-07_BD_79degPD';
run_data_processing(function_name,folderpath,input_data)
%% 66deg:
folderpath='E:\local processing\chips\experiment_20150609-10_BD_66degPD';
% run_data_processing(function_name,folderpath,input_data)
%% 224deg:
folderpath='E:\local processing\chips\experiment_20150612-14_BD_224degPD';
run_data_processing(function_name,folderpath,input_data)
%% 316deg:
folderpath='E:\local processing\chips\experiment_20150616_BD_316degPD';
run_data_processing(function_name,folderpath,input_data)
%% 192deg:
folderpath='E:\local processing\chips\experiment_20150625_BD_192degPD';
run_data_processing(function_name,folderpath,input_data)


%% kramer
% 210deg:
folderpath='E:\local processing\kramer\experiment_20130228-0506_BD_210degstim';
run_data_processing(function_name,folderpath,input_data)
%% 70deg:
folderpath='E:\local processing\kramer\experiment_20130305_0322_BD_70degstim';
run_data_processing(function_name,folderpath,input_data)
%% 270deg:
folderpath='E:\local processing\kramer\experiment_20130319-23_270degstim';
run_data_processing(function_name,folderpath,input_data)
%% 20deg:
folderpath='E:\local processing\kramer\experiment_20130326_BD_20degstim';
run_data_processing(function_name,folderpath,input_data)
%% 352deg:
folderpath='E:\local processing\kramer\experiment_20130606-07_352degstim';
run_data_processing(function_name,folderpath,input_data)
%% 211deg:
folderpath='E:\local processing\kramer\experiment_20130627-0702_BD_211degstim';
run_data_processing(function_name,folderpath,input_data)
%% 140deg:
folderpath='E:\local processing\kramer\experiment_20130712-14_BD_140degstim';
run_data_processing(function_name,folderpath,input_data)
