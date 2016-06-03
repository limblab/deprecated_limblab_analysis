%% Target Entries

SRTHybEntries = [ChewieLDAentriesRW; MiniLDAentriesRW];
SRTStdEntries = [ChewieLinEntriesRW; MiniLinEntriesRW];
SRTHybHist = hist(SRTHybEntries, 0:max(SRTHybEntries));
SRTStdHist = hist(SRTStdEntries, 0:max(SRTStdEntries));
SRTHybCum = 0;
SRTStdCum = 0;
for x = 1:length(SRTHybHist)-1; SRTHybCum(x) = 1-sum(SRTHybHist(x+1:end))/sum(SRTHybHist); end; SRTHybCum(x+1) = 1;
for x = 1:length(SRTStdHist)-1; SRTStdCum(x) = 1-sum(SRTStdHist(x+1:end))/sum(SRTStdHist); end; SRTStdCum(x+1) = 1;

figure
plot((0:length(SRTHybCum)-1), SRTHybCum, 'k')
hold on
plot((0:length(SRTStdCum)-1), SRTStdCum, 'k--')
 
COshHybEntries = [ChewieLDAentriesVS; MiniLDAentriesVS];
COshStdEntries = [ChewieLinEntriesVS; MiniLinEntriesVS];
COshHybHist = hist(COshHybEntries, 0:max(COshHybEntries));
COshStdHist = hist(COshStdEntries, 0:max(COshStdEntries));
COshHybCum = 0;
COshStdCum = 0;
for x = 1:length(COshHybHist)-1; COshHybCum(x) = 1-sum(COshHybHist(x+1:end))/sum(COshHybHist); end; COshHybCum(x+1) = 1;
for x = 1:length(COshStdHist)-1; COshStdCum(x) = 1-sum(COshStdHist(x+1:end))/sum(COshStdHist); end; COshStdCum(x+1) = 1;

plot((0:length(COshHybCum)-1), COshHybCum, 'b')
plot((0:length(COshStdCum)-1), COshStdCum, 'b--')

COlhHybEntries = HybEntries;
COlhStdEntries = StdEntries;
COlhHybHist = hist(COlhHybEntries, 0:max(COlhHybEntries));
COlhStdHist = hist(COlhStdEntries, 0:max(COlhStdEntries));
COlhHybCum = 0;
COlhStdCum = 0;
for x = 1:length(COlhHybHist)-1; COlhHybCum(x) = 1-sum(COlhHybHist(x+1:end))/sum(COlhHybHist); end; COlhHybCum(x+1) = 1;
for x = 1:length(COlhStdHist)-1; COlhStdCum(x) = 1-sum(COlhStdHist(x+1:end))/sum(COlhStdHist); end; COlhStdCum(x+1) = 1;

plot((0:length(COlhHybCum)-1), COlhHybCum, 'r')
plot((0:length(COlhStdCum)-1), COlhStdCum, 'r--')

legend('SRT Hybrid', 'SRT Standard', 'CO-sh Hybrid', 'CO-sh Standard', 'CO-lh Hybrid', 'CO-lh Standard', 'Location', 'SouthEast')
axis([0 10 0 1])
title('Number of Target Entries per Success')
xlabel('Number of Entries')
ylabel('Cumulative Occurrence Rate')

%% Time to Success

SRTHybTime = [ChewieLDAtimeRW MiniLDAtimeRW];
SRTStdTime = [ChewieLinTimeRW MiniLinTimeRW];
SRTHybHist = hist(SRTHybTime, 0:0.1:max(SRTHybTime));
SRTStdHist = hist(SRTStdTime, 0:0.1:max(SRTStdTime));
SRTHybCum = 0;
SRTStdCum = 0;
for x = 1:length(SRTHybHist)-1; SRTHybCum(x) = 1-sum(SRTHybHist(x+1:end))/sum(SRTHybHist); end; SRTHybCum(x+1) = 1;
for x = 1:length(SRTStdHist)-1; SRTStdCum(x) = 1-sum(SRTStdHist(x+1:end))/sum(SRTStdHist); end; SRTStdCum(x+1) = 1;

