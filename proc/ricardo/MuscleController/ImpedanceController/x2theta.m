function theta = x2theta(x,arm_params)

%     theta = nan(1,2);
%     theta(2) = acos((2*x(1)^2-arm_params.l(1)^2-arm_params.l(2)^2)/(2*arm_params.l(1)*arm_params.l(2)));
%     theta(1) = -(arm_params.l(2)*sin(theta(2)))*x(1) + (arm_params.l(1)+arm_params.l(2)*cos(theta(2)))*x(2)/...
%         (arm_params.l(2)*sin(theta(2))*x(2) + (arm_params.l(1) + arm_params.l(2)*cos(theta(2)))*x(1));
% %     theta(2) = theta(1)+theta(2);

a1 = arm_params.l(1);
a2 = arm_params.l(2);
y = x(2)-arm_params.X_s(2);
x = x(1)-arm_params.X_s(1);

if sqrt((x^2+y^2)) > sqrt((a1^2+a2^2))
    th_temp = atan2(y,x);
    amp_temp = sqrt((a1^2+a2^2));
    x = amp_temp*cos(th_temp);
    y = amp_temp*sin(th_temp);
end

% if ~arm_params.left_handed
    theta2 = 2*atan(sqrt(((a1+a2)^2-(x^2+y^2))/((x^2+y^2)-(a1-a2)^2)));
% else
%     theta2 = 2*pi-2*atan(sqrt(((a1+a2)^2-(x^2+y^2))/((x^2+y^2)-(a1-a2)^2)));
% end

phi = atan2(y,x);
psi = atan2(a2*sin(theta2),a1+a2*cos(theta2));
theta1 = phi-psi;

theta = [theta1 theta2+theta1];
