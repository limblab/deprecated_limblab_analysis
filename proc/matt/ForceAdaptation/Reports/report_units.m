%% Print out data for units
for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    html = strcat(html,['<h1>Unit Information: ' currArray '</h1>']);
    % loop along electrodes
    for i = 1:length(uElecs)
        idx = find(sg(:,1)==uElecs(i));
        units = sg(idx,2);
        
        % loop along units on each electrode
        for j = 1:length(units)
            
            html = strcat(html,['<div id="' currArray 'elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '"><div id="unit"><h2>elec' num2str(uElecs(i)) ' : unit' num2str(units(j)) '</h2>']);
            
            useComp = tracking.(currArray){1}.chan;
            useCompPw = tracking.(currArray){1}.p_wave;
            useCompPi = tracking.(currArray){1}.p_isi;
            relCompInd = useComp(:,1)==uElecs(i)+.1*units(j);
            for iEpoch = 1:length(epochs)
                
                % Add some info about the waveforms and spike behavior
                try
                    html = strcat(html,['<br><table>' ...
                        '<tr><td><h2>' epochs{iEpoch} '</h2></td>' ...
                        '<td>&nbsp;&nbsp;Mean FR: ' num2str(d.(epochs{iEpoch}).(currArray).units.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]).mfr,4) ...
                        '<br>&nbsp;&nbsp;Peak to Peak: ' num2str(d.(epochs{iEpoch}).(currArray).units.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]).p2p,4) ' mV' ...
                        '<br>&nbsp;&nbsp;Mean ISI: ' num2str(d.(epochs{iEpoch}).(currArray).units.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]).misi*1000,4) ' msec' ...
                        '<br>&nbsp;&nbsp;Unit Match: ' num2str(useComp(relCompInd,iEpoch)) ' ( ' num2str(useCompPw(relCompInd,iEpoch)) ',' num2str(useCompPi(relCompInd,iEpoch)) ' )</td>']);
                catch
                    keyboard
                end

                for iPeriod = 1:length(tuningPeriods)
                    tune_sg = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).unit_guide;
                    tcs = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).tuned_cells;
                    istuned = ismember([uElecs(i), units(j)],tune_sg(tcs,:),'rows');
                    if istuned
                        useColor = '#0055ee';
                    else
                        useColor = '#000000';
                    end
                    html = strcat(html,['<td><font color="' useColor '">' tuningPeriods{iPeriod} '</font></td>']);
                end
                
                % plots for waveforms and isis
                html = strcat(html,['</tr><tr><td><img src="' figPath '\' currArray '_elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '_' epochs{iEpoch} '_wf.png" width="' num2str(imgWidth) '"></td>' ...
                    '<td><img src="' figPath '\' currArray '_elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '_' epochs{iEpoch} '_isi.png" width="' num2str(imgWidth) '"></td>']);
                
                % Add plots for tuning in each period
                for iPeriod = 1:length(tuningPeriods)
                    html = strcat(html,['<td><img src="' figPath '\' currArray '_elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '_' epochs{iEpoch} '_tc_' tuningPeriods{iPeriod} '.png" width="' num2str(imgWidth) '"></td>']);
                end
                
                
                html = strcat(html,'</tr></table>');
            end
            
            html = strcat(html,'<br><table><tr>');
            
            html = strcat(html,'</tr></table>');
            
            %%%%%
            % make a table to show tuning info with various methods
            html = strcat(html,'<table border="1" style="text-align:center"><tr><td> Epoch </td>');
            for iPeriod = 1:length(tuningPeriods)
                html = strcat(html,['<td>' tuningPeriods{iPeriod} '</td>']);
            end
            html = strcat(html,'</tr>');
            
            % populate the table
            % first with images showing activity
            html = strcat(html,'<tr><td>BL<br>blue<br><br>AD<br>red<br><br>WO<br>green</td>');
            for iPeriod = 1:length(tuningPeriods)
                html = strcat(html,['<td><img src="' figPath '\' currArray '_elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '_all_tc_' tuningPeriods{iPeriod} '.png" width="' num2str(imgWidth) '"></td>']);
            end
            html = strcat(html,'</tr>');
            
            % now write some info on cell classification
            html = strcat(html,'<tr><td>class</td>');
            for iPeriod = 1:length(tuningPeriods)
                useClasses = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).classes;
                tune_sg = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).unit_guide;
                tunedCells = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).tuned_cells;
                
                useCell = find(tune_sg(:,1)==uElecs(i) & tune_sg(:,2)==units(j));
                
                if any(ismember(tunedCells,useCell))
                    dispClass = classNames{useClasses(useCell)};
                else
                    dispClass = '&nbsp;';
                end
                html = strcat(html,['<td>' dispClass '</td>']);
            end
            html = strcat(html,'</tr>');
            
            % next with PD and confidence bound info
            for iMethod = 1:length(tuningMethods)
                html = strcat(html,['<tr><td colspan="5">' tuningMethods{iMethod} '</td></tr>']);
                for iEpoch = 1:length(epochs)
                    html = strcat(html,['<tr><td>' epochs{iEpoch} '</td>']);
                    for iPeriod = 1:length(tuningPeriods)
                        
                        tune_sg = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).unit_guide;
                        tcs = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).tuned_cells;
                        istuned = ismember([uElecs(i), units(j)],tune_sg(tcs,:),'rows');
                        
                        tune_sg = t.(epochs{iEpoch}).(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod}).unit_guide;
                        useInd = tune_sg(:,1) == uElecs(i) & tune_sg(:,2) == units(j);
                        pds = t.(epochs{iEpoch}).(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod}).pds(useInd,:);
                        
                        useColor = '#ffffff';
                        if istuned
                            useColor = tableColors{iPeriod};
                        end
                        
                        % write PDs for current period and method and epoch
                        html = strcat(html,['<td bgcolor="' useColor '">' num2str(pds(2)*180/pi,3) '&nbsp;(&nbsp;' num2str(pds(1)*180/pi,3) '&nbsp;)&nbsp;' num2str(pds(3)*180/pi,3) '</td>']);
                    end
                    html = strcat(html,'</tr>');
                end
            end
            html = strcat(html,'</table>');
        end
        html = strcat(html,'<br><a href="#header">back to top</a><br><br></div></div><hr>');
    end
end
