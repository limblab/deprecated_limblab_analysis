%% Make plot showing adaptation/deadaptation over time
function html = report_adaptation(html,p)

% get necessary parameters
adaptationMetric = p.adaptationMetric;
genFigPath = p.genFigPath;
imgWidth = p.imgWidth;

html = strcat(html,['<div id="adapt"><h2>Adaptation</h2>' ...
    '<table style="text-align:center"><tr> <td>&nbsp;</td>']);

html = strcat(html,['<td>' adaptationMetric '</td>']);

switch adaptationMetric
    case 'angle_error'
        temp  = 'sliding_error_mean';
    case 'curvature'
        temp = 'sliding_curvature_mean';
    otherwise
        error('metric not recognized.');
end

html = strcat(html,['</tr><tr><td>' adaptationMetric '</td>']);
html = strcat(html,['<td><img src="' genFigPath '\adaptation_' temp '.png" width="' num2str(imgWidth+200) '"></td>']);
html = strcat(html,'</tr></table><br><a href="#header">back to top</a></div><hr>');