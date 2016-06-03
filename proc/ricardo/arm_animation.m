bdf_struct = bdf;

l1 = 24.765; l2 = 24.13;
l1_prime = l1 + 3.175;
l2_prime = 24.13;
theta_prime = asin(3.175/l2_prime);

th_t = bdf_struct.raw.enc(:,1); % encoder time stamps

start_time = 1.0;
last_enc_time = bdf_struct.raw.enc(end,1);
stop_time = floor(last_enc_time) - 1;
adfreq = round(1/mode(diff(bdf_struct.pos(:,1)))); 
analog_time_base = start_time:1/adfreq:stop_time;

adfreq = round(1/mode(diff(bdf_struct.pos(:,1))));
th_1 = bdf_struct.raw.enc(:,2) * 2 * pi / 18000;
th_2 = bdf_struct.raw.enc(:,3) * 2 * pi / 18000;
th_1_adj = interp1(th_t, th_1, analog_time_base);
th_2_adj = interp1(th_t, th_2, analog_time_base);

J = [sin(th_1_adj(1))*l1 -cos(th_2_adj(1))*l2 ; -sin(th_2_adj(1))*l2 -cos(th_1_adj(1))*l1];
T = J * [bdf.force(:,2) bdf.force(:,3)]';

T_1 = -cos(th_1_adj)*l1.*bdf.force(:,2)' - sin(th_2_adj)*l2.*bdf.force(:,3)';
T_2 = sin(th_1_adj)*l1*bdf.force(:,2) - cos(th_2_adj)*l2*bdf.force(:,3);

fhcal = [-0.0129 0.0254 -0.1018 -6.2876 -0.1127 6.2163;...
    -0.2059 7.1801 -0.0804 -3.5910 0.0641 -3.6077]'./1000;
rotcal = [-1 0; 0 1];  
Fy_invert = 1;