figure
plot((0:length(SRTHybCum)-1)*0.1, SRTHybCum, 'k')
hold on
plot((0:length(SRTStdCum)-1)*0.1, SRTStdCum, 'k--')
 
COshHybTime = [ChewieLDAtimeVS MiniLDAtimeVS];
COshStdTime = [ChewieLinTimeVS MiniLinTimeVS];
COshHybHist = hist(COshHybTime, 0:0.1:max(COshHybTime));
COshStdHist = hist(COshStdTime, 0:0.1:max(COshStdTime));
COshHybCum = 0;
COshStdCum = 0;
for x = 1:length(COshHybHist)-1; COshHybCum(x) = 1-sum(COshHybHist(x+1:end))/sum(COshHybHist); end; COshHybCum(x+1) = 1;
for x = 1:length(COshStdHist)-1; COshStdCum(x) = 1-sum(COshStdHist(x+1:end))/sum(COshStdHist); end; COshStdCum(x+1) = 1;

plot((0:length(COshHybCum)-1)*0.1, COshHybCum, 'b')
plot((0:length(COshStdCum)-1)*0.1, COshStdCum, 'b--')

COlhHybTime = HybTime;
COlhStdTime = StdTime;
COlhHybHist = hist(COlhHybTime, 0:0.1:max(COlhHybTime));
COlhStdHist = hist(COlhStdTime, 0:0.1:max(COlhStdTime));
COlhHybCum = 0;
COlhStdCum = 0;
for x = 1:length(COlhHybHist)-1; COlhHybCum(x) = 1-sum(COlhHybHist(x+1:end))/sum(COlhHybHist); end; COlhHybCum(x+1) = 1;
for x = 1:length(COlhStdHist)-1; COlhStdCum(x) = 1-sum(COlhStdHist(x+1:end))/sum(COlhStdHist); end; COlhStdCum(x+1) = 1;

plot((0:length(COlhHybCum)-1)*0.1, COlhHybCum, 'r')
plot((0:length(COlhStdCum)-1)*0.1, COlhStdCum, 'r--')

legend('SRT Hybrid', 'SRT Standard', 'CO-sh Hybrid', 'CO-sh Standard', 'CO-lh Hybrid', 'CO-lh Standard', 'Location', 'SouthEast')
axis([0 10 0 1])
title('Time to Achieve Success')
xlabel('Time (s)')
ylabel('Cumulative Occurrence Rate')

%% Variance

SRTHybVar = [ChewieLDAvarRW MiniLDAvarRW];
SRTStdVar = [ChewieLinVarRW MiniLinVarRW];
SRTHybHist = hist(SRTHybVar, 0:0.1:max(SRTHybVar));
SRTStdHist = hist(SRTStdVar, 0:0.1:max(SRTStdVar));
SRTHybCum = 0;
SRTStdCum = 0;
for x = 1:length(SRTHybHist)-1; SRTHybCum(x) = 1-sum(SRTHybHist(x+1:end))/sum(SRTHybHist); end; SRTHybCum(x+1) = 1;
for x = 1:length(SRTStdHist)-1; SRTStdCum(x) = 1-sum(SRTStdHist(x+1:end))/sum(SRTStdHist); end; SRTStdCum(x+1) = 1;

figure
plot((0:length(SRTHybCum)-1)*0.1, SRTHybCum, 'k')
hold on
plot((0:length(SRTStdCum)-1)*0.1, SRTStdCum, 'k--')
 
legend('SRT Hybrid', 'SRT Standard', 'Location', 'SouthEast')
axis([0 3 0 1])
title('Variance Near Target')
xlabel('Cursor Variance (cm)')
ylabel('Cumulative Occurrence Rate')
