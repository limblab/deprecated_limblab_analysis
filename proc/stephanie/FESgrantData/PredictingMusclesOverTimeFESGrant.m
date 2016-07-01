% PredictingMusclesOverTimeFESGrant
% Run GeneralizableAnalysisPapaScript_Feb252016 First to get MegaVAFstruct

MarkerSize=20;LineWidth = 2;
figure; hold on;
for a=1:length(MegaVAFstruct)
h1=errorbar(a,MegaVAFstruct(a).IonI_vaf_mean,MegaVAFstruct(a).IonI_vaf_ste,MegaVAFstruct(a).IonI_vaf_ste,'.c');
set(h1,'MarkerSize',MarkerSize);set(h1,'LineWidth',2)
h2=errorbar(a,MegaVAFstruct(a).WonW_vaf_mean,MegaVAFstruct(a).WonW_vaf_ste,MegaVAFstruct(a).WonW_vaf_ste,'.m');
set(h2,'MarkerSize',MarkerSize);set(h2,'LineWidth',2)
if ~isempty(MegaVAFstruct(a).SonS_vaf_mean)
    h3=errorbar(a,MegaVAFstruct(a).SonS_vaf_mean,MegaVAFstruct(a).SonS_vaf_ste,MegaVAFstruct(a).SonS_vaf_ste,'.k');
    set(h3,'MarkerSize',MarkerSize); set(h3,'LineWidth',2)
end
end


% Session labels for Jango
xlim([0 15])
ylim([0 1])
 set(gca,'Xtick',1:14,'XTickLabel',{'July 23', 'July 24', 'July 25', 'Aug 19', 'Aug 20', 'Aug 21',...
     'Sept 23', 'Sept 25', 'Sept 26', 'Oct 10', 'Oct 11', 'Oct 12', 'Nov 6', 'Nov 7'})
 ax=gca;
 ax.XTickLabelRotation=45;
 title('Multivariate VAF of Predictions For 3 Different Tasks')
 legend([h1(1),h2(1),h3(1)],{'Isometric','Movement','Spring'})
legend boxoff
MillerFigure
 
 
 
 