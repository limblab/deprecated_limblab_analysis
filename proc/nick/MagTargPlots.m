% load('\\165.124.111.182\limblab\user_folders\Rachel\FINAL Data Sets\Mini\VS\MiniVSMetrics.mat')
% load('\\165.124.111.182\limblab\user_folders\Rachel\FINAL Data Sets\Mini\VS-Long Hold\MiniVSLHmetrics.mat')
% load('\\165.124.111.182\limblab\user_folders\Rachel\FINAL Data Sets\Chewie\ChewieVSMetrics.mat')

ChewieGroupRW;
MiniGroupRW;
ChewieGroupVS;
MiniGroupVS;
MiniGroupVSLH;

%% Path Efficiency

% hyb_srt_patheff = sort([1./CRW2_totpatheff 1./MRW2_totpatheff]);
% std_srt_patheff = sort([1./CRW1_totpatheff 1./MRW1_totpatheff]);
% hyb_cosh_patheff = sort([1./CVS2_totpatheff 1./MVS2_totpatheff]);
% std_cosh_patheff = sort([1./CVS1_totpatheff 1./MVS1_totpatheff]);
% hyb_colh_patheff = sort(1./MVSLH2_totpatheff);
% std_colh_patheff = sort(1./MVSLH1_totpatheff);
% hyb_srt_patheff = 1./sort([CRW2_totpatheff MRW2_totpatheff]);
% std_srt_patheff = 1./sort([CRW1_totpatheff MRW1_totpatheff]);
% hyb_cosh_patheff = 1./sort([CVS2_totpatheff MVS2_totpatheff]);
% std_cosh_patheff = 1./sort([CVS1_totpatheff MVS1_totpatheff]);
% hyb_colh_patheff = 1./sort(MVSLH2_totpatheff);
% std_colh_patheff = 1./sort(MVSLH1_totpatheff);

hyb_srt_patheff = sort([CRW2_totpatheff MRW2_totpatheff]);
std_srt_patheff = sort([CRW1_totpatheff MRW1_totpatheff]);
hyb_cosh_patheff = sort([CVS2_totpatheff MVS2_totpatheff]);
std_cosh_patheff = sort([CVS1_totpatheff MVS1_totpatheff]);
hyb_colh_patheff = sort(MVSLH2_totpatheff);
std_colh_patheff = sort(MVSLH1_totpatheff);

figure;
set(gca,'TickDir','out')
% hold on; plot([-1 -hyb_srt_patheff],0:1/length(hyb_srt_patheff):1,'k',[-1 -std_srt_patheff],0:1/length(std_srt_patheff):1,'k--')
% hold on; plot([-1 -hyb_cosh_patheff],0:1/length(hyb_cosh_patheff):1,'c',[-1 -std_cosh_patheff],0:1/length(std_cosh_patheff):1,'c--')
% hold on; plot([-1 -hyb_colh_patheff],0:1/length(hyb_colh_patheff):1,'r',[-1 -std_colh_patheff],0:1/length(std_colh_patheff):1,'r--')
hold on; plot([0 hyb_srt_patheff],0:1/length(hyb_srt_patheff):1,'k',[0 std_srt_patheff],0:1/length(std_srt_patheff):1,'k--')
hold on; plot([0 hyb_cosh_patheff],0:1/length(hyb_cosh_patheff):1,'c',[0 std_cosh_patheff],0:1/length(std_cosh_patheff):1,'c--')
hold on; plot([0 hyb_colh_patheff],0:1/length(hyb_colh_patheff):1,'r',[0 std_colh_patheff],0:1/length(std_colh_patheff):1,'r--')
% title('Path Efficiency')
title('Relative Path Length')
ylabel('Cumulative Occurrence Rate')
% xlabel('Ideal Path Length / Actual Path Length')
xlabel('Actual Path Length / Ideal Path Length')
axis([0 10 0 1])
% axis([0 1 0 1])
legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')

