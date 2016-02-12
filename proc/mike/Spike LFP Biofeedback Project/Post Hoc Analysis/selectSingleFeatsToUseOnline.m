vaf1featMAT = cell2mat(vaf1feat);
vaf1featX = vaf1featMAT(:,2:2:end);
vaf1featY = vaf1featMAT(:,1:2:end);

vaf1featXSort = [vaf1featX' featind'];
vaf1featXSorted = sortrows(vaf1featXSort,11)';

vaf1featYSort = [vaf1featY' featind'];
vaf1featYSorted = sortrows(vaf1featYSort,11)';

vaf1featXgam2 = vaf1featXSorted(:,5:7:end);
vaf1featYlowgam = vaf1featYSorted(:,7:7:end);

vaf1featXlowgam = vaf1featXSorted(:,7:7:end);
vaf1featYgam2 = vaf1featYSorted(:,5:7:end);

Sum_LowGamY_Gam2X_Mean = mean(vaf1featXgam2(1:10,:)) + mean(vaf1featYlowgam(1:10,:));
Sum_Gam2Y_LowGamX_Mean = mean(vaf1featXlowgam(1:10,:)) + mean(vaf1featYgam2(1:10,:));
figure
plot(Sum_LowGamY_Gam2X_Mean)
figure
plot(Sum_Gam2Y_LowGamX_Mean)