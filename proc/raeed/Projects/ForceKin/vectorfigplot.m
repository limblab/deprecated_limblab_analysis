function vectorfigplot
%% Create the sergio & kalaska type figure for force+velocity traces
% equilibrium point thing
[t,x] = ode45(@odefun, [0 1.5], [0;0;0;0]);

dx = odefun(t,x');
dx = dx';

figure(1)
clf
% plot(t,x(:,1),t,x(:,2),t,dx(:,2))
% plot(t,x(:,1),t,x(:,2))
subplot(141)
plot(x(:,2),-t,'g',dx(:,2)/3,-t,'k','linewidth',2)
set(gca,'xtick',[0],'ytick',[],'xticklabels',[])
grid on
subplot(142)
plot(-x(:,2),-t,'g',-dx(:,2)/3,-t,'k','linewidth',2)
set(gca,'xtick',[0],'ytick',[],'xticklabels',[])
grid on
subplot(143)
plot(x(:,2),-t,'g',-dx(:,2)/3,-t,'k','linewidth',2)
set(gca,'xtick',[0],'ytick',[],'xticklabels',[])
grid on
subplot(144)
plot(-x(:,2),-t,'g',dx(:,2)/3,-t,'k','linewidth',2)
set(gca,'xtick',[0],'ytick',[],'xticklabels',[])
grid on

% get times to plot
t_samp = linspace(0,1.5,30);
dx_samp = interp1(t,dx,t_samp);
vel_samp = dx_samp(:,1);
force_samp = dx_samp(:,2)/3;

figure(2)
clf
subplot(141)
stem(t_samp,vel_samp,'filled','g','linewidth',2,'markersize',10)
hold on
stem(t_samp,force_samp,'filled','k','linewidth',2,'markersize',10)
set(gca,'cameraupvector',[-1 0 0],'xtick',[],'ytick',[])
subplot(142)
stem(t_samp,-vel_samp,'filled','g','linewidth',2,'markersize',10)
hold on
stem(t_samp,-force_samp,'filled','k','linewidth',2,'markersize',10)
set(gca,'cameraupvector',[-1 0 0],'xtick',[],'ytick',[])
subplot(143)
stem(t_samp,vel_samp,'g','linewidth',2,'markersize',10)
hold on
stem(t_samp,-force_samp,'k','linewidth',2,'markersize',10)
set(gca,'cameraupvector',[-1 0 0],'xtick',[],'ytick',[])
subplot(144)
stem(t_samp,-vel_samp,'g','linewidth',2,'markersize',10)
hold on
stem(t_samp,force_samp,'k','linewidth',2,'markersize',10)
set(gca,'cameraupvector',[-1 0 0],'xtick',[],'ytick',[])
legend('Force','Velocity')

end

function dy = odefun(~,y)
    %eq point dynamics
    w0_eq = 10;
    zeta_eq = 1;
    eq_eq_pt = 5;
    displac_eq = y(3,:)-eq_eq_pt;
    eq_vec = [displac_eq;y(4,:)];
    trans_mat_eq = [0 1;-w0_eq^2 -2*zeta_eq*w0_eq];
    eq_dot = trans_mat_eq*eq_vec;
    
    %actual dynamics
    w0 = 5;
    zeta = 1;
    displac = y(1,:)-y(3,:);
    state_vec = [displac;y(2,:)];
    trans_mat = [0 1;-w0^2 -2*zeta*w0];
    state_dot = trans_mat*state_vec;
    
    dy = [state_dot;eq_dot];
end