figure;
set(gca,'TickDir','out')
hold on; bar([mean(hyb_srt_patheff) mean(std_srt_patheff) 0 0 0 0 0 0],1,'w')
hold on; bar([0 0 0 mean(hyb_cosh_patheff) mean(std_cosh_patheff) 0 0 0],1,'c')
hold on; bar([0 0 0 0 0 0 mean(hyb_colh_patheff) mean(std_colh_patheff)],1,'r')
errorbar([1 2 4 5 7 8],[mean(hyb_srt_patheff) mean(std_srt_patheff) mean(hyb_cosh_patheff) mean(std_cosh_patheff) mean(hyb_colh_patheff) mean(std_colh_patheff)],[std(hyb_srt_patheff)/sqrt(length(hyb_srt_patheff)) std(std_srt_patheff)/sqrt(length(hyb_srt_patheff)) std(hyb_cosh_patheff)/sqrt(length(hyb_cosh_patheff)) std(std_cosh_patheff)/sqrt(length(hyb_cosh_patheff)) std(hyb_colh_patheff)/sqrt(length(hyb_colh_patheff)) std(std_colh_patheff)/sqrt(length(std_colh_patheff))],'.k')
% errorbar(1:6,[mean(hyb_srt_patheff) mean(std_srt_patheff) mean(hyb_cosh_patheff) mean(std_cosh_patheff) mean(hyb_colh_patheff) mean(std_colh_patheff)],[std(hyb_srt_patheff) std(std_srt_patheff) std(hyb_cosh_patheff) std(std_cosh_patheff) std(std_colh_patheff) std(std_colh_patheff)],'.k')
axis([0 9 0 1])
% title('Path Efficiency')
title('Relative Path Length')
% ylabel('Ideal Path Length / Actual Path Length')
ylabel('Actual Path Length / Ideal Path Length')
xlabel('Task')
legend('SRT','COsh','COlh')
% legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')

%% Time to Target

% hyb_srt_time2targ = sort([CRW2_time2targ MRW2_time2targ]);
% std_srt_time2targ = sort([CRW1_time2targ MRW1_time2targ]);
% hyb_cosh_time2targ = sort([CVS2_time2targ MVS2_time2targ]);
% std_cosh_time2targ = sort([CVS1_time2targ MVS1_time2targ]);
% hyb_colh_time2targ = sort(MVSLH2_time2targ);
% std_colh_time2targ = sort(MVSLH1_time2targ);
hyb_srt_time2targ = sort([CRW2_time2reward MRW2_time2reward])-1;
std_srt_time2targ = sort([CRW1_time2reward MRW1_time2reward])-1;
hyb_cosh_time2targ = sort([CVS2_time2reward MVS2_time2reward])-0.2;
std_cosh_time2targ = sort([CVS1_time2reward MVS1_time2reward])-0.2;
hyb_colh_time2targ = sort(MVSLH2_time2reward)-1;
std_colh_time2targ = sort(MVSLH1_time2reward)-1;

figure;
set(gca,'TickDir','out')
hold on; plot([0 hyb_srt_time2targ],0:1/length(hyb_srt_time2targ):1,'k',[0 std_srt_time2targ],0:1/length(std_srt_time2targ):1,'k--')
hold on; plot([0 hyb_cosh_time2targ],0:1/length(hyb_cosh_time2targ):1,'c',[0 std_cosh_time2targ],0:1/length(std_cosh_time2targ):1,'c--')
hold on; plot([0 hyb_colh_time2targ],0:1/length(hyb_colh_time2targ):1,'r',[0 std_colh_time2targ],0:1/length(std_colh_time2targ):1,'r--')
title('Time to Target')
ylabel('Cumulative Occurrence Rate')
xlabel('Time to Target (s)')
axis([0 10 0 1])
legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')

%% Variance

hyb_srt_var = sort([CRW2_var MRW2_var]);
std_srt_var = sort([CRW1_var MRW1_var]);
hyb_cosh_var = sort([CVS2_var MVS2_var]);
std_cosh_var = sort([CVS1_var MVS1_var]);
hyb_colh_var = sort(MVSLH2_var);
std_colh_var = sort(MVSLH1_var);

figure;
set(gca,'TickDir','out')
hold on; plot([0 hyb_srt_var],0:1/length(hyb_srt_var):1,'k',[0 std_srt_var],0:1/length(std_srt_var):1,'k--')
hold on; plot([0 hyb_cosh_var],0:1/length(hyb_cosh_var):1,'c',[0 std_cosh_var],0:1/length(std_cosh_var):1,'c--')
hold on; plot([0 hyb_colh_var],0:1/length(hyb_colh_var):1,'r',[0 std_colh_var],0:1/length(std_colh_var):1,'r--')
title('Cursor Variance During Target Acquisition')
ylabel('Cumulative Occurrence Rate')
xlabel('Variance (cm)')
axis([0 3 0 1])
legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')

%% Target Entries

