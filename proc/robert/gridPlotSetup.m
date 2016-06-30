function axH=gridPlotSetup(figH,numPlots,layoutOverride)

% syntax axH=gridPlotSetup(figH,numPlots,layoutOverride)
%
% layoutOverride is a [rows cols] vector.  If omitted, defaults to a 
% square arrangement.
% 
% to add: variables for if we want to take up some fraction of the
% figure window instead of the whole thing

figure(figH)

numPlotsRoot=ceil(sqrt(numPlots));
if (numPlotsRoot^2-numPlots) >= numPlotsRoot
    numXplots=numPlotsRoot-1;
else
    numXplots=numPlotsRoot;
end
heightOfPlot=1/numPlotsRoot;
if nargin > 2
    numXplots=layoutOverride(2);
    heightOfPlot=1/layoutOverride(1);
end
widthOfPlot=1/numXplots;

pushRight=0; pushDown=0;
for n=1:numPlots
    if ~mod(n-1,numXplots), pushRight=0; end
    x=1-widthOfPlot*numXplots+pushRight*widthOfPlot;
    y=1-heightOfPlot-pushDown*heightOfPlot;
    axH(n)=subplot('Position',[x y widthOfPlot heightOfPlot]);
    pushRight=pushRight+1;
    if ~mod(n,numXplots), pushDown=pushDown+1; end
end

