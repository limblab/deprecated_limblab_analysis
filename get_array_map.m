function grid = get_array_map(units, map)
% GET_ARRAY_MAP     10x10 logical map of the array
%       GRID = GET_ARRAY_MAP(UNITS, MAP) returns a 10x10 element array
%       containing logical values that are true iff that array position
%       appears in UNITS. MAP takes a 10x10 array containing the channel
%       numbers of the various electrodes
%

grid = zeros(size(map));

for i = 1:length(units);
    grid = grid + (units(i) == map);
end
