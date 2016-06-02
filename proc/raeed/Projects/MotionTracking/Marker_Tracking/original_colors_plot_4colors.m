%This script plots the original points
%and can be used for inputting the starting locations of the markers

%Note that yellow is plotted in cyan for visibility

%% All colors at once

n=length(color1);
xlims=[-.4 .5];
ylims=[-.4 .4]; 
zlims=[.8 1.5];

figure;

xlim(zlims)
ylim(xlims)
zlim(ylims)
set(gca,'NextPlot','replacechildren');


for i=1:100%70000:70100 %536
    temp=color1{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    scatter3(z,x,y,'b')
    hold on;
    temp=color2{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    scatter3(z,x,y,'g')
    temp=color3{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    scatter3(z,x,y,'r')
    temp=color4{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    scatter3(z,x,y,'c')
    hold off
    title(i);
    xlabel('z')
    ylabel('x')
    zlabel('y')
    xlim(zlims)
    ylim(xlims)
    zlim(ylims)
%     pause(.03)
    pause;
end