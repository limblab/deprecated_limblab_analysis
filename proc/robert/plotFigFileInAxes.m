function plotFigFileInAxes(plotInFigH,plotInAxH,toPlotPath)

% syntax plotFigFileInAxes(plotInFigH,plotInAxH,toPlotPath)
%
%       INPUTS
% 
%               plotInFigH          handle of the figure in which to plot
%               plotInAxH           handle of the axes in which to plot
%               toPlotPath          the figure to stick in plotInAxH
%
%   example: 
%
%               >> fig1=figure, subH=subplot(2,4,3)
%               >> plotFigFileInAxes(fig1,subH,'somePathToAFigFile.fig')

% open the figure, get appropriate handles.
RMfig=openfig(toPlotPath,'reuse');
Axs=findobj(gcf,'Type','Axes');
Axs(ismember(get(Axs,'Tag'),{'Colorbar','Legend'}))=[];
RMax=Axs(1);

% duplicate figure properties into the new parent from the child, 
% with certain exceptions.
figProps=get(RMfig);
figPropsNames=fieldnames(figProps);
dontMessWith={'BeingDeleted','Children','CurrentAxes','CurrentCharacter','CurrentObject','CurrentPoint', ...
    'DockControls','FileName','PaperOrientation','PaperPosition','PaperPositionMode',...
    'Parent','Position','Renderer','RendererMode','Resize','ResizeFcn','Type','WindowStyle'};
figPropsNames(ismember(figPropsNames,dontMessWith))=[];
for n=1:length(figPropsNames)
    set(plotInFigH,figPropsNames{n},get(RMfig,figPropsNames{n}))
end, clear n

% duplicate axes properties into the new parent axes from the 
% child axes, with certain exceptions.
figure(RMfig)
RMaxProps=get(RMax);
RMaxPropsNames=fieldnames(RMaxProps);
dontMessWith={'BeingDeleted','Children','CurrentPoint','Parent','Position', ...
    'OuterPosition','TightInset','Title','Type','XLabel','YLabel','ZLabel'};
RMaxPropsNames(ismember(RMaxPropsNames,dontMessWith))=[];
for n=1:length(RMaxPropsNames)
    set(plotInAxH,RMaxPropsNames{n},get(RMax,RMaxPropsNames{n}))
end, clear n

% import the children
RMkids=get(RMax,'Children');
figure(plotInFigH)
copyobj(RMkids,plotInAxH)
close(RMfig)