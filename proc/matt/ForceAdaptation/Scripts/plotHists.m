close all;

baseDir = 'Z:\MrT_9I4\Matt\ProcessedData';
% cell matrix. each row is a file to add to plots. each column is info:
%   {'recording_date','adaptation','task','parameter_set_name','title of file'}
useDates = {'2013-09-04','VR','RT','standard','9/04'; ...
            '2013-09-27','VRFF','RT','standard','9/25'};
usePeriod = 'befpeak';

baseDir = 'Z:\Chewie_8I2\Matt\ProcessedData';
% cell matrix. each row is a file to add to plots. each column is info:
%   {'recording_date','adaptation','task','parameter_set_name','title of file'}
useDates = {'2013-10-03','VR','CO','befpeak','9/04'; ...
            '2013-10-03','VR','CO','befpeak','9/04'};

plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array','M1')

plotPDShiftCellClasses('dir',baseDir,'dates',useDates,'period',usePeriod,'array','M1')