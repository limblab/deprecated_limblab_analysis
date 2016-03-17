function h = plotLM(varargin)
% Calls to plot.m with different default linewidth,tickmarks,boxes
% properties, etc. to make plots prettier and standardized for Miller lab
% 

h = plot(varargin{:});

% set ticks outside, no box and heavier lineweigth
set(gca,'Box','Off',...
        'FontName','Arial','FontSize',16,'FontWeight','Bold',...
        'TickDir','Out','LineWidth',2);

% change line colors to the jet colormap
lines     = get(gca,'Children');
lines_col = jet(numel(lines));
for i = 1:numel(lines)
    set(lines(i),'Color',lines_col(i,:),...
                'LineWidth',2,...
                'MarkerEdgeColor',lines_col(i,:),...
                'MarkerFaceColor',lines_col(i,:) ...
                );
end