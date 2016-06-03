function xdot = sandercock_param_fit(t,z,p)
global musc_act

theta = z;
g = 0;
T = 0;
F_end = [0 0];
m = [2 1.5];
l = [.4 .35];
lc = l/2;
i = m.*l.^2/3;
Ksh = 60; 
Kl = 1;
null_angles = [pi/4 3*pi/4];

c = p(1:2)';
F_max = p(3:6)';
m_ins = p(7:10)';
k_gain = p(11)';

musc_l0 = sqrt(2*m_ins.^2);

xdot = zeros(4,1);

sin_theta_1 = sin(theta(1));
sin_theta_2 = sin(theta(2));
cos_theta_1 = cos(theta(1));
cos_theta_2 = cos(theta(2));

X_e = [l(1)*cos_theta_1 l(1)*sin_theta_1];

musc_end_1 = [m_ins(1)*cos(null_angles(1)+pi/2)...
    m_ins(1)*cos(null_angles(1)-pi/2)...
    X_e(1)-m_ins(3)*cos_theta_1...
    X_e(1)+m_ins(4)*cos_theta_1;...
    m_ins(1)*sin(null_angles(1)+pi/2)...
    m_ins(2)*sin(null_angles(1)-pi/2)...
    X_e(2)-m_ins(3)*sin_theta_1...
    X_e(2)+m_ins(4)*sin_theta_1];
musc_end_2 = [m_ins(1)*cos_theta_1...
    m_ins(2)*cos_theta_1...
    X_e(1)+m_ins(3)*cos_theta_2...
    X_e(1)+m_ins(4)*cos_theta_2;...
    m_ins(1)*sin_theta_1...
    m_ins(2)*sin_theta_1...
    X_e(2)+m_ins(3)*sin_theta_2...
    X_e(2)+m_ins(4)*sin_theta_2];

musc_vel = [m_ins(1)*theta(3) m_ins(2)*theta(3)...
    m_ins(3)*theta(4) m_ins(4)*theta(4);...
    m_ins(1)*theta(3) m_ins(2)*theta(3)...
    m_ins(3)*theta(4) m_ins(4)*theta(4)];

musc_vel = musc_vel.*[-sin_theta_1 -sin_theta_1...
                        -sin_theta_2 -sin_theta_2;...
                        cos_theta_1 cos_theta_1...
                        cos_theta_2 cos_theta_2];

musc_vel = sqrt(sum(musc_vel.^2));

% Negative musc_vel is muscle shortening.
musc_vel(1) = -sign(theta(3))*musc_vel(1);
musc_vel(2) = sign(theta(3))*musc_vel(2);
musc_vel(3) = -sign(theta(4))*musc_vel(3);
musc_vel(4) = sign(theta(4))*musc_vel(4);

musc_length = sqrt(sum((musc_end_1 - musc_end_2).^2));

active_musc_force = musc_act(round(t),:).*F_max.*...
    (1-4*((musc_length-musc_l0)./musc_l0).^2) +...
    (musc_length-musc_l0).*musc_act(round(t),:).*k_gain;

% Make active force flat when muscle is longer than l0.
active_musc_force(musc_length>musc_l0) = musc_act(round(t),musc_length>musc_l0).*...
    F_max(musc_length>musc_l0);
    
f = [.82 .5 .43 58]; % from Heliot2010
active_musc_force = active_musc_force.*(f(1) + f(2)*atan(f(3)+f(4)*musc_vel));
active_musc_force = max(0,active_musc_force);

passive_musc_force = F_max.*exp(Ksh*(musc_length-Kl*2*m_ins)./(Kl*2*m_ins));

% %%     Code for plotting force-length relationship:
%     p = get_default_p;    
%     musc_l0 = sqrt(2*m_ins.^2)+...
%         0*sqrt(2*m_ins.^2)/5.*...
%         (rand(1,length(m_ins))-.5);
%     musc_length = 0:.001:musc_l0(1)*2;
%     
%     figure;
%     alpha = 1;
%     active_force_plot = alpha.*F_max(1).*...
%         (1-4*((musc_length-musc_l0(1))./musc_l0(1)).^2) +...
%         (musc_length-musc_l0(1)).*ones(size(F_max(1))).*k_gain;
%     active_force_plot(active_force_plot<0) = 0;
%     active_force_plot(musc_length>musc_l0(1)) = alpha.*F_max(1);
%     passive_force_plot = F_max(1).*exp(Ksh*...
%         (musc_length-Kl*2*m_ins(1))./(Kl*2*m_ins(1)));
%     passive_force_plot(passive_force_plot<0) = 0;
% 
%     plot(musc_length,active_force_plot,...
%         musc_length,passive_force_plot,...
%         musc_length,active_force_plot+passive_force_plot);
%     legend('Passive','Active','Passive + active')
%     xlabel('Muscle length (m)')
%     ylabel('Muscle force (N)')
%     ylim([0 1500])

%%
passive_musc_force = max(0,passive_musc_force);

musc_force = active_musc_force + passive_musc_force;
musc_force = max(0,musc_force);
musc_force = min(musc_force,F_max);

musc_torque = [(m_ins(1)*musc_force(1) - m_ins(2)*musc_force(2));...
    (m_ins(3)*musc_force(3) - m_ins(4)*musc_force(4))];

 %matrix equations 
M = [m(2)*lc(1)^2+m(2)*l(1)^2+i(1), m(2)*l(1)*lc(2)^2*cos(theta(1)-theta(2));
 m(2)*l(1)*lc(2)*cos(theta(1)-theta(2)),+m(2)*lc(2)^2+i(2)]; 

C = [-m(2)*l(1)*lc(2)*sin(theta(1)-theta(2))*theta(4)^2;
 -m(2)*l(1)*lc(2)*sin(theta(1)-theta(2))*theta(3)^2];

Fg = [(m(1)*lc(1)+m(2)*l(1))*g*cos_theta_1;
 m(2)*g*lc(2)*cos_theta_2];

T_endpoint = [-(l(1)*sin_theta_1+l(2)*sin_theta_2) * F_end(1) + (l(1)*cos_theta_1-l(2)*cos_theta_2) * F_end(2);
    -l(2)*sin_theta_2 * F_end(1) + l(2)*cos_theta_2 * F_end(2)];

tau_c = [-theta(3)*c(1);-(theta(4)-theta(3))*c(2)]; % viscosity
tau = T(:) + tau_c;
xdot(1:2,1)=theta(3:4);
xdot(3:4,1)= M\(T_endpoint + tau-Fg-C + musc_torque);

end