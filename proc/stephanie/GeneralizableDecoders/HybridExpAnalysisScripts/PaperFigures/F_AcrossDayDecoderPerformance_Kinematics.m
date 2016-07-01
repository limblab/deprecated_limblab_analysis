%F_AcrossDayDecoderPerformance_Kinematics

[meanAllHonS_kin_vaf steAllHonS_kin_vaf] = FindMeanAndSTE(AllHonS_kin_vaf(:,1));
[meanAllHonW_kin_vaf steAllHonW_kin_vaf] = FindMeanAndSTE(AllHonW_kin_vaf(:,1));
[meanAllSonS_kin_vaf steAllSonS_kin_vaf] = FindMeanAndSTE(AllSonS_kin_vaf(:,1));
[meanAllWonW_kin_vaf steAllWonW_kin_vaf] = FindMeanAndSTE(AllWonW_kin_vaf(:,1));
[meanAllWonS_kin_vaf steAllWonS_kin_vaf] = FindMeanAndSTE(AllWonS_kin_vaf(:,1));
[meanAllSonW_kin_vaf steAllSonW_kin_vaf] = FindMeanAndSTE(AllSonW_kin_vaf(:,1));


figure; hold on;
h1 = errorbar(1,meanAllHonS_kin_vaf, steAllHonS_kin_vaf, steAllHonS_kin_vaf,'.g');
h2 = errorbar(1,meanAllSonS_kin_vaf, steAllSonS_kin_vaf, steAllSonS_kin_vaf,'.b');
h3 = errorbar(1,meanAllWonS_kin_vaf, steAllWonS_kin_vaf, steAllWonS_kin_vaf,'.r');

h4 = errorbar(2,meanAllHonW_kin_vaf, steAllHonW_kin_vaf, steAllHonW_kin_vaf,'.g');
h5 = errorbar(2,meanAllWonW_kin_vaf, steAllWonW_kin_vaf, steAllWonW_kin_vaf,'.b');
h6 = errorbar(2,meanAllSonW_kin_vaf, steAllSonW_kin_vaf, steAllSonW_kin_vaf,'.r');


set([h1 h2 h3 h4 h5 h6],'MarkerSize',20);
set([h1 h2 h3 h4 h5 h6],'LineWidth',1)
xlim=([.5 2.5]);
ax=gca;
ax.XTickLabel = {'','Spring','','','','','Movement',''};
title('Kinematic predictions')




