function params = setParamValues(params,varargin)
% Replace parameters with new values. First input must be parameter struct
% loaded from getParamDefaults, then each input after takes form of:
%       ...'field_name',value,...
%
% For organization, some parameters are in sub-structs (e.g 'tuning').
% However, each parameter in the end has a unique name, so the code will
% first look in the main struct, then in each sub-struct. However, this
% code assumes that there will only be one level of sub-struct.

% get all of the field names for params
fn = fieldnames(params);

% find out which ones are sub-structs
s = zeros(size(fn));
for i = 1:length(fn)
    s(i) = isstruct(params.(fn{i}));
end
s = find(s);

for i = 1:2:length(varargin)
    success = 0;
    if isfield(params,varargin{i})
        params.(varargin{i}) = varargin{i+1};
        success = 1;
    else % now look in the sub-structs
        for j = 1:length(s)
            if isfield(params.(fn{s(j)}),(varargin{i}))
                params.(fn{s(j)}).(varargin{i}) = varargin{i+1};
                success = 1;
                break;
            end
        end
    end
    
    if ~success
        warning(['Parameter ' varargin{i} ' not found, skipping.']);
    end
end