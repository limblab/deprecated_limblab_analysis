function plotAdaptationOverTime(varargin)
% necessary variables
%   baseDir
%   useDate (date, task, perturbation, title)
%   metric
%   doFiltering
%   filtWidth
%   epochs
%   figurePosition
%   fontSize
%   traceWidth
%   plotBuffer [upper,lower] amount to add above min/max value
%   plotColors

%% TO DO!
%   figure out alignment of epoch transitions
%   figure out title placement
%   figure out vertical ticks
%   figure out lengend and stuff

%%
% Make curvature plots to show adaptation over time

traceWidth = 2;
doFiltering = false;
filtWidth = 10;
epochs = {'BL','AD','WO'};
figurePosition =  [200, 200, 800, 600];
plotBuffer = [0.1 0.1];
plotColors = {'b','b','r','r'};
useMetric = 'angle_error';
saveFilePath = [];
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'dir'
            baseDir = varargin{i+1};
        case 'dates'
            useDate = varargin{i+1};
        case 'metric'
            useMetric = varargin{i+1};
        case 'filter'
            doFiltering = varargin{i+1};
        case 'filterwidth'
            filtWidth = varargin{i+1};
        case 'epochs'
            epochs = varargin{i+1};
        case 'buffer'
            plotBuffer = varargin{i+1};
        case 'colors'
            plotColors = varargin{i+1};
        case 'tracewidth'
            traceWidth = varargin{i+1};
        case 'figurepos'
            figurePosition = varargin{i+1};
        case 'savepath'
            saveFilePath = varargin{i+1};
        case 'doscale'
            doScale = varargin{i+1};
    end
end

switch lower(useMetric)
    case 'curvature'
        metricName = 'curvature_mean';
    case 'angle_error'
        metricName = 'angle_error_mean';
    case 'time_to_target'
        metricName = 'time_to_target_mean';
    otherwise
        error('Metric not recognized...');
end

% load plotting parameters
fontSize = 16;
stepSize = 5;

minMC = zeros(1,size(useDate,1));
maxMC = zeros(1,size(useDate,1));
dateDividers = cell(1,size(useDate,1));
dateMC = cell(1,size(useDate,1));
for iDate = 1:size(useDate,1)
    adaptation = load(fullfile(baseDir,useDate{iDate,1},[useDate{iDate,2} '_' useDate{iDate,3} '_adaptation_' useDate{iDate,1} '.mat']));
    
    allMC = [];
    dividers = zeros(1,length(epochs)+1);
    for iEpoch = 1:length(epochs)
        a = adaptation.(epochs{iEpoch});
        
        mC = a.(metricName)(:,1);
        
%         if strcmpi(epochs{iEpoch},'AD')
%             mC = abs(mC);
%         end
        
        % low pass filter to smooth out traces
        if doFiltering
            f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
            
            mC = filter(f, 1, mC);
            
        end
        
        dividers(iEpoch+1) = dividers(iEpoch) + length(mC);
        
        allMC = [allMC; mC];
        aMC{iEpoch,iDate} = mC.*(180/pi);
    end
    
    if strcmpi(useMetric,'angle_error')
        allMC = allMC.*(180/pi);
    end
    
    dateDividers{iDate} = dividers;
    dateMC{iDate} = allMC;
    
    minMC(iDate) = min(allMC);
    maxMC(iDate) = max(allMC);
    
end

minMC = min(minMC);
maxMC = max(maxMC);

% now do the plotting
fh = figure('Position', figurePosition);
% subplot1(1,3);

% now plot data, each on its own axis
% subplot1(1);
hold all;
set(gca,'TickLength',[0 0],'FontSize',fontSize);
%         axis([0 1 minMC maxMC]);
xlabel('Movements','FontSize',16);
switch useMetric
    case 'curvature'
        ylabel('Curvature (cm^-^1)','FontSize',fontSize);
    case 'angle_error'
        ylabel('Angular error (deg)','FontSize',fontSize);
    case 'time_to_target'
        ylabel('Time to target (???)','FontSize',fontSize);
end

% find max length of each epoch
allMaxes = cellfun(@(x) length(x),aMC);

maxBL = max(allMaxes(1,:));
maxAD = maxBL + max(allMaxes(2,:));

for iDate = 1:size(useDate,1)
    plot(stepSize.*(1:length(aMC{1,iDate})),aMC{1,iDate},'Color',plotColors{iDate},'LineWidth',traceWidth);
    plot(stepSize.*(maxBL+1:maxBL+length(aMC{2,iDate})),aMC{2,iDate},'Color',plotColors{iDate},'LineWidth',traceWidth);
    plot(stepSize.*(maxAD+1:maxAD+length(aMC{3,iDate})),aMC{3,iDate},'Color',plotColors{iDate},'LineWidth',traceWidth);
end
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,['adaptation_' useMetric '.png']);
    saveas(fh,fn,'png');
else
    %     pause;
end

