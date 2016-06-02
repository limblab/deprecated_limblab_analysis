%% initialize (dataset date: 5/30/2014, Kramer)
bdf = get_nev_mat_data('Y:\Kramer_10I1\Kramer\Processed\Experiment_20140530_RW_cuneate_sorted\Kramer');
tt=rw_trial_table(bdf);
channel_num = 60;
unit_num = 1;

%% calculate PD
b = glm_kin(bdf,channel_num,unit_num,0,'posvel');
dir = b(4:5)/norm(b(4:5));

%% plot firing rate and speed
ts = get_unit(bdf,channel_num,unit_num);
ti = 1:0.01:ts(end);
rates = 5*calcFR(ti,ts,0.2,'gaussian');
vel = interp1(bdf.vel(:,1),bdf.vel(:,2:3),ti);
speed = sqrt(vel(:,1).^2+vel(:,2).^2);

target_times = tt(:,12:17);
target_times = target_times(:);

figure
plot(ti-25.4,speed,'-r','linewidth',2)
hold on
plot(ti-25.4,rates,'-b','linewidth',2)
for i=1:length(target_times)
    plot([target_times(i)-25.4 target_times(i)-25.4],[0 80],'--k','linewidth',5)
end
axis([0 4.9 0 80])
legend('Speed of hand movement','Neural Firing Rate')
title 'Modulation of Neuron on Channel 60'
xlabel 'Time (s)'
ylabel 'Hand Speed (cm/s)/Firing Rate*5 (Hz)'


%% plot firing rate against directed velocity
dir_vel = vel*dir;
figure
plot(ti-25.4,dir_vel,'-r',ti-25.4,rates,'-b')
axis([0 4.9 0 80])