function H = plotScatterWithHist(x,y,varargin)
% PLOTSCATTERWITHHIST Makes scatter plot with histograms on side
%
%   Plots a scatter plot with histograms to show how the horizontal and/or
% vertical axes of the data is distributed. For instance, PD changes under
% two different conditions.
%
% INPUTS:
%   x: data for horizontal axis
%   y: data for vertical axis
%   varargin: specify more parameters as needed. Use a format
%               ...,'parameter_name',parameter_value,...
%       Options:
%           'xhist': (bool) plot the histogram for x data (default true)
%           'yhist': (bool) plot the histogram for y data (default true)
%           'title': (string) title for plot (default empty)
%           'xlabel': (string) label for x axis of scatter plot
%           'ylabel': (string) label for y axis of scatter plot
%           'fontsize': (int) font size to use for labels (default 14)
%           'symbol': (string) symbol for scatter plot (default '.')
%           'xline': value to plot a red marking line across the scatter
%           'yline': same but for y data
%           'nbins': (int) number of bins to use for histograms
%
% OUTPUTS:
%   H: array of handles to each of the subplots used
%
% EXAMPLES:
%
%
%%%%%%
% written by Matt Perich; last updated July 2013
%%%%%

%%%%% Define parameters
% set defaults
doXHist = true;
doYHist = true;
useTitle = '';
useXLabel = '';
useYLabel = '';
useFontSize = 14;
useSymbol = '.';
markScatterX = [];
markScatterY = [];
nBins = 50;
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'xhist'
            doXHist = varargin{i+1};
        case 'yhist'
            doYHist = varargin{i+1};
        case 'title'
            useTitle = varargin{i+1};
        case 'xlabel'
            useXLabel = varargin{i+1};
        case 'ylabel'
            useYLabel = varargin{i+1};
        case 'fontsize'
            useFontSize = varargin{i+1};
        case 'symbol'
            useSymbol = varargin{i+1};
        case 'xline'
            markScatterX = varargin{i+1};
        case 'yline'
            markScatterY = varargin{i+1};
        case 'nbins'
            nBins = varargin{i+1};
    end
end
%%%%%

% Set up plot
if doXHist && doYHist
    figure;
    subplot1(2,2,'Gap',[0 0]);
    sInd = 3; %index for scatter plot in subplot1
    yInd = 4; %x ind will always be 1 if the x hist is plotted
    H = zeros(4,1);
elseif doXHist && ~doYHist
    figure;
    subplot1(2,1,'Gap',[0 0]);
    sInd = 2;
    H = zeros(2,1);
elseif doYHist && ~doXHist
    figure;
    subplot1(1,2,'Gap',[0 0]);
    sInd = 1;
    yInd = 2;
    H = zeros(2,1);
else
    disp('WARNING: Nothing plotted. You said to display neither histogram. Why not just do a normal scatter plot? This function is not for you! Plus, I am too lazy to write a case for this scenario.');
    return;
end

% Make scatter plot in lower left corner
subplot1(sInd);
H(sInd) = gca;
hold all;
plot(x,y,useSymbol);
axis('tight')
% Get axes limits
if ~isempty(markScatterX)
    plot([markScatterX markScatterX],ylim,'r--','LineWidth',2);
end
if ~isempty(markScatterY)
    plot(xlim,[markScatterY markScatterY],'r--','LineWidth',2);
end
set(gca,'FontSize',useFontSize)
xlabel(useXLabel,'FontSize',useFontSize);
ylabel(useYLabel,'FontSize',useFontSize);

if doYHist
    % plot histogram of vertical data in lower right
    subplot1(yInd);
    H(yInd) = gca;
    [counts,bins] = hist(y,nBins); %# get counts and bin locations
    barh(bins,counts,'hist')
    axis('tight');
    % Remove the first tick (always '0') to clean up plot
    temp = get(gca,'XTick');
    temp(1) = [];
    set(gca,'XTick',temp,'FontSize',useFontSize);
end

if doXHist
    % plot histogram of horizontal data in upper left
    subplot1(1);
    H(1) = gca;
    [counts,bins] = hist(x,nBins); %# get counts and bin locations
    bar(bins,counts,'hist')
    axis('tight');
    % Remove the first tick (always '0') to clean up plot
    temp = get(gca,'YTick');
    temp(1) = [];
    set(gca,'YTick',temp,'FontSize',useFontSize);
end

if doXHist && doYHist
    % Set the upper right to be invisible
    subplot1(2);
    H(2) = gca;
    set(gca,'Visible','off');
end

% Set the title
set(gcf,'NextPlot','add');
axes;
h = title(useTitle,'FontSize',useFontSize);
set(gca,'Visible','off');
set(h,'Visible','on');
