function add_filename_to_figures(handles,filename)

for iFigure = 1:length(handles)
    figure(handles(iFigure))
    ha = axes;
    axis off
    set(ha,'Position',[0 0 1 1])
    text(0,0,filename,'VerticalAlignment','bottom','FontSize',10,'Interpreter','none')
    uistack(ha,'bottom')
end