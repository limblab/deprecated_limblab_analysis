% load_paths.m
%
% Loads all of the necessary paths to run s1_analysis.  Should only be
% used once per session.

% $Id: $

dir = pwd;

addpath(dir);
addpath([dir '\\lib']);
addpath([dir '\\lib\\ml']);
addpath([dir '\\lib\\stats']);
addpath([dir '\\mimo']);
addpath([dir '\\spike']);
addpath([dir '\\bdf']);