temp_d = diff(bdf_struct.pos(:,2))<.004 & diff(bdf_struct.pos(:,3))<.004;
q = diff([0 temp_d(:)' 0]);
v1 = find(q == 1); v2 = find(q == -1); 
v = v2-v1;
[max_v,max_v_ind] = max(v);
no_mov_idx = v1(max_v_ind):v2(max_v_ind);
force_offsets_temp = zeros(1,6);

[b,a] = butter(4, 200/adfreq);
raw_force = zeros(length(analog_time_base), 6);
for c = 1:6
    channame = sprintf('ForceHandle%d', c);
    a_data = double(get_analog_signal(bdf_struct, channame));   
    a_data(:,2) = filtfilt(b, a, a_data(:,2));
    a_data = interp1( a_data(:,1), a_data(:,2), analog_time_base);
    raw_force(:,c) = a_data';
    force_offsets(c) = mean(a_data(no_mov_idx));
end

force_offsets = repmat(force_offsets, length(raw_force), 1);
bdf_struct.force = (raw_force - force_offsets) * fhcal * rotcal;
clear force_offsets; % cleanup a little
bdf_struct.force(:,2) = Fy_invert.*bdf_struct.force(:,2); % fix left hand coords in old force
            
temp = bdf_struct.force;
bdf_struct.force(:,1) = temp(:,1).*cos(-th_2_adj)' - temp(:,2).*sin(th_2_adj)';
bdf_struct.force(:,2) = temp(:,1).*sin(th_2_adj)' + temp(:,2).*cos(th_2_adj)';
bdf_struct.force = [analog_time_base' bdf_struct.force];

forceNew = bdf_struct.force;
forceNew(:,2) = temp(:,1).*cos(-(th_2_adj - theta_prime))' - temp(:,2).*sin( + th_2_adj - theta_prime)';
forceNew(:,3) = temp(:,1).*sin( + th_2_adj - theta_prime)' + temp(:,2).*cos( + th_2_adj - theta_prime)';
clear temp
figure;
plot(bdf_struct.force(:,2),bdf_struct.force(:,3),'r')
hold on
plot(forceNew(:,2),forceNew(:,3),'k')
axis equal
axis square


forceTheta = atan2(bdf_struct.force(:,3),bdf_struct.force(:,2));
forceTheta(forceTheta<0) = forceTheta(forceTheta<0) + 2*pi;
forceNewTheta = atan2(forceNew(:,3),forceNew(:,2));
forceNewTheta(forceNewTheta<0) = forceNewTheta(forceNewTheta<0) + 2*pi;
figure; 
plot(180/pi*forceTheta)
hold on
plot(180/pi*forceNewTheta,'r')

syms arm1X_sym(th_1_adj_s) 
syms arm1Y_sym(th_2_adj_s)
arm1X_sym(th_1_adj_s) = -l1*sin(th_1_adj_s);
arm1Y_sym(th_1_adj_s) = -l1*cos(th_1_adj_s);
arm1X = -l1*sin(th_1_adj);
arm1Y= -l1*cos(th_1_adj);

syms arm2X_sym(th_1_adj_s,th_2_adj_s)
syms arm2Y_sym(th_1_adj_s,th_2_adj_s)
arm2X_sym(th_1_adj_s,th_2_adj_s) = -l1*sin(th_1_adj_s) + l2*cos(-th_2_adj_s);
arm2Y_sym(th_1_adj_s,th_2_adj_s) = -l1*cos(th_1_adj_s) - l2*sin(-th_2_adj_s);
arm2X = -l1*sin(th_1_adj) + l2*cos(-th_2_adj);
arm2Y = -l1*cos(th_1_adj) - l2*sin(-th_2_adj);

syms arm1newX_sym(th_1_adj_s,th_2_adj_s)
syms arm1newY_sym(th_1_adj_s,th_2_adj_s)
arm1newX_sym(th_1_adj_s) = -l1_prime*sin(th_1_adj_s);
arm1newY_sym(th_1_adj_s) = -l1_prime*cos(th_1_adj_s);
arm1newX = -l1_prime*sin(th_1_adj);
arm1newY = -l1_prime*cos(th_1_adj);

syms arm2newX_sym(th_1_adj_s,th_2_adj_s)
syms arm2newY_sym(th_1_adj_s,th_2_adj_s)
arm2newX_sym(th_1_adj_s,th_2_adj_s) = -l1_prime*sin(th_1_adj_s) + l2_prime*cos(-th_2_adj_s - theta_prime);
arm2newY_sym(th_1_adj_s,th_2_adj_s) = -l1_prime*cos(th_1_adj_s) - l2_prime*sin(-th_2_adj_s - theta_prime);

arm2newX = -l1_prime*sin(th_1_adj) + l2_prime*cos(-th_2_adj - theta_prime);
arm2newY = -l1_prime*cos(th_1_adj) - l2_prime*sin(-th_2_adj - theta_prime);

%%
figure; 
subplot(121)
plot(bdf_struct.pos(:,2),bdf_struct.pos(:,3))
axis equal
hold on
t_idx = 1;

h_arm1 = plot([0 arm1X_sym(th_1_adj(t_idx))],[0 arm1Y_sym(th_1_adj(t_idx))],'r-');
h_arm2 = plot([arm1X_sym(th_1_adj(t_idx)) arm2X_sym(th_1_adj(t_idx),th_2_adj(t_idx))],...
    [arm1Y_sym(th_1_adj(t_idx)) arm2Y_sym(th_1_adj(t_idx),th_2_adj(t_idx))],'r-');

h_arm1new = plot([0 arm1newX_sym(th_1_adj(t_idx))],[0 arm1newY_sym(th_1_adj(t_idx))],'k-');
h_arm2new = plot([arm1newX_sym(th_1_adj(t_idx)) arm2newX_sym(th_1_adj(t_idx),th_2_adj(t_idx))],...
    [arm1newY_sym(th_1_adj(t_idx)) arm2newY_sym(th_1_adj(t_idx),th_2_adj(t_idx))],'k-');

subplot(122)
hold on
axis equal
xlim([-5 5])
ylim([-5 5])
h_force = plot([0 bdf_struct.force(t_idx,2)],[0 bdf_struct.force(t_idx,3)],'r');
h_forceNew = plot([0 forceNew(t_idx,2)],[0 forceNew(t_idx,3)],'k');

for t_idx = 1:100:length(th_1_adj)    
    set(h_arm1,'XData',[0 subs(arm1X_sym(th_1_adj(t_idx)))],'YData',[0 subs(arm1Y_sym(th_1_adj(t_idx)))])
    set(h_arm2,'XData',[subs(arm1X_sym(th_1_adj(t_idx))) subs(arm2X_sym(th_1_adj(t_idx),th_2_adj(t_idx)))],...
    'YData',[subs(arm1Y_sym(th_1_adj(t_idx))) subs(arm2Y_sym(th_1_adj(t_idx),th_2_adj(t_idx)))])
    set(h_arm1new,'XData',[0 subs(arm1newX_sym(th_1_adj(t_idx)))],'YData',[0 subs(arm1newY_sym(th_1_adj(t_idx)))])
    set(h_arm2new,'XData',[subs(arm1newX_sym(th_1_adj(t_idx))) subs(arm2newX_sym(th_1_adj(t_idx),th_2_adj(t_idx)))],...
    'YData',[subs(arm1newY_sym(th_1_adj(t_idx))) subs(arm2newY_sym(th_1_adj(t_idx),th_2_adj(t_idx)))])
    set(h_force,'XData',[0 bdf_struct.force(t_idx,2)],'YData',[0 bdf_struct.force(t_idx,3)])
    set(h_forceNew,'XData',[0 forceNew(t_idx,2)],'YData',[0 forceNew(t_idx,3)])
    drawnow
end
    


