%
% Parameters for paired intracortical-muscle stimulation using
% paired_stimulation() 
%
%       function paired_stim_params = paired_stimulation_s88_default()
%
%       paired_stim_params      : structure with fields
%           ISI                 : inter-stimulus interval. + = cortex first (ms)
%           cortical_elec       : cortical electrode for ICMS
%           muscle_elecs        : paired of muscle electrodes for stimulation 
%           stim_freq           : frequency at which the pairs of stimuli are delivered (Hz)
%           nbr_stimuli         : nbr of paired stimuli
%           pre_stim_win        : time (ms), before the delivery of a stimulus, during which force will be recorded and plotted
%           post_stim_win       : time (ms), after the delivery of a stimulus, during which force will be recorded and plotted
%           record_force_yn     : (=1) record force; (=0) don't
%           save_data_yn        : save Matlab and cerebus data
%           data_dir            : directory where the data will be saved
%           monkey              : monkey name, to generate the filename



function paired_stim_params = paired_stimulation_s88_default()

% TODO: MAY NOT BE CORRECT

paired_stim_params  = struct(...
    'ISI',                      1, ...
    'cortical_elec',            1, ...
    'muscle_elecs',             [1 2], ... 
    'stim_freq',                1, ...
    'nbr_stimuli',              100, ...
    'pre_stim_win',             100, ...
    'post_stim_win',            500, ...
    'record_force_yn',          1, ...
    'save_data_yn',             1, ...
    'data_dir',                 'c:\Users\limblab\Desktop\temp code', ...
    'monkey',                   'Jango');