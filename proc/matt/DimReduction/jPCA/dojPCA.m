clear;
clc;
close all;

allFiles = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
    'Mihili','2014-03-03','VR','CO'; ...    %12 S(M-P)
    'Mihili','2014-03-04','VR','CO'; ...    %13 S(M-P)
    'Mihili','2014-03-06','VR','CO'; ...    %14 S(M-P)
    'Mihili','2014-03-07','FF','CO'; ...    % 15
    'Chewie','2013-10-03','VR','CO'; ... %16  S ?
    'Chewie','2013-10-09','VR','RT'; ... %17  S x
    'Chewie','2013-10-10','VR','RT'; ... %18  S ?
    'Chewie','2013-10-11','VR','RT'; ... %19  S x
    'Chewie','2013-10-22','FF','CO'; ... %20  S ?
    'Chewie','2013-10-23','FF','CO'; ... %21  S ?
    'Chewie','2013-10-28','FF','RT'; ... %22  S x
    'Chewie','2013-10-29','FF','RT'; ... %23  S x
    'Chewie','2013-10-31','FF','CO'; ... %24  S ?
    'Chewie','2013-11-01','FF','CO'; ... %25 S ?
    'Chewie','2013-12-03','FF','CO'; ... %26 S
    'Chewie','2013-12-04','FF','CO'; ... %27 S
    'Chewie','2013-12-09','FF','RT'; ... %28 S
    'Chewie','2013-12-10','FF','RT'; ... %29 S
    'Chewie','2013-12-12','VR','RT'; ... %30 S
    'Chewie','2013-12-13','VR','RT'; ... %31 S
    'Chewie','2013-12-17','FF','RT'; ... %32 S
    'Chewie','2013-12-18','FF','RT'; ... %33 S
    'Chewie','2013-12-19','VR','CO'; ... %34 S
    'Chewie','2013-12-20','VR','CO'};    %35 S

root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';
dateInd = 6;
doFile = allFiles(dateInd,:);

epochs = {'BL','AD','WO'};

useArray = 'M1';
paramSetName = 'movement';

[spikes,allMT,indices] = combineAllEpochs(root_dir,doFile,epochs,useArray,paramSetName);

trial_table = allMT;
t1 = [4,0.2];
t2 = [4,-0.4];
t_step = 0.01; %in seconds

%%
% get firing rates for each reach to each target
disp('Getting firing rates...');

u = unique(allMT(:,1));
for cond = 1:length(u)
    idx = allMT(:,1)==u(cond);
    temp = allMT(idx,:);
    for i = 1:size(temp,1)
        % get time vector
        t_start = temp(i,t1(1))-t1(2);
        t_end = temp(i,t2(1))-t2(2);
        ti = t_start:t_step:t_end;
        
        allRates(cond).trial(i).ti = ti;
        
        for unit = 1:length(spikes)
            % get spike times
            ts = spikes{unit};
            idx = ts >= t_start & ts <= t_end;
            rate = calcFR( ti, ts(idx), 0.05, 'gaussian');
            
            allRates(cond).trial(i).rate{unit} = rate;
        end
    end
end

%%
% stretch them all to be the same length (for each target)
% num_samples = 1000;
num_samples = length(ti);
Data = struct();
for cond = 1:length(u)
    d = allRates(cond);
    A = zeros(num_samples,length(spikes));
    for unit = 1:length(spikes)
        
        getTrials = zeros(num_samples,length(d.trial));
        for i = 1:length(d.trial)
            ti = d.trial(i).ti;
            r = d.trial(i).rate{unit};
            % stretch out v to be 1000 samples
            %rate = interp1(1:length(r),r,1:length(r)/num_samples:length(r));
            rate = r;
            
            getTrials(:,i) = rate;
        end
        A(:,unit) = mean(getTrials,2);
    end
    % find average across trials
    Data(cond).A = A;
    Data(cond).times = 1000.*(-t1(2):t_step:-t2(2));
end

%%
disp('Starting jPCA analysis...');

% loading libraries
addpath 'fromMarksLibraries' -END
addpath 'CircStat2010d' -END

% loading data
% load exampleData

% Notes on format of data:
% You must organize your data the way that the example structure 'Data' is organized
% Data should be a structure that is at least one element long.  For the example, 'Data' is 27
% elements long, one for each condition (reach type) that the monkey performed.  If you have only
% one condition (e.g., when we analyze a 30 second period of walking) then you will just have one
% element.
% Data.A should be a matrix, with time running vertically and neurons running horizontally.
%       This is the same format as when using matlabs 'princomp'.
% Data.times should be some set of times that you understand.  You will ask for the analysis / plots to
% apply to subsets of these times.


