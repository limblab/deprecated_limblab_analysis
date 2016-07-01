function makeHTMLfromRasters(theTitle, theSections, fn, folderName)

html = '';

% theTitle = 'CD-sorted | 03-10-14 | 2 Force Levels | Target 2';
% theSections = {'2 Force Levels',''};
% fn = 'Jango_031014_2ForceLevels_Target2_Sorted.html';
% folderName = 'Y:\user_folders\Stephanie\Data Analysis\ContextDependence\Jango\03-10-14\Jango_031014_2ForceLevels_Target2_Sorted\' ;


% start the document
html = strcat(html,'<html>');

% make the header
html = strcat(html,['<head><title>' theTitle '</title></head>']);

% start the body
html = strcat(html,'<body>');

% html = strcat(html,'<div id="contents">');
% for i = 1:length(theSections)
%     html = strcat(html,['<a href="#' theSections{i} '">' theSections{i} '</a><br>']);
% end
% html = strcat(html,'</div><hr>');
% 

html = strcat(html,'&nbsp&nbsp', theTitle, '<br><br>');
thePlots = (ls(folderName));
html = strcat(html,'<div id="<br>Histograms">');
for i = 3:length(thePlots(:,1))
    html = strcat(html,['<a href="' strcat(folderName, thePlots(i,:)) '">' thePlots(i,:) '</a><br>']);
end
html = strcat(html,'</div><hr>');

html = strcat(html,'&nbsp&nbsp   Histograms <br><br>');
html = strcat(html,'<div id="Images">');
for i = 3:length(thePlots(:,1))
    html = strcat(html,['&nbsp&nbsp' thePlots(i,:) '<br><img src="' strcat(folderName, thePlots(i,:)) '" height="400px"><br>']);
end
html = strcat(html,'</div><hr>');




% % add content
% for i = 1:length(theSections)
%     html = strcat(html,['<div id="' theSections{i} '">']);
%     html = strcat(html,['<p>' theSections{i} '</p>']);
%     for j = 1:50
%         html = strcat(html,'<br>');
%     end
%     html = strcat(html,'<hr></div>');
% end

html = strcat(html,'</body></html>');

fid = fopen(fn,'w+');
fprintf(fid,'%s',html);
fclose(fid);

end
