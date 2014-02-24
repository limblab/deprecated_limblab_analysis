% function xdot = muscle_arm(x,t,arm_params)
function xdot = muscle_arm(t,x)

% Parameters
params.l = [.2 .2];
params.m = [1 1];
params.d = params.l/2;
params.theta_ref = [pi/4 pi/4]; 

m = params.m;
d = params.d;
l = params.l;

I = m.*l.^2/3;
J = m.*d.^2+I;

theta = x(1:2);
theta_dot = x(3:4);

M = [J(1) + J(2) + m(2)*l(2)^2 + 2*m(2)*l(1)*d(2)*cos(theta(2)) ...
    J(2)+m(2)*l(2)*d(2)*cos(theta(2));...
    J(2)+m(2)*l(1)*d(2)*cos(theta(2)) ...
    J(2)];

C = [-m(2)*l(1)*d(2)*sin(theta(2))*(theta_dot(2)^2+2*theta_dot(1)*theta_dot(2));...
    m(2)*l(1)*d(2)*sin(theta(2))*theta_dot(1)^2];

% T_musc = 

xdot(1:2,1) = theta_dot;
xdot(3:4,1) = M\C;


% M = [m(2)*lc(1)^2+m(2)*l(1)^2+i(1), m(2)*l(1)*lc(2)^2*cos(x(1)-x(2));
%  m(2)*l(1)*lc(2)*cos(x(1)-x(2)),+m(2)*lc(2)^2+i(2)]; 
% 
% C = [-m(2)*l(1)*lc(2)*sin(x(1)-x(2))*x(4)^2;
%  -m(2)*l(1)*lc(2)*sin(x(1)-x(2))*x(3)^2];
% 
% Fg = [(m(1)*lc(1)+m(2)*l(1))*g*cos(x(1));
%  m(2)*g*lc(2)*cos(x(2))];
% 
% T_endpoint = [-(l(1)*sin(x(1))+l(2)*sin(x(2))) * F_end(1) + (l(1)*cos(x(1))-l(2)*cos(x(2))) * F_end(2);
%     -l(2)*sin(x(2)) * F_end(1) + l(2)*cos(x(2)) * F_end(2)];
% 
% xdot(1:2,1)=x(3:4);
% xdot(3:4,1)= M\(T_endpoint + tau-Fg-C + musc_torque);