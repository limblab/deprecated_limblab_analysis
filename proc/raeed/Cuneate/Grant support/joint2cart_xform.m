function cartPD = joint2cart_xform(jointPD,should_flexion,elbow_flexion)
% CART2JOINT_XFORM Computes the joint PD from a Cartesian PD and given arm
% angles. Angles given referenced from shoulder abducted to side and elbow
% straight, where flexion for each joint is positive.

% Calculate Jacobian for joint->cart from given angles
% Assume both arm links are 20 cm
l1 = 20; %cm
l2 = 20; %cm
theta_s = should_flexion;
theta_e = elbow_flexion;
gamma = theta_s+theta_e;
J_jtoc = [-l1*sin(theta_s)-l2*sin(gamma) -l2*sin(gamma);...
           l1*cos(theta_s)+l2*cos(gamma)  l2*cos(gamma)];

% find jointPD from cartPD
cart_vec = [cos(jointPD) sin(jointPD)];
cart_vec = cart_vec*(J_jtoc');
cartPD = atan2(cart_vec(:,2),cart_vec(:,1));