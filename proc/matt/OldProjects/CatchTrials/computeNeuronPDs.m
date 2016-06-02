function [pds, pdmags] = computeNeuronPDs(bdf,doPlot,useIndices, useUnsorted)
% Returns a Nx3 array where N is the number of units with 
% bdf: BDF struct
% doPlot: bool whether or not to display plots
% useIndices: (optional) indices of trial table associated with the bdf to
% use. Defaults to "reward trials"

if nargin < 4
    useUnsorted = true;
    if nargin < 2
        doPlot = true;
    end
end

%Length of time window for rate calculation
windowLength = .5;
plotSize = 5;

trialTable = wf_trial_table(bdf);
% Get all of the units with spikes
unitList = unit_list(bdf, useUnsorted);

% Compute target centers
targetCenters = [(trialTable(:,4)+trialTable(:,2))/2 (trialTable(:,5)+trialTable(:,3))/2];
% Identify target IDs for successful trials

% use reward trials by default
if nargin < 3
    useIndices = trialTable(:,9) == 82;
end

rewards = trialTable( useIndices, 8);
targIDs = trialTable( useIndices, 10);

% map targids to target centers
targIDList = sort(unique(targIDs));
targMap = zeros(length(targIDList),4);
for i = 1:length(targIDList)
    target = targetCenters(find(targIDs==targIDList(i),1),:);
    targMap(i,:) = [atan2(target(2),target(1)) targIDList(i) target(1) target(2)];
end

pds = zeros(length(unitList),2);

% Loop along the units
for unit = 1:length(unitList)
    % Get binned count
    [~, ~, count] = raster(get_unit(bdf,unitList(unit,1),unitList(unit,2)), rewards, -windowLength, 0, -1);
    count = count / windowLength;
    
    % Compute mean firing at each direction
    f = zeros(length(targIDList),1);
    for idir = 1:length(targIDList)
        f(idir) = mean(count(targIDs==targIDList(idir)));        
    end % foreach target direction
    
    % preferred direction should be vector sum
    pds(unit,:) = sum([f.*targMap(:,3) f.*targMap(:,4)]);
    
    tuning_curve = [targMap(:,1) f];
    tuning_curve = sortrows(tuning_curve,1);
    pdmags(unit,:) = max(tuning_curve(:,2));

    % Start a new figure after a certain amount
    if doPlot
        if unit==1 || mod(unit,plotSize^2)==0
            figure;
        end
        subplot(plotSize, plotSize, mod(unit,plotSize^2)+1);
        polar([tuning_curve(:,1); tuning_curve(1,1)], [tuning_curve(:,2); tuning_curve(1,2)], 'ko-');
        hold on;
        plot([0 pds(unit,1)],[0 pds(unit,2)],'r-');
    end
    
end % foreach unit

pds = [unitList(:,1) pds];
pdmags = [unitList(:,1) pdmags];