hyb_srt_num_entries = sort([CRW2_num_entries MRW2_num_entries]);
std_srt_num_entries = sort([CRW1_num_entries MRW1_num_entries]);
hyb_cosh_num_entries = sort([CVS2_num_entries MVS2_num_entries]);
std_cosh_num_entries = sort([CVS1_num_entries MVS1_num_entries]);
hyb_colh_num_entries = sort(MVSLH2_num_entries);
std_colh_num_entries = sort(MVSLH1_num_entries);
[hyb_srt_num_entries_uni, hyb_srt_num_entries_idx] = unique(hyb_srt_num_entries,'first');
[std_srt_num_entries_uni, std_srt_num_entries_idx] = unique(std_srt_num_entries,'first');
[hyb_cosh_num_entries_uni, hyb_cosh_num_entries_idx] = unique(hyb_cosh_num_entries,'first');
[std_cosh_num_entries_uni, std_cosh_num_entries_idx] = unique(std_cosh_num_entries,'first');
[hyb_colh_num_entries_uni, hyb_colh_num_entries_idx] = unique(hyb_colh_num_entries,'first');
[std_colh_num_entries_uni, std_colh_num_entries_idx] = unique(std_colh_num_entries,'first');

figure;
set(gca,'TickDir','out')
hold on; plot([0 hyb_srt_num_entries_uni],[(hyb_srt_num_entries_idx-1)/length(hyb_srt_num_entries) 1],'k',[0 std_srt_num_entries_uni],[(std_srt_num_entries_idx-1)/length(std_srt_num_entries) 1],'k--')
hold on; plot([0 hyb_cosh_num_entries_uni],[(hyb_cosh_num_entries_idx-1)/length(hyb_cosh_num_entries) 1],'c',[0 std_cosh_num_entries_uni],[(std_cosh_num_entries_idx-1)/length(std_cosh_num_entries) 1],'c--')
hold on; plot([0 hyb_colh_num_entries_uni],[(hyb_colh_num_entries_idx-1)/length(hyb_colh_num_entries) 1],'r',[0 std_colh_num_entries_uni],[(std_colh_num_entries_idx-1)/length(std_colh_num_entries) 1],'r--')
title('Target Entries per Trial')
ylabel('Cumulative Occurrence Rate')
xlabel('Number of Target Entries')
axis([0 10 0 1])
legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')

%% Dial-in Time

hyb_srt_dial_in = sort([CRW2_dial_in MRW2_dial_in]);
std_srt_dial_in = sort([CRW1_dial_in MRW1_dial_in]);
hyb_cosh_dial_in = sort([CVS2_dial_in MVS2_dial_in]);
std_cosh_dial_in = sort([CVS1_dial_in MVS1_dial_in]);
hyb_colh_dial_in = sort(MVSLH2_dial_in);
std_colh_dial_in = sort(MVSLH1_dial_in);

figure;
set(gca,'TickDir','out','FontSize',16)
% hold on; bar([mean(hyb_srt_dial_in) mean(std_srt_dial_in) 0 0 0 0 0 0],1,'w')
% hold on; bar([0 0 0 mean(hyb_cosh_dial_in) mean(std_cosh_dial_in) 0 0 0],1,'c')
% hold on; bar([0 0 0 0 0 0 mean(hyb_colh_dial_in) mean(std_colh_dial_in)],1,'r')
% errorbar([1 2 4 5 7 8],[mean(hyb_srt_dial_in) mean(std_srt_dial_in) mean(hyb_cosh_dial_in) mean(std_cosh_dial_in) mean(hyb_colh_dial_in) mean(std_colh_dial_in)],[std(hyb_srt_dial_in)/sqrt(length(hyb_srt_dial_in)) std(std_srt_dial_in)/sqrt(length(hyb_srt_dial_in)) std(hyb_cosh_dial_in)/sqrt(length(hyb_cosh_dial_in)) std(std_cosh_dial_in)/sqrt(length(hyb_cosh_dial_in)) std(hyb_colh_dial_in)/sqrt(length(hyb_colh_dial_in)) std(std_colh_dial_in)/sqrt(length(std_colh_dial_in))],'.k')
% errorbar(1:6,[mean(hyb_srt_dial_in) mean(std_srt_dial_in) mean(hyb_cosh_dial_in) mean(std_cosh_dial_in) mean(hyb_colh_dial_in) mean(std_colh_dial_in)],[std(hyb_srt_dial_in) std(std_srt_dial_in) std(hyb_cosh_dial_in) std(std_cosh_dial_in) std(std_colh_dial_in) std(std_colh_dial_in)],'.k')
% axis([0 9 0 5])
hold on; plot([0 hyb_srt_dial_in(hyb_srt_dial_in ~= 0)],sum(hyb_srt_dial_in == 0)/length(hyb_srt_dial_in):1/length(hyb_srt_dial_in):1,'k',[0 std_srt_dial_in(std_srt_dial_in ~= 0)],sum(std_srt_dial_in == 0)/length(std_srt_dial_in):1/length(std_srt_dial_in):1,'k--')
hold on; plot([0 hyb_cosh_dial_in(hyb_cosh_dial_in ~= 0)],sum(hyb_cosh_dial_in == 0)/length(hyb_cosh_dial_in):1/length(hyb_cosh_dial_in):1,'c',[0 std_cosh_dial_in(std_cosh_dial_in ~= 0)],sum(std_cosh_dial_in == 0)/length(std_cosh_dial_in):1/length(std_cosh_dial_in):1,'c--')
hold on; plot([0 hyb_colh_dial_in(hyb_colh_dial_in ~= 0)],sum(hyb_colh_dial_in == 0)/length(hyb_colh_dial_in):1/length(hyb_colh_dial_in):1,'r',[0 std_colh_dial_in(std_colh_dial_in ~= 0)],sum(std_colh_dial_in == 0)/length(std_colh_dial_in):1/length(std_colh_dial_in):1,'r--')
title('Dial-in Time','FontSize',16)
ylabel('Cumulative Occurrence Rate','FontSize',16)
xlabel('Seconds (s)','FontSize',16)
axis([0 10 0 1])
legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')
% ylabel('Seconds (s)')
% xlabel('Task')
% legend('SRT','COsh','COlh')
% legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')

