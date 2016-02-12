function compare_opt_forces(out_struct,time_window,hfig)

calmat = out_struct.calmat;
emg_enable = out_struct.emg_enable;
platON = time_window(1);
platOFF = time_window(2);
[magForce,~,dirForce,~,forceCloud,~,~,~] = compute_force_magnitude(out_struct,calmat,emg_enable,platON,platOFF);

fdes = out_struct.fdes;
fx = magForce*cos(dirForce);
fy = magForce*sin(dirForce);
fx = mean(forceCloud.fX);
fy = mean(forceCloud.fY);

figure(hfig); hold on;

plot(forceCloud.fX,forceCloud.fY,'g.')
plot([0 fdes(1)],[0 fdes(2)],'k','LineWidth',2);
plot(fdes(1),fdes(2),'ko','MarkerSize',6,'MarkerFaceColor','r');
plot([0 fx],[0 fy],'m','LineWidth',2);
axis equal
