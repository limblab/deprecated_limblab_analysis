%% Make plot showing CO traces
function html = report_CO(html,p)
genFigPath = p.genFigPath;
epochs = p.epochs;
imgWidth = p.imgWidth;

html = strcat(html,['<div id="CO"><h2>Center Out Plots</h2>' ...
    'average of first two (red) and last two (blue) traces to each target... first target shown in green' ...
    '<table style="text-align:center"><tr> <td>&nbsp;</td>']);

for iEpoch = 1:length(epochs)
    html = strcat(html,['<td>' epochs{iEpoch} '</td>']);
end

html = strcat(html,'</tr><tr><td>First/Last</td>');

for iEpoch = 1:length(epochs)
    html = strcat(html,['<td><img src="' genFigPath '\' epochs{iEpoch} '_CO_trajectories_first_and_last.png" width="' num2str(imgWidth+200) '"></td>']);
end

html = strcat(html,'</tr><tr><td>All Movements</td>');

for iEpoch = 1:length(epochs)
    html = strcat(html,['<td><img src="' genFigPath '\' epochs{iEpoch} '_CO_trajectories_all.png" width="' num2str(imgWidth+200) '"></td>']);
end

html = strcat(html,'</tr></table><br><a href="#header">back to top</a></div><hr>');