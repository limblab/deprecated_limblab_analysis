%% PDs and depth of modulation.  Top view of array, wire bundle to the right
function PD_map(table,monkey_array)

figure
chan = table(:,1);
pref_dirs = table(:,3);
modulation = table(:,4);
electrode_pin = electrode_pin_mapping(monkey_array);

for i = 1:length(chan)
    subplot(10,10,electrode_pin(electrode_pin(:,2)==chan(i),1))
    area([0 0 1 1],[0 1 1 0],'FaceColor',hsv2rgb([pref_dirs(i)/(2*pi) modulation(i) 1]))
    hold on
    vectarrow(.5+[0 0],.5+modulation(i)*[0.5*cos(pref_dirs(i)) 0.5*sin(pref_dirs(i))],.3,.3,'k')
    axis off
    title(num2str(chan(i,1)))
end

no_unit_electrodes = setdiff(electrode_pin(:,2),chan);
for i = 1:length(no_unit_electrodes)
    subplot(10,10,electrode_pin(electrode_pin(:,2)==no_unit_electrodes(i),1))     
    area([0 0 1 1],[0 1 1 0],'FaceColor','white')
    axis off
    title(num2str(no_unit_electrodes(i)))
end

subplot(10,10,1)    
n = 20; 
theta = pi*(0:2*n)/n; 
r = (0:n)'/n;
x = r*cos(theta); 
y = r*sin(theta); 
c = ones(size(r))*theta; 
pcolor(x,y,c)
colormap hsv(360)
set(get(gca,'Children'),'LineStyle','none');
axis equal
axis off
title('PD color')
