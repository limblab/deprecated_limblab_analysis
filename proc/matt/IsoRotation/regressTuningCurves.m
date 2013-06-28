function [tunCurves, p] = regressTuningCurves(fr,offsetFR,theta,doPlots)
% Compute tuning curves relating neural activity to output
% INPUTS
%   fr: neural firing rate for each movement
%   theta: direction of movement
%
% OUTPUTS
%   tc: tuning curve of model b0 + b1*cos(theta + b2)
%   sig: vector saying whether tuning of each cell is significant
%
% Unlike computeTuningCurves which finds PDs with vector sum and uses
% bootstrapping for significance, this fits tuning curves with cosine and
% uses a one-way ANOVA for significance

sig = 0.1; % level for R2 significance


oldfr = fr;

% Subtract non-directional component and find the directional tuning curve
for unit = 1:size(fr,2)
    fr(:,unit) = fr(:,unit) - offsetFR(unit);
end

%%% Only consider well-tuned cells
%   Do one way ANOVA for tuning?
% Put into bins
% angSize = pi/4;
% thetaBin = round(theta./angSize);
for i = 1:size(fr,2)
    ap(i) = anova1(fr(:,i),theta,'off');
end

tunCurves = zeros(size(fr,2),3);

st = sin(theta);
ct = cos(theta);
X = [ones(size(theta)) st ct];

for iN = 1:size(fr,2)
    % model is b0+b1*cos(theta)+b2*sin(theta)
    [b,~,~,~,temp] = regress(fr(:,iN),X);
    p(iN) = temp(1);
    
    % convert to model b0 + b1*cos(theta+b2)
    b  = [b(1); sqrt(b(2).^2 + b(3).^2); atan2(b(2),b(3))];
    
    if doPlots && p(iN)
        temp = b(1) + b(2)*cos(theta-b(3));
        [~,I] = sort(theta);
        plot(theta(I),temp(I),'b','LineWidth',2)
        hold all
        plot(theta,fr(:,iN),'r.')
        plot([b(3) b(3)],[0 max(fr(:,iN))],'k')
        title(['r2 = ' num2str(p(iN))]);
        pause;
        close all
    end
    tunCurves(iN,:) = b;
end

p = p > sig;
