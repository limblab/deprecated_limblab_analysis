% function UnstableField()

theta = .7853;
F_offset = 0.02;
F_offset_theta = 0;
% Fx_offset = 10;
% Fy_offset = 10;
x_offset = 0;
y_offset = 0;
neg_stiffness = 0.008;
pos_stiffness = 0.16;
axis_lim = 10;

[X,Y] = meshgrid(-axis_lim:axis_lim/5:axis_lim);
X = X(:);
Y = Y(:);
X_new = X(sqrt(X.^2+Y.^2)<10);
Y_new = Y(sqrt(X.^2+Y.^2)<10);
X = X_new;
Y = Y_new;

Fx_prime = neg_stiffness*((X-x_offset)*cos(theta) + (Y-y_offset)*sin(theta))*cos(theta) +...
    pos_stiffness*(-(X-x_offset)*sin(theta) + (Y-y_offset)*cos(theta))*sin(theta) +...
    F_offset*cos(F_offset_theta);
Fy_prime = neg_stiffness*((X-x_offset)*cos(theta) + (Y-y_offset)*sin(theta))*sin(theta) -...
    pos_stiffness*(-(X-x_offset)*sin(theta) + (Y-y_offset)*cos(theta))*cos(theta) +...
    F_offset*sin(F_offset_theta);


X_target = 4*cos(0:.1:2*pi);
Y_target = 4*sin(0:.1:2*pi);
X_workspace = 10*cos(0:.1:2*pi);
Y_workspace = 10*sin(0:.1:2*pi);

figure;
area([X_workspace X_workspace(1)],[Y_workspace Y_workspace(1)],'LineStyle','none','FaceColor',[.8 .8 .8])
hold on
area([X_target X_target(1)],[Y_target Y_target(1)],'LineStyle','none','FaceColor',[.4 .4 1])
quiver(X,Y,Fx_prime,Fy_prime,'k')
xlim([-15 15])
ylim([-15 15])
axis square
% set(gca,'ytick',[],'xtick',[])


