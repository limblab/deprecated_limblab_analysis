function plotCOTrajectoriesStartEnd(data, saveFilePath)
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

numTraces = 2;
doMean = true;

% number of samples for resampling force traces
n = 3000;

if nargin < 2
    saveFilePath = [];
end

interval = 'full';
switch lower(interval)
    case 'full'
        interval = 9;
    case 'move'
        interval = 10;
end

trialTable = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
holdTime = data.params.hold_time; %hold period in seconds
epoch = data.meta.epoch;

% Group all of the trials by target
targets = unique(trialTable(:,2));

fh = figure;
hold all;
for i = 1:length(targets)
    relInds = find(trialTable(:,2)==targets(i));
    % For each movement to that target, find the total force applied
    
    for ind = 1:numTraces
        % get first few movements
        tempPos = pos(t >= trialTable(relInds(ind),interval) & t <= trialTable(relInds(ind),13)-holdTime,:);
        [allx_1(:,ind),ally_1(:,ind)] = resampleTraces(tempPos(:,1), tempPos(:,2), n);
        
        % get last few movements
        tempPos = pos(t >= trialTable(relInds(end-(ind-1)),interval) & t <= trialTable(relInds(end-(ind-1)),13)-holdTime,:);
        [allx_2(:,ind),ally_2(:,ind)] = resampleTraces(tempPos(:,1), tempPos(:,2), n);
    end
    
    adaptColor = 'r';
    if any(relInds==1) %first movement
        adaptColor = 'g';
    end
    
    if doMean
        plot(mean(allx_1(10:end-10,:),2),mean(ally_1(10:end-10,:),2),adaptColor,'LineWidth',2);
        plot(mean(allx_2(10:end-10,:),2),mean(ally_2(10:end-10,:),2),'b','LineWidth',2);
    else
        plot(allx_1(10:end-10,:),ally_1(10:end-10,:),adaptColor,'LineWidth',2);
        plot(allx_2(10:end-10,:),ally_2(10:end-10,:),'b','LineWidth',2);
    end
    
end
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_CO_trajectories_first_and_last.png']);
    saveas(fh,fn,'png');
else
    pause;
end

end

%%%%%%%%%%%%%%%
function [x, y] = resampleTraces(x,y,n)
% Put all of the data in a consistent time scale
% x: x data, y: y data, n: # resampling points

x = resample(double(x),n,length(x),5);
y = resample(double(y),n,length(y),5);

% trim last point?
x = x(5:end-5);
y = y(5:end-5);

end
