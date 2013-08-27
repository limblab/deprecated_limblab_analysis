function out = compareCellTuning(pds,sg)
% compares tuning in different methods, epochs, files, days, etc
%   pds is cell array of pd arrays [pd ci_low ci_high]
%   sg is spike guide
%
% assumes for now that the same cells are in each struct

if ~iscell(pds) || length(pds) < 2
    error('Nothing to compare!')
end

% for each unit, compare pds and cis across three epochs

for unit = 1:size(pds{1},1)
    diffMat = zeros(length(dataFiles));
    for i = 1:length(dataFiles)
        pd1 = pds{i};
        ci1 = pd1(unit,2:3);
        for j = i+1:length(dataFiles)
            pd2 = pds{j};
            ci2 = pd2(unit,2:3);
            
            % do the confidence intervals overlap?
            overlap = range_intersection(ci1,ci2);
            
            % build matrix showing how they differ
            if isempty(overlap)
                diffMat(i,j) = 1;
            end
        end
    end
    out.(['elec' num2str(sg(unit,1))]).(['unit' num2str(sg(unit,2))]) = diffMat;
end
