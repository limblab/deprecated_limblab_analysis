%% glm comparison
%
%  Create and compare a glm for different stimulation blocks
%
%  John W. Miller
%  7/30/14


%% Prep the data
%%
% -----
% Day 2

% day2stimCycle = [0 10 10.5 22.5 23 31.5 31.7 34.2];
day2stimCycle = [0 10 10.5 22.5 23 31.5];
frAndGroups=tuningCurveStats(day2bdf,day2tt,day2stimCycle);

%% Choose a neuron
n_neuron = 10;
FRs = frAndGroups{n_neuron,1};
direction = frAndGroups{n_neuron,2};
stimBlock = frAndGroups{n_neuron,3};

%% Create a glm

predictors = [direction stimBlock];
link = 'log';
dist = 'poisson';

[logCoef,dev] = glmfit(direction,FRs,dist,link);
logFit  = glmval(logCoef,direction,link);
figure
plot(direction,FRs,'bs',direction,logFit,'r-');

[logCoef,dev] = glmfit(stimBlock,FRs,dist,link);
logFit  = glmval(logCoef,stimBlock,link);
figure
plot(stimBlock,FRs,'bs',stimBlock,logFit,'r-');


% [logCoef,dev] = glmfit(predictors,FRs,dist,link);
% logFit  = glmval(logCoef,predictors,link);
% figure
% plot(predictors,FRs,'bs',predictors,logFit,'r-');




