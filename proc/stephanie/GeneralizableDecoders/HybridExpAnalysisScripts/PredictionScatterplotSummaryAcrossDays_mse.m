%PredictionScatterplotSummaryAcrossDays_mse

% mse within versus hybrid
%within = [IonIPC_mse_0525 IonIPC_mse_0604 IonIPC_mse_0606 IonIPC_mse_0520 IonIPC_mse_0519];
%hybrid = [HonIPC_mse_0525 HonIPC_mse_0604 HonIPC_mse_0606 HonIPC_mse_0520 HonIPC_mse_0519];

within = [IonIPC_mse_0515 IonIPC_mse_0819 IonIPC_mse_0820 IonIPC_mse_0925 IonIPC_mse_1011];
hybrid = [HonIPC_mse_0515 HonIPC_mse_0819 HonIPC_mse_0820 HonIPC_mse_0925 HonIPC_mse_1011];
figure;
plot(within,hybrid,'*')
x=[0 300];
y = [0 300];
hold on;
plot(x,y)
xlabel('Within')
ylabel('Hybrid')
title('Isometric predictions | mse')

% mse within versus hybrid
% across
% hybrid

across = [WonIPC_mse_0515 WonIPC_mse_0819 WonIPC_mse_0820 WonIPC_mse_0925 WonIPC_mse_1011];
hybrid = [HonIPC_mse_0515 HonIPC_mse_0819 HonIPC_mse_0820 HonIPC_mse_0925 HonIPC_mse_1011];
figure;
plot(across,hybrid,'*')
x=[0 300];
y = [0 300];
hold on;
plot(x,y)
title('Isometric predictions | mse')
xlabel('Across')
ylabel('Hybrid')


%----

%within = [WonWPC_mse_0525 WonWPC_mse_0604 WonWPC_mse_0606 WonWPC_mse_0520 WonWPC_mse_0519];
%hybrid = [HonWPC_mse_0525 HonWPC_mse_0604 HonWPC_mse_0606 HonWPC_mse_0520 HonWPC_mse_0519];

within = [WonWPC_mse_0515 WonWPC_mse_0819 WonWPC_mse_0820 WonWPC_mse_0925 WonWPC_mse_1011];
hybrid = [HonWPC_mse_0515 HonWPC_mse_0819 HonWPC_mse_0820 HonWPC_mse_0925 HonWPC_mse_1011];

figure;
plot(within,hybrid,'*')
x=[0 300];
y = [0 300];
hold on;
plot(x,y)
xlabel('Within')
ylabel('Hybrid')
title('Movement predictions | mse')

% mse within versus hybrid
% across = [WonIPC_mse_0525 WonIPC_mse_0604 WonIPC_mse_0606 WonIPC_mse_0520 WonIPC_mse_0519];
% hybrid = [HonWPC_mse_0525 HonWPC_mse_0604 HonWPC_mse_0606 HonWPC_mse_0520 HonWPC_mse_0519];

across = [WonIPC_mse_0515 WonIPC_mse_0819 WonIPC_mse_0820 WonIPC_mse_0925 WonIPC_mse_1011];
hybrid = [HonWPC_mse_0515 HonWPC_mse_0819 HonWPC_mse_0820 HonWPC_mse_0925 HonWPC_mse_1011];

figure;
plot(across,hybrid,'*')
x=[0 300];
y = [0 300];
hold on;
plot(x,y)
xlabel('Across')
ylabel('Hybrid')
title('Movement predictions | mse')