SSEPsummary

[RPEt,RPEp]=ttest2(histStats_1011_1240(:,1), histStats_1011_baseline(:,1));
[LMEt,LMEp]=ttest2(histStats_1011_1240(:,2), histStats_1011_baseline(:,2));
[LPEt,LPEp]=ttest2(histStats_1011_1240(:,2), histStats_1011_baseline(:,3));
[RMEt,RMEp]=ttest2(histStats_1011_1240(:,2), histStats_1011_baseline(:,4));

[RPt,RPp]=ttest2(histStats_1011_1240(:,1), histStats_1011_1225(:,1));
[LMt,LMp]=ttest2(histStats_1011_1240(:,2), histStats_1011_1225(:,2));
[LPt,LPp]=ttest2(histStats_1011_1240(:,3), histStats_1011_1225(:,3));
[RMt,RMp]=ttest2(histStats_1011_1240(:,4), histStats_1011_1225(:,4));