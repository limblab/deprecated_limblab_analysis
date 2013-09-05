function html = neuronReports(expParamFile)
% NEURONREPORTS  Constructs html document to summarize a session's data
%
%   This function will load processed data and generate html for a summary
% report with data and figures.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%
% OUTPUTS:
%   html: (string) giant piece of html code with everything included
%
% NOTES:
%   -This function requires several bits of pre-processing
%       1) Create a data struct from the Cerebus files (makeDataStruct)
%       2) Create adaptation metrics struct (getAdaptationMetrics)
%       3) Run empirical KS test to track stability of neurons (trackNeurons)
%       4) Fit tuning for neurons, regression and nonparametric recommended (fitTuningCurves)
%       5) Classify cells based on adaptation behavior (findMemoryCells)
%       6) Generate a variety of plots (makeFFPlots)
%   - This function will automatically write the html to a file, too
%   - See "experimental_parameters_doc.m" for documentation on expParamFile
%   - Analysis parameters file must exist (see "analysis_parameters_doc.m")

% set some parameters
tuningPeriods = {'initial','peak','final','full'};
sigMethod = 'regression'; %what tuning method to look for for significance

imgWidth = 300; %pixels
cssLoc = 'Z:\MrT_9I4\Matt\mainstyle.css';
tableColors = {'#ff55ff','#55ffff','#ffff55','#55aaaa','#eeee77','#cccccc'};
classNames = {'kinematic','dynamic','memory I','memory II','other','weird'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(expParamFile);
baseDir = params.out_dir{1};
useDate = params.date{1};
arrays = params.arrays;
monkey = params.monkey{1};
taskType = params.task{1};
adaptType = params.adaptation_type{1};
epochs = params.epochs;
forceMag = str2double(params.force_magnitude{1});
forceAng = str2double(params.force_angle{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
disp('Loading data...')
for iEpoch = 1:length(epochs)
    load(dataFiles{iEpoch});
    d.(epochs{iEpoch}) = data;
    t.(epochs{iEpoch}) = tuning;
    clear data tuning;
end

% load the classification information
load(fullfile(dataPath,[taskType '_' adaptType '_classes_' useDate '.mat']));

% load neuron tracking data
load(fullfile(dataPath,[taskType '_' adaptType '_tracking_' useDate '.mat']));

disp('Done. Writing html...')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tuningMethods = fieldnames(classes.(arrays{1}));
% we don't really care about the nonparametric tuning atthis time
tuningMethods = setdiff(tuningMethods,'nonparametric');

if isempty(tuningMethods)
    error('Need to have at least one of glm/regression/vectorsum tuning to continue');
end

% if none are defined above, do them all
if isempty(tuningPeriods) || ~exist('tuningPeriods','var')
    tuningPeriods = fieldnames(classes.(arrays{1}).(tuningMethods{1}));
end


%% Write meta data
html = strcat(html,['<div id="header"><h1>Data Summary:&nbsp;' monkey '&nbsp; | &nbsp' cell2mat(arrays) '&nbsp; | &nbsp' useDate '&nbsp; | &nbsp;' taskType '&nbsp; | &nbsp;' adaptType '</h1><hr></div>']);

%% Make table of contents links
html = strcat(html,'<div id="contents">');
html = strcat(html,'<a href="#summary">Summary</a><br>');
html = strcat(html,'<a href="#behavior">Behavior Metrics</a><br>');
html = strcat(html,'<a href="#force">Force Plots</a><br>');
html = strcat(html,'<a href="#adapt">Adaptation Plots</a><br>');
html = strcat(html,'<a href="#classes">Cell Classifications</a><br>');

% if there is M1 and PMd, loop
for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    useComp = tracking.(currArray){1}.chan;
    
    % check to ensure same units are in all epochs
    unit_guides = cell(size(epochs));
    for iEpoch = 1:length(epochs)
        unit_guides{iEpoch} = d.(epochs{iEpoch}).(currArray).unit_guide;
    end
    badUnits = checkUnitGuides(unit_guides);
    % get the master unit guide
    sg = d.(epochs{1}).(currArray).unit_guide;
    sg = setdiff(sg,badUnits,'rows');
    
    % now we have the master list of units included in all epochs
    uElecs = unique(sg(:,1));
    
    html=strcat(html,[currArray '<br>']);
    tunedCount = 0;
    superTunedCount = 0;
    for i = 1:length(uElecs)
        idx = sg(:,1)==uElecs(i);
        units = sg(idx,2);
        
        html = strcat(html,['elec' num2str(uElecs(i)) ':&nbsp; &nbsp;']);
        for j = 1:length(units)
            
            for iMethod = 1:length(tuningMethods)
                temp_tuning = zeros(length(epochs),length(tuningPeriods));
                % find out if it's tuned in any periods
                for iPeriod = 1:length(tuningPeriods)
                    for iEpoch = 1:length(epochs)
                        % get the guide for that epoch so you get the right indices
                        usesg = t.(epochs{iEpoch}).(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod}).unit_guide;
                        useind = usesg(:,1)==uElecs(i) & usesg(:,2)==units(j);
                        if sum(useind) == 0
                            keyboard
                        end
                        temp_tuning(iEpoch,iPeriod) = checkTuningCISignificance(t.(epochs{iEpoch}).(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod}).pds(useind,:),ciSig,true);
                    end
                end
                
                sig_tuned.(tuningMethods{iMethod}).(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]) = temp_tuning;
            end
            
            temp_tuning = sig_tuned.(sigMethod).(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]);
            
            html = strcat(html,['<a href="#' currArray 'elec' num2str(uElecs(i)) 'unit' num2str(units(j)) '">unit' num2str(units(j)) '</a>']);
            if any(any(temp_tuning))
                if any(all(temp_tuning)) % star if tuned in all epochs
                    html = strcat(html,'*');
                    superTunedCount = superTunedCount + 1;
                end
                tunedCount = tunedCount + 1;
            end

            relCompInd = useComp(:,1)==uElecs(i)+.1*units(j);
            if any(diff(useComp(relCompInd,:)))
                html = strcat(html,'<--');
            end
            
            html = strcat(html,'&nbsp; &nbsp;');
            
        end
        html = strcat(html,'<br>');
    end
