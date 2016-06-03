function varargout=plotOnLine(lineHandle,Xpt,varargin)

% syntax [XptsToPlot,YptsToPlot]=plotOnLine(lineHandle,Xpt,varargin)
%
% puts the dot on the point Xpt, on the trace specified by lineHandle
%
% if output arguments are specified, it returns them & does not plot.
% otherwise it just plots into the current axes
% If the inputs are out of range, NaNs are plotted or returned
%
% to force plotting along with returning the values, pass in the p-v pair
% 'plot','yes'.  In actual fact the 'yes' is superfluous; it's just there
% to keep the p-v pairs in equal numbers.  DON'T SHORT-CIRCUIT THE PAIRWISE
% SETUP.  i.e. no 'ko' for black circle; spell them all out.

if ~nargin, help plotOnLine, return, end

doPlot=0;
% if the keyword 'plot' is included in the argument list, plot.
for n=1:length(varargin)
	if ischar(varargin{n}) && strcmp(varargin{n},'plot')
		doPlot=1;
		varargin(n:n+1)=[];
		break
	end
end

Xincluded=find(get(lineHandle,'XData')>min(get(gca,'Xlim')) & ...
	get(lineHandle,'XData')<max(get(gca,'Xlim')));

Xdata=get(lineHandle,'XData');
Ydata=get(lineHandle,'YData');

if (min(Xpt) > max(Xdata)) || (max(Xpt) < min(Xdata))
	disp(sprintf('input %s data is out of range of \npreviously plotted data', ...
		inputname(2)))
	disp('do not be surprised if nothing is plotted')
end

for n=1:length(Xpt)
	if Xpt(n) >= min(get(gca,'Xlim')) && Xpt(n) <= max(get(gca,'Xlim'))
		[minVal,minPos]=min(abs(Xpt(n)-get(lineHandle,'XData')));
		XptsToPlot(n)=Xdata(minPos);                                        %#ok<*AGROW>
		YptsToPlot(n)=Ydata(minPos);
	else
		XptsToPlot(n)=NaN;
		YptsToPlot(n)=NaN;		
	end
end

if ~nargout || doPlot
    holdStatus=ishold;
    hold on
    if ~isempty(varargin)
        lineOnPlotH=plot(XptsToPlot,YptsToPlot,varargin{:});
    else
        lineOnPlotH=plot(XptsToPlot,YptsToPlot);
    end
    set(lineOnPlotH,'Parent',get(lineHandle,'Parent'))
    if ~holdStatus, hold off, end
end
if nargout
	varargout{1}=XptsToPlot;
	varargout{2}=YptsToPlot;
end