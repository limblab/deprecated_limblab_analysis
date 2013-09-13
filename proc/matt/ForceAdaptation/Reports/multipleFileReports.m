% Make html summary of multiple files
%   Meant to be saved as pdf
baseDir = 'Z:\MrT_9I4\Matt\ProcessedData';

useDates = {'2013-08-22','2013-08-23','2013-09-05','2013-09-06'};
cssLoc = 'Z:\MrT_9I4\Matt\mainstyle.css';

html = ['<html><head><title>Summary</title><link rel="stylesheet" href="' cssLoc '" /></head><body>'];

for iDate = 1:length(useDates)
    useDate = useDates{iDate};
    disp(['Writing HTML for ' useDates{iDate} '...']);
    html = makeSummaryReport(['Z:\MrT_9I4\Matt\ProcessedData\' useDate '\' useDate '_experiment_parameters.dat'],true,html);
    
    html = strcat(html,'<br><br><hr><br><br>');
end

html = strcat(html,'</body></html>');

fn = fullfile(baseDir, 'Experiment_summary_report.html');

fid = fopen(fn,'w+');
fprintf(fid,'%s',html);