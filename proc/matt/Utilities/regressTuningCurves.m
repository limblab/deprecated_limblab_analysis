function [tunCurves,sig] = regressTuningCurves(fr,theta,sigTest,varargin)
% Compute cosine tuning curves relating neural activity to output using a
% linear regression method to get preferred directions
%
% INPUTS
%   fr: Array of neural firing rate for each trial. Each row should be a
%       trial (or movement) and each column should be a different unit.
%   theta: Array of direction of movement in radians for each trial.
%   sigTest: Cell array of parameters for testing significance.
%     OPTIONS:
%       {'none'}: No significance test, simply returns the tuning for each unit
%       {'bootstrap',numIters,confLevel}: bootstrapping test to resample
%           the data the specified number of times (numIters). Returns
%           confidence bounds (for confLevel, eg 0.95 for 95%)
%       {'anova',confLevel}: performs one-way ANOVA with direction as
%           factor to determine if each unit has a spatial tuning. Set 0.05
%           for 5% confLevel.
%   varargin: specify more parameters as needed. Use a format
%               ...,'parameter_name',parameter_value,...
%       Options:
%           'doplots': (boolean) plot each unit with tuning curve?
% OUTPUTS
%   tunCurves: tuning of each model using b0+b1*cos(theta+b2)
%                   tunCurves = [b0,b1,b2]
%   sig: vector saying whether tuning of each cell is significant
%
% EXAMPLES:
%   Compute simple cosine tuning for some firing rate data
%       tcs = regressTuningCurves(fr,theta);
%
%   Plot the tuning cuves one by one (pauses after each plot)
%       tcs = regressTuningCurves(fr,theta,{'none'},'doplots',true);
%
%   Run a bootstrapping test on the data
%       [tcs, cis] = regressTuningCurves(fr,theta,{'bootstrap',1000,0.95});
%
%%%%%%
% written by Matt Perich; last updated July 2013
%%%%%

if nargin < 3
    sigTest = {'none'};
elseif ~iscell(sigTest)
    sigTest = {sigTest};
end

%%%%% Define parameters
% set defaults
doPlots = false; % By default, don't plot
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'doplots'
            doPlots = varargin{i+1};
    end
end
%%%%%

switch lower(sigTest{1})
    case 'bootstrap'
        numIters = sigTest{2};
        confLevel = sigTest{3};
        
        b0s = zeros(size(fr,2),numIters);
        b1s = zeros(size(fr,2),numIters);
        b2s = zeros(size(fr,2),numIters);
        for iter = 1:numIters
            tempfr = zeros(size(fr));
            tempTheta = zeros(size(fr));
            for unit = 1:size(fr,2)
                randInds = randi([1 size(fr,1)],size(fr,1),1);
                tempfr(:,unit) = fr(randInds,unit);
                tempTheta(:,unit) = theta(randInds);
            end
            
            tunCurves = regressTCs(tempfr,tempTheta,doPlots);
            b0s(:,iter) = tunCurves(:,1);
            b1s(:,iter) = tunCurves(:,2);
            b2s(:,iter) = tunCurves(:,3);
            
        end
        
        % find confidence bounds on PD and return as sig
        % IN THE FUTURE: maybe have confidence bounds for all three params?
        b2s = sort(b2s,2);
        sig = [b2s(:,ceil(numIters - confLevel*numIters)), b2s(:,floor(confLevel*numIters))].*180./pi;
        
        b0s = mean(b0s,2).*180./pi;
        b1s = mean(b1s,2).*180./pi;
        b2s = mean(b2s,2).*180./pi;
        
        tunCurves = [b0s,b1s,b2s];
        
    case 'anova'
        confLevel = sigTest{2};
        
        ap = zeros(size(fr,2));
        for i = 1:size(fr,2)
            ap(i) = anova1(fr(:,i),theta(:,i),'off');
        end
        sig = ap <= confLevel;
        
        tunCurves = regressTCs(fr,theta,doPlots);

    otherwise
        % Don't do any significance testing
        tunCurves = regressTCs(fr,theta,doPlots);
        sig = [];
end

end %end main function

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunction to regress the tuning curves
function tunCurves = regressTCs(fr,theta,doPlots)
%   tunCurves: tuning curve of model b0 + b1*cos(theta + b2)
%       b2 is preferred direction

if size(theta,2)==1
    % replicate theta array to be same size as fr
    theta = repmat(theta,1,size(fr,2));
end

tunCurves = zeros(size(fr,2),3);

for iN = 1:size(fr,2)
    st = sin(theta(:,iN));
    ct = cos(theta(:,iN));
    X = [ones(size(theta(:,iN))) st ct];
    
    % model is b0+b1*cos(theta)+b2*sin(theta)
    [b,~,~,~,temp] = regress(fr(:,iN),X);
    p(iN) = temp(1);
    
    % convert to model b0 + b1*cos(theta+b2)
    b  = [b(1); sqrt(b(2).^2 + b(3).^2); atan2(b(2),b(3))];
    
    if doPlots
        figure;
        temp = b(1) + b(2)*cos(theta(:,iN)-b(3));
        [~,I] = sort(theta(:,iN));
        plot(theta(I,iN).*(180/pi),temp(I),'b','LineWidth',2)
        hold all
        plot(theta(:,iN).*(180/pi),fr(:,iN),'r.')
        plot([b(3) b(3)].*(180/pi),[0 max(fr(:,iN))],'k')
        title(['r2 = ' num2str(p(iN))]);
        pause;
        close all
    end
    tunCurves(iN,:) = b;
end

end