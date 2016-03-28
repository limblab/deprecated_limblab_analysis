%
% Plot targets of a current behavior
%
%   function [nbr_targets, target_coord] = plot_targets( binned_data )
%
% Inputs:
%   binned_data         : binned_data struct
%
% Ouputs:
%   nbr_targets         : number of targets
%   target_coord        : target coordinates (ULx ULy LRx LRy) for each
%                           target
%
%

function [nbr_targets, target_coord] = plot_targets( binned_data, varargin )

if nargin == 2
    label               = varargin{1};
else 
    label               = '';
end

% find targets
targets                 = unique(binned_data.trialtable(:,2:5),'rows');
nbr_targets             = size(targets,1);


% find bottom left corner (X and Y), width and height for rectangle command
rect_coord              = zeros(nbr_targets,4);
rect_coord(:,1)         = targets(:,1);
rect_coord(:,2)         = min(targets(:,2),targets(:,4));
rect_coord(:,3)         = abs(targets(:,1)-targets(:,3));
rect_coord(:,4)         = abs(targets(:,2)-targets(:,4));

% get rid of targets with width or height zero, if there's any
rect_coord(rect_coord(:,3) == 0,:) = [];
rect_coord(rect_coord(:,4) == 0,:) = [];

% return variables
nbr_targets             = size(rect_coord,1);
target_coord            = rect_coord;


% plot
colors                  = parula(nbr_targets);
max_coord               = max(max(abs(rect_coord)));

figure
hold on
for tg = 1:nbr_targets
    rectangle('Position',rect_coord(tg,:),'Edgecolor',colors(tg,:),...
        'Facecolor',colors(tg,:))    
end
rectangle('Position',[-1,-1,2,2],'Edgecolor','k');
xlim([-max_coord-3, max_coord+3])
ylim([-max_coord-3, max_coord+3])
set(gca,'TickDir','out'),set(gca,'FontSize',14)
title(['target positions ' label],'FontSize',14);