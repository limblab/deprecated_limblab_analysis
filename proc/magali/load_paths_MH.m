%script to add paths Magali uses for analysis:
dir = pwd;

addpath(dir);

addpath([dir '/nev']);
addpath([dir '/process']);

% Loads all of the necessary paths to run s1_analysis.  Should only be
% used once per session.

dir = fileparts(fileparts(dir));

addpath(dir);
addpath([dir '/proc/basic functions']);
addpath([dir '/lib']);
addpath([dir '/lib/ml']);
addpath([dir '/lib/stats']);
addpath([dir '/lib/bootstrapping']);
addpath([dir '/lib/glm']);
addpath([dir '/lib/boundedline']);
addpath(genpath([dir '/lib/NPMK 2.5.2.0']));
addpath([dir '/mimo']);
addpath([dir '/spike']);
addpath([dir '/bdf']);
addpath([dir '/bdf/event_decoders']);
addpath([dir '/bdf/lib_cb']);
addpath([dir '/bdf/lib_plx']);
addpath([dir '/bdf/lib_plx/core_files/']);
addpath([dir '/bdf/NEVNSx']);
addpath([dir '/BMI_analysis']);

clear dir;


