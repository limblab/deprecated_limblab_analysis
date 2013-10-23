%% Show population PD tuning changes
function html = report_pdChanges(html,p)

% get necessary parameters
arrays = p.arrays;
tuningPeriods = p.tuningPeriods;
figPath = p.figPath;
imgWidth = p.imgWidth;

html = strcat(html,'<div id="pdchanges"><h2>PD Changes</h2>Showing cells that are significantly tuned in all three epochs and pass same-neuron test<br>');
for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    html = strcat(html,['<h3>' currArray '</h3>']);
    
    % set up table and add titles
    html = strcat(html,'<table style="text-align:center"><tr><td>&nbsp;</td>');
    for iPeriod = 1:length(tuningPeriods)
        html = strcat(html,['<td>' tuningPeriods{iPeriod} '</td>']);
    end
    
    % plots of change in PD as trace
    html = strcat(html,'</tr><tr><td>Change in PD</td>');
    for iPeriod = 1:length(tuningPeriods)
        html = strcat(html,['<td><img src="' figPath '\' currArray '_' tuningPeriods{iPeriod} '_pd_changes.png" width="' num2str(imgWidth+200) '"></td>']);
    end
    
    html = strcat(html,'</tr></table>');
    
    % plots of change in PD as histogram
    html = strcat(html,'<table style="text-align:center"><tr><td>&nbsp;</td><td>BL->AD</td><td>AD->WO</td><td>BL->WO</td></tr>');
    
    for iPeriod = 1:length(tuningPeriods)
        html = strcat(html,['<tr><td>' tuningPeriods{iPeriod} '</td>']);
        html = strcat(html,['<td><img src="' figPath '\' currArray '_' tuningPeriods{iPeriod} '_change_PD_hist_BL-AD.png" width="' num2str(imgWidth+200) '"></td>']);
        html = strcat(html,['<td><img src="' figPath '\' currArray '_' tuningPeriods{iPeriod} '_change_PD_hist_AD-WO.png" width="' num2str(imgWidth+200) '"></td>']);
        html = strcat(html,['<td><img src="' figPath '\' currArray '_' tuningPeriods{iPeriod} '_change_PD_hist_BL-WO.png" width="' num2str(imgWidth+200) '"></td></tr>']);
    end
    
    html = strcat(html,'</table>');
end

html = strcat(html,'<br><a href="#header">back to top</a></div><hr>');