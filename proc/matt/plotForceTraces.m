function plotForceTraces(trialTable, force)
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
n = 1000;

for i = 1:length(targets)
    relInds = find(trialTable(:,10)==targets(i));
    indsHC = find(trialTable(relInds,11) == 0);
    indsCT = find(trialTable(relInds,11) == 1);
    indsBC = find(trialTable(relInds,11) == 2);
    % For each movement to that target, find the total force applied
    
    allForceX = zeros(length(relInds),n);
    allForceY = zeros(length(relInds),n);
    
    for ind = 1:length(relInds)
        % first ind is time, second ind is x, third ind is y
        tempForce = force.data(force.data(:,1) >= trialTable(relInds(ind),interval) & force.data(:,1) <= trialTable(relInds(ind),8),:);
        
        fuck = 'yes';
        switch fuck
            case 'yes'
                % plot all the traces
                plot(tempForce(:,2), tempForce(:,3));
            case 'no'
                % plot mean +/- std
                [allForceX(ind,:), allForceY(ind,:)] = resampleTraces(tempForce(:,2), tempForce(:,3), n);
        end

    end
    
    % Find the mean force for each of the three conditions        
    meanForceHC = [mean(allForceX(indsHC,:),1) std(allForceX(indsHC,:),1); mean(allForceY(indsHC,:),1) std(allForceY(indsHC,:),1)];
    meanForceCT = [mean(allForceX(indsCT,:),1) std(allForceX(indsCT,:),1); mean(allForceY(indsCT,:),1) std(allForceY(indsCT,:),1)];
    meanForceBC = [mean(allForceX(indsBC,:),1) std(allForceX(indsBC,:),1); mean(allForceY(indsBC,:),1) std(allForceY(indsBC,:),1)];
    
    figure;
    
end

end

function [x, y] = resampleTraces(x,y,n)
% x: x data, y: y data, n: # resampling points

x = resample(x,n,length(x));
y = resample(y,n,length(y));

end

function H = plotplotplot(f)
% f is X-Y mean/std force values (2x2 array)
H = figure;
hold all

% plot shaded area for std

% plot mean trace

end
