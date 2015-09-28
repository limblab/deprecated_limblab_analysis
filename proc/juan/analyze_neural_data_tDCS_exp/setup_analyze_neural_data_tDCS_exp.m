% This script allows to setup everything to analyze neural data during a
% tDCS/control experiment


clear all; close all; clc

% 'control' or 'tDCS_exp'
exp_type                = 'tDCS_exp';

% Folder with the data
atp.exp_folder          = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/CerebusData/tDCS/Neural_data_2015_07_25';
% atp.exp_folder          = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/CerebusData/tDCS/Neural_data_2015_07_26';
% atp.exp_folder          = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/CerebusData/TDCS/Neural_data_2015_07_27';
% atp.exp_folder          = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/CerebusData/Other/2014_07_11_WFHC_4blocks_10min';


% --------------
% Define the parameters for binning the neural activity (and discarding
% some blocks), in atp.sad_params

% The data in each of the files will be split in windows of length
% 'atp.sad_params.win_duration' (s)
atp.sad_params.win_duration     = 300;

% Method for normalizing the firing rate
atp.sad_params.normalization    = 'Z-score';

% Analyze LFPs?
atp.sad_params.lfp              = true;

% The behavior signal that will be used to discard bins of neural activity
% ('pos', 'emg', 'none')
% atp.sad_params.behavior_data    = 'vel';
atp.sad_params.behavior_data    = 'word';

% And the threshold above which data will be discarded (cursor data will be
% rectified) 
atp.sad_params.thr_statistic    = 'none';
% atp.sad_params.thr_behavior     = 3;
% atp.sad_params.rectify_behavior = false;
atp.sad_params.word_hex         = 20;
atp.sad_params.win_word         = [-2000, 0];

% Choose the neurons whose activity will be analyze
% atp.sad_params.chosen_neurons   = 1:78;
atp.sad_params.chosen_neurons   = [2:4, 9, 11, 18, 20, 22, 24, 26:30, 32, 40, 41, 43:47, 51:53, 55:64, 68, 71:76, 78, 80, 83:86, 88, 90:93 ]; % for the 2015_07_25 dataset
% atp.sad_params.chosen_neurons   = [3:4, 9, 16, 27:30, 33, 39:41, 44, 46:47, 50:53, 56:57, 59, 61:63, 68, 71:76, 78, 83:85, 88:93]; % for the 2015_07_26 dataset
% atp.sad_params.chosen_neurons   = [1:6, 9, 11:12, 14:18, 20:22, 24:35, 37:53, 55:64]; % for the 2015_07_27 dataset

% Initialize the rest of the parameters to the defaults
atp.sad_params                  = split_and_analyze_data_defaults( atp.sad_params );

% -------------------------------------------------------------------------
% Fill the fields with the files

% Get current folder, to come back
current_folder          = pwd;
cd(atp.exp_folder);

switch exp_type
    case 'control'
        atp.baseline_files  = {};
    case 'tDCS_exp'
        % Get the baseline files
        atp.baseline_files  = uigetfile({'*.mat;*.nev','Neural data (*.mat, *.nev)'},...
                                'Choose baseline files','Multiselect','on');
        % Get the tDCS files
        atp.tDCS_files      = uigetfile({'*.mat;*.nev','Neural data (*.mat, *.nev)'},...
                                'Choose tDCS files','Multiselect','on');
        % Get the post-tDCS files
        atp.post_tDCS_files =  uigetfile({'*.mat;*.nev','Neural data (*.mat, *.nev)'},...
                                'Choose post-tDCS files','Multiselect','on');
    otherwise
        error('''exp_type'' has to be ''ICMS_only'' or ''tDCS_exp''');
end


% -------------------------------------------------------------------------
% Call the function that analyzes and plost the data

tDCS_results            = analyze_tDCS_neural_data( atp );



% Save results
% ToDo


% Go back to where you were
cd(current_folder);