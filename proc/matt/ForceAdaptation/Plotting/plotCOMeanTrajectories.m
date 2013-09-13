function [meanHC,stdHC] = plotCOMeanTrajectories(data, saveFilePath)
% Plot the mean+/-std of force traces over distance
%   Trial table:
%    1: Start time
%    2: Target ID                 -- -1 for none
%`   3: Target angle (rad)
%    4-7: Target location (ULx ULy LRx LRy)
%    8: OT on time
%    9: Go cue
%    10: Movement start time
%    11: Peak speed time
%    12: Movement end time
%    13: Trial End time
        
interval = 'full';

switch lower(interval)
    case 'full'
        interval = 9;
    case 'move'
        interval = 10;
end



% number of samples for resampling force traces
n = 3000;

t = data.cont.t;
pos = data.cont.pos;
holdTime = data.params.hold_time; %hold period in seconds
trialTable = data.trial_table;
epoch = data.meta.epoch;

% Group all of the trials by target
targets = unique(trialTable(:,2));

fh = figure;
hold all;
for i = 1:length(targets)
    randColor = [rand rand rand];
    relInds = find(trialTable(:,2)==targets(i));
    % For each movement to that target, find the total force applied
    
    allPosX = zeros(length(relInds),n-19);
    allPosY = zeros(length(relInds),n-19);
    
    for ind = 1:length(relInds)
        % first ind is time, second ind is x, third ind is y
        tempPos = pos(t >= trialTable(relInds(ind),interval) & t <= trialTable(relInds(ind),13)-holdTime,:);

        % Plot all of the force traces grouped with color by target
        plot(tempPos(:,1), tempPos(:,2),'Color',randColor);
        % resample
        [allPosX(ind,:), allPosY(ind,:)] = resampleTraces(tempPos(:,1), tempPos(:,2), n);
    end
    
    % Find the mean force for each of the three conditions
    meanPos = [mean(allPosX,1); mean(allPosY,1)];
    stdPos = [std(allPosX,1); std(allPosY,1)];
    
    meanHC{i} = meanPos;
    stdHC{i} = stdPos;
    
%     keyboard
end

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_CO_trajectories_all.png']);
    saveas(fh,fn,'png');
else
    close all
end

% Now plot the mean/std plot for all three conditions
fh = plotMeanByTarget(meanHC,stdHC);

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_CO_trajectories_mean.png']);
    saveas(fh,fn,'png');
else
    close all;
end

end

%%%%%%%%%%%%%%%%
function fh = plotMeanByTarget(meanCell, stdCell)
% Make single plot in x-y coordinates showing mean+/- std for the provided
% data to each target
% f is X-Y mean/std force values (2x2 array)

fh = figure;
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
%     plot(meanf(1,:)+stdf(1,:), meanf(2,:)+stdf(2,:),'--','Color',randColor);
%     plot(meanf(1,:)-stdf(1,:), meanf(2,:)-stdf(2,:),'--','Color',randColor);
end
axis('tight');

end
