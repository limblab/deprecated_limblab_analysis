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

%%
% Make curvature plots to show adaptation over time
useDate = {'2013-08-22','RT','FF','title1'; ...
    '2013-09-04','RT','VR','title2'};
traceWidth = 3;
doFiltering = true;
filtWidth = 4;
epochs = {'BL','AD','WO'};
figurePosition =  [200, 200, 800, 600];
plotBuffer = [0.1 0.1];
plotColors = {'b','r'};
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
    end
end

switch lower(useMetric)
    case 'curvature'
        useMetric = 'sliding_curvature_mean';
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
    load(fullfile(baseDir,useDate{iDate,1},[useDate{iDate,2} '_' useDate{iDate,3} '_adaptation_' useDate{iDate,1} '.mat']));

    allMC = [];
    dividers = zeros(1,length(iEpoch)+1);
    for iEpoch = 1:length(epochs)
        a = adaptation.(epochs{iEpoch});
        mC = a.(useMetric)(:,1);

        % low pass filter to smooth out traces
        if doFiltering
            f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
            mC = filter(f, 1, mC);
        end

        dividers(iEpoch+1) = dividers(iEpoch) + length(mC);
        allMC = [allMC; mC];
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

% xlabel('Movements','FontSize',16);
ylabel('Curvature (cm^-^1)','FontSize',fontSize);

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
    h1=gca;
    h2=axes('position',get(h1,'position'));
    hold all;

    plot(dateMC{iDate}',plotColors{iDate},'LineWidth',traceWidth);

    plot([dateDividers{iDate}(1) dateDividers{iDate}(1)],[minMC-plotBuffer(1) maxMC+plotBuffer(2)],'k--','LineWidth',1);
    plot([dateDividers{iDate}(2) dateDividers{iDate}(2)],[minMC-plotBuffer(1) maxMC+plotBuffer(2)],'k--','LineWidth',1);
    
    axis('tight');
    
    axis([90 1450 minMC-plotBuffer(1) maxMC+plotBuffer(2)]);

    set(h2,'YAxisLocation','right','Color','none','XTickLabel',[],'YTickLabel',[],'TickLength',[0 0],'FontSize',16,'XTick',[]);
end



