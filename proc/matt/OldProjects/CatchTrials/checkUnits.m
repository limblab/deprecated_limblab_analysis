function badUnits = checkUnits(varargin)
% CHECKUNITS Checks to ensure units are consistent across all inputs. Unit
% IDs are expected to be defined by the first column. This currently only
% works with thresholded files and not sorted files

badUnits = [];
for i = 2:length(varargin)

    temp1 = varargin{i-1};
    temp2 = varargin{i}; 

    % If either is empty they can't really be compared...
    if ~isempty(temp1) && ~isempty(temp2)
        badUnits = [badUnits setxor(temp1(:,1),temp2(:,1))];
    end
end

badUnits = unique(badUnits);