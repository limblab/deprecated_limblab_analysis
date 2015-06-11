function getExperimentParameters()
% point it to a directory with NEV files and it will parse out names
%   Returns:
%   1) monkey name
%   2) available array names
%   3) task
%   4) perturbation
%   5) available epochs
%   6) date
%
%   What it doesn't have is parameters for task
%     - load them from task parameter file used?
%     - provide force/rotation parameters as inputs?