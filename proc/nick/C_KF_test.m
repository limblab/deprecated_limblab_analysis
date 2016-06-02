addpath('Kalman');
addpath('KPMstats');
addpath('KPMtools');

load('C:\Users\Nicholas Sachs\Desktop\KF_C_test_data.dat')

A = eye(3);
C = eye(3);
Q = eye(3);
R = eye(3);
A(1,2) = 1;
A(2,3) = 1;
state = [0 0 0]';
V = zeros(3);

y = KF_C_test_data(:,4:6)';

for i = 1:length(y)
    [state, V, loglik, VVnew] = kalman_update(A, C, Q, R, y(:,i), state, V);
    
    pred_state(i,:) = state';
end

figure
plot(KF_C_test_data(:,1),'k')
hold on
plot(KF_C_test_data(:,4),'r')
plot(pred_state(:,1))