%% Make plot showing adaptation/deadaptation over time
function html = report_adaptation(html,p)

% get necessary parameters
adaptationMetrics = p.adaptationMetrics;
genFigPath = p.genFigPath;
imgWidth = p.imgWidth;

html = strcat(html,['<div id="adapt"><h2>Adaptation</h2>' ...
    '<table style="text-align:center"><tr>']);
for iMetric = 1:length(adaptationMetrics)
    html = strcat(html,['<td>' adaptationMetrics{iMetric} '</td>']);
end
html = strcat(html,'</tr><tr>');

for iMetric = 1:length(adaptationMetrics)
    switch adaptationMetrics{iMetric}
        case 'angle_error'
            temp  = 'angle_error';
        case 'curvature'
            temp = 'curvature';
        case 'time_to_target'
            temp = 'time_to_target';
        otherwise
            error('metric not recognized.');
    end
    
    html = strcat(html,['<td><img src="' genFigPath '\adaptation_' temp '.png" width="' num2str(imgWidth+200) '"></td>']);
end

html = strcat(html,'</tr></table><br><a href="#header">back to top</a></div><hr>');