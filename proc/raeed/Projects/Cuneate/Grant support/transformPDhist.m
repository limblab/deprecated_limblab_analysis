function transformPDhist
%% Transform Cartesian distribution of PDs to Joint distribution of PDs
% First generate Cartesian distribution
clear
cart_PD = 2*pi*rand(100000,1);
% adjustments = [pi/4*randn(400,1)+pi/2; pi/4*randn(400,1)-pi/2];
adjustments = [];
cart_PD = [cart_PD;adjustments];

figure(234)
subplot(121)
rose(cart_PD)
title 'Cartesian PD distribution'

% then transform to joint
% assume shoulder and elbow at right angle and shoulder at 45 degrees
should_flexion = pi/4;
elbow_flexion = pi/2;
joint_PD = cart2joint_xform(cart_PD,should_flexion,elbow_flexion);

figure(234)
subplot(122)
rose(joint_PD,100)
title 'Joint PD distribution'

%% transform back
% cart_PD_back = joint2cart_xform(joint_PD,should_flexion,elbow_flexion);
% 
% figure(234)
% subplot(133)
% rose(cart_PD_back)
% title 'Joint PD distribution'

%% try optimizing posture for most linear possible relationship
% optimal_armpos = fmincon(@maxmin_diffjoint,rand(2,1), [eye(2);-eye(2)], [pi/2;2*pi/3;0;0])

%% plot relationshiop
% should_flexion = optimal_armpos(1);
% elbow_flexion = optimal_armpos(2);
cart_PD_sort = linspace(0,2*pi,10000)';
[joint_PD_sort,joint_vec_sort] = cart2joint_xform(cart_PD_sort,should_flexion,elbow_flexion);
figure(213)
subplot(211)
plot(cart_PD_sort*180/pi,joint_PD_sort*180/pi)
axis([0 360 -180 180])
ylabel 'Joint PD'
% xlabel 'Cartesian PD'
title 'Relationship between Joint and Cartesian PD'

cart_PD_diff = diff(cart_PD_sort);

joint_PD_diff = [joint_PD_sort(1)-joint_PD_sort(end)+2*pi;diff(joint_PD_sort)]/(2*pi/1000);
figure(213)
subplot(212)
plot(cart_PD_sort(2:end)*180/pi,joint_PD_diff(2:end)*180/pi)
set(gca,'xlim',[0 360])
xlabel 'Cartesian PD'
ylabel '{dJointPD} over {dCartPD}'
title 'Derivative of Relationship between Joint and Cartesian PD'

%% plot actual joint angle displacements
cart_dirs = linspace(0,2*pi,100)';
cart_targs = linspace(0,7*pi/4,8)';
[~,joint_disp] = cart2joint_xform(cart_dirs,should_flexion,elbow_flexion);
[~,joint_targs] = cart2joint_xform(cart_targs,should_flexion,elbow_flexion);
targ_colors = linspace(1,64,8);
scale_factor = 0.75;

figure(12345)
subplot(121)
plot(cos(cart_dirs),sin(cart_dirs),'bo')
hold on
plot(scale_factor*cos(cart_dirs),scale_factor*sin(cart_dirs),'ro')
scatter(cos(cart_targs),sin(cart_targs),500,targ_colors,'s','filled')
axis([-1.2 1.2 -1.2 1.2])
axis square
grid on
xlabel 'X Displacement (cm)'
ylabel 'Y Displacement (cm)'
title 'Cartesian Displacements'

subplot(122)
plot(joint_disp(:,1)*180/pi,joint_disp(:,2)*180/pi,'bo')
hold on
plot(scale_factor*joint_disp(:,1)*180/pi,scale_factor*joint_disp(:,2)*180/pi,'ro')
scatter(joint_targs(:,1)*180/pi,joint_targs(:,2)*180/pi,500,targ_colors,'s','filled')
axis square
xlabel 'Shoulder Flexion (º)'
ylabel 'Elbow Flexion (º)'
title 'Joint Displacements'

colormap jet

% get distance between points
point_dist = diff(joint_disp)/(2*pi/100);
figure;
plot(cart_dirs(2:end)*180/pi,sum(point_dist.^2,2))
max(sum(point_dist.^2,2))/min(sum(point_dist.^2,2))

%%
% figure(7843912)
% subplot(211)
% plot(cart_PD_sort,joint_vec_sort(:,1))
% ylabel 'Shoulder movement'
% subplot(212)
% plot(cart_PD_sort,joint_vec_sort(:,2))
% ylabel 'Elbow movement'
% xlabel 'Cartesian PD'