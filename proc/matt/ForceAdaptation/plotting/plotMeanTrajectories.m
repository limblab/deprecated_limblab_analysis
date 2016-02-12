function posOut = plotMeanTrajectories(trialTable, pos)
% Plot the mean+/-std of force traces over distance
%  Requires the trial table with 11th catch trial column
        %    1: Start time
        %    2: Target                  -- -1 for none
        %    3: OT on time
        %    4: Go cue
        %    5: Movement start time
        %    6: Peak speed time
        %    7: End of movement window (for pd purposes)
        %    8: Trial End time
        %    9: Angle of target
        %   10: Angle of movement
        
interval = 'full';

switch lower(interval)
    case 'full'
        interval = 1;
    case 'move'
        interval = 5;
end

startTimes = trialTable(:,1);
endTimes = trialTable(:,8);

% Group all of the trials by target
targets = unique(trialTable(:,2));

% number of samples for resampling force traces
n = 3500;

figure;
hold all;
for i = 1:length(targets)
    randColor = [rand rand rand];
    relInds = find(trialTable(:,2)==targets(i));
    % For each movement to that target, find the total force applied
    
    allPosX = zeros(length(relInds),n-1);
    allPosY = zeros(length(relInds),n-1);
    
    for ind = 1:length(relInds)
        % first ind is time, second ind is x, third ind is y
        tempPos = pos(pos(:,1) >= trialTable(relInds(ind),interval) & pos(:,1) <= trialTable(relInds(ind),8),:);

        % Plot all of the force traces grouped with color by target
        %plot(tempForce(:,2), tempForce(:,3),'Color',randColor);
        
        [allPosX(ind,:), allPosY(ind,:)] = resampleTraces(tempPos(:,2), tempPos(:,3), n);

        plot(allPosX(ind,:), allPosY(ind,:),'Color',randColor);
    end
    
    % Find the mean force for each of the three conditions
    meanPos = [mean(allPosX,1); mean(allPosY,1)];
    stdPos = [std(allPosX,1); std(allPosY,1)];
    
    posOut.meanHC{i} = meanPos;
    posOut.stdHC{i} = stdPos;
    
end

% Now plot the mean/std plot for all three conditions
plotMeanByTarget(posOut.meanHC, posOut.stdHC);

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
