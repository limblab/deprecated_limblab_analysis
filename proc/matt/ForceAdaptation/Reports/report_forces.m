%% Make plot showing forces check out
html = strcat(html,['<div id="force">' ...
    '<table><tr><td><h2>Forces</h2></td><td>Strength:</td><td>' num2str(forceMag) ' Ns/cm</td><td>Direction:</td><td>' num2str(forceAng.*180/pi) ' deg </td></tr></table>' ...
    '<img src="' genFigPath '\force_vel.png" width="' num2str(imgWidth+200) '">' ...
    '<img src="' genFigPath '\force_mag.png" width="' num2str(imgWidth+200) '">' ...
    '<img src="' genFigPath '\force_line.png" width="' num2str(imgWidth+200) '">' ...
    '<br><a href="#header">back to top</a>' ...
    '</div><hr>']);