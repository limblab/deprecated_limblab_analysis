function vec = table_to_vector( tbl )
%TABLE_TO_VECTOR 
%  Converts the output of RASTER to a vector of spike counts
%  Inputs a cell array of spike times (one trial per cell) and outputs a
%  vector of counts.

vec = zeros(1, length(tbl));
for i = 1:length(tbl)
    vec(i) = length(tbl{i});
end
