function makeMovementTuningPlots(data,saveFilePath)
% compType is the type of computation
%   'glm'
%   'regression'
%   'vectorsum'

if nargin < 2
    saveFilePath = [];
end

% Load some parameters
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
clear params;

useArrays = data.meta.arrays;
epoch = data.meta.epoch;

fh = figure;
% get units from data, and for each, plot all of the waveforms
for iArray = 1:length(useArrays)
    currArray = useArrays{iArray};
    
    % get the spike guide showing electrodes and units
    sg = data.(currArray).unit_guide;
    
    % find how many different types of tuning periods there are to plot
    tuneTypes = fieldnames(data.(currArray).tuning);
    
    for unit = 1:size(sg,1)
        for iPlot = 1:length(tuneTypes)
            tuneType = tuneTypes{iPlot};
            
            fr = data.(currArray).tuning.(tuneType).fr(:,unit);
            theta = data.(currArray).tuning.(tuneType).theta;
            utheta = unique(theta);
            
            % find the mean firing rate
            mFR = zeros(length(utheta),1);
            sFR = zeros(length(utheta),1);
            for it = 1:length(utheta)
                relFR = fr(theta==utheta(it));
                mFR(it) = mean(relFR);
                sFR(it) = std(relFR);
            end
            
            set(0, 'CurrentFigure', fh);
            clf reset;
            
            hold all;
            h = area(utheta.*(180/pi),[mFR-sFR 2*sFR]);
            set(h(1),'FaceColor',[1 1 1]);
            set(h(2),'FaceColor',[0.8 0.9 1],'EdgeColor',[1 1 1]);
            plot(utheta.*(180/pi),mFR,'b','LineWidth',2);
            
            ylabel('Firing Rate (Hz)','FontSize',fontSize);
            xlabel('Movement Direction (deg)','FontSize',fontSize);
            axis('tight');

            V = axis;
            axis([V(1) V(2) 0 V(4)]);
            
            if ~isempty(saveFilePath)
                fn = fullfile(saveFilePath,[currArray '_elec' num2str(sg(unit,1)) 'unit' num2str(sg(unit,2)) '_' epoch '_tc_' tuneType '.png']);
                saveas(fh,fn,'png');
            else
                pause;
            end
            
        end
    end
end