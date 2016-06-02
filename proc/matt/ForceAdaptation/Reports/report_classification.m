%% Add a list of tuned cells with their classification
function html = report_classification(html,d,classes,tracking,p)
epochs = p.epochs;
arrays = p.arrays;
tuningPeriods = p.tuningPeriods;
sigMethod = p.sigMethod;
classNames = p.classNames;
minFR = p.minFR;

html = strcat(html,'<div id="classes"><h2>Classes</h2>Showing cells that are significantly tuned in all three epochs<br>');
for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    useComp = tracking.(currArray){1}.chan;
    
    for iPeriod = 1:length(tuningPeriods)
        if isfield(classes.(currArray).(sigMethod),tuningPeriods{iPeriod})
            html = strcat(html,['<h3>' tuningPeriods{iPeriod} '</h3>']);
            
            useBlock = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod});
            
            useClasses = useBlock(end).classes;
            tune_sg = useBlock(end).sg;
            tunedCells = useBlock(end).tuned_cells;
            
            if ~isempty(tunedCells)
                html = strcat(html,'<table border="1" style="display:inline"> <tr> <td>Unit</td> <td>PD</td> <td>MD</td> </tr>');
                for unit = 1:length(tunedCells)
                    
                    % mark the background as red if the neuron tracking says that the cells may be different in each epoch
                    e = tune_sg(tunedCells(unit),1);
                    u = tune_sg(tunedCells(unit),2);
                    
                    % expect a certain average level of activity, over whole file
                    mfr = zeros(length(epochs),1);
                    for iEpoch = 1:length(epochs)
                        idx = cellfun(@(x) all(x==[e u]),{d.(epochs{iEpoch}).(currArray).units.id});
                        mfr(iEpoch) = d.(epochs{iEpoch}).(currArray).units(idx).mfr;
                    end
                    
                    if  all(mfr > minFR)
                        
                        relCompInd = useComp(:,1)==e+.1*u;
                        if any(diff(useComp(relCompInd,:)))
                            useColor = '#ff0000';
                        else
                            useColor = '#ffffff';
                        end
                        
                        temp = useClasses(tunedCells(unit),:);
                        temp(temp < 0) = 6;
                        
                        html = strcat(html,['<tr bgcolor="' useColor '"><td> <a href="#' currArray 'elec' num2str(tune_sg(tunedCells(unit),1)) 'unit' num2str(tune_sg(tunedCells(unit),2)) '"> Elec' num2str(tune_sg(tunedCells(unit),1)) '/Unit' num2str(tune_sg(tunedCells(unit),2)) '</a></td>' ...
                            '<td>' classNames{temp(1)} '</td>' ...
                            '<td>' classNames{temp(2)} '</td></tr>']);
                        
                    end
                end
            else
                html = strcat(html,'No tuned Cells<br><br>');
            end
            
        else
            html = strcat(html,[tuningPeriods{iPeriod} ' period not found.<br>']);
        end
        
        html = strcat(html,'</table>');
    end
end
html = strcat(html,'<br><br><a href="#header">back to top</a></div><hr>');