%% Time to First Touch

hyb_srt_time2targ = sort([CRW2_time2targ MRW2_time2targ]);
std_srt_time2targ = sort([CRW1_time2targ MRW1_time2targ]);
hyb_cosh_time2targ = sort([CVS2_time2targ MVS2_time2targ]);
std_cosh_time2targ = sort([CVS1_time2targ MVS1_time2targ]);
hyb_colh_time2targ = sort(MVSLH2_time2targ);
std_colh_time2targ = sort(MVSLH1_time2targ);
% hyb_srt_time2targ = sort([CRW2_time2reward MRW2_time2reward])-1;
% std_srt_time2targ = sort([CRW1_time2reward MRW1_time2reward])-1;
% hyb_cosh_time2targ = sort([CVS2_time2reward MVS2_time2reward])-0.2;
% std_cosh_time2targ = sort([CVS1_time2reward MVS1_time2reward])-0.2;
% hyb_colh_time2targ = sort(MVSLH2_time2reward)-1;
% std_colh_time2targ = sort(MVSLH1_time2reward)-1;

figure;
set(gca,'TickDir','out')
hold on; plot([0 hyb_srt_time2targ],0:1/length(hyb_srt_time2targ):1,'k',[0 std_srt_time2targ],0:1/length(std_srt_time2targ):1,'k--')
hold on; plot([0 hyb_cosh_time2targ],0:1/length(hyb_cosh_time2targ):1,'c',[0 std_cosh_time2targ],0:1/length(std_cosh_time2targ):1,'c--')
hold on; plot([0 hyb_colh_time2targ],0:1/length(hyb_colh_time2targ):1,'r',[0 std_colh_time2targ],0:1/length(std_colh_time2targ):1,'r--')
title('Time to First Touch')
ylabel('Cumulative Occurrence Rate')
xlabel('Time to Touch (s)')
axis([0 10 0 1])
legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')

%% Initial Path Efficiency

% hyb_srt_patheff = sort([1./CRW2_totpatheff 1./MRW2_totpatheff]);
% std_srt_patheff = sort([1./CRW1_totpatheff 1./MRW1_totpatheff]);
% hyb_cosh_patheff = sort([1./CVS2_totpatheff 1./MVS2_totpatheff]);
% std_cosh_patheff = sort([1./CVS1_totpatheff 1./MVS1_totpatheff]);
% hyb_colh_patheff = sort(1./MVSLH2_totpatheff);
% std_colh_patheff = sort(1./MVSLH1_totpatheff);
% hyb_srt_patheff = 1./sort([CRW2_totpatheff MRW2_totpatheff]);
% std_srt_patheff = 1./sort([CRW1_totpatheff MRW1_totpatheff]);
% hyb_cosh_patheff = 1./sort([CVS2_totpatheff MVS2_totpatheff]);
% std_cosh_patheff = 1./sort([CVS1_totpatheff MVS1_totpatheff]);
% hyb_colh_patheff = 1./sort(MVSLH2_totpatheff);
% std_colh_patheff = 1./sort(MVSLH1_totpatheff);

hyb_srt_patheff = sort([CRW2_movepatheff MRW2_movepatheff]);
std_srt_patheff = sort([CRW1_movepatheff MRW1_movepatheff]);
hyb_cosh_patheff = sort([CVS2_movepatheff MVS2_movepatheff]);
std_cosh_patheff = sort([CVS1_movepatheff MVS1_movepatheff]);
hyb_colh_patheff = sort(MVSLH2_movepatheff);
std_colh_patheff = sort(MVSLH1_movepatheff);

figure;
set(gca,'TickDir','out')
% hold on; plot([-1 -hyb_srt_patheff],0:1/length(hyb_srt_patheff):1,'k',[-1 -std_srt_patheff],0:1/length(std_srt_patheff):1,'k--')
% hold on; plot([-1 -hyb_cosh_patheff],0:1/length(hyb_cosh_patheff):1,'c',[-1 -std_cosh_patheff],0:1/length(std_cosh_patheff):1,'c--')
% hold on; plot([-1 -hyb_colh_patheff],0:1/length(hyb_colh_patheff):1,'r',[-1 -std_colh_patheff],0:1/length(std_colh_patheff):1,'r--')
hold on; plot([0 hyb_srt_patheff],0:1/length(hyb_srt_patheff):1,'k',[0 std_srt_patheff],0:1/length(std_srt_patheff):1,'k--')
hold on; plot([0 hyb_cosh_patheff],0:1/length(hyb_cosh_patheff):1,'c',[0 std_cosh_patheff],0:1/length(std_cosh_patheff):1,'c--')
hold on; plot([0 hyb_colh_patheff],0:1/length(hyb_colh_patheff):1,'r',[0 std_colh_patheff],0:1/length(std_colh_patheff):1,'r--')
% title('Path Efficiency')
title('Relative Path Length')
ylabel('Cumulative Occurrence Rate')
% xlabel('Ideal Path Length / Actual Path Length')
xlabel('Actual Path Length / Ideal Path Length')
axis([0 10 0 1])
% axis([0 1 0 1])
legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')

figure;
set(gca,'TickDir','out')
hold on; bar([mean(hyb_srt_patheff) mean(std_srt_patheff) 0 0 0 0 0 0],1,'w')
hold on; bar([0 0 0 mean(hyb_cosh_patheff) mean(std_cosh_patheff) 0 0 0],1,'c')
hold on; bar([0 0 0 0 0 0 mean(hyb_colh_patheff) mean(std_colh_patheff)],1,'r')
errorbar([1 2 4 5 7 8],[mean(hyb_srt_patheff) mean(std_srt_patheff) mean(hyb_cosh_patheff) mean(std_cosh_patheff) mean(hyb_colh_patheff) mean(std_colh_patheff)],[std(hyb_srt_patheff)/sqrt(length(hyb_srt_patheff)) std(std_srt_patheff)/sqrt(length(hyb_srt_patheff)) std(hyb_cosh_patheff)/sqrt(length(hyb_cosh_patheff)) std(std_cosh_patheff)/sqrt(length(hyb_cosh_patheff)) std(hyb_colh_patheff)/sqrt(length(hyb_colh_patheff)) std(std_colh_patheff)/sqrt(length(std_colh_patheff))],'.k')
% errorbar(1:6,[mean(hyb_srt_patheff) mean(std_srt_patheff) mean(hyb_cosh_patheff) mean(std_cosh_patheff) mean(hyb_colh_patheff) mean(std_colh_patheff)],[std(hyb_srt_patheff) std(std_srt_patheff) std(hyb_cosh_patheff) std(std_cosh_patheff) std(std_colh_patheff) std(std_colh_patheff)],'.k')
axis([0 9 0 ceil(max([mean(hyb_srt_patheff) mean(std_srt_patheff) mean(hyb_cosh_patheff) mean(std_cosh_patheff) mean(hyb_colh_patheff) mean(std_colh_patheff)]))])
% title('Path Efficiency')
title('Relative Initial Path Length')
% ylabel('Ideal Path Length / Actual Path Length')
ylabel('Actual Path Length / Ideal Path Length')
xlabel('Task')
legend('SRT','COsh','COlh')
% legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')
