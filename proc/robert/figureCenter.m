function varargout=figureCenter(figHin)

% syntax figHout=figureCenter(figHin)
% 
% brings up a new figure and places it in the center of the screen,
% regardless of what monitor is connected.  Does checks to make sure the
% top isn't above the top edge of the screen.
%
%           INPUTS
%                       figHin      - (optional) handle to the figure to
%                                     center.  Can use gcf.  If omitted, a
%                                     new figure will be created.
%           OUTPUTS
%                       figH        - (optional) handle to the figure that 
%                                     has been centered (or created).


if nargin==0        % if figure does not exist, generate
    figHin=figure;
end
if nargout>0        % if asked for the handle, pass through
    varargout{1}=figHin;
end

screenDims=get(0,'ScreenSize');
currPos=get(figHin,'Position');

newPos=[screenDims(3)/2-currPos(3)/2, ...
    screenDims(4)/2-currPos(4)/2, currPos(3:4)];
if sum(newPos([2 4])) > screenDims(4)
    % if the figure is above the top of the screen, set it down 
    % so that it's not.  The -100 is a buffer for the menus, etc of the
    % window.
    newPos(2)=screenDims(4)-newPos(4)-100;
end
set(figHin,'Position',newPos)



