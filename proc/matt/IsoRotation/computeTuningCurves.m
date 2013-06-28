function [meanPD, sig] = computeTuningCurves(fr,theta,numResamples,doPlots)
% Compute tuning curves relating neural activity to output
% INPUTS
%   fr: neural firing rate for each movement
%   theta: direction of movement
%
% OUTPUTS
%   tc: tuning curve of model b0 + b1*cos(theta + b2)
%   sig: vector saying whether tuning of each cell is significant

sigThresh = 25; %degrees
cBound = 95;

theta = wrapAngle(theta,pi); % make sure it goes from [-pi,pi)

% cell array where each cell represents a direction.  Each
%  cell contains a vector where each element is the number of spikes for
%  that particular reach
uTh = unique(theta);

for iN = 1:size(fr,2)
    for iTh = 1:length(uTh)
        temp{iTh} = fr(theta==uTh(iTh),iN);
    end
    byReach{iN} = temp;
end

% Do Bootstrapping for each cell iN
for iN = 1:size(fr,2)
    res{iN} = bootstrap(@PD_angle_calc,byReach{iN},'all',numResamples);
end


for p=1:length(byReach)
    clear resTemp resTempBuffered resTempSort val idx
    bound = floor((cBound/2)/100*numResamples);
    resTemp = res{p}(:,1);
    resTempSort = sort(resTemp);
    resTempBuffered = [resTempSort; resTempSort; resTempSort];
    confBoundNew(2) = circ_mean(resTemp);
    [val, idx]= min((resTempSort - confBoundNew(2)).^2);
    idx = idx + size(res{1},1);
    confBoundNew(1) = resTempBuffered(idx-bound);
    confBoundNew(3) = resTempBuffered(idx+bound);
    confBound{p} = confBoundNew;
end

for p=1:length(byReach)
    bounds(p,1) = abs(confBound{p}(3)-confBound{p}(1));
    bounds(p,2) = bounds(p,1)*180/pi;
    meanPD(p,:) = wrapAngle(circ_mean(res{p}),pi)*180/pi;
end

% Only include cells with bounds < 25 degrees
%   Added an extra condition to remove units with no spikes
sig = bounds(:,2) <= sigThresh & sum(fr,1)' > 0;

if doPlots
    for iN = 1:length(sig)
        if sig(iN) == 1
            figure;
            % [~,I] = sort(theta);
            hold all
            plot(theta*180/pi,fr(:,iN),'r.')
            plot([meanPD(iN) meanPD(iN)],[0 max(fr(:,iN))],'k','LineWidth',2)
            pause;
            close all
        end
    end
end

