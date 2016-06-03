%% options header for a particular animal

% these lines are only needed if there is mislabelling of markers by Vicon
% in the data file, which seems to happen if the markers aren't named
% correctly

OPTS.NMARKERSET = 2;
OPTS.MARKERSETIND{1} = 1:6;

% parameters for preprocessing - these should be different for the
% construction of marker models and virtual points vs. data analysis of
% marker motion
OPTS.MAX_NFRAMES_2_DROP = 50;  % how many frames can be dropped yet still allow it to be 'continuous'
OPTS.MIN_NFRAMES_PER_BLOCK = 50;  % how many frames in a row have to be marked for it to be considered a block

OPTS.DISPLAY = 0;
% OPTS.SCALING = 4.7243;  % only appiles to animals with incorrect calibration, using the wrong wand
OPTS.SCALING = 1;  

OPTS.VICONDIRECTORY = 'C:\Users\Matt Tresch\Documents\My Files\Data Analyses\Mfiles\RatLegMovement';

dataset.NAME = 'Rat flexion';
dataset.FNAME_ROOT = '2-12-16';
dataset.LIST{1} = [31 32 33];
dataset.MARKERIND = {1:6};
dataset.MARKERLABEL = {'leg'};
OPTS.DATASET(1) = dataset;

dataset.NAME = 'Rat stepping';
dataset.FNAME_ROOT = '2-12-16';
dataset.LIST{1} = [38 39 40];
dataset.MARKERIND = {1:6};
dataset.MARKERLABEL = {'leg'};
OPTS.DATASET(2) = dataset;

% dataset.NAME = 'Isometric Stim';
% dataset.FNAME_ROOT = '5-27-15_';
% dataset.LIST{1} = 164:3:182;  % 11.7
% dataset.LIST{2} = 165:3:183;
% dataset.LIST{3} = 143:3:161;  % 9.1
% dataset.LIST{4} = 144:3:162;
% dataset.LIST{5} = 185:3:203;  % 10.7
% dataset.LIST{6} = 186:3:204;
% dataset.LIST{7} = 206:3:224;  % 9.7
% dataset.LIST{8} = 207:3:225;
% dataset.MARKERIND = {1:3, 4:7};
% dataset.MARKERLABEL = {'patella','femur'};
% OPTS.DATASET(3) = dataset;

