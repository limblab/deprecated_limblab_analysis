inputaccel = importdata('accel.csv');
time = inputaccel.data(:,1) - inputaccel.data(1,1);
accel = inputaccel.data(:,2:4)*9.8;
inputgyro = importdata('gyro.csv');
gyro = inputgyro.data(:,2:4)*(pi/180);


figure(1)
plot(time,accel)
ylabel('Accel (m/s^2)')
xlabel('Time (s)')
title('Intrinsic Acceleration')
print('Intrinsic Acceleration','-djpeg')

figure(2)
plot(time,gyro)
ylabel('Gyro (rad/s)')
xlabel('Time (s)')
title('Intrinsic Acceleration')
print('Intrinsic Gyro','-djpeg')

dlmwrite('CorrectedSensors.csv',[time,accel,gyro])
