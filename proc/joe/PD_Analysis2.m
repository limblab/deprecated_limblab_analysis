%This script compares the preferred directions of a number of neurons
%across several data recording sessions. It is necessary to edit the script
%to accurately include the filenames (files(i).filename), the file paths 
%(files(i).datapath), the number of files (numSets), and the number of 
%channels in the electrode array (numChans). 

%Initial data. Ensure this is correct before proceeding.
files(1).filename = 'Pedro_S1_041-s';
files(1).datapath = '/Users/limblab/Documents/Joe Lancaster/MATLAB/s1_analysis/proc/joe/';
files(2).filename = 'Pedro_S1_042-s';
files(2).datapath = '/Users/limblab/Documents/Joe Lancaster/MATLAB/s1_analysis/proc/joe/';
files(3).filename = 'Pedro_S1_043-s';
files(3).datapath = '/Users/limblab/Documents/Joe Lancaster/MATLAB/s1_analysis/proc/joe/';
files(4).filename = 'Pedro_S1_044-s';
files(4).datapath = '/Users/limblab/Documents/Joe Lancaster/MATLAB/s1_analysis/proc/joe/';
files(5).filename = 'Pedro_S1_046-s';
files(5).datapath = '/Users/limblab/Documents/Joe Lancaster/MATLAB/s1_analysis/proc/joe/';
files(6).filename = 'Pedro_S1_047-s';
files(6).datapath = '/Users/limblab/Documents/Joe Lancaster/MATLAB/s1_analysis/proc/joe/';
files(7).filename = 'Pedro_S1_048-s';
files(7).datapath = '/Users/limblab/Documents/Joe Lancaster/MATLAB/s1_analysis/proc/joe/';
numSets = 7;
numChans = 96;

%Run RW_PDs on data files and save output for later use.
for i = 1:numSets
    files(i).data = RW_PDs([files(i).datapath files(i).filename]);
end;

%Initialize data collection dates. 
collectionDates = zeros(numSets,1);
for i = 1:numSets
    currpath = [files(i).datapath files(i).filename];
    load(currpath);
    currDate = datenum(bdf.meta.datetime);
    if i == 1
        firstDate = currDate;
    end;
    files(i).date = currDate - (firstDate-1);
end;
for i = 1:numSets
    collectionDates(i) = files(i).date;
end;

%Make an array describing the size of each of the input data sets
setSize = zeros(numSets, 2);
for i = 1:numSets
    setSize(i, :) = size(files(i).data);
end;
trodes = setSize(:, 2); 

%Make a cell array with all the PD data arranged by electrode including 
%missing values as empty cells.
pdCell = cell(numSets, numChans);
for i = 1:numSets;
    for j = 1:trodes(i)
        trode = files(i).data(j).chan;
        unit = files(i).data(j).unit;
        pdCell{i, trode}(unit) = files(i).data(j).glmpd;
    end;
end;
for i = 1:numSets
    for j = 1:numChans
        pdCell{i,j} = unwrap(pdCell{i,j});
    end;
end;

%Make a plot containing 96 subplots showing PD over time
pdPlot = cell(1, numChans);
for i = 1:numChans
    pdPlot{i} = nan(5); %5 is assumed to be MAX number of neurons
    for j = 1:numSets
        for k = 1:size(pdCell{j,i})
            pdPlot{i}(j,k) = pdCell{j,i}(k);
        end;
    end;
end;

figure(5);
title('PDs For All Channels');
for i = 1:numChans
    subplot(8,12,i) %This subplot configuration is up to the user's judgement
    plot(collectionDates, pdPlot{i}(:,1), collectionDates, pdPlot{i}(:,2),...
        collectionDates, pdPlot{i}(:,3), collectionDates, pdPlot{i}(:,4), ...
        collectionDates, pdPlot{i}(:,5), 'marker', '.', 'markerSize', 10);
    axis( [1 files(numSets).date -6.5 6.5]);
end;