function plotNeuralData(bdf,plotVars,timeWin)
% Plots rasters for each unit in a BDF as well as continuous variables over
% a specified time range
%
% INPUTS:
%   bdf: bdf struct
%   plotVars: (cell array of strings) names of continuous variables to plot
%   timeWin: (1x2 array) specifies a time window as [start end] in seconds
%
% NOTES:
%  Labeling assumes that if there are 3 columns, they represent [t,x,y]. So
% far this has always been true for my data...
%
% EXAMPLES:
%   Plot raster only
%       plotNeuralData(bdf);
%   Plot neural, kinematic, and force data
%       plotNeuralData(bdf,{'pos','vel','force'});
%   Plot neural data only over a limited window
%       plotNeuralData(bdf,{},[100 200]);
%
%%%%%%
% written by Matt Perich; last updated July 2013
%%%%%

if nargin < 3 % Default to use all time
    timeWin = [0 Inf];
    if nargin < 2 %Default to only plot raster
        plotVars = {};
    end
end

% Right now hard code the labeling if there are multiple columns in data
plotExts = {'_t','_x','_y','_z'};

% Determine how many things to plot (add one for rasters)
numPlots = length(plotVars)+1;

figure;
subplot1(numPlots,1,'Min',[0.1 0.1],'Max',[0.95 0.95],'Gap',[0 0],'FontS',12);

% ignore units that are id 255 or channel greater than 128
useInds = find(cellfun(@(x) x(2)~=0 && x(2)~=255 && x(1)<=128,{bdf.units.id}));

%Plot the neural rasters
subplot1(1);
hold all;
for unit = 1:length(useInds)
    ts = bdf.units(useInds(unit)).ts;
    ts = ts(ts >= timeWin(1) & ts < timeWin(2));
    plot([ts ts]',[(unit-1).*ones(size(ts)) unit.*ones(size(ts))]','k');
end
ylabel('neuron id','FontSize',14);
axis('tight');

%Plot the continuous variables
for iPlot = 2:numPlots
    data = bdf.(plotVars{iPlot-1});
    tinds = data(:,1) >= timeWin(1) & data(:,1) < timeWin(2);
    
    subplot1(iPlot);
    hold all;
    % Assumes first column is time vector and plots other columns
    for j = 2:size(data,2)
        plot(data(tinds,1),data(tinds,j));
        labels{j-1} = [plotVars{iPlot-1} plotExts{j}];
    end
    ylabel(plotVars{iPlot-1},'FontSize',14);
    axis('tight');
    legend(labels);
end

xlabel('Time (sec)','FontSize',14);
ax = findobj(gcf,'Type','axes');
linkaxes(ax,'x');