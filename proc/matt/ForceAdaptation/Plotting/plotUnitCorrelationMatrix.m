function plotUnitCorrelationMatrix(units,sg)

% this function does a noise correlation matrix for all of the neurons in a
% file. 
%
%   1) get all firing rates for all neurons
%   2) plot all against each other
%   3) fit regression line and see if slope is non-zero