%% Generate data for active and passive
numpts = 100;
active_right = 0.2*randn(numpts,2)+ones(numpts,2);
active_left = 0.2*randn(numpts,2)-ones(numpts,2);
passive_left = 0.2*randn(numpts,2)+repmat([-1 1],numpts,1);
passive_right = 0.2*randn(numpts,2)+repmat([1 -1],numpts,1);

% generate boundary lines
velneg = linspace(-2,-0.01,1000);
velpos = linspace(0.01,2,1000);
forceneg = 0.1./velneg;
forcepos = 0.1./velpos;

% Plot velocity force
figure(1)
clf
plot(active_right(:,1),active_right(:,2),'.b', 'markersize', 20)
hold on
plot(passive_left(:,1),passive_left(:,2),'or', 'markersize', 5)
plot(active_left(:,1),active_left(:,2),'.r', 'markersize', 20)
plot(passive_right(:,1),passive_right(:,2),'ob', 'markersize', 5)
plot(velneg,forceneg,'--k','linewidth',1)
plot(velpos,forcepos,'--k','linewidth',1)

axis([-2 2 -2 2])
grid on
set(gca,'xticklabel','','yticklabel','','xtick',[0],'ytick',[0])
xlabel 'Velocity'
ylabel 'Force'

%% compute force*vel
active_right_forcevel = active_right(:,1).*active_right(:,2);
active_left_forcevel = active_left(:,1).*active_left(:,2);
passive_left_forcevel = passive_left(:,1).*passive_left(:,2);
passive_right_forcevel = passive_right(:,1).*passive_right(:,2);

% Plot velocity force-velocity
figure(2)
clf
plot(active_right(:,1),active_right_forcevel,'.b', 'markersize', 20)
hold on
plot(passive_left(:,1),passive_left_forcevel,'or', 'markersize', 5)
plot(active_left(:,1),active_left_forcevel,'.r', 'markersize', 20)
plot(passive_right(:,1),passive_right_forcevel,'ob', 'markersize', 5)
plot([velneg velpos], zeros(size([velneg velpos])),'--k')

axis([-2 2 -2 2])
grid on
set(gca,'xticklabel','','yticklabel','','xtick',[0],'ytick',[0])
xlabel 'Velocity'
ylabel 'Force x Velocity'

% plot 3d
% figure
% plot3(active_right(:,1),active_right(:,2),active_right_forcevel,'.b', 'markersize', 30)
% hold on
% plot3(passive_left(:,1),passive_left(:,2),passive_left_forcevel,'or', 'markersize', 10)
% plot3(active_left(:,1),active_left(:,2),active_left_forcevel,'.r', 'markersize', 30)
% plot3(passive_right(:,1),passive_right(:,2),passive_right_forcevel,'ob', 'markersize', 10)
% axis([-1.5 1.5 -1.5 1.5 -1.5 1.5])
% grid on