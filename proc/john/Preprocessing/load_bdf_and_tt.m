% function [tt, tc] = load_bdf_and_tt(bdf)
%% 
% 7/9/14
% Use Ricardo's DCO_trial_table function to generate a trial table for
% whatever bdfs I put in here
% 
% ------------------------------------------------------------------------------
%% Chewie
%% Load the bdfs
day1bdf = load(...
    '~/Research/NU_LimbLab/Animals/Chewie_8I2/Data/tDCS/Sorted/Chewie_2014-06-30_DCO_tDCS_Sorted/Chewie_2014-06-30_DCO_tDCS_001-10.bdf','-mat');
day2bdf = load(...
    '~/Research/NU_LimbLab/Animals/Chewie_8I2/Data/tDCS/Sorted/Chewie_2014-07-1_DCO_tDCS_Sorted/Chewie_2014-07-01_DCO_tDCS_001-06.bdf','-mat');

%% Load the DCOs
folder = '~/Research/NU_LimbLab/Animals/Chewie_8I2/Data/tDCS/Sorted/';
filename = 'day1DCO.mat'; wholepath = [folder filename];
day1DCO = load(wholepath,'-mat'); clear('filename','wholepath');
filename = 'day2DCO.mat'; wholepath = [folder filename];
day2DCO = load(wholepath,'-mat'); clear('filename','wholepath');

%% Generate trial tables
tc     = day1DCO.table_columns;
day1tt = day1DCO.trial_table;
day2tt = day2DCO.trial_table;

day1stimCycle = [0 9.5 10 19 20 29]; 
% day2stimCycle = [0 10 10.5 22.5 23 31.5 31.7 34.2];
day2stimCycle = [0 10 10.5 22.5 23 31.5];


%% Mihili
% ------------------------------------------------------------------------------
folder = '~/Research/NU_LimbLab/Animals/Mihili/Data/BDFs/';

% BDF while on ACE
filename  = 'Mihili_M1_07302014_tdcs_001_SORTED.bdf';
wholepath = [folder filename];
ACEbdf = load(wholepath,'-mat'); clear(filename,wholepath);
ACEstimCycle = [0 10.25 10.5 20.25 20.5 25.75 25.75 30.1 30.25 35.5 35.6 40.5];
	% ACEstimCycle = [0 10.25 10.5 20.25 20.5 25.75];

% BDF 2014-08-11
filename = 'Mihili_M1_08112014_tdcs_002_SORTED.bdf';
wholepath = [folder filename];
bdf0811 = load(wholepath,'-mat'); clear('filename','wholepath');
sc0811  = [0 10.3 10.3 20.25 20.25 39];
[tt0811,tc] = DCO_trial_table(bdf0811);

% BDF 2014-08-13 (get_cerebus_data -- from Titan)
filename = 'Mihili_M1_08132014_tdcs_001_SORTED.bdf';
wholepath = [folder filename];
bdf0813  = load(wholepath,'-mat'); clear('filename','wholepath');
sc0813   = [0 10.37 11.04 20.83 20.84 40];
    % sc0813 = [0 10.37 10.375 10.83 10.84 11.03 11.04 20.83 20.84 40];
[tt0813,~] = DCO_trial_table(bdf0813);

% BDF 2014-08-14 (get_nev_mat_data)
filename  = 'Mihili_M1_08142014_tdcs001-01.bdf';
wholepath = [folder filename];
bdf0814  = load(wholepath,'-mat'); clear('filename','wholepath');
sc0814   = [0 11.5 11.51 21.92 21.93 31.7];
[tt0814,~] = DCO_trial_table(bdf0814);
