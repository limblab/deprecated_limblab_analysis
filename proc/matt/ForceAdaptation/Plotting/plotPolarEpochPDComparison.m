function plotPolarEpochPDComparison(blt,adt,wot,saveFilePath)
% only need one data struct (baseline probably)
% make polar plot showing PD +/- CI for each epoch

plotColors = {{'b',[0.8 0.9 1]},{'r',[1 0.9 0.8]},{'g',[0.9 1 0.8]}};

if nargin < 4
    saveFilePath = [];
end
% Load some parameters
paramFile = fullfile(blt.meta.out_directory, [blt.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
clear params;

useArrays = blt.meta.arrays;

% fh = figure;
% get units from data, and for each, plot all of the waveforms
for iArray = 1:length(useArrays)
    currArray = useArrays{iArray};
    
    % find how many different types of tuning periods there are to plot
    tuningMethods = fieldnames(blt.(currArray));
    for iMethod = 1:length(tuningMethods)
        
        useMethod = tuningMethods{iMethod};
        
        if ~strcmpi(useMethod,'nonparametric')
            
            tuningPeriods = fieldnames(blt.(currArray).(tuningMethods{iMethod}));
            
            for iPeriod = 1:length(tuningPeriods)

                tuneType = tuningPeriods{iPeriod};
                
                sg_bl = blt.(currArray).(useMethod).(tuneType).sg;
                sg_ad = adt.(currArray).(useMethod).(tuneType).sg;
                sg_wo = wot.(currArray).(useMethod).(tuneType).sg;
                badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
                
                sg_master = setdiff(sg_bl,badUnits,'rows');
                
                for i = 1:size(sg_master,1)
                    e = sg_master(i,1);
                    u = sg_master(i,2);
                    
                    % set(0, 'CurrentFigure', fh);
                    % clf reset;
                    % hold all;
                    
                    % prefer to use nonparametric tuning curves
                    
                    figure;
                    % baseline
                    useColors = plotColors{1};
                    unit = find(sg_bl(:,1)==e & sg_bl(:,2)==u,1);
                    pds = blt.(currArray).(useMethod).(tuneType).pds(unit,:);
                    polar([pds(1) pds(1)],[0 1],useColors{1});
                    hold all;
                    polar([pds(2) pds(2)],[0 1],[useColors{1} '--']);
                    polar([pds(3) pds(3)],[0 1],[useColors{1} '--']);
                    
                    % adaptation
                    useColors = plotColors{2};
                    unit = find(sg_ad(:,1)==e & sg_ad(:,2)==u,1);
                    temp = adt.(currArray).(useMethod).(tuneType);
                    pds = temp(end).pds(unit,:);
                    polar([pds(1) pds(1)],[0 1],useColors{1});
                    polar([pds(2) pds(2)],[0 1],[useColors{1} '--']);
                    polar([pds(3) pds(3)],[0 1],[useColors{1} '--']);
                    
                    % washout
                    useColors = plotColors{3};
                    unit = find(sg_wo(:,1)==e & sg_wo(:,2)==u,1);
                    pds = wot.(currArray).(useMethod).(tuneType).pds(unit,:);
                    polar([pds(1) pds(1)],[0 1],useColors{1});
                    polar([pds(2) pds(2)],[0 1],[useColors{1} '--']);
                    polar([pds(3) pds(3)],[0 1],[useColors{1} '--']);

                    if ~isempty(saveFilePath)
                        fn = fullfile(saveFilePath,[currArray '_elec' num2str(sg_master(i,1)) 'unit' num2str(sg_master(i,2)) '_all_polarpd_' useMethod '_' tuneType '.png']);
                        saveas(gcf,fn,'png');
                    else
                        pause;
                    end
                    close all;
                end
            end
        end
    end
end
