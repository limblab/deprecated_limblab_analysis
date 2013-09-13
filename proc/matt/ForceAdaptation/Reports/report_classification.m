%% Add a list of tuned cells with their classification
html = strcat(html,'<div id="classes"><h2>Classes</h2>Showing cells that are significantly tuned in all three epochs<br>');
for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    useComp = tracking.(currArray){1}.chan;
    
    for iPeriod = 1:length(tuningPeriods)
        html = strcat(html,['<h3>' tuningPeriods{iPeriod} '</h3>']);
        
        useClasses = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).classes;
        tune_sg = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).unit_guide;
        tunedCells = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).tuned_cells;
        
        if ~isempty(tunedCells)
            html = strcat(html,'<table border="1" style="display:inline"> <tr> <td> Unit </td> <td> Classification </td> </tr>');
            for unit = 1:length(tunedCells)
                
                % mark the background as red if the neuron tracking says that the cells may be different in each epoch
                e = tune_sg(tunedCells(unit),1);
                u = tune_sg(tunedCells(unit),2);
                
                % expect a certain average level of activity, over whole file
                mfr = zeros(length(epochs),1);
                for iEpoch = 1:length(epochs)
                    mfr(iEpoch) = d.(epochs{iEpoch}).(currArray).units.(['elec' num2str(e)]).(['unit' num2str(u)]).mfr;
                end
                
                if  all(mfr > minFR)
                    
                    relCompInd = useComp(:,1)==e+.1*u;
                    if any(diff(useComp(relCompInd,:)))
                        useColor = '#ff0000';
                    else
                        useColor = '#ffffff';
                    end
                    
                    html = strcat(html,['<tr bgcolor="' useColor '"><td> <a href="#' currArray 'elec' num2str(tune_sg(tunedCells(unit),1)) 'unit' num2str(tune_sg(tunedCells(unit),2)) '"> Elec' num2str(tune_sg(tunedCells(unit),1)) '/Unit' num2str(tune_sg(tunedCells(unit),2)) '</a></td>' ...
                        '<td>' classNames{useClasses(tunedCells(unit))} '</td></tr>']);
                end
            end
        else
            html = strcat(html,'No tuned Cells<br><br>');
        end
        html = strcat(html,'</table>');
    end
end
html = strcat(html,'<br><br><a href="#header">back to top</a></div><hr>');
