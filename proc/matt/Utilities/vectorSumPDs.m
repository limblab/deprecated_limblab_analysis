function [pds,pd_cis,boot_pds] = vectorSumPDs(fr,theta,sigTest,varargin)
% VECTORSUMPDS Finds preferred direction of neural activity based on firing
% rate and direction data. Can perform different statistical tests.
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
%   sig: vector saying whether tuning of each cell is significant. Empty if
%       no statistical test is performed.
%
% EXAMPLES:
%   Compute pds for some firing rate data
%       pds = vectorSumPDs(fr,theta);
%
%   Plot the tuning cuves one by one (pauses after each plot)
%       pds = vectorSumPDs(fr,theta,{'none'},'doplots',true);
%
%   Run a bootstrapping test on the data
%       [pds, cis] = vectorSumPDs(fr,theta,{'bootstrap',1000,0.95});
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
        
        % Bootstrapping
        pds = zeros(size(fr,2),numIters);
        for iter = 1:numIters
            tempfr = zeros(size(fr));
            tempTheta = zeros(size(fr));
            for unit = 1:size(fr,2)
                randInds = randi([1 size(fr,1)],size(fr,1),1);
                tempfr(:,unit) = fr(randInds,unit);
                tempTheta(:,unit) = theta(randInds);
            end
            
            pds(:,iter) = vectorTCs(tempfr,tempTheta,doPlots);            
        end
        
        % find confidence bounds and return as sig
        pds = sort(pds,2);
        pd_cis = [pds(:,ceil(numIters - confLevel*numIters)), pds(:,floor(confLevel*numIters))];
        
        boot_pds = pds;
        pds = mean(pds,2);
        
    case 'anova'
        confLevel = sigTest{2};
        
        ap = zeros(size(fr,2));
        for i = 1:size(fr,2)
            ap(i) = anova1(fr(:,i),theta(:,i),'off');
        end
        pd_cis = ap <= confLevel;
        
        pds = vectorTCs(fr,theta,doPlots);

    otherwise
        % Don't do any significance testing
        pds = vectorTCs(fr,theta,doPlots);
        pd_cis = [];
end

end %end main function

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunction to regress the tuning curves
function pds = vectorTCs(fr,theta,doPlots)
%  finds preferred direction by vector sum

if size(theta,2)==1
    % replicate theta array to be same size as fr
    theta = repmat(theta,1,size(fr,2));
end

pds = zeros(size(fr,2),1);
for iN = 1:size(fr,2)
    % Compute the PD
    pd = atan2(sum(fr(:,iN).*sin(theta(:,iN))),sum(fr(:,iN).*cos(theta(:,iN))));
    
    if doPlots
        figure;
        hold all
        plot(theta(:,iN).*(180/pi),fr(:,iN),'r.')
        plot([pd pd].*(180/pi),[0 max(fr(:,iN))],'k')
        pause;
        close all
    end
    pds(iN,:) = pd;
end

end