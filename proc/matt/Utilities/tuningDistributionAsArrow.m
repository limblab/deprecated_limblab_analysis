% make plot summarizing tuning of population
%   have arrows where direction is PD, thickness is BO, length is MD


pd = tuning(1).pds(:,1);
md = tuning(1).mds(:,1);
fr = tuning(1).bos(:,1);

% color depends on fr
figure;
cmap=colormap('jet');                      % Set colormap
yy=linspace(min(fr),max(fr),size(cmap,1));  % Generate range of color indices that map to cmap
cm = spline(yy,cmap',fr);                  % Find interpolated colorvalue
cm(cm>1)=1;                               % Sometimes iterpolation gives values that are out of [0,1] range...
cm(cm<0)=0;

hold all;
for unit = 1:size(pd,1)
    plot((md(unit)./fr(unit)).*[0,cos(pd(unit))],(md(unit)./fr(unit)).*[0,sin(pd(unit))],'Color',cm(:,unit));
end
colorbar;
for unit = 1:size(pd,1)
    arrow([0,0],(md(unit)./fr(unit)).*[cos(pd(unit)),sin(pd(unit))],'FaceColor',cm(:,unit),'EdgeColor',cm(:,unit));
end
set(gca,'FontSize',14,'Box','off','TickDir','out');

axis('square');
axis('tight');
V = axis;
axis([-max(abs(V)),max(abs(V)),-max(abs(V)),max(abs(V))]);
plot([-max(abs(V)),max(abs(V))],[0 0],'k--');
plot([0 0],[-max(abs(V)),max(abs(V))],'k--');

figure;
for unit = 1:size(pd,1)
    arrow([0,0],[cos(pd(unit)),sin(pd(unit))]);
end

set(gca,'FontSize',14,'Box','off','TickDir','out');
axis('square');