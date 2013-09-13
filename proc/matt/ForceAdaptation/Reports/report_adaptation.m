%% Make plot showing adaptation/deadaptation over time
html = strcat(html,['<div id="adapt"><h2>Adaptation</h2>' ...
    '<table style="text-align:center"><tr> <td>&nbsp;</td>']);

for iEpoch = 1:length(epochs)
    html = strcat(html,['<td>' epochs{iEpoch} '</td>']);
end

html = strcat(html,'</tr><tr><td>Curvature</td>');
for iEpoch = 1:length(epochs)
    html = strcat(html,['<td><img src="' figPath '\' epochs{iEpoch} '_adaptation_curvature.png" width="' num2str(imgWidth+200) '"></td>']);
end
html = strcat(html,'</tr><tr><td>Reaction Time</td>');
for iEpoch = 1:length(epochs)
    html = strcat(html,['<td><img src="' figPath '\' epochs{iEpoch} '_adaptation_reactiontime.png" width="' num2str(imgWidth+200) '"></td>']);
end
html = strcat(html,'</tr><tr><td>Time to Target</td>');
for iEpoch = 1:length(epochs)
    html = strcat(html,['<td><img src="' figPath '\' epochs{iEpoch} '_adaptation_timetotarget.png" width="' num2str(imgWidth+200) '"></td>']);
end
html = strcat(html,'</tr></table><br><a href="#header">back to top</a></div><hr>');