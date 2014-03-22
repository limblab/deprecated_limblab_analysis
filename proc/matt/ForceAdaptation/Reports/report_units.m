%% Print out data for units
function html = report_units(html,d,t,classes,tracking,allsg,p)
arrays = p.arrays;
epochs = p.epochs;
tuningPeriods = p.tuningPeriods;
tuningMethods = p.tuningMethods;
classNames = p.classNames;
tableColors = p.tableColors;
sigMethod = p.sigMethod;
imgWidth = p.imgWidth;
genFigPath = p.genFigPath;
figPath = p.figPath;


for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    sg = allsg{iArray};
    uElecs = unique(sg(:,1));
    
    html = strcat(html,['<h1>Unit Information: ' currArray '</h1>']);
    % loop along electrodes
    for i = 1:length(uElecs)
        e = uElecs(i);
        idx = find(sg(:,1)==e);
        
        units = sg(idx,2);
        
        % loop along units on each electrode
        for j = 1:length(units)
            u = units(j);
            
            html = strcat(html,['<div id="' currArray 'elec' num2str(e) 'unit' num2str(u) '"><div id="unit"><h2>elec' num2str(e) ' : unit' num2str(u) '</h2>']);
            
            
            
            % Add some plots
            html = strcat(html,'<table><tr><td>Waveforms</td><td>ISI</td>');
            for iPeriod = 1:length(tuningPeriods)
                if isfield(classes.(currArray).(sigMethod),tuningPeriods{iPeriod});
                    tune_sg = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).sg;
                    tcs = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).tuned_cells;
                    istuned = ismember([e, u],tune_sg(tcs,:),'rows');
                    if istuned
                        useColor = '#0055ee';
                    else
                        useColor = '#000000';
                    end
                    html = strcat(html,['<td><font color="' useColor '">' tuningPeriods{iPeriod} '</font></td>']);
                else
                    html = strcat(html,['<td>' tuningPeriods{iPeriod} ' period not found.</td>']);
                end
            end
            
            % plots for waveforms and isis
            html = strcat(html,['<tr><td><img src="' genFigPath '\' currArray '_elec' num2str(e) 'unit' num2str(u) '_wf.png" width="' num2str(imgWidth) '"></td>' ...
                '<td><img src="' genFigPath '\' currArray '_elec' num2str(e) 'unit' num2str(u) '_isi.png" width="' num2str(imgWidth) '"></td>']);
            
            % now add plot showing tuning in each period
            for iPeriod = 1:length(tuningPeriods)
                % html = strcat(html,['<td><img src="' figPath '\' currArray '_elec' num2str(e) 'unit' num2str(u) '_all_tc_' tuningPeriods{iPeriod} '.png" width="' num2str(imgWidth) '"></td>']);
                html = strcat(html,['<td><img src="' figPath '\' currArray '_elec' num2str(e) 'unit' num2str(u) '_all_polarpd_' sigMethod '_' tuningPeriods{iPeriod} '.png" width="' num2str(imgWidth) '"></td>']);
            end
            
            html = strcat(html,'</tr></table>');
            
            
            % Now make plots with tuning info and stats and what not
            useComp = tracking.(currArray){1}.chan;
            useCompPw = tracking.(currArray){1}.p_wave;
            useCompPi = tracking.(currArray){1}.p_isi;
            relCompInd = useComp(:,1)==e+.1*u;
            
            html = strcat(html,'<br><table border="1" style="text-align:center"><tr><td>Epochs</td><td>Stats</td>');
            for iPeriod = 1:length(tuningPeriods)
                html = strcat(html,['<td>' tuningPeriods{iPeriod} '</td>']);
            end
            html = strcat(html,'</tr>');
            
            for iEpoch = 1:length(epochs)
                idx = cellfun(@(x) all(x==[e u]),{d.(epochs{iEpoch}).(currArray).units.id});
                
                % Add some info about the waveforms and spike behavior
                html = strcat(html,['<tr><td><h2>' epochs{iEpoch} '</h2></td>' ...
                    '<td>&nbsp;&nbsp;Mean FR: ' num2str(d.(epochs{iEpoch}).(currArray).units(idx).mfr,4) '' ...
                    '<br>&nbsp;&nbsp;Peak to Peak: ' num2str(d.(epochs{iEpoch}).(currArray).units(idx).p2p,4) ' mV' ...
                    '<br>&nbsp;&nbsp;Mean ISI: ' num2str(d.(epochs{iEpoch}).(currArray).units(idx).misi*1000,4) ' msec' ...
                    '<br>&nbsp;&nbsp;Total Spikes: ' num2str(length(d.(epochs{iEpoch}).(currArray).units(idx).ts)) ...
                    '<br>&nbsp;&nbsp;Unit Match: ' num2str(useComp(relCompInd,iEpoch)) ' ( ' num2str(round(1000*useCompPw(relCompInd,iEpoch))/1000) ',' num2str(round(1000*useCompPi(relCompInd,iEpoch))/1000) ' )</td>']);
                
                % next with PD and confidence bound info
                for iPeriod = 1:length(tuningPeriods)
                    html = strcat(html,'<td><table><tr>');
                    % add title for subtable
                    for iMethod = 1:length(tuningMethods)
                        html = strcat(html,['<td>' tuningMethods{iMethod} '</td>']);
                    end
                    html = strcat(html,'</tr><tr>');
                    
                    for iMethod = 1:length(tuningMethods)
                        if isfield(classes.(currArray).(tuningMethods{iMethod}),tuningPeriods{iPeriod})
                            classBlocks = classes.(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod});
                            tuneBlocks = t.(epochs{iEpoch}).(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod});
                            
                            html = strcat(html,'<td><table>');
                            for iBlock = 1:length(tuneBlocks)
                                tune_sg = classBlocks(iBlock).sg;
                                tcs = classes.(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod}).tuned_cells;
                                istuned = ismember([e, u],tune_sg(tcs,:),'rows');
                                
                                tune_sg = tuneBlocks(iBlock).sg;
                                useInd = tune_sg(:,1) == e & tune_sg(:,2) == u;
                                pds = tuneBlocks(iBlock).pds(useInd,:);
                                
                                useColor = '#ffffff';
                                if istuned
                                    useColor = tableColors{iPeriod};
                                end
                                
                                % write PDs for current period and method and epoch
                                html = strcat(html,['<tr><td bgcolor="' useColor '">' num2str(pds(2)*180/pi,3) '&nbsp;(&nbsp;' num2str(pds(1)*180/pi,3) '&nbsp;)&nbsp;' num2str(pds(3)*180/pi,3) '</td></tr>']);
                            end
                            html = strcat(html,'</table></td>');
                        else
                            html = strcat(html,['<td>' tuningPeriods{iPeriod} ' period not found.</td>']);
                        end
                    end
                    html = strcat(html,'</tr></table></td>');
                end
                html = strcat(html,'</tr>');
            end
            
            % Now write some info on classification
            html = strcat(html,'<tr><td></td><td></td>');
            for iMethod = 1:length(tuningMethods)
                for iPeriod = 1:length(tuningPeriods)
                    if isfield(classes.(currArray).(tuningMethods{iMethod}),tuningPeriods{iPeriod})
                        useClasses = classes.(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod}).classes;
                        tune_sg = classes.(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod}).sg;
                        tunedCells = classes.(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod}).tuned_cells;
                        
                        useCell = find(tune_sg(:,1)==e & tune_sg(:,2)==u);
                        
                        temp = useClasses(useCell,1);
                        temp(temp < 0) = 6;
                        if any(ismember(tunedCells,useCell))
                            dispClass = classNames{temp};
                        else
                            dispClass = '&nbsp;';
                        end
                        html = strcat(html,['<td>' dispClass '</td>']);
                    else
                        html = strcat(html,['<td>' tuningPeriods{iPeriod} ' period not found.</td>']);
                    end
                end
            end
            
            html = strcat(html,'</table><br><a href="#header">back to top</a><br><br></div></div><hr>');
        end
        
    end
    
end


