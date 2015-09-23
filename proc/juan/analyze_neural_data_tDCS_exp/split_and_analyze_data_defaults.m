%
% function sad_params = split_and_analyze_data_defaults(varargin)
%
% 'sad_params' structure with fields:
%       'win_duration'      : duration of the window for computing firing
%                               rates (s).
%       'lfp'               : also analyze LFPs. The code will load
%                               different files that contain re-arranged
%                               LFP data 
%       'behavior_data'     : signal used for choosing/discarding bins of
%                               neural activity based on the monkey's
%                               behavior ('emg','pos','vel','none','word').
%                               When set to 'emg' or 'pos', bins of data
%                               are discarded if the chosen variables goes
%                               above a threshold specified with
%                               'thr_statistic' and 'thr_behavior.' If set
%                               to 'word', the code will use data in the
%                               time window 'win_word' around the word
%                               chosen in 'word_hex'.
%       'rectify_behavior'  : boolean that specifies whether the behavior
%                               data ('pos','vel') will be rectified.
%       'thr_statistic'     : statistic used for the threshold for
%                               discarding bins ('none', std'). 'none': the
%                               value in 'thr_behavior' is used as
%                               threshold; 'std': the threshold will be the
%                               SD of the signal times 'thr_behavior' over
%                               the mean. 
%       'thr_behavior'      : if 'thr_statistic' is 'std', this value is
%                               the "gain" for the SD. If 'thr_statistic'
%                               is 'none', this value is the value of the
%                               threshold.
%       'word_hex'          : the word for analyzing the data based on the
%                               task, in hexadecimal (see Words.m).
%       'win_word'          : window around each word that will be
%                               considered for the analysis (ms). Negative
%                               values mean before the word.
%       'chosen_neurons'    : neurons (id number) which activity will be
%                               analyzed.
%       'normalization'     : how the firing rate will be normalized.
%                               'mean_only': by dividing the firing rate by
%                               the mean firing rate during the whole
%                               baseline block. 'Z-score': using the mean
%                               and SD during the whole baseline block.


function sad_params = split_and_analyze_data_defaults(varargin)

sad_params_defaults     = struct( ...
    'win_duration',         300, ...
    'lfp',                  true, ...
    'behavior_data',        'pos', ...
    'rectify_behavior',     true, ...
    'thr_statistic',        'none', ...
    'thr_behavior',         10, ...
    'word_hex',             20, ...
    'win_word',             [-2000, 0], ...
    'chosen_neurons',       1:96, ...
    'normalization',        'Z-score');


% fill the default values in the fields of sad_params that are missing in
% the (optional) input argument 
if nargin
    sad_params          = varargin{1};
else
    sad_params          = [];
end

all_param_names         = fieldnames(sad_params_defaults);
for i = 1:numel(all_param_names)
    if ~isfield(sad_params,all_param_names(i))
        sad_params.(all_param_names{i}) = sad_params_defaults.(all_param_names{i});
    end
end