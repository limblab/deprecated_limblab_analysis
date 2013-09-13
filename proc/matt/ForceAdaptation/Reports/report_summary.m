%% Make summary, maybe with memory cells and stuff? link to the cell then
html = strcat(html,'<div id="summary"><h2>Summary</h2>');

if ~useUnsorted
    html = strcat(html,['<br><table><tr><td># Units:</td><td>' num2str(d.(epochs{1}).params.unit_count) '</td></tr>' ...
        '<tr><td># tuned in any epoch</td><td>' num2str(tunedCount) '</td></tr>' ...
        '<tr><td># tuned in all epochs</td><td>' num2str(superTunedCount) '</td></tr></table>']);
end

html = strcat(html,'<br><a href="#header">back to top</a></div><hr>');