end
html = strcat(html,['*unit tuned for direction in all epochs by bootstrapping regression of PD at ' num2str(confLevel.*100) '% CI']);
html = strcat(html,'</div><hr>');

%% Make summary, maybe with memory cells and stuff? link to the cell then
html = strcat(html,['<div id="summary">' ...
    '<h2>Summary</h2>' ...
    '<br><table><tr><td># Units:</td><td>' num2str(d.(epochs{1}).params.unit_count) '</td></tr>' ...
    '<tr><td># tuned in any epoch</td><td>' num2str(tunedCount) '</td></tr>' ...
    '<tr><td># tuned in all epochs</td><td>' num2str(superTunedCount) '</td></tr></table>' ...
    '<br><a href="#header">back to top</a>' ...
    '</div><hr>']);

%% Make plots of behavior metrics
html = strcat(html,['<div id="behavior"><h2>Behavior Metrics</h2>' ...
    '<table><tr> <td>epoch</td> <td>Time To Target</td> <td>Reaction Time</td> <td>Target Directions</td></tr>']);

for iEpoch = 1:length(epochs)
    html = strcat(html,['<tr>' ...
        '<td>' epochs{iEpoch} '</td> <td><img src="' figPath '\' epochs{iEpoch} '_behavior_time_to_target.png" width="' num2str(imgWidth+100) '"></td>' ...
        '<td><img src="' figPath '\' epochs{iEpoch} '_behavior_reaction_time.png" width="' num2str(imgWidth+100) '"></td>' ...
        '<td><img src="' figPath '\' epochs{iEpoch} '_behavior_target_direction.png" width="' num2str(imgWidth+100) '"></td>' ...
        '</tr>']);
