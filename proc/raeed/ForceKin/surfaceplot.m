function surfaceplot
%% set up force and velocity arrays
num_pts = 20;
force_dirs = linspace(-180,180,num_pts);
vel_dirs = linspace(-180,180,num_pts);

[vel_mat,force_mat] = meshgrid(vel_dirs,force_dirs);

%% do power surface plot
power = cosd(force_mat-vel_mat);
surf(vel_dirs,force_dirs,power)
colormap jet
axis([-200 200 -200 200 -2 2])
grid off
set(gca,'xtick',[-180 -90 0 90 180],'ytick',[-180 -90 0 90 180],'ztick',[-2 0 2])
xlabel 'Velocity Direction'
ylabel 'Force Direction'

%% Cosine product surface plot
cproduct = cosd(force_mat).*cosd(vel_mat);
surf(vel_dirs,force_dirs,cproduct)
colormap jet
axis([-200 200 -200 200 -2 2])
grid off
set(gca,'xtick',[-180 -90 0 90 180],'ytick',[-180 -90 0 90 180],'ztick',[-2 0 2])
xlabel 'Velocity Direction'
ylabel 'Force Direction'