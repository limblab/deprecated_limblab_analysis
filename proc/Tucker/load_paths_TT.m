%script to add paths Tucker uses for analysis:
dir = pwd;

addpath(dir);

addpath([dir '/data processing helper functions']);
addpath([dir '/extrema/extrema']);
addpath([dir '/impedance file test folder']);
addpath([dir '/intersections']);
addpath([dir '/kinetics processing']);
addpath([dir '/nev handling functions']);
addpath([dir '/PDs']);
addpath([dir '/plx_nse_converter']);
addpath([dir '/processing scripts']);
addpath([dir '/psychometric curves']);
addpath([dir '/sigmoid fitting']);
addpath([dir '/Spike_sorting']);
addpath([dir '/Trial Table']);
addpath([dir '/bar_with_error']);
addpath([dir '/alternative periodics']);


% re-work of load_paths.m
%
% Loads all of the necessary paths to run s1_analysis.  Should only be
% used once per session.

dir = fileparts(fileparts(dir));

addpath(dir);

addpath([dir '/lib']);
addpath([dir '/lib/ml']);
addpath([dir '/lib/stats']);
addpath([dir '/lib/bootstrapping']);
addpath([dir '/lib/glm']);
addpath(genpath([dir '/lib/NPMK 2.5.2.0']));
addpath([dir '/mimo']);
addpath([dir '/spike']);
addpath([dir '/bdf']);
addpath([dir '/bdf/event_decoders']);
addpath([dir '/bdf/lib_cb']);
addpath([dir '/bdf/lib_plx']);
addpath([dir '/bdf/lib_plx/core_files/']);
addpath([dir '/BMI_analysis']);

clear dir;


