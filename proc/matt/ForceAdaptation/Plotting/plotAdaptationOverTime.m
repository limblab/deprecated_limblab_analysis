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
baseDir = 'Z:\MrT_9I4\Matt\ProcessedData\';
useDate = {'2013-09-04','RT','VR','9-04'; ...
           '2013-09-06','RT','VR','9-06'; ...
           '2013-09-10','RT','VR','9-10'; ...
           '2013-08-20','RT','FF','8-20'; ...
           '2013-08-22','RT','FF','8-22'; ...
           '2013-08-30','RT','FF','8-30'};
% useDate = {'2013-09-24','RT','VRFF','9-24'; ...
%            '2013-09-25','RT','VRFF','9-25'; ...
%            '2013-09-27','RT','VRFF','9-27 '};
% useDate = {'2013-09-03','CO','VR','9-04'; ...
%            '2013-09-05','CO','VR','9-06'; ...
%            '2013-09-09','CO','VR','9-10'; ...
%            '2013-08-19','CO','FF','8-20'; ...
%            '2013-08-21','CO','FF','8-22'; ...
%            '2013-08-23','CO','FF','8-30'};
traceWidth = 1;
doFiltering = true;
filtWidth = 15;
epochs = {'BL','AD','WO'};
figurePosition =  [200, 200, 800, 600];
plotBuffer = [0.1 0.1];
plotColors = {'b','b','b','r','r','r'};
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
    end
end

switch lower(useMetric)
    case 'curvature'
        metricName = 'sliding_curvature_mean';
    case 'angle_error'
        metricName = 'sliding_error_mean';
    otherwise
        error('Metric not recognized...');
end

% load plotting parameters
fontSize = 16;

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
        
        % low pass filter to smooth out traces
        if doFiltering
            f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
            mC = filter(f, 1, mC);
        end
        
        dividers(iEpoch+1) = dividers(iEpoch) + length(mC);
        
        allMC = [allMC; mC];
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
hold all;
set(gca,'TickLength',[0 0],'FontSize',fontSize,'XTick',[]);
axis([0 1 minMC maxMC]);

xlabel('Movements','FontSize',16);

switch useMetric
    case 'curvature'
        ylabel('Curvature (cm^-^1)','FontSize',fontSize);
    case 'angle_error'
        ylabel('Angular error (deg)','FontSize',fontSize);
end



% add labels and legend
% plot([950 1100],[0.38 0.38],'b','LineWidth',3);
% plot([950 1100],[0.33 0.33],'r','LineWidth',3);
% text(1150,0.38,'Force Field','FontSize',fontSize);
% text(1150,0.33,'Rotation','FontSize',fontSize);
%
% text(150,-0.35,'Baseline','FontSize',fontSize);
% text(600,-0.35,'Adaptation','FontSize',fontSize);
% text(1150,-0.35,'Washout','FontSize',fontSize);

% now plot data, each on its own axis
for iDate = 1:size(useDate,1)
%     h1=gca;
%     h2=axes('position',get(h1,'position'));
    hold all;
    
    dd = dateDividers{iDate};
    mc = dateMC{iDate}';

    for j = 2:length(dd)
        plot( linspace((0.33333.*(j-2)),(0.33333.*(j-1)),dd(j)-dd(j-1)), mc(dd(j-1)+1:dd(j)),'Color',plotColors{iDate},'LineWidth',traceWidth);
    end
%     plot(dateMC{iDate}',plotColors{iDate},'LineWidth',traceWidth);
%     plot([dd(2) dd(2)],[minMC-plotBuffer(1) maxMC+plotBuffer(2)],'--','LineWidth',1,'Color',plotColors{iDate});
%     plot([dd(3) dd(3)],[minMC-plotBuffer(1) maxMC+plotBuffer(2)],'--','LineWidth',1,'Color',plotColors{iDate});
%     axis([0 length(dateMC{iDate}) minMC-plotBuffer(1) maxMC+plotBuffer(2)]);
    
%     set(h2,'YAxisLocation','right','Color','none','XTickLabel',[],'YTickLabel',[],'TickLength',[0 0],'FontSize',16,'XTick',[]);
end

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,['adaptation_' useMetric '.png']);
    saveas(fh,fn,'png');
else
%     pause;
end

