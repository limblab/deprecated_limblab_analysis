% RUN_ANOVA - Run anovan analysis on multiple tDCS sessions
%
% Created by John W. Miller
% 2014-07-23
%
%%
% load_bdf_and_tt

% Calculate tuning curve firing rate means, standard devs. and std. errors
%% ----- CHEWIE -----
% Day 1

day1stimCycle = [0 9.5 10 19 20 29]; 
frAndGroups=tuningCurveStats(day1bdf,day1tt,day1stimCycle);
    % Run anovan analysis & find interesting neurons
[day1pValues,day1neurons] = anova_tuningCurve(frAndGroups,0.05);
day1neurons'

% Plot the interesting neurons
tuningCurve(day1bdf,day1tt,day1stimCycle,'neurons',day1neurons,'stdError',0);

%% Day 2

% day2stimCycle = [0 10 10.5 22.5 23 31.5 31.7 34.2];
day2stimCycle = [0 10 10.5 22.5 23 31.5];
frAndGroups=tuningCurveStats(day2bdf,day2tt,day2stimCycle);
    % Run anovan analysis & find interesting neurons
[day2pValues,day2neurons] = anova_tuningCurve(frAndGroups,.05);
day2neurons'

% Plot the interesting neurons
tuningCurve(day2bdf,day2tt,day2stimCycle,'neurons',day2neurons,'stdError',1);
% tuningCurve(day2bdf,day2tt,day2stimCycle,'neurons',3:5,'stdError',1);

%% ----- MIHILI -----
% 
% 2014-08-11
stimCycle0811 = [0 10.3 10.3 20.25 20.25 39];
frAndGroups   = tuningCurveStats(bdf0811,tt0811,stimCycle0811);
    % Run anovan analysis & find interesting neurons
[pValues0811,neurons0811] = anova_tuningCurve(frAndGroups,.05);
neurons0811'
%%
% Plot the interesting neurons
tuningCurve(bdf0811,tt0811,stimCycle0811,'neurons',neurons0811,'stdError',1,'tt_label',4);


