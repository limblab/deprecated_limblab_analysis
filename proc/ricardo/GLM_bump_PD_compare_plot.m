function GLM_bump_PD_compare_plot(glm_pd_table,bump_pd_table,monkey_array)

figure
chan_glm = glm_pd_table(:,1);
chan_bump = bump_pd_table(:,1);
chan_both = intersect(chan_glm,chan_bump);
pref_dirs_glm = glm_pd_table(:,3);
pref_dirs_bump = bump_pd_table(:,3);

electrode_pin = electrode_pin_mapping(monkey_array);

[temp, index_bump, index_glm] = intersect(chan_bump,chan_glm);
pref_dirs_diff = abs(pref_dirs_bump(index_bump(:))-pref_dirs_glm(index_glm(:)));
cos_pref_dirs = cos(pref_dirs_bump(index_bump(:))-pref_dirs_glm(index_glm(:)));
pref_dirs_diff = min(pref_dirs_diff,2*pi-pref_dirs_diff);

for i = 1:length(index_bump)
    subplot(10,10,electrode_pin(electrode_pin(:,2)==chan_glm(i),1))
    area([0 0 1 1],[0 1 1 0],'FaceColor',hsv2rgb([1 1 cos_pref_dirs(i)/2 + .5]))
    hold on
    vectarrow(.5+[0 0],.5+[0.5*cos(pref_dirs_diff(i)) 0.5*sin(pref_dirs_diff(i))],.3,.3,'white')
    axis off
    title(num2str(chan_glm(i)))
end

no_unit_electrodes = setdiff(electrode_pin(:,2),chan_both(:,1));
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
title('PD difference')

% PD difference histogram
figure; hist(180*pref_dirs_diff/pi)
xlabel('Absolute PD difference (deg)')
ylabel('Count')