%
% Function to analyze and plot BMI-FES data
%

function results = analyze_BMI_FES_data( analysis_params )


file_name           = fullfile( analysis_params.dir, analysis_params.file );


% -------------------------------------------------------------------------
% load data

% load spike data
temp_file           = [file_name 'spikes.txt'];
temp_data           = tdfread(temp_file); % read tab-delimited file
temp_fieldname      = fieldnames(temp_data); % read automatically-generated field name to store data
spike_data          = temp_data.(temp_fieldname{1});

% load EMG preds
temp_file           = [file_name 'emgpreds.txt'];
temp_data           = tdfread(temp_file); % read tab-delimited file
temp_fieldname      = fieldnames(temp_data); % read automatically-generated field name to store data
emgpred_data        = temp_data.(temp_fieldname{1});

% load stimulator output
temp_file           = [file_name 'stim_out.txt'];
temp_data           = tdfread(temp_file); % read tab-delimited file
temp_fieldname      = fieldnames(temp_data); % read automatically-generated field name to store data
stim_data           = temp_data.(temp_fieldname{1});

clear temp_*;

% load BMI-FES params
params_file         = [file_name 'params.mat'];
params              = load(params_file);