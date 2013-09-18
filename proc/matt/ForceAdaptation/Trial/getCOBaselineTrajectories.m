function blTraces = getCOBaselineTrajectories(data)
% returns mean trace to each target for CO


n = 3000;

interval = 'move';
switch lower(interval)
    case 'full'
        interval = 9;
    case 'move'
        interval = 10;
end


t = data.cont.t;
pos = data.cont.pos;
holdTime = data.params.hold_time;
trialTable = data.trial_table;

% Group all of the trials by target
targets = unique(trialTable(:,2));

for i = 1:length(targets)
    relInds = find(trialTable(:,2)==targets(i));
    % For each movement to that target, find the total force applied
    
    allPosX = zeros(length(relInds),n-19);
    allPosY = zeros(length(relInds),n-19);
    
    for ind = 1:length(relInds)
        % first ind is time, second ind is x, third ind is y
        tempPos = pos(t >= trialTable(relInds(ind),interval) & t <= trialTable(relInds(ind),13)-holdTime,:);
        [allPosX(ind,:), allPosY(ind,:)] = resampleTraces(tempPos(:,1), tempPos(:,2), n);
        
        % plot(allPosX(ind,:), allPosY(ind,:),'Color',randColor);
    end
    
    % Find the mean force for each of the three conditions
    meanPos = [mean(allPosX,1); mean(allPosY,1)];
    
    blTraces{i} = meanPos();
end
