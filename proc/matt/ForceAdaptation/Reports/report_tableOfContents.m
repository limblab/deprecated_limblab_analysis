% Make table of contents links
function [html,allsg] = report_tableOfContents(html,d,tracking,p)
arrays = p.arrays;
epochs = p.epochs;
adaptType = p.adaptType;
taskType = p.taskType;
useUnsorted = p.useUnsorted;
confLevel = p.confLevel;

html = strcat(html,'<div id="contents">');
html = strcat(html,'<a href="#summary">Summary</a><br>');
html = strcat(html,'<a href="#behavior">Behavior Metrics</a><br>');
if strcmpi(adaptType,'FF');
    html = strcat(html,'<a href="#force">Force Plots</a><br>');
end

html = strcat(html,'<a href="#adapt">Adaptation Plots</a><br>');

if strcmpi(taskType,'CO')
    html = strcat(html,'<a href="#CO">Center Out Plots</a><br>');
end

if ~useUnsorted
    html = strcat(html,'<a href="#classes">Cell Classifications</a><br>');
    html = strcat(html,'<a href="#pdchanges">PD Change Plots</a><br>');
end

if ~useUnsorted
    
    % set up table for arrays
    html = strcat(html,'<br><table><tr>');
    for iArray = 1:length(arrays)
        html = strcat(html,['<td>' arrays{iArray} '</td>']);
    end
    html = strcat(html,'</tr><tr>');
    
    % if there is M1 and PMd, loop
    for iArray = 1:length(arrays)
        currArray = arrays{iArray};
        
        useComp = tracking.(currArray){1}.chan;
        
        % check to ensure same units are in all epochs
        unit_guides = cell(size(epochs));
        for iEpoch = 1:length(epochs)
            unit_guides{iEpoch} = d.(epochs{iEpoch}).(currArray).sg;
        end
        badUnits = checkUnitGuides(unit_guides);
        % get the master unit guide
        sg = d.(epochs{1}).(currArray).sg;
        sg = setdiff(sg,badUnits,'rows');
        
        allsg{iArray} = sg;
        uElecs = unique(sg(:,1));
        
%         % add links to all units for this array
%         html = strcat(html,'<td>');
%         for unit = 1:size(sg,1)
%             html = strcat(html,['<a href="#' currArray 'elec' num2str(sg(unit,1)) 'unit' num2str(sg(unit,2)) '">elec-' num2str(sg(unit,1)) '_unit-' num2str(sg(unit,2)) '</a>']);
%             
%             relCompInd = useComp(:,1)==sg(unit,1)+.1*sg(unit,2);
%             if any(diff(useComp(relCompInd,:)))
%                 html = strcat(html,'<--');
%             end
%             html = strcat(html,'<br>');
%         end
%         html = strcat(html,'</td>');

                
        html=strcat(html,'<td>');
        for i = 1:length(uElecs)
            idx = sg(:,1)==uElecs(i);
            units = sg(idx,2);
            
            html = strcat(html,['elec' num2str(uElecs(i)) ':&nbsp; &nbsp;']);
            for j = 1:length(units)
                
                html = strcat(html,['<a href="#' currArray 'elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '">unit' num2str(units(j)) '</a>']);
                relCompInd = useComp(:,1)==uElecs(i)+.1*units(j);
                if any(diff(useComp(relCompInd,:)))
                    html = strcat(html,'<--');
                end
                
                html = strcat(html,'&nbsp; &nbsp;');
                
            end
            html = strcat(html,'<br>');
        end
        html = strcat(html,'</td>');
        
        
    end
    html = strcat(html,'</tr></table>');
    html = strcat(html,['*unit tuned for direction in all epochs by bootstrapping regression of PD at ' num2str(confLevel.*100) '% CI']);
end

html = strcat(html,'</div><hr>');
