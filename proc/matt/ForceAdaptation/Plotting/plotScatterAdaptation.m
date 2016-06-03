function plotScatterAdaptation(varargin)
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
baseDir = 'Z:\MrT_9I4\Matt\ProcessedData\';
useDate = {'2013-09-04','RT','VR','9-04'; ...
           '2013-09-06','RT','VR','9-04'; ...
           '2013-09-10','RT','VR','9-04'; ...
           '2013-08-20','RT','FF','9-04'; ...
           '2013-08-22','RT','FF','9-04'; ...
           '2013-08-30','RT','FF','9-04'};
useDate = {'2013-08-22','RT','FF','9-04'};
plotColors = {'r','r','r','b','b','b'};

% baseDir = 'Z:\Chewie_8I2\Matt\ProcessedData\';
% useDate = {'2013-10-09','RT','VR','10-09'; ...
%            '2013-10-11','RT','VR','10-11'; ...
%            '2013-10-28','RT','FF','10-28'; ...
%            '2013-10-29','RT','FF','10-29'};
% plotColors = {'r','r','b','b'};

doAbs = true;
traceWidth = 5;
epochs = {'BL','AD','WO'};
figurePosition =  [200, 200, 800, 600];
% plotColors = {'r','r','r','b','b','b'};
useMetric = 'angle_error';
saveFilePath = [];
plotScatter = true;
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'dir'
            baseDir = varargin{i+1};
        case 'dates'
            useDate = varargin{i+1};
        case 'metric'
            useMetric = varargin{i+1};
        case 'epochs'
            epochs = varargin{i+1};
        case 'colors'
            plotColors = varargin{i+1};
        case 'tracewidth'
            traceWidth = varargin{i+1};
        case 'figurepos'
            figurePosition = varargin{i+1};
        case 'savepath'
            saveFilePath = varargin{i+1};
        case 'plotscatter'
            plotScatter = varargin{i+1};
    end
end

switch lower(useMetric)
    case 'curvature'
        metricName = 'curvature_means';
    case 'angle_error'
        metricName = 'errors';
    otherwise
        error('Metric not recognized...');
end

% load plotting parameters
fontSize = 16;

allMC = cell(length(epochs),size(useDate,1));
dividers = zeros(length(epochs),size(useDate,1));
for iDate = 1:size(useDate,1)
    adaptation = load(fullfile(baseDir,useDate{iDate,1},[useDate{iDate,2} '_' useDate{iDate,3} '_adaptation_' useDate{iDate,1} '.mat']));

    for iEpoch = 1:length(epochs)
        a = adaptation.(epochs{iEpoch});
        
        mC = a.(metricName)(:,1);
        
        
        
        if strcmpi(useMetric,'angle_error')
            % remove outliers
            mC(mC > circular_mean(mC)+2*circular_std(mC)) = [];
            mC = mC.*(180/pi);
        end
        
        dividers(iEpoch,iDate) = length(mC);
        
        % fit a line to baseline
        if strcmpi(epochs{iEpoch},'BL')
            b(:,iEpoch)=regress(mC,[ones(size(mC))'; 1:length(mC)]');
        elseif strcmpi(epochs{iEpoch},'AD')
            % fit a decaying exponential to adaptation
            b(:,iEpoch)=regress(mC,[ones(size(mC))'; log(1:length(mC))]');
        else
            % fit a rising exponential to washout
            b(:,iEpoch)=regress(mC,[ones(size(mC))'; log(1:length(mC))]');
            %plot(b(1)+b(2).*log((1:length(mC))))
        end

        allB{iDate} = b;
        allMC{iEpoch,iDate} = mC;
    end
end

% now do the plotting
fh = figure('Position', figurePosition);
hold all;
set(gca,'TickLength',[0 0],'FontSize',fontSize,'XTick',[]);
% axis([0 1 minMC maxMC]);

xlabel('Movements','FontSize',16);

switch useMetric
    case 'curvature'
        ylabel('Curvature (cm^-^1)','FontSize',fontSize);
    case 'angle_error'
        ylabel('Angular error (deg)','FontSize',fontSize);
end


% find the max length of each epoch
maxDividers = [];


% now plot data, each on its own axis
subplot1(1,3);
for iDate = 1:size(useDate,1)
%     dd = dateDividers{iDate};
%     mc = dateMC{iDate}';
    b = allB{iDate};
    subplot1(1);
    hold all;
    if plotScatter
        plot(1:length(allMC{1,iDate}),allMC{1,iDate},'.','Color',plotColors{iDate},'LineWidth',1);
    end
    plot(1:length(allMC{1,iDate}),b(1,1)+b(2,1).*(1:length(allMC{1,iDate})),'Color',plotColors{iDate},'LineWidth',traceWidth);
    axis('tight');
    V = axis;
    axis([V(1) V(2) -60 60]);
    
    subplot1(2);
    hold all;
    if plotScatter
        plot(1:length(allMC{2,iDate}),allMC{2,iDate},'.','Color',plotColors{iDate},'LineWidth',1);
    end
    
    
    plot(1:length(allMC{2,iDate}),b(1,2)+b(2,2).*log(1:length(allMC{2,iDate})),'Color',plotColors{iDate},'LineWidth',traceWidth);
    axis('tight');
    V = axis;
    axis([V(1) V(2) -60 60]);
    
        subplot1(3);
    hold all;
    if plotScatter
        plot(1:length(allMC{3,iDate}),allMC{3,iDate},'.','Color',plotColors{iDate},'LineWidth',1);
    end
    plot(1:length(allMC{3,iDate}),b(1,3)+b(2,3).*log(1:length(allMC{3,iDate})),'Color',plotColors{iDate},'LineWidth',traceWidth);
    axis('tight');
    V = axis;
    axis([V(1) V(2) -60 60]);
    
end

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,['adaptation_' useMetric '.png']);
    saveas(fh,fn,'png');
else
    %     pause;
end

