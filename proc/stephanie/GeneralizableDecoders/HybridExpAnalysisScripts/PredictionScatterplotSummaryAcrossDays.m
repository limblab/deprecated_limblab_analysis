PredictionScatterplotSummaryAcrossDays

% VAF within versus hybrid
within = [IonIPC_vaf_0525 IonIPC_vaf_0604 IonIPC_vaf_0606 IonIPC_vaf_0520 IonIPC_vaf_0519];
hybrid = [HonIPC_vaf_0525 HonIPC_vaf_0604 HonIPC_vaf_0606 HonIPC_vaf_0520 HonIPC_vaf_0519];
figure;
plot(within,hybrid,'*')
x=[0 1];
y = [0 1];
hold on;
plot(x,y)
xlabel('Within')
ylabel('Hybrid')
title('Isometric predictions')

% VAF within versus hybrid
across = [WonIPC_vaf_0525 WonIPC_vaf_0604 WonIPC_vaf_0606 WonIPC_vaf_0520 WonIPC_vaf_0519];
hybrid = [HonIPC_vaf_0525 HonIPC_vaf_0604 HonIPC_vaf_0606 HonIPC_vaf_0520 HonIPC_vaf_0519];
figure;
plot(across,hybrid,'*')
x=[0 1];
y = [0 1];
hold on;
plot(x,y)
title('Isometric predictions')
xlabel('Across')
ylabel('Hybrid')


%----

within = [WonWPC_vaf_0525 WonWPC_vaf_0604 WonWPC_vaf_0606 WonWPC_vaf_0520 WonWPC_vaf_0519];
hybrid = [HonWPC_vaf_0525 HonWPC_vaf_0604 HonWPC_vaf_0606 HonWPC_vaf_0520 HonWPC_vaf_0519];
figure;
plot(within,hybrid,'*')
x=[0 1];
y = [0 1];
hold on;
plot(x,y)
xlabel('Within')
ylabel('Hybrid')
title('Movement predictions')

% VAF within versus hybrid
across = [WonIPC_vaf_0525 WonIPC_vaf_0604 WonIPC_vaf_0606 WonIPC_vaf_0520 WonIPC_vaf_0519];
hybrid = [HonWPC_vaf_0525 HonWPC_vaf_0604 HonWPC_vaf_0606 HonWPC_vaf_0520 HonWPC_vaf_0519];
figure;
plot(across,hybrid,'*')
x=[0 1];
y = [0 1];
hold on;
plot(x,y)
xlabel('Across')
ylabel('Hybrid')
title('Movement predictions')