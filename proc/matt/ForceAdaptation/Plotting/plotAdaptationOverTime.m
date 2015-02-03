function [fh,outData] = plotAdaptationOverTime(varargin)
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

doBLDiff = false;

averageAcrossDays = false;
fillColors = {'b',[0.8 0.9 1];'r',[1 0.9 0.8];'g',[0.9 1 0.8]};

%%
% Make curvature plots to show adaptation over time

traceWidth = 2;
doFiltering = false;
filtWidth = 4;
epochs = {'BL','AD','WO'};
figurePosition =  [200, 200, 800, 600];
plotBuffer = [0.1 0.1];
plotColors = {'b','b','r','r'};
useMetric = 'angle_error';
saveFilePath = [];
fh = [];
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
        case 'handle'
            fh = varargin{i+1};
    end
end

switch lower(useMetric)
    case 'curvature'
        metricName = 'curvatures';
        if doBLDiff
            ymin = -0.2;
            ymax = 1;
        else
            ymin = 0.2;
            ymax = 1.5;
        end
    case 'angle_error'
        metricName = 'errors';
        ymin = -15;
        ymax = 5;
    case 'time_to_target'
        metricName = 'time_to_target';
        ymin = 0;
        ymax = 0.2;
    otherwise
        error('Metric not recognized...');
end

% load plotting parameters
fontSize = 24;
stepSize = 1;

minMC = zeros(1,size(useDate,1));
maxMC = zeros(1,size(useDate,1));
dateMC = cell(1,size(useDate,1));
numMoves = zeros(size(useDate,1),length(epochs));
for iDate = 1:size(useDate,1)
    adaptation = loadResults(root_dir,useDate(iDate,:),'adaptation');
        
    allMC = [];
    for iEpoch = 1:length(epochs)
        a = adaptation.(epochs{iEpoch});
        
        mC = a.(metricName)(:,1);
        
        if strcmpi(useMetric,'angle_error')
            %mC = abs(mC);
            mC = mC.*(180/pi);
        end
        
        % low pass filter to smooth out traces
        if doFiltering
            f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
            mC = filter(f, 1, mC);
        end
        
        numMoves(iDate,iEpoch) = length(mC);
        allMC = [allMC; mC];
        aMC{iDate,iEpoch} = mC;
    end
    
    dateMC{iDate} = allMC;
    
    minMC(iDate) = min(allMC);
    maxMC(iDate) = max(allMC);
end

minMC = min(minMC);
maxMC = max(maxMC);


% get the minimum length across files in each epoch
minMoves = min(numMoves,[],1);

% now, truncate each of the data to this length. So throw away later trials
% from longer sessions
for iDate = 1:size(useDate,1)
    for iEpoch = 1:length(epochs)
        temp = aMC{iDate,iEpoch};
        aMC{iDate,iEpoch} = temp(1:minMoves(iEpoch))';
    end
end

%%
% what if, instead, I averaged in non-overlapping bins of, say, 10% of
% movements and THEN averaged across days?
% numMoves = ceil(.35*length(mean(cell2mat(aMC(:,1)),1)));
numMoves(1) = ceil(0.99*length(mean(cell2mat(aMC(:,1)),1)));
numMoves(2) = ceil(.19*length(mean(cell2mat(aMC(:,2)),1)));
numMoves(3) = ceil(.32*length(mean(cell2mat(aMC(:,3)),1)));

meanVals = cell(1,length(epochs));
seVals = cell(1,length(epochs));
count = 0;
% loop along epochs
for iEpoch = 1:length(epochs)
    % get the values for the adaptation metric in this epoch
    vals = cell2mat(aMC(:,iEpoch));
    
    % get trial indices for each bin, defined above. This is starting and
    % ending points of each bin (so min length is 2)
    inds = 1:numMoves(iEpoch):size(vals,2);
    
    % loop along each bin and get all trials from start of one bin to the
    % start of the next bin
    newVals = cell(1,length(inds)-1);
    for j = 1:length(inds)-1
        % rows are sessions, columns are trials
        temp = vals(:,inds(j):inds(j+1));
        
        % reshape to stitch all sessions together into one big pool
        newVals{j} = reshape(temp,size(temp,1)*size(temp,2),1);
        
        % compile a list of all of the data for significance testing
        count = count + 1;
        allData{count} = reshape(temp,size(temp,1)*size(temp,2),1);
        
        for iDate = 1:size(useDate,1)
            % now get data for output
            vals = aMC{iDate,iEpoch};
            temp = vals(:,inds(j):inds(j+1));
            outData{iDate,count} = reshape(temp,size(temp,1)*size(temp,2),1);
        end
    end
    
    % take mean and std of pooled trials
    meanVals{iEpoch} = cellfun(@(x) nanmean(x),newVals);
    seVals{iEpoch} = cellfun(@(x) nanstd(x)./sqrt(size(x,1)),newVals);
    
    %meanVals{iEpoch} = mean(newVals,1);
    %seVals{iEpoch} = std(newVals,1)./sqrt(size(newVals,1));
    
    
end

allTests(1) = 1;
for i = 1:length(allData)
    for j = 1:length(allData)
        if i==j
            allTests(i,j) = 1;
        else
            [~,p] = ttest2(allData{i},allData{j});
            allTests(i,j) = p < 0.05; 
        end
    end
end


%% now do the plotting
if isempty(fh)
    fh = figure('Position', figurePosition);
else
    figure(fh);
end
hold all;
data = [meanVals{1},meanVals{2},meanVals{3}];
sedata = [seVals{1},seVals{2},seVals{3}];

if doBLDiff
    data = data - data(1);
end
% plot baseline across screen
% patch([-1,length(data),length(data),-1],[data(1)-sedata(1),data(1)-sedata(1),data(1)+sedata(1),data(1)+sedata(1)],fillColors{strcmpi(fillColors(:,1),plotColors{1}),2},'EdgeColor',fillColors{strcmpi(fillColors(:,1),plotColors{1}),2});

% h = findobj(gca,'Type','patch');
% set(h,'facealpha',0.8,'edgealpha',0.8);
% plot([-1,length(data)],[data(1),data(1)],'LineWidth',2,'Color',plotColors{1})

% plot the data
%plot((0:length(data)-1),data,'o','LineWidth',3,'Color',plotColors{1});
for j = 1:length(data)
    if ~allTests(1,j)
        plot(j-1,data(j),'o','LineWidth',3,'Color',plotColors{1});
    else
        plot(j-1,data(j),'o','LineWidth',3,'Color',plotColors{1});
    end
    plot([j-1,j-1],[data(j)-sedata(j),data(j)+sedata(j)],'-','LineWidth',2,'Color',plotColors{1});
end

axis('tight');
set(gca,'TickDir','out','FontSize',fontSize,'XLim',[-1 length(data)],'YLim',[ymin ymax],'XTick',[0 2 5],'XTickLabel',{'Baseline','Adaptation','Washout'});
box off;
switch useMetric
    case 'curvature'
        ylabel('Curvature (cm^-^1)','FontSize',fontSize);
    case 'angle_error'
        ylabel('Angular error (deg)','FontSize',fontSize);
    case 'time_to_target'
        ylabel('Time to target (???)','FontSize',fontSize);
end

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,['adaptation_' useMetric '.png']);
    saveas(fh,fn,'png');
    fn = fullfile(saveFilePath,['adaptation_' useMetric '.fig']);
    saveas(fh,fn,'fig');
end

% % now add lines showing significance
% % compare 1 to 2
% if allTests(1,2)
%     plot([0,1],[data(1),data(2)]);
% end
% % compare 2 to 4
% if allTests(2,4)
%     plot([1,3],[data(2),data(4)]);
% end
% % compare 1 to 4
% if allTests(1,4)
%     plot([0,3],[data(1),data(4)]);
% end
% % compare 1 to 5
% if allTests(1,5)
%     plot([0,4],[data(1),data(5)]);
% end
% % compare 5 to 7
% if allTests(5,7)
%     plot([4,6],[data(5),data(7)]);
% end
% % compare 1 to 7
% if allTests(1,7)
%     plot([0,6],[data(1),data(7)]);
% end
% 



