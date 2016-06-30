%% save things
dPD_trained = 180/pi*(ycpd-yupd);

%% save
dPD_rand = 180/pi*(ycpd-yupd);

%% fix
dPD_rand(dPD_rand<-180) = dPD_rand(dPD_rand<-180)+360;
dPD_rand(dPD_rand>180) = dPD_rand(dPD_rand>180)-360;

%% plot histogram stuff
figure
hist(dPD_rand,20);
h = get(gca,'children');
set(h,'facecolor',[0 0 1])
axis([-200 200 0 60])
title 'Change in Preferred Direction: Randomly Weighted Neurons'
xlabel 'Change in Preferred Direction (Degrees)'
ylabel 'Number of Neurons'

figure
hist(dPD_trained)
set(get(gca,'children'),'facecolor',[0 1 0])
axis([-200 200 0 60])
title 'Change in Preferred Direction: Trained Neurons'
xlabel 'Change in Preferred Direction (Degrees)'
ylabel 'Number of Neurons'