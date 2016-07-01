%F_AcrossDayDecoderPerformance
% Run this after running the main script

[meanAllDaysIonI steAllDaysIonI] = FindMeanAndSTE(AllDaysIonI);
[meanAllDaysWonW steAllDaysWonW] = FindMeanAndSTE(AllDaysWonW);
[meanAllDaysWonI steAllDaysWonI] = FindMeanAndSTE(AllDaysWonI);
[meanAllDaysIonW steAllDaysIonW] = FindMeanAndSTE(AllDaysIonW);
[meanAllDaysHonI steAllDaysHonI] = FindMeanAndSTE(AllDaysHonI);
[meanAllDaysHonW steAllDaysHonW] = FindMeanAndSTE(AllDaysHonW);

[meanAllDaysHonS steAllDaysHonS] = FindMeanAndSTE(AllDaysHonS);
[meanAllDaysH3onI steAllDaysH3onI] = FindMeanAndSTE(AllDaysH3onI);
[meanAllDaysH3onW steAllDaysH3onW] = FindMeanAndSTE(AllDaysH3onW);
[meanAllDaysH3onS steAllDaysH3onS] = FindMeanAndSTE(AllDaysH3onS);
[meanAllDaysSonS steAllDaysSonS] = FindMeanAndSTE(AllDaysSonS);
[meanAllDaysWonS steAllDaysWonS] = FindMeanAndSTE(AllDaysWonS);
[meanAllDaysIonS steAllDaysIonS] = FindMeanAndSTE(AllDaysIonS);

[meanAllIsoFits steAllIsoFits] = FindMeanAndSTE(AllIsoFits);
[meanAllWmFits steAllWmFits] = FindMeanAndSTE(AllWmFits);
[meanAllSprFits steAllSprFits] = FindMeanAndSTE(AllSprFits);

figure; hold on;
h1 = errorbar(1,meanAllDaysIonI, steAllDaysIonI,steAllDaysIonI,'.b');
%h2 = errorbar(1,meanAllDaysHonI, steAllDaysHonI,steAllDaysHonI,'.g');
h3 = errorbar(1,meanAllDaysH3onI, steAllDaysH3onI,steAllDaysH3onI,'.c');
h4 = errorbar(1,meanAllDaysWonI, steAllDaysWonI,steAllDaysWonI,'.r');
h2 = errorbar(1,meanAllIsoFits, steAllIsoFits,steAllIsoFits, '.k');

h5 = errorbar(2,meanAllDaysWonW, steAllDaysWonW,steAllDaysWonW,'.b');
%h6 = errorbar(2,meanAllDaysHonW, steAllDaysHonW,steAllDaysHonW,'.g');
h7 = errorbar(2,meanAllDaysH3onW, steAllDaysH3onW,steAllDaysH3onW,'.c');
h8 = errorbar(2,meanAllDaysIonW, steAllDaysIonW,steAllDaysIonW,'.r');
h6 = errorbar(2,meanAllWmFits, steAllWmFits,steAllWmFits, '.k');

h9 = errorbar(3,meanAllDaysSonS, steAllDaysSonS,steAllDaysSonS,'.b');
%h10 = errorbar(3,meanAllDaysHonS, steAllDaysHonS,steAllDaysHonS,'.g');
h11 = errorbar(3,meanAllDaysH3onS, steAllDaysH3onS,steAllDaysH3onS,'.c');
h12 = errorbar(3,meanAllDaysIonS, steAllDaysIonS,steAllDaysIonS,'.m');
h13 = errorbar(3,meanAllDaysWonS, steAllDaysWonS,steAllDaysWonS,'.r');
h10 = errorbar(3,meanAllSprFits, steAllSprFits,steAllSprFits, '.k');
ylim([-2 1]); xlim([.5 3.5])
set([h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13],'MarkerSize',20);
set([h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13],'LineWidth',1)

ax=gca;
ax.XTickLabel = {'','Iso','','Movement','','Spring',''};


% Confusion matrix
% confusionmat
map = [1 0 0; .9 0 0 ; .8 0 0; .7 0 0 ; .6 0 0;.5 0 0; 1 1 1; 0 1 0; 0 .9 0; 0 .8 0; 0 .7 0; 0 .6 0; 0 .5 0];
map = [1 0 0; .9 0 0 ; .8 0 0; .7 0 0 ; .6 0 0;.5 0 0; 1 1 1; 0 .8 0; 0 .9 0];
colormap(map)
figure
confusionMatrixValues = [meanAllDaysIonI meanAllDaysIonW meanAllDaysIonS; meanAllDaysWonI meanAllDaysWonW meanAllDaysWonS;...
    meanAllDaysH3onI meanAllDaysH3onW meanAllDaysH3onS];
colormap(map)
imagesc(confusionMatrixValues);




