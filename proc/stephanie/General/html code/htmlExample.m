

html = '';

theTitle = 'CD | 10-06-17 | 2 Force Levels';
theSections = {'2 Force Levels',''};
fn = 'stephie_html.html';

% start the document
html = strcat(html,'<html>');

% make the header
html = strcat(html,['<head><title>' theTitle '</title></head>']);

% start the body
html = strcat(html,'<body>');

html = strcat(html,'<div id="contents">');
for i = 1:length(theSections)
    html = strcat(html,['<a href="#' theSections{i} '">' theSections{i} '</a><br>']);
end
html = strcat(html,'</div><hr>');

% add content
for i = 1:length(theSections)
    html = strcat(html,['<div id="' theSections{i} '">']);
    html = strcat(html,['<p>' theSections{i} '</p>']);
    for j = 1:100
        html = strcat(html,'<br>');
    end
    html = strcat(html,'<hr></div>');
end

html = strcat(html,'</body></html>');

fid = fopen(fn,'w+');
fprintf(fid,'%s',html);
fclose(fid);

