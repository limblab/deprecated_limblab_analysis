function targetData = plotForceSummaryByTarget(trialTable, force, interval)
% Plot the total (integrated) force for each of the target directions

if nargin < 3
    interval = 'move';
end

switch lower(interval)
    case 'full'
        interval = 1;
    case 'move'
        interval = 7;
end

% Group all of the trials by target
targets = unique(trialTable(:,10));
% Get polar theta coordinates for each target
targcoords = 0:2*pi/length(targets):2*pi-0.00001;

for i = 1:length(targets)
    relInds = find(trialTable(:,10)==targets(i));
    totalForce = zeros(length(relInds),1);
    peakForce = zeros(length(relInds),1);
    meanForce = zeros(length(relInds),1);
    stdForce = zeros(length(relInds),1);
    % For each movement to that target, find the total force applied
    for ind = 1:length(relInds)
        tempForce = force.data(force.data(:,1) >= trialTable(relInds(ind),interval) & force.data(:,1) <= trialTable(relInds(ind),8),:);
        DeltaX = diff(tempForce(:,2));
        DeltaY = diff(tempForce(:,3));
        
        totalForce(ind) = sum(sqrt(DeltaX.^2 + DeltaY.^2));
        peakForce(ind) = max(sqrt(tempForce(:,2).^2 + tempForce(:,3).^2));
        meanForce(ind) = mean(sqrt(tempForce(:,2).^2 + tempForce(:,3).^2));
        stdForce(ind) = std(sqrt(tempForce(:,2).^2 + tempForce(:,3).^2));
    end
    
    % add the forces to the trial table
    tempTable = trialTable(relInds,:);
    targetData.(['Target' num2str(targets(i))]) = [tempTable totalForce peakForce meanForce stdForce];
    
    % Find the mean force for each of the three conditions
    indsHC = find(tempTable(:,11) == 0);
    indsCT = find(tempTable(:,11) == 1);
    indsBC = find(tempTable(:,11) == 2);
    
    meanHC(i,:) = [mean(totalForce(indsHC)) std(totalForce(indsHC))];
    meanCT(i,:) = [mean(totalForce(indsCT)) std(totalForce(indsCT))];
    meanBC(i,:) = [mean(totalForce(indsBC)) std(totalForce(indsBC))];
end

% Make polar plot
targcoords = [targcoords targcoords(1)];
meanHC = [meanHC(:,1); meanHC(1,1)]';
meanBC = [meanBC(:,1); meanBC(1,1)]';
meanCT = [meanCT(:,1); meanCT(1,1)]';

figure;
polar(targcoords, meanCT,'k');
hold all;
polar(targcoords, meanBC,'b');
polar(targcoords, meanHC,'r');

