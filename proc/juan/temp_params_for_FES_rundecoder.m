clear all, close all

bmi_params = bmi_params_defaults;

params.neuron_decoder   = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/Decoders/20150320_Jango_WF_001_binned_Decoder.mat';
params.output           = 'stimulator';
params.mode             = 'emg_only';
params.offline_data     = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/BinnedData/behavior plasticity/20150320_Jango_WF_001_binned.mat';
params.n_emgs           = 12;
params.online           = false;
params.display_plots    = false;
params.save_data        = false;

params.emg_decoder      = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/Decoders/20150320_Jango_WF_001_binned_Decoder_EMG2Force.mat';

run_decoder(params);