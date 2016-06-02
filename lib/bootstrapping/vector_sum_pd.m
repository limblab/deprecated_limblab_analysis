function result = vector_sum_pd(data)
% VECTOR_SUM_PD - Calculates asigns a vector to each reach direction scaled
%                 by average firing rate in that direction and finds the PD
%                 from the sum of those vectors.
%
% [PD,MAG] = VECTOR_SUM_PD(DATA) Returns the PD (prefered direction) and
%   MAG (magnitude of PD vector) for the cell given in data.  DATA expects
%   a cell array where each cell represents a reach direction and contains
%   an array of firing rates for each reach in that direction.

if iscell(data)
    nDirs = length(data);
else
    nDirs = size(data,2);
end
dirs = (0:nDirs-1) * 2 * pi / nDirs;

avgRates = zeros(1,nDirs);
if iscell(data)
    for i = 1:nDirs
        avgRates(i) = mean(data{i});
    end
else
     avgRates = mean(data);
end

% get x and y components of the vectors for each reach direction
x = avgRates .* cos(dirs);
y = avgRates .* sin(dirs);

% find mag and pd
PDVect = [sum(x) sum(y)]; 

mag = sqrt(PDVect(1)*PDVect(1) + PDVect(2)*PDVect(2));
pd = atan2(PDVect(2), PDVect(1));

result = [pd mag];