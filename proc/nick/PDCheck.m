function PDCheck(PDMatrix)

% PDCHECK plots the preferred directions (PDs) of the units represented in
% PDMATRIX in a compass plot and allows the user to exclude individual
% units from the plot by de-selecting check boxes.
%
% PDMATRIX should be in the form of a matrix [a, b] where each represents
% the following:
% 
%   a - unit number
%   b - data
%       1 - channel number
%       2 - unit number (for specific channel)
%       1 - 5th percentile of preferred direction (in radians)
%       2 - mean preferred direction (in radians)
%       3 - 95th percentile of preferred direction (in radians)
%       3 - PD vector magnitude

num_units = size(PDMatrix, 1); % calculate the total number of units
goodUnits = true(1, num_units); % create a logical array to represent units that will be plotted

fig_pos = [0, 0, 650 + floor((num_units-1)/20)*100, 600]; % set GUI dimensions

UI = figure('Position', fig_pos, ...
    'Name', 'PD Checker', ...
    'NumberTitle', 'off'); % initialize GUI

unit_check = zeros(1, num_units); % create array for handles to all check boxes

for x = 1:num_units
    unit_check(x) = uicontrol('Parent', UI, ... % place check boxes in GUI
        'Style', 'checkbox', ... % indicate control style to be checkbox
        'String', ['ch' num2str(PDMatrix(x,1)) ' u' num2str(PDMatrix(x,2))], ... % label each check box as 'chX uY' where X is the channel number and Y is the channel specific unit number
        'Position', [500 + floor((x-1)/20)*100, 525 - mod(x-1,20)*25, 100, 25], ... % position check boxes in a grid 20 high
        'Value', 1, ... % default all check boxes to 'checked'
        'Callback', @BoxCheck); % set all checks and unchecks to call function BoxCheck below
end

axes('Position', [50/fig_pos(3), 100/fig_pos(4), 400/fig_pos(3), 400/fig_pos(4)]); % set position of axes for PD plot

[PDcartX, PDcartY]=pol2cart(PDMatrix(goodUnits,4), PDMatrix(goodUnits,6)); % convert PD vectors from polar to cartesian coordinates for plotting
compass(PDcartX, PDcartY); % plot all PDs on a compass plot
title('Preferred Directions of Active Units');

    function BoxCheck(~,~) % called whenever a check box is either checked or unchecked
        unit = find(unit_check(:) == gcbo); % find the unit whose check box has been clicked
        val = get(unit_check(unit), 'Value'); % find whether the check box was checked or unchecked
        goodUnits(unit) = logical(val); % toggle the value for the unit from either 1 to 0 (unchecked) or 0 to 1 (checked)
        compass(PDcartX(goodUnits), PDcartY(goodUnits)); % plot PDs for all checked units on a compass plot
        title('Preferred Directions of Active Units');
    end

end