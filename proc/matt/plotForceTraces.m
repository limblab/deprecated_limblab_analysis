function forceOut = plotForceTraces(trialTable, force)
% Plot the mean+/-std of force traces over distance
%  Requires the trial table with 11th catch trial column

interval = 'full';

switch lower(interval)
    case 'full'
        interval = 1;
    case 'move'
        interval = 7;
end

startTimes = trialTable(:,1);
endTimes = trialTable(:,8);

% Group all of the trials by target
targets = unique(trialTable(:,10));

% number of samples for resampling force traces
n = 3500;

figure;
hold all;
for i = 1:length(targets)
    randColor = [rand rand rand];
    relInds = find(trialTable(:,10)==targets(i));
    indsHC = find(trialTable(relInds,11) == 0);
    indsCT = find(trialTable(relInds,11) == 1);
    indsBC = find(trialTable(relInds,11) == 2);
    % For each movement to that target, find the total force applied
    
    allForceX = zeros(length(relInds),n-1);
    allForceY = zeros(length(relInds),n-1);
    
    for ind = 1:length(relInds)
        % first ind is time, second ind is x, third ind is y
        tempForce = force.data(force.data(:,1) >= trialTable(relInds(ind),interval) & force.data(:,1) <= trialTable(relInds(ind),8),:);

        % Plot all of the force traces grouped with color by target
        %plot(tempForce(:,2), tempForce(:,3),'Color',randColor);
        
        [allForceX(ind,:), allForceY(ind,:)] = resampleTraces(tempForce(:,2), tempForce(:,3), n);

        plot(allForceX(ind,:), allForceY(ind,:),'Color',randColor);
    end
    
    % Find the mean force for each of the three conditions
    meanForceHC = [mean(allForceX(indsHC,:),1); mean(allForceY(indsHC,:),1)];
    stdForceHC = [std(allForceX(indsHC,:),1); std(allForceY(indsHC,:),1)];
    
    meanForceCT = [mean(allForceX(indsCT,:),1); mean(allForceY(indsCT,:),1)];
    stdForceCT = [std(allForceX(indsCT,:),1); std(allForceY(indsCT,:),1)];
    
    meanForceBC = [mean(allForceX(indsBC,:),1); mean(allForceY(indsBC,:),1)];
    stdForceBC = [std(allForceX(indsBC,:),1); std(allForceY(indsBC,:),1)];
    
    forceOut.meanHC{i} = meanForceHC;
    forceOut.stdHC{i} = stdForceHC;
    forceOut.meanCT{i} = meanForceCT;
    forceOut.stdCT{i} = stdForceCT;
    forceOut.meanBC{i} = meanForceBC;
    forceOut.stdBC{i} = stdForceBC;
    
end

% Now plot the mean/std plot for all three conditions
%plotMeanByTarget(forceOut.meanHC, forceOut.stdHC);
%plotMeanByTarget(forceOut.meanCT, forceOut.stdCT);
%plotMeanByTarget(forceOut.meanBC, forceOut.stdBC);

% Plot
plotMeans(forceOut);

%plotStds(forceOut);

% Plot for each target the three conditions
%plotMeanByCondition(forceOut);

end


%%%%%%%%%%%%%%%
function [x, y] = resampleTraces(x,y,n)
% Put all of the data in a consistent time scale
% x: x data, y: y data, n: # resampling points

x = resample(double(x),n,length(x),5);
y = resample(double(y),n,length(y),5);

% trim last point?
x = x(1:end-1);
y = y(1:end-1);

end


%%%%%%%%%%%%%%%
function plotMeans(forceOut)
% Plot the means for all three conditions for all targets in one x-y plot

figure;
hold all;
for i = 1:length(forceOut.meanHC)
    randColor = [rand rand rand];
    meanf = forceOut.meanHC{i};
    plot(meanf(1,:),meanf(2,:),'LineWidth',2,'Color','k');
    meanf = forceOut.meanCT{i};
    plot(meanf(1,:),meanf(2,:),'--','LineWidth',2,'Color','r');
    meanf = forceOut.meanBC{i};
    plot(meanf(1,:),meanf(2,:),':','LineWidth',2,'Color','b');
    
end
axis('tight');

end


%%%%%%%%%%%%%%%
function plotStds(forceOut)
% Plot the stds for all three conditions for all targets in one x-y plot

figure;
hold all;
for i = 1:length(forceOut.meanHC)
    meanf = forceOut.meanBC{i};
    stdf = forceOut.stdBC{i};
    
    xs = [meanf(1,:) + stdf(1,:); meanf(1,:) - stdf(1,:)];
    ys = [meanf(2,:) + stdf(2,:); meanf(2,:) - stdf(2,:)];
    
    patch(xs', ys', 'b')
    
    meanf = forceOut.meanCT{i};
    stdf = forceOut.stdCT{i};
    
    xs = [meanf(1,:) + stdf(1,:); meanf(1,:) - stdf(1,:)];
    ys = [meanf(2,:) + stdf(2,:); meanf(2,:) - stdf(2,:)];
    
    patch(xs', ys', 'r')
    
    meanf = forceOut.meanHC{i};
    stdf = forceOut.stdHC{i};
    
    xs = [meanf(1,:) + stdf(1,:); meanf(1,:) - stdf(1,:)];
    ys = [meanf(2,:) + stdf(2,:); meanf(2,:) - stdf(2,:)];
    
    patch(xs', ys', 'k')
    
end
axis('tight');

end


%%%%%%%%%%%%%%%%
function plotMeanByCondition(forceOut)
% Make a plot for each target with three subplots showing the mean+/-std
% for the three conditions

for i = 1:length(forceOut.meanHC)
    figure;
    subplot(3,1,1);
    hold all;
    meanf = forceOut.meanHC{i};
    stdf = forceOut.stdHC{i};
    plot(meanf(1,:),meanf(2,:),'LineWidth',2);
    plot(meanf(1,:)+stdf(1,:), meanf(2,:)+stdf(2,:),'--');
    plot(meanf(1,:)-stdf(1,:), meanf(2,:)-stdf(2,:),'--');
    
    subplot(3,1,2);
    hold all;
    meanf = forceOut.meanCT{i};
    stdf = forceOut.stdCT{i};
    plot(meanf(1,:),meanf(2,:),'LineWidth',2);
    plot(meanf(1,:)+stdf(1,:), meanf(2,:)+stdf(2,:),'--');
    plot(meanf(1,:)-stdf(1,:), meanf(2,:)-stdf(2,:),'--');
    
    subplot(3,1,3);
    hold all;
    meanf = forceOut.meanBC{i};
    stdf = forceOut.stdBC{i};
    plot(meanf(1,:),meanf(2,:),'LineWidth',2);
    plot(meanf(1,:)+stdf(1,:), meanf(2,:)+stdf(2,:),'--');
    plot(meanf(1,:)-stdf(1,:), meanf(2,:)-stdf(2,:),'--');
    axis('tight');
end

end



%%%%%%%%%%%%%%%%
function plotMeanByTarget(meanCell, stdCell)
% Make single plot in x-y coordinates showing mean+/- std for the provided
% data to each target
% f is X-Y mean/std force values (2x2 array)

figure;
hold all
for i=1:length(meanCell)
    randColor = [rand rand rand];
    
    meanf = meanCell{i};
    stdf = stdCell{i};
    xs = [meanf(1,:) + stdf(1,:); meanf(1,:) - stdf(1,:)];
    ys = [meanf(2,:) + stdf(2,:); meanf(2,:) - stdf(2,:)];

    % plot shaded area for std
    %patch([xs fliplr(xs)], [ys,fliplr(ys)],'g');
    %patch(xs', ys','g');
    
    % plot mean trace
    plot(meanf(1,:), meanf(2,:), 'Color', randColor, 'LineWidth', 2);
    plot(meanf(1,:)+stdf(1,:), meanf(2,:)+stdf(2,:),'--','Color',randColor);
    plot(meanf(1,:)-stdf(1,:), meanf(2,:)-stdf(2,:),'--','Color',randColor);
end
axis('tight');

end
