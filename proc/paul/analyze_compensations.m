traj.pos_x_mid(find(isnan(traj.pos_x_mid)))=0;
traj.pos_y_mid(find(isnan(traj.pos_y_mid)))=0;

sm_cloud_trials = find(traj.feedback==0.5);
bg_cloud_trials = find(traj.feedback==3.5);

figure;
plot(smooth(traj.pos_x_mid-traj.pos_x_go,25),'b.');
xlabel('Trial #');
ylabel('Displacement from Start (cm)')
title('Displacement at Midpoint');

figure;
plot(smooth(traj.pos_x_comp+traj.shifts,25),'b.');
xlabel('Trial #');
ylabel('Endpoint Error (cm)')
title('Error vs Time');



figure; hold on;
plot(traj.shifts(sm_cloud_trials),traj.pos_x_comp(sm_cloud_trials)+traj.shifts(sm_cloud_trials),'r.');
plot(traj.shifts(bg_cloud_trials),traj.pos_x_comp(bg_cloud_trials)+traj.shifts(bg_cloud_trials),'b.');
b = polyfit(traj.shifts(sm_cloud_trials),traj.pos_x_comp(sm_cloud_trials)+traj.shifts(sm_cloud_trials),1);
fitrange = [-10:10];
plot(fitrange,polyval(b,fitrange),['r-']);
lgnd{1}=['0.5 slope: ' num2str(b(1))];
b = polyfit(traj.shifts(bg_cloud_trials),traj.pos_x_comp(bg_cloud_trials)+traj.shifts(bg_cloud_trials),1);
fitrange = [-10:10];
plot(fitrange,polyval(b,fitrange),['b-']);
lgnd{2}=[ '2.5 slope: ' num2str(b(1))];
xlabel('Cursor Shift (cm)');
ylabel('Endpoint Error (cm)');
legend(lgnd);

figure; hold on;
plot(traj.pos_x_mid(sm_cloud_trials)+traj.shifts(sm_cloud_trials),traj.pos_x_comp(sm_cloud_trials)+traj.shifts(sm_cloud_trials),'r.');
plot(traj.pos_x_mid(bg_cloud_trials)+traj.shifts(bg_cloud_trials),traj.pos_x_comp(bg_cloud_trials)+traj.shifts(bg_cloud_trials),'b.');

b = polyfit(traj.pos_x_mid(sm_cloud_trials)+traj.shifts(sm_cloud_trials),traj.pos_x_comp(sm_cloud_trials)+traj.shifts(sm_cloud_trials),1);
fitrange = [-10:10];
lgnd{1}=['0.5 slope: ' num2str(b(1))];
plot(fitrange,polyval(b,fitrange),['r-']);
b = polyfit(traj.pos_x_mid(bg_cloud_trials)+traj.shifts(bg_cloud_trials),traj.pos_x_comp(bg_cloud_trials)+traj.shifts(bg_cloud_trials),1);
fitrange = [-10:10];
lgnd{2}=[ '2.5 slope: ' num2str(b(1))];

plot(fitrange,polyval(b,fitrange),['b-']);

xlabel('MidMovement Lateral Error (cm)');
ylabel('Endpoint Error (cm)');
legend(lgnd);



figure; hold on;
plot(traj.pos_x_mid(sm_cloud_trials)+traj.shifts(sm_cloud_trials),traj.pos_x_comp(sm_cloud_trials)-traj.pos_x_mid(sm_cloud_trials),'r.');
plot(traj.pos_x_mid(bg_cloud_trials)+traj.shifts(bg_cloud_trials),traj.pos_x_comp(bg_cloud_trials)-traj.pos_x_mid(bg_cloud_trials),'b.');

b = polyfit(traj.pos_x_mid(sm_cloud_trials)+traj.shifts(sm_cloud_trials),traj.pos_x_comp(sm_cloud_trials)-traj.pos_x_mid(sm_cloud_trials),1);
fitrange = [-10:10];
lgnd{1}=['0.5 slope: ' num2str(b(1))];

plot(fitrange,polyval(b,fitrange),['r-']);
b = polyfit(traj.pos_x_mid(bg_cloud_trials)+traj.shifts(bg_cloud_trials),traj.pos_x_comp(bg_cloud_trials)-traj.pos_x_mid(bg_cloud_trials),1);
fitrange = [-10:10];
lgnd{2}=[ '2.5 slope: ' num2str(b(1))];

plot(fitrange,polyval(b,fitrange),['b-']);

xlabel('MidMovement Lateral Error (cm)');
ylabel('Lateral Compensation (cm)');
legend(lgnd);




