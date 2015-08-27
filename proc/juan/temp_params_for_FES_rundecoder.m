clear all, close all, clc

bmi_params = bmi_params_defaults;

params.neuron_decoder   = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/Decoders/20150320_Jango_WF_001_binned_Decoder.mat';
%params.neuron_decoder   = 'E:\Data-lab1\12A1-Jango\SavedFilters\Jango_WF_2014_05_29_HC_001_N2E_Decoder.mat';
params.output           = 'stimulator';
params.mode             = 'emg_only';
params.offline_data     = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/BinnedData/behavior plasticity/20150320_Jango_WF_001_binned.mat';
%params.offline_data     = 'E:\Data-lab1\12A1-Jango\BinnedData\20140529\Jango_WF_2014_05_29_HC_001.mat';
params.n_emgs           = 12;
params.online           = false; % true if you want to read from the monkey
params.display_plots    = false;
params.save_data        = true;
params.realtime         = true;

params.emg_decoder      = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/Decoders/20150320_Jango_WF_001_binned_Decoder_EMG2Force.mat';

run_decoder(params);