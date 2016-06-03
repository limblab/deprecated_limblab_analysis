function [] = plotTuningCurve(firingRates,errorBars,directions)
% PLOTTUNINGCURVE -
%
% INPUT:
%
% OUTPUT:
%
% Created by John W. Miller
% 2014-08-26
%
%%

n_blocks = size(firingRates,2);

figure
hold on
% colors = colormap(autumn);
colors    = [1 0 0; 0 0 1; 1 .5 0];
leg_entries = [];

for iBlock = 1:n_blocks
    color  = colors(iBlock,:);
        % Tuning curve
    plot(directions, firingRates(:,iBlock));
    leg_entries = [leg_entries; '-------' ; sprintf('Block %d',iBlock)];
        % Error bars
    X = [directions' fliplr(directions')];
    Y = [(firingRates(:,iBlock)'+errorBars(:,iBlock)'), ...
        fliplr(firingRates(:,iBlock)'-errorBars(:,iBlock)')];
    
    patch(X,Y,color,'FaceAlpha',0.25,'EdgeAlpha',0);
    
end
legend(leg_entries)

% Figure parameters
xlim([min(directions) max(directions)])










end
