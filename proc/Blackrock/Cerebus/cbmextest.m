function trialdata = cbmextest()
% cbmextest: function for use with cbmex testing, that reads in data from a
% Matlab 'trialdata' file, useful for debugging. Set 'mode' parameter for
% CBWait4Word to 'test' to use this.

name = uigetfile('*.mat', 'Select a "trialdata" file') 
load(name, 'trialdata');
end
