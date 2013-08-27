function neuronReports(expParamFile)
% make HTML file with summary of data file
% Built to support any number of arrays with any names
% Built to support any number of files (called "epochs" here after my force
% field stuff), just give each one a consistent code in the parameters file
%

% set some parameters
imgWidth = 300; %pixels
cssLoc = 'Z:\MrT_9I4\Matt\mainstyle.css';
sigMethod = 'regression'; %what tuning method to look for for significance

% get experiment details from file
params = parseExpParams(expParamFile);
baseDir = params.outDir{1};
useDate = params.useDate{1};
arrays = params.useArray;
monkey = params.monkey{1};
taskType = params.taskType{1};
adaptType = params.adaptType{1};
epochs = params.epochs;
forceMag = str2double(params.forceMag{1});
forceAng = str2double(params.forceMag{1});
clear params;

% Load some more parameters
paramFile = fullfile(baseDir, useDate, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
confLevel = str2double(params.confidence_level{1});
ciSig = str2double(params.ci_significance{1});
clear params;

dataPath = fullfile(baseDir,useDate);
figPath = fullfile(dataPath,'figs');

dataFiles = cell(size(epochs));
for iEpoch = 1:length(epochs)
    dataFiles{iEpoch} = fullfile(dataPath,[taskType '_' adaptType '_' epochs{iEpoch} '_' useDate '.mat']);
end

html = ['<html><head><title>' useDate '&nbsp; &nbsp;' taskType '&nbsp; &nbsp;' adaptType '</title><link rel="stylesheet" href="' cssLoc '" /></head><body>'];

% load data for each epoch
for iEpoch = 1:length(epochs)
    load(dataFiles{iEpoch});
    d.(epochs{iEpoch}) = data;
    clear data;
end

tuningPeriods = fieldnames(d.(epochs{1}).(arrays{1}).tuning);


%% Write meta data
html = strcat(html,['<div id="header"><h1>Data Summary:&nbsp;' monkey '&nbsp; | &nbsp' cell2mat(arrays) '&nbsp; | &nbsp' useDate '&nbsp; | &nbsp;' taskType '&nbsp; | &nbsp;' adaptType '</h1><hr></div>']);

%% Make table of contents links
html = strcat(html,'<div id="contents">');
html = strcat(html,'<a href="#summary">Summary</a><br>');
html = strcat(html,'<a href="#force">Force Plots</a><br>');
html = strcat(html,'<a href="#adapt">Adaptation</a><br>');

% if there is M1 and PMd, loop
for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    %     Check to ensure same units are in all epochs
    clear sg
    unit_guide = d.(epochs{1}).(currArray).unit_guide;
    sg = unit_guide(:,1);
    if length(epochs) > 1
        for iEpoch = 2:length(epochs)
            sg2 = d.(epochs{iEpoch}).(currArray).unit_guide;
            sg2 = sg2(:,1);
            sg = intersect(sg,sg2,'sorted');
        end
    end
    % now we have the master list of units included in all epochs
    uElecs = unique(sg(:,1));
    % FOR NOW ASSUME THAT UNITS ARE SAME ON EACH ELECTRODE
    
    html=strcat(html,[currArray '<br>']);
    tunedCount = 0;
    superTunedCount = 0;
    for i = 1:length(uElecs)
        idx = find(unit_guide(:,1)==uElecs(i));
        units = unit_guide(idx,2);
        
        html = strcat(html,['elec' num2str(uElecs(i)) ':&nbsp; &nbsp;']);
        for j = 1:length(units)
            
            temp_tuning = zeros(length(epochs),length(tuningPeriods));
            % find out if it's tuned in any periods
            for iPeriod = 1:length(tuningPeriods)
                for iEpoch = 1:length(epochs)
                    temp_tuning(iEpoch,iPeriod) = checkTuningCISignificance(d.(epochs{iEpoch}).(currArray).tuning.(tuningPeriods{iPeriod}).(sigMethod).pds(idx(j),:),ciSig,true);
                end
            end
            
            sig_tuned.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]) = temp_tuning;
            
            html = strcat(html,['<a href="#' currArray 'elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '">unit' num2str(units(j)) '</a>']);
            if any(any(temp_tuning))
                if any(all(temp_tuning)) % 3 stars if tuned in all epochs
                    html = strcat(html,'***');
                    superTunedCount = superTunedCount + 1;
                else
                    html = strcat(html,'*');
                end
                tunedCount = tunedCount + 1;
            end
            html = strcat(html,'&nbsp; &nbsp;');
        end
        html = strcat(html,'<br>');
    end
end
html = strcat(html,['*unit tuned for direction by one way anova at ' num2str(confLevel.*100) '%']);
html = strcat(html,'</div><hr>');

%% Make summary, maybe with memory cells and stuff? link to the cell then
html = strcat(html,['<div id="summary">' ...
    '<h1>Summary</h1>' ...
    '<br><table><tr><td># Units:</td><td>' num2str(d.(epochs{1}).params.unit_count) '</td></tr>' ...
    '<tr><td># tuned in any epoch</td><td>' num2str(tunedCount) '</td></tr>' ...
    '<tr><td># tuned in all epochs</td><td>' num2str(superTunedCount) '</td></tr></table>' ...
    '<br><a href="#header">back to top</a>' ...
    '</div><hr>']);

%% Make plots of position traces in each epoch for CO?

%% Make plot showing adaptation/deadaptation over time
html = strcat(html,'<div id="adapt"><h1>Adaptation</h1>');
for iEpoch = 1:length(epochs)
    html = strcat(html,['<img src="' figPath '\' epochs{iEpoch} '_adaptation_curvature.png" width="' num2str(imgWidth+200) '">']);
end
html = strcat(html,'<br><a href="#header">back to top</a></div><hr>');

%% Make plot showing forces check out
html = strcat(html,['<div id="force">' ...
    '<table><tr><td><h2>Forces</h2></td><td>Strength:</td><td>' num2str(forceMag) ' Ns/cm</td><td>Direction:</td><td>' num2str(forceAng.*180/pi) ' deg </td></tr></table>' ...
    '<img src="' figPath '\force_vel.png" width="' num2str(imgWidth+200) '">' ...
    '<img src="' figPath '\force_mag.png" width="' num2str(imgWidth+200) '">' ...
    '<img src="' figPath '\force_line.png" width="' num2str(imgWidth+200) '">' ...
    '<br><a href="#header">back to top</a>' ...
    '</div><hr>']);

%% For each unit, make plot of waveforms in BL, plot of ISI in BL
%   Also make plots showing tuning in each epoch
for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    for i = 1:length(uElecs)
        idx = find(unit_guide(:,1)==uElecs(i));
        units = unit_guide(idx,2);
        
        for j = 1:length(units)
            html = strcat(html,['<div id="' currArray 'elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '"><div id="unit"><h2>elec' num2str(uElecs(i)) ' : unit' num2str(units(j)) '</h2>']);
            for iEpoch = 1:length(epochs)
                
                html = strcat(html,['<br><table>' ...
                    '<tr><td><h2>' epochs{iEpoch} '</h2></td>' ...
                    '<td>&nbsp;&nbsp;# Spikes: ' num2str(d.(epochs{iEpoch}).(currArray).units.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]).ns,4) ...
                    '<br>&nbsp;&nbsp;Peak to Peak: ' num2str(d.(epochs{iEpoch}).(currArray).units.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]).p2p,4) 'mV' ...
                    '<br>&nbsp;&nbsp;Mean ISI: ' num2str(d.(epochs{iEpoch}).(currArray).units.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]).misi*1000,4) '</td>']);
                
                temp_tuning = sig_tuned.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]);
                % add label for periods, and use different color if significantly tuned
                for iPeriod = 1:length(tuningPeriods)
                    if temp_tuning(iEpoch,iPeriod)
                        useColor = '#0055ee';
                    else
                        useColor = '#000000';
                    end
                    html = strcat(html,['<td><font color="' useColor '">' tuningPeriods{iPeriod} '</font></td>']);
                end
                
                html = strcat(html,['</tr><tr><td><img src="' figPath '\' currArray '_elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '_' epochs{iEpoch} '_wf.png" width="' num2str(imgWidth) '"></td>' ...
                    '<td><img src="' figPath '\' currArray '_elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '_' epochs{iEpoch} '_isi.png" width="' num2str(imgWidth) '"></td>']);
                
                % Add plots
                for iPeriod = 1:length(tuningPeriods)
                    html = strcat(html,['<td><img src="' figPath '\' currArray '_elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '_' epochs{iEpoch} '_tc_' tuningPeriods{iPeriod} '.png" width="' num2str(imgWidth) '"></td>']);
                end
                
                
                html = strcat(html,'</tr></table>');
            end
            
            tableColors = {'#ff55ff','#55ffff','#ffff55','#55aaaa','#eeee77'};
            
            html = strcat(html,['<table border="1"><tr> <td> period </td> <td> PDs </td> <td>Vector Sum</td> <td>Regression</td></tr>']); %<td>GLM</td> </tr>']);
            for iPeriod = 1:length(tuningPeriods)
                useColor = tableColors{iPeriod};
                for iEpoch = 1:length(epochs)
                    pds_vs = d.(epochs{iEpoch}).(currArray).tuning.(tuningPeriods{iPeriod}).vectorsum.pds(idx(j),:);
                    pds_reg = d.(epochs{iEpoch}).(currArray).tuning.(tuningPeriods{iPeriod}).regression.pds(idx(j),:);
%                     pds_glm = d.(epochs{iEpoch}).(currArray).tuning.(tuningPeriods{iPeriod}).vectorsum.pds(idx(j),:);
                    % add table summarizing tuning
                    
                    temp_tuning = sig_tuned.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]);
                    if temp_tuning(iEpoch,iPeriod)
                    	istuned = '*';
                    else
                        istuned = '&nbsp;';
                    end
                    
                    html = strcat(html,['<tr> <td>' tuningPeriods{iPeriod} '<td>' epochs{iEpoch} '&nbsp;' istuned '</td> ' ...
                        '<td> <table bgcolor="' useColor '" style="text-align:center"><tr> <td>' num2str(pds_vs(2)*180/pi,3) '</td><td>&nbsp;(&nbsp;' num2str(pds_vs(1)*180/pi,3) '</td><td>&nbsp;)&nbsp;' num2str(pds_vs(3)*180/pi,3) '</td> </tr></table> </td>' ...
                        '<td> <table bgcolor="' useColor '"><tr> <td>' num2str(pds_reg(2)*180/pi,3) '</td><td>&nbsp;(&nbsp;' num2str(pds_reg(1)*180/pi,3) '</td><td>&nbsp;)&nbsp;' num2str(pds_reg(3)*180/pi,3) '</td> </tr></table> </td>']);
%                         '<td> <table bgcolor="' useColor '"><tr> <td>' num2str(pds_glm(2)*180/pi,3) '</td><td>&nbsp;(&nbsp;' num2str(pds_glm(1)*180/pi,3) '</td><td>&nbsp;)&nbsp;' num2str(pds_glm(3)*180/pi,3) '</td> </tr></table> </td> </tr>']);
                end
                html = strcat(html,'<tr></tr>');
            end
            html = strcat(html,'</table>');
        end
        html = strcat(html,'<br><a href="#header">back to top</a><br><br></div></div><hr>');
    end
end


%% close up shop
html = strcat(html,'</body></html>');

fid = fopen([dataPath '\' useDate '_summary_report.html'],'w+');
fprintf(fid,'%s',html);