end
html = strcat(html,'</table></div><hr>');

%% Make plot showing adaptation/deadaptation over time
html = strcat(html,['<div id="adapt"><h2>Adaptation</h2>' ...
    '<table style="text-align:center"><tr> <td>&nbsp;</td> <td>BL</td> <td>AD</td> <td>WO</td></tr>']);

html = strcat(html,'<tr><td>Curvature</td>');
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

%% Make plot showing forces check out
html = strcat(html,['<div id="force">' ...
    '<table><tr><td><h2>Forces</h2></td><td>Strength:</td><td>' num2str(forceMag) ' Ns/cm</td><td>Direction:</td><td>' num2str(forceAng.*180/pi) ' deg </td></tr></table>' ...
    '<img src="' figPath '\force_vel.png" width="' num2str(imgWidth+200) '">' ...
    '<img src="' figPath '\force_mag.png" width="' num2str(imgWidth+200) '">' ...
    '<img src="' figPath '\force_line.png" width="' num2str(imgWidth+200) '">' ...
    '<br><a href="#header">back to top</a>' ...
    '</div><hr>']);

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
                
                relCompInd = useComp(:,1)==e+.1*u;
                if any(diff(useComp(relCompInd,:)))
                    useColor = '#ff0000';
                else
                    useColor = '#ffffff';
                end
                
                html = strcat(html,['<tr bgcolor="' useColor '"><td> <a href="#' currArray 'elec' num2str(tune_sg(tunedCells(unit),1)) 'unit' num2str(tune_sg(tunedCells(unit),2)) '"> Elec' num2str(tune_sg(tunedCells(unit),1)) '/Unit' num2str(tune_sg(tunedCells(unit),2)) '</a></td>' ...
                    '<td>' classNames{useClasses(tunedCells(unit))} '</td></tr>']);
            end
        else
            html = strcat(html,'No tuned Cells<br><br>');
        end
        html = strcat(html,'</table>');
    end
end
html = strcat(html,'<br><br><a href="#header">back to top</a></div><hr>');

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
                        '<td>&nbsp;&nbsp;# Spikes: ' num2str(d.(epochs{iEpoch}).(currArray).units.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]).ns,4) ...
                        '<br>&nbsp;&nbsp;Peak to Peak: ' num2str(d.(epochs{iEpoch}).(currArray).units.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]).p2p,4) ' mV' ...
                        '<br>&nbsp;&nbsp;Mean ISI: ' num2str(d.(epochs{iEpoch}).(currArray).units.(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]).misi*1000,4) ' msec' ...
                        '<br>&nbsp;&nbsp;Unit Match: ' num2str(useComp(relCompInd,iEpoch)) ' ( ' num2str(useCompPw(relCompInd,iEpoch)) ',' num2str(useCompPi(relCompInd,iEpoch)) ' )</td>']);
                catch
                    keyboard
                end
                
                temp_tuning = sig_tuned.(sigMethod).(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]);
                % add label for period plots, and use different color if significantly tuned
                for iPeriod = 1:length(tuningPeriods)
                    if temp_tuning(iEpoch,iPeriod)
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
                        
                        temp_tuning = sig_tuned.(tuningMethods{iMethod}).(['elec' num2str(uElecs(i))]).(['unit' num2str(units(j))]);
                        
                        pds = t.(epochs{iEpoch}).(currArray).(tuningMethods{iMethod}).(tuningPeriods{iPeriod}).pds(idx(j),:);
                        
                        useColor = '#ffffff';
                        if temp_tuning(iEpoch,iPeriod)
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


%% close up shop
html = strcat(html,'</body></html>');

fid = fopen([dataPath '\' useDate '_summary_report.html'],'w+');
fprintf(fid,'%s',html);
