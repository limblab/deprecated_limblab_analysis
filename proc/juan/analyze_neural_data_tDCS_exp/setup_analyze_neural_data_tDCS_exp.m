% This script allows to setup everything to analyze neural data during a
% tDCS/control experiment


clear all; close all; clc

% 'control' or 'tDCS_exp'
exp_type                = 'tDCS_exp';

% Folder with the data
% atp.exp_folder          = '/Volumes/data/Jango_12a1/CerebusData/TDCS/Neural_data_2015_07_25';
atp.exp_folder          = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/CerebusData/tDCS/Neural_data_2015_07_25';

% The data in each of the files will be split in windows of length
% 'atp.win_duration' (s)
atp.win_duration        = 300;


% Choose the neurons whose activity will be analyze
% atp.chosen_neurons      = 1:95;
atp.chosen_neurons      = [2:4, 9, 11, 18, 20, 22, 24, 26:30, 32, 40, 41, 43:47, 51:53, 55:64, 68, 71:76, 78, 80, 83:86, 88, 90:93 ];

% -------------------------------------------------------------------------
% Fill the fields with the files

switch exp_type
    case 'control'
        atp.baseline_files  = {};
    case 'tDCS_exp'
        % Get the baseline files
        atp.baseline_files  = uigetfile([atp.exp_folder '/*.nev'], 'Choose the Baseline files', ...
                                'Multiselect', 'on' );
        % Get the tDCS files
        atp.tDCS_files      =  uigetfile([atp.exp_folder '/*.nev'], 'Choose the tDCS files', 'Multiselect', 'on' );
        % Get the post-tDCS files
        atp.post_tDCS_files =  uigetfile([atp.exp_folder '/*.nev'], 'Choose the post-tDCS files', 'Multiselect', 'on' );
    otherwise
        error('''exp_type'' has to be ''ICMS_only'' or ''tDCS_exp''');
end

% Get current folder, to come back
current_folder          = pwd;
cd(atp.exp_folder);

% -------------------------------------------------------------------------
% Call the function that analyzes and plost the data

tDCS_results            = analyze_tDCS_neural_data( atp );


% Go back to where you were
cd(current_folder);