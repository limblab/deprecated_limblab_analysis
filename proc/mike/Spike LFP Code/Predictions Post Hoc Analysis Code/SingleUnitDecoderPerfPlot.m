[r2_X_SingleUnits_DayAvg_Mini r2_Y_SingleUnits_DayAvg_Mini Mini_DayNames] =...
     DayAverage(r2_X_SingleUnitsMATavg, r2_Y_SingleUnitsMATavg,...
     Mini_LFP_BC_Decoder1_filenames(155:end,2), Mini_LFP_BC_Decoder1_filenames(155:end,3));


r2_X_SingleUnits_Dayavg_sorted = sortrows(r2_X_SingleUnits_DayAvg_Mini,-1);
r2_Y_SingleUnits_Dayavg_sorted = sortrows(r2_Y_SingleUnits_DayAvg_Mini,-1);

figure;
imagesc(sqrt(r2_X_SingleUnits_Dayavg_sorted(15:end,:)));figure(gcf);
caxis([0 .6])
title('Spike SU performances (R - X-vel) during LFP BC sorted by Unit perf. on First Day')
%set(gca,'XTick',[1,30,60],'XTickLabel',{'1','66','204'})
xlabel('Decoder Age (files)')
ylabel('Single Units')

figure;
imagesc(sqrt(r2_Y_SingleUnits_Dayavg_sorted(15:end,:)));figure(gcf);
caxis([0 .6])
%set(gca,'XTick',[1,30,60],'XTickLabel',{'1','66','204'})
title('Spike SU performances (R - Y-vel) during LFP BC sorted by unit perf. on First Day')
xlabel('Decoder Age (days)')
ylabel('Single Units')