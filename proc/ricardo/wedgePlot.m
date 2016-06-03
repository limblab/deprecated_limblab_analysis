%wedgePlot Plot a series of wedges representing confidence intervals.
% wedgePlot(avg, error) plots a set of polar wedges representing the
% confidence intervals described by avg +/- error.
%
% h = wedgePlot(...) returns the figure handle.
%
% This code was written by Joe Lancaster 2/22/2011

function h = wedgePlot(avg, error)
error = min(error,pi);
nargs = size(avg,2);

LB = zeros(1, nargs);
RB = zeros(1, nargs);

for i = 1:nargs
    LB(i) = avg(i) - error(i);
    RB(i) = avg(i) + error(i);
end

wedgeRad = zeros(nargs, 50);

for i = 1:nargs
    dist = abs(LB(i)-RB(i));
    if LB(i)~=RB(i)
        wedgeRad(i,:) = LB(i):dist/49:RB(i);
    else
        wedgeRad(i,:) = zeros(1,50);
    end
end

wedgeCart = cell(1,nargs);

for i = 1:nargs
    [currX, currY] = pol2cart(wedgeRad(i,:), ones(1,50));
    wedgeCart{i} = [currX; currY];
end

polar(0,0);

for i = 1:nargs
    patch([wedgeCart{i}(1,:) 0], [wedgeCart{i}(2,:) 0], 'b', 'FaceAlpha', 0.2,'LineStyle','none');
end
% set(findobj(gcf,'Type','Text'),'String','');
h = gca;


% [LBCartX, LBCartY] = pol2cart(LB, ones(1,nargs));
% [RBCartX, RBCartY] = pol2cart(RB, ones(1,nargs));
% 
% for i = 1:nargs
%     wedgeX(i,:) = LBCartX(i):
%     wedgeY(i,:) = [LBCartY(i), RBCartY(i), 0];
% end
% 
% polar(0,0);
% 
% for i = 1:nargs
%     patch(wedgeX(i,:), wedgeY(i,:), 'b', 'FaceAlpha', 0.5);
% end;
% 
% h = gcf;