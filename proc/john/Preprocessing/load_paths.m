% load_paths.m
%
% Loads all of the necessary paths to run s1_analysis.  Should only be
% used once per session.

% $Id: load_paths.m 1405 2014-01-30 20:58:08Z tucker $

dir = '~/Code/svn/LimbLab_svn/s1_analysis/';

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
addpath([dir '/bdf/NEVNSx/']);
addpath([dir '/BMI_analysis']);

% Please do not add your proc directory to this file.  Create a load paths
% script in your proc directory if you need to.  This is to avoid filename
% conflicts between proc directories.

clear dir;