% these will be used for everything below
jPCA_params.softenNorm = 5;  % how each neuron's rate is normized, see below
jPCA_params.suppressBWrosettes = true;  % these are useful sanity plots, but lets ignore them for now
jPCA_params.suppressHistograms = true;  % these are useful sanity plots, but lets ignore them for now


%% EX1: FIRST PLANE
% plotting the first jPCA plane for 200 ms of data, using 6 PCs (the default)
times = -50:10:150;  % 50 ms before 'neural movement onset' until 150 ms after
jPCA_params.numPCs = 6;  % default anyway, but best to be specific
[Projection, Summary] = jPCA(Data, times, jPCA_params);

phaseSpace(Projection, Summary);  % makes the plot

printFigs(gcf, '.', '-dpdf', 'Basic jPCA plot');  % prints in the current directory as a PDF


%% EX2: GREATER RANGE OF TIME
times = -50:10:300;  % 50 ms before 'neural movement onset' until 300 ms after
jPCA_params.numPCs = 6;  % sticking with 6 for now, but will move up to 10 below
[Projection, Summary] = jPCA(Data, times, jPCA_params);
phaseSpace(Projection, Summary);  % makes the plot


%% EX3:  also do in higher D
times = -50:10:300;
jPCA_params.numPCs = 12;  % search for the jPCA plane within the top 12 PCs, not just the top 6
[Projection, Summary] = jPCA(Data, times, jPCA_params);
phaseSpace(Projection, Summary);  % makes the plot


%% EX4: THREE PLANES

times = -50:10:300;  % first we will just run the analysis as we did above
jPCA_params.numPCs = 12;
[Projection, Summary] = jPCA(Data, times, jPCA_params);

% now we will plot all three planes
plotParams.planes2plot = [1 2 3];
phaseSpace(Projection, Summary, plotParams);  % makes all three plots



%% EX5: SIMPLE MOVIE FOR VIEWING

times = -50:10:300;  % This is just what we did for examples 3 & 4 above
jPCA_params.numPCs = 12;
[Projection, Summary] = jPCA(Data, times, jPCA_params);

phaseMovie(Projection, Summary);

% for a greater range of times
movParams.times = -50:10:550;  % a range of times that is broader than that used to find the jPCA projection
phaseMovie(Projection, Summary, movParams);


%% EX6: SAVING MOVIES

% Probably best with an undocked figure.
% You will have to play with '.pixelsToGet'
% You may get a warning if you use to many pixels.

movParams.times = -50:10:550;
movParams.pixelsToGet = [25 35 280 280]; % These WILL vary depending on your monitor and layout.
MV = phaseMovie(Projection, Summary, movParams);

figure; movie(MV);  % shows the movie in a matlab figure window

movie2avi(MV, 'jPCA movie', 'FPS', 12, 'compression', 'none'); % 'MV' now contains the movie




%% EX7: MOVIE OF THE CHANGE IN BASIS FROM PCA TO jPCA

% going back to the original 6D analysis over a short period of time.
times = -50:10:150;  % 50 ms before 'neural movement onset' until 150 ms after
jPCA_params.numPCs = 6;  % default anyway, but best to be specific
[Projection, Summary] = jPCA(Data, times, jPCA_params);

phaseSpace(Projection, Summary);  % Static plot as a sanity check

rotationMovie(Projection, Summary, -50:10:150, 70, 70);  % 70 steps to full rotation.  Show all 70.




% List of examples:

% 3) Plotting a movie.
% 5) Plotting with no mean subtraction.

% errors to avoid:

% After running the examples below, type 'help functionName' for all the relevant functions: jPCA,
% phaseSpace & phaseMovie.  All these functions allow many useful parameters to be passed if you so wish.





%% EX8: MEAN SUBTRACTION

% turning off mean subtraction
times = -50:10:150;  % 200 ms of time, as in supp fig. 7
jPCA_params.meanSubtract = false;  % no mean subtraction
jPCA_params.numPCs = 10;  % as in supp fig. 7
[Projection, Summary] = jPCA(Data, times, jPCA_params);

plotParams.plotPlanEllipse = false;
plotParams.planes2plot = [1 2 3];
phaseSpace(Projection, Summary, plotParams);


% turning mean subtraction back on
times = -50:10:150;
jPCA_params.meanSubtract = true;  % the default
jPCA_params.numPCs = 6;  % as in fig 3f
[Projection, Summary] = jPCA(Data, times, jPCA_params);
plotParams.crossCondMean = true;
plotParams.planes2plot = 1;
phaseSpace(Projection, Summary, plotParams);


