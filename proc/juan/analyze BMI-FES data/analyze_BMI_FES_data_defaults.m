%
% Options for analyzing data from a BMI-FES experiment, using
% analyze_BMI-FES_data.m
%

function params = analyze_BMI_FES_data_defaults( varargin )

params_defaults = struct( ...
    'win_length',       60, ...
    'dir',              '/Users/juangallego/Documents/NeuroPlast/Data/Jango/CerebusData/BMI-FES/20151218', ...
    'file',             'Jango_WF_MUblock__20151218_135709' ...
);


% fill default options missing from input argument
if nargin
    params      = varargin{1};
else
    params      = [];
end

all_param_names = fieldnames(params_defaults);
for i = 1:numel(all_param_names)
    if ~isfield(params,all_param_names(i))
        params.(all_param_names{i}) = params_defaults.(all_param_names{i});
    end
end