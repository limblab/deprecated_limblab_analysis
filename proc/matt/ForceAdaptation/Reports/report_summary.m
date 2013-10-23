%% Make summary, maybe with memory cells and stuff? link to the cell then
function html = report_summary(html,d,p)
useUnsorted = p.useUnsorted;
epochs = p.epochs;

html = strcat(html,'<div id="summary"><h2>Summary</h2>');

if ~useUnsorted
    html = strcat(html,['<br><table><tr><td># Units:</td><td>' num2str(d.(epochs{1}).params.unit_count) '</td></tr>' ...
        '<tr><td># tuned in any epoch</td><td>' num2str(0) '</td></tr>' ...
        '<tr><td># tuned in all epochs</td><td>' num2str(0) '</td></tr></table>']);
end

html = strcat(html,'<br><a href="#header">back to top</a></div><hr>');