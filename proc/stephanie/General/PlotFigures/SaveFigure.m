% Save figure
function SaveFigure(foldername, filename)


saveas(gcf, strcat(foldername, filename, '.fig'))
saveas(gcf, strcat(foldername, filename, '.pdf'))


end