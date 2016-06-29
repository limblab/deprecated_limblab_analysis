function cost = maxmin_diffjoint(armpos)
% MAXMIN_DIFFJOINT finds the max-min difference of the derivative of joint
% PD with respect to Cartesian PD at a given arm position and returns it as
% the cost of the arm position. Used to minimize nonlinearity of
% transformation between Cartesian and Joint PDs

should_flexion = armpos(1);
elbow_flexion = armpos(2);

cart_PD_sort = linspace(0,2*pi,1000)';
joint_PD_sort = cart2joint_xform(cart_PD_sort,should_flexion,elbow_flexion);
joint_PD_diff = [joint_PD_sort(1)-joint_PD_sort(end)+2*pi;diff(joint_PD_sort)]/(2*pi/1000);

cost = max(joint_PD_diff)-min(joint_PD_diff);