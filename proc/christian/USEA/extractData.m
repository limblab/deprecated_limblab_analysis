%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract data from *.ns4 files and insert to struct %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
clc
close all

%% Select folder path
fileExt = '*.ns4';
baseDir = [uigetdir(matlabroot,'MATLAB Root Directory') '/'];

%% Import data
[NUM]=xlsread([baseDir '/' 'filename.xls']);
filenames = importdata([baseDir '/' 'filename.prn']);

%% Allocate struct
for i=1:100
    IOcurves.electrode(i) = struct('PW',[],'Filename',[],'EMGdata',[],'StimData',[]);
end

tempData = openNSx('read',[baseDir filenames{i}]);
emgNumber = size(tempData.Data,1);
inputText = ['c:' num2str(emgNumber)];
inputText1 = ['c:1:' num2str(emgNumber-1)];

%% Import data to struct
for i=1:size(NUM,1)
    
    if isempty(IOcurves.electrode(NUM(i,1)).PW)==1
        IOcurves.electrode(NUM(i,1)).PW = NUM(i,2);
        IOcurves.electrode(NUM(i,1)).Filename = filenames(i);
        IOcurves.electrode(NUM(i,1)).EMGdata = openNSx('read',[baseDir filenames{i}],'p:double');
        IOcurves.electrode(NUM(i,1)).EMGdata.Data = IOcurves.electrode(NUM(i,1)).EMGdata.Data';
    else
        IOcurves.electrode(NUM(i,1)).PW = [IOcurves.electrode(NUM(i,1)).PW ; NUM(i,2)];
        IOcurves.electrode(NUM(i,1)).Filename = [IOcurves.electrode(NUM(i,1)).Filename ; filenames(i)];
        tempData = openNSx('read',[baseDir filenames{i}],inputText1,'p:double');
        tempData.Data = tempData.Data';
        IOcurves.electrode(NUM(i,1)).EMGdata = [IOcurves.electrode(NUM(i,1)).EMGdata ; tempData];
    end
end

%% Calculate mWave
for i=1:size(NUM,1)
    tempDataStim = openNSx('read',[baseDir filenames{i}],inputText,'p:double');
    tempEMG = openNSx('read',[baseDir filenames{i}],inputText1,'p:double');
    
    if i==1
        IOcurves.electrode(NUM(i,1)).StimData = tempDataStim.Data';
        IOcurves.electrode(NUM(i,1)).mWave = calcMWave(tempEMG.Data', tempDataStim.Data',emgNumber,NUM(i,1));
    else
        IOcurves.electrode(NUM(i,1)).StimData = [IOcurves.electrode(NUM(i,1)).StimData ; tempDataStim];
        IOcurves.electrode(NUM(i,1)).mWave = [IOcurves.electrode(NUM(i,1)).mWave ; calcMWave(tempEMG.Data',tempDataStim.Data',emgNumber,NUM(i,1))];
    end
    
    IOcurves.electrode(NUM(i,1)).maxmWave = max(IOcurves.electrode(NUM(i,1)).mWave,[],1);
end

%% Normalization
IOcurves.norm = zeros(1,emgNumber-1);
for j=1:100
    for i=1:emgNumber-1
        
        if IOcurves.norm(1,i) < IOcurves.electrode(1,j).maxmWave(1,i)
            IOcurves.norm(1,i) = IOcurves.electrode(1,j).maxmWave(1,i);
        end
    end
end

%% Plotting normalized data
plots=zeros(100,1);
for i=1:100
    IOcurves.electrode(i).normalized = normalize(IOcurves.electrode(i),IOcurves.norm);
    plots(i,1) = scatterPlot( IOcurves.electrode(i),emgNumber,i);
end

%% Remember which electrodes are plotted
plots(plots == 0) = [];
IOcurves.plots = plots;

%% Selectivity
%selec = [];
for i=1:size(plots,1)
    IOcurves.electrode(plots(i)).selectivity = selectivity(IOcurves.electrode(plots(i)),emgNumber);
end

%% Clean up
clearvars -except IOcurves
uisave