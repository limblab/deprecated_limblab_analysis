% function [tt, tc] = load_bdf_and_tt(bdf)
%% 
% 7/9/14
% Use Ricardo's DCO_trial_table function to generate a trial table for
% whatever bdfs I put in here
% 
% ------------------------------------------------------------------------------
%% Chewie
    % Load the bdfs
folder = '~/Research/NU_LimbLab/Animals/Chewie_8I2/Data/Sorted/';
day1bdf = load([folder 'Chewie_2014-06-30_DCO_tDCS_001-10.bdf'],'-mat');
day2bdf = load([folder 'Chewie_2014-07-01_DCO_tDCS_001-06.bdf'],'-mat');
    % Load the DCOs
folder = '~/Research/NU_LimbLab/Animals/Chewie_8I2/Data/Sorted/';
day1DCO = load([folder 'day1DCO.mat'],'-mat');
day2DCO = load([folder 'day2DCO.mat'],'-mat');
    % Generate trial tables
tc     = day1DCO.table_columns;
day1tt = day1DCO.trial_table;
day2tt = day2DCO.trial_table;
    % Stim cycles
day1stimCycle = [0 9.5 10 19 20 29]; 
day2stimCycle = [0 10 10.5 22.5 23 31.5];
% day2stimCycle = [0 10 10.5 22.5 23 31.5 31.7 34.2];


%% Mihili
% ------------------------------------------------------------------------------
folder = '~/Research/NU_LimbLab/Animals/Mihili/Data/BDFs/';

% BDF while sedated with ACE
wholepath = [folder 'Mihili_M1_07302014_tdcs_001_SORTED.bdf'];
ACEbdf = load(wholepath,'-mat'); clear(wholepath);
ACEstimCycle = [0 10.25 10.5 20.25 20.5 25.75 25.75 30.1 30.25 35.5 35.6 40.5];
	% ACEstimCycle = [0 10.25 10.5 20.25 20.5 25.75];

% BDF 2014-08-11
wholepath = [folder 'Mihili_M1_08112014_tdcs_002_SORTED.bdf'];
bdf0811 = load(wholepath,'-mat'); clear('wholepath');
sc0811  = [0 10.3 10.3 20.25 20.25 39];
[tt0811,tc] = DCO_trial_table(bdf0811);

% BDF 2014-08-13 (get_cerebus_data -- from Titan)
wholepath = [folder 'Mihili_M1_08132014_tdcs_001_SORTED.bdf'];
bdf0813  = load(wholepath,'-mat'); clear('wholepath');
sc0813   = [0 10.37 11.04 20.83 20.84 40];
    % sc0813 = [0 10.37 10.375 10.83 10.84 11.03 11.04 20.83 20.84 40];
[tt0813,~] = DCO_trial_table(bdf0813);

% BDF 2014-08-14 (get_nev_mat_data)
wholepath = [folder 'Mihili_M1_08142014_tdcs001-01.bdf'];
bdf0814  = load(wholepath,'-mat'); clear('wholepath');
sc0814   = [0 11.5 11.51 21.92 21.93 31.7];
[tt0814,~] = DCO_trial_table(bdf0814);

%% Jango
% ------------------------------------------------------------------------------
folder = '~/Research/NU_LimbLab/Animals/Jango/Data/BDFs/';

% BDF 2014-08-27 (1st tDCS session)
wholepath = [folder 'Jango_08272014_tDCS_ROUGHSORT.bdf'];
jangoBdf0827 = load(wholepath,'-mat'); clear(wholepath);
jangoSc0827  = [0 10.33 10.33 23.15 23.15 35.20];
jangoTt08287 = DCO_trial_table(jangoBdf0827);



