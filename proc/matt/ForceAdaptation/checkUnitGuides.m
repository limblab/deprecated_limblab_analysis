function badUnits = checkUnitGuides(varargin)
% CHECKUNITS Checks to ensure units are consistent across all inputs. Unit
% IDs are expected to be defined by the first column.
%
% if varargin is a single cell, assumes it is a cell array of guides

if iscell(varargin{1})
    varargin = varargin{1};
end

badUnits = [];
for i = 2:length(varargin)

    temp1 = varargin{i-1};
    temp2 = varargin{i}; 

    % If either is empty they can't really be compared...
    if ~isempty(temp1) && ~isempty(temp2)
        badUnits = [badUnits; setxor(temp1,temp2,'rows')];
    end
end

badUnits = unique(badUnits,'rows');