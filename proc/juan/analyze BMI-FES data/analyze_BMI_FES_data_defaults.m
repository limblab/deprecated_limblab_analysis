%
% Options for analyzing data from a BMI-FES experiment, using
% analyze_BMI-FES_data.m
%

function analysis_params = analyze_BMI_FES_data_defaults( varargin )

analysis_params_defaults = struct( ...
    'task',             'MG', ...
    'win_length',       60, ...
    'dir',              '/Users/juangallego/Documents/NeuroPlast/Data/Jango/CerebusData/BMI-FES/20160403', ...
    'file',             'Jango_WF_Mblock__20160403_152049_' ...
);


% fill default options missing from input argument
if nargin
    analysis_params      = varargin{1};
else
    analysis_params      = [];
end

all_param_names = fieldnames(analysis_params_defaults);
for i = 1:numel(all_param_names)
    if ~isfield(analysis_params,all_param_names(i))
        analysis_params.(all_param_names{i}) = analysis_params_defaults.(all_param_names{i});
    end
end