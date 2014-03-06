function xdot = arm_dynamics_feedforward(t,x,arm_params)
% function xdot = arm_dynamics(t,x)

m = arm_params.m;
d = arm_params.d;
l = arm_params.l;
k = arm_params.k;
b = arm_params.b;
theta_e = arm_params.theta_e;
theta_ref = arm_params.theta_ref;
theta_ref_dot_dot = arm_params.theta_ref_dot_dot;
F_end = arm_params.F_end;

I = m.*l.^2/3;
J = m.*d.^2+I;

theta = x(1:2);
theta_dot = x(3:4);

theta_12 = sum(theta);
theta_12_dot = sum(theta_dot);
theta_ref_12 = sum(theta_ref);

theta_ref_dot_dot_12 = sum(theta_ref_dot_dot);

M = [J(1) + J(2) + m(2)*l(2)^2 + 2*m(2)*l(1)*d(2)*cos(theta(2)) ...
    J(2)+m(2)*l(2)*d(2)*cos(theta(2));...
    J(2)+m(2)*l(1)*d(2)*cos(theta(2)) ...
    J(2)];

C = [-m(2)*l(1)*d(2)*sin(theta(2))*(theta_dot(2)^2+2*theta_dot(1)*theta_dot(2));...
    m(2)*l(1)*d(2)*sin(theta(2))*theta_dot(1)^2];

if ~arm_params.monkey_control
    % Feedforward control
    T_feedforward(1) = (J(1) + m(2)*l(1)^2 + m(2)*l(1)*d(2)*cos(theta(2)))*theta_ref_dot_dot(1);
    T_feedforward(2) = -m(2)*l(1)*cos(theta(2))*theta_ref_dot_dot(2) +...
        m(2)*l(1)*d(2)*sin(theta(2))*(sum(theta_dot)^2);
    T_feedforward(3) = (J(2) + m(2)*l(1)*d(2)*cos(theta(2)))*theta_ref_dot_dot_12 -...
        m(2)*l(1)*d(2)*sin(theta(2))*(theta_dot(2)^2+2*theta_dot(1)*theta_dot(2));

    % Feedback control
    K(1) = l(1)^2*(k(1)*sin(theta(1))*sin(theta(1)+theta_e)+...
        k(2)*cos(theta(1))*cos(theta(1)+theta_e));
    K(2) = l(1)*l(2)*(k(1)*sin(theta(1))*sin(theta_12+theta_e)+...
        k(2)*cos(theta(1))*cos(theta_12+theta_e));
    K(3) = l(1)*l(2)*(k(1)*sin(theta_12)*sin(theta(1)+theta_e)+...
        k(2)*cos(theta_12)*cos(theta(1)+theta_e));
    K(4) = l(2)^2*(k(1)*sin(theta_12)*sin(theta_12+theta_e)+...
        k(2)*cos(theta_12)*cos(theta_12+theta_e));

    T_feedback(1) = K(1)*(theta_ref(1)-theta(1)) + K(2)*(theta_ref_12-theta_12) -...
        b*(K(1)*theta_dot(1) + K(2)*theta_12_dot);
    T_feedback(2) = 0;
    T_feedback(3) = K(3)*(theta_ref(1)-theta(1)) + K(4)*(theta_ref_12-theta_12) -...
        b*(K(3)*theta_dot(1) + K(4)*theta_12_dot);

    T_musc = [T_feedforward(1) + T_feedback(1) + T_feedforward(3) + T_feedback(3);...
        T_feedforward(2) + T_feedback(2) + T_feedforward(3) + T_feedback(3)];
else
    T_musc = [(arm_params.u1e - arm_params.u1f) + (arm_params.u3e - arm_params.u3f);
        (arm_params.u2e - arm_params.u2f) + (arm_params.u3e - arm_params.u3f)];
end

T_endpoint = [-(l(1)*sin(theta(1))+l(2)*sin(theta(2))) * F_end(1) + (l(1)*cos(theta(1))-l(2)*cos(theta(2))) * F_end(2);
    -l(2)*sin(theta(2)) * F_end(1) + l(2)*cos(theta(2)) * F_end(2)];

xdot(1:2,1) = theta_dot;
xdot(3:4,1) = M\(C + T_musc + T_endpoint);
xdot(5:7,1) = T_feedback;
xdot(8:10,1) = T_feedforward;
