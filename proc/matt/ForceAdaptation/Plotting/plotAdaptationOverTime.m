function fh = plotAdaptationOverTime(varargin)
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

averageAcrossDays = false;

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
    case 'angle_error'
        metricName = 'errors';
    case 'time_to_target'
        metricName = 'time_to_target';
    otherwise
        error('Metric not recognized...');
end

% load plotting parameters
fontSize = 16;
stepSize = 1;

minMC = zeros(1,size(useDate,1));
maxMC = zeros(1,size(useDate,1));
dateMC = cell(1,size(useDate,1));
numMoves = zeros(size(useDate,1),length(epochs));
for iDate = 1:size(useDate,1)
    adaptation = load(fullfile(baseDir,useDate{iDate,1},useDate{iDate,2},[useDate{iDate,4} '_' useDate{iDate,3} '_adaptation_' useDate{iDate,2} '.mat']));
    
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

% now, truncate each of the data to this length
for iDate = 1:size(useDate,1)
    for iEpoch = 1:length(epochs)
        temp = aMC{iDate,iEpoch};
        aMC{iDate,iEpoch} = temp(1:minMoves(iEpoch))';
    end
end


% now do the plotting
if isempty(fh)
    fh = figure('Position', figurePosition);
end
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
    data = [aMC{iDate,1}, aMC{iDate,2}, aMC{iDate,3}];
    plot(data,'.','Color',plotColors{iDate},'LineWidth',traceWidth);
end
legend(useDate(:,2)');
axis('tight');

% if ~isempty(saveFilePath)
%     fn = fullfile(saveFilePath,['adaptation_' useMetric '.png']);
%     saveas(fh,fn,'png');
% else
%     %     pause;
% end

% now, plot the mean

meanVals = cell(1,length(epochs));
for iEpoch = 1:length(epochs)
    meanVals{iEpoch} = mean(cell2mat(aMC(:,iEpoch)),1);
end

% now ask the question if the final 33% of AD trials are different from BL
ad_vals = meanVals{2};
ad_vals = ad_vals(ceil(0.66*length(ad_vals)):end);
[~,p] = ttest2(meanVals{1},ad_vals,'tail','both')
% now ask the question if the final 33% of WO trials are different from BL
wo_vals = meanVals{3};
wo_vals = wo_vals(ceil(0.66*length(wo_vals)):end);
[~,p] = ttest2(meanVals{1},wo_vals,'tail','both')

% figure;
% hold all;
% data = [meanVals{1},meanVals{2},meanVals{3}];
% plot(data,'.','LineWidth',3);
% 
% % fit lines and plot them
% [b_bl,~,~,~,s_bl] = regress(meanVals{1}',[ones(length(meanVals{1}),1) (1:length(meanVals{1}))']);
% [b_ad,~,~,~,s_ad] = regress(meanVals{2}',[ones(length(meanVals{2}),1) (1:length(meanVals{2}))']);
% [b_wo,~,~,~,s_wo] = regress(meanVals{3}',[ones(length(meanVals{3}),1) (1:length(meanVals{3}))']);
% 
% data = [b_bl(1)+b_bl(2)*(1:length(meanVals{1})), b_ad(1)+b_ad(2)*(1:length(meanVals{2})), b_wo(1)+b_wo(2)*(1:length(meanVals{3}))];
% 
% plot(data,'r-','LineWidth',2)


% what if, instead, I averaged in non-overlapping bins of, say, 10% of movements?
numMoves = ceil(.1*length(meanVals{1}));

meanVals = cell(1,length(epochs));
seVals = cell(1,length(epochs));
for iEpoch = 1:length(epochs)
    vals = cell2mat(aMC(:,iEpoch));
    
    inds = 1:numMoves:size(vals,2);
    
    newVals = zeros(size(vals,1),length(inds)-1);
    for j = 1:length(inds)-1
        newVals(:,j) = mean(vals(:,inds(j):inds(j+1)),2);
    end
    
    meanVals{iEpoch} = newVals;
end

data = [meanVals{1},meanVals{2},meanVals{3}];

figure;
plot(numMoves*(0:length(data)-1),data','LineWidth',2);
legend(useDate(:,2)');
set(gca,'TickDir','out','FontSize',14);
xlabel('Movements','FontSize',16);
ylabel(useMetric,'FontSize',16);



% what if, instead, I averaged in non-overlapping bins of, say, 10% of
% movements and THEN averaged across days?
numMoves = ceil(.1*length(meanVals{1}));

meanVals = cell(1,length(epochs));
seVals = cell(1,length(epochs));
for iEpoch = 1:length(epochs)
    vals = cell2mat(aMC(:,iEpoch));
    
    inds = 1:numMoves:size(vals,2);
    
    newVals = zeros(size(vals,1),length(inds)-1);
    for j = 1:length(inds)-1
        newVals(:,j) = mean(vals(:,inds(j):inds(j+1)),2);
    end
    
    meanVals{iEpoch} = mean(newVals,1);
    seVals{iEpoch} = std(newVals,1)./sqrt(size(newVals,1));
end

figure;
hold all;
data = [meanVals{1},meanVals{2},meanVals{3}];
sedata = [seVals{1},seVals{2},seVals{3}];
plot(numMoves*(0:length(data)-1),data,'bo','LineWidth',3);
for j = 0:length(data)-1
    plot(numMoves.*[j,j],[data(j+1)-sedata(j+1),data(j+1)+sedata(j+1)],'b-','LineWidth',1);
end

% fit lines and plot them
[b_bl,~,~,~,s_bl] = regress(meanVals{1}',[ones(length(meanVals{1}),1) (1:length(meanVals{1}))']);
[b_ad,~,~,~,s_ad] = regress(meanVals{2}',[ones(length(meanVals{2}),1) (1:length(meanVals{2}))']);
[b_wo,~,~,~,s_wo] = regress(meanVals{3}',[ones(length(meanVals{3}),1) (1:length(meanVals{3}))']);

data = [b_bl(1)+b_bl(2)*(1:length(meanVals{1})), b_ad(1)+b_ad(2)*(1:length(meanVals{2})), b_wo(1)+b_wo(2)*(1:length(meanVals{3}))];

plot(numMoves*(0:length(data)-1),data,'r-','LineWidth',2)
set(gca,'TickDir','out','FontSize',14);
xlabel('Movements','FontSize',16);
ylabel(useMetric,'FontSize',16);



