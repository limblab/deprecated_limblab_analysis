% plot SU spikes decoder perf with LFP organization
l = 1;
for j = 1:size(r2_X_SingleUnitsMAT,1)
    ChMatchflag = 0;
    for i = 1:size(bestc_sorted,1)
        
        if bestc_sorted(i) == j
            r2_X_SingleUnitsMATavg_LFP(i,:) = r2_X_SingleUnitsMATavg(j,:);
            r2_Y_SingleUnitsMATavg_LFP(i,:) = r2_Y_SingleUnitsMATavg(j,:);
            ChMatchflag = 1;
        end
        
    end
    
    if ChMatchflag == 0
        r2_X_indirectCh(l,:) = r2_X_SingleUnitsMATavg(j,:);
        r2_Y_indirectCh(l,:) = r2_Y_SingleUnitsMATavg(j,:);
        l = l+1;
    end
end

r2_X_SingleUnitsMATavg_LFPsort = [r2_X_SingleUnitsMATavg_LFP bestf_bychan(:,1) LFPDec1File8perfX];
r2_Y_SingleUnitsMATavg_LFPsort = [r2_Y_SingleUnitsMATavg_LFP bestf_bychan(:,1) LFPDec1File8perfY];


r2_X_SingleUnitsMATavg_LFPsort_by_freq_perf = sortrows(r2_X_SingleUnitsMATavg_LFPsort,[size(r2_X_SingleUnitsMATavg_LFPsort,2)-1 -size(r2_X_SingleUnitsMATavg_LFPsort,2)]);
r2_Y_SingleUnitsMATavg_LFPsort_by_freq_perf = sortrows(r2_Y_SingleUnitsMATavg_LFPsort,[size(r2_Y_SingleUnitsMATavg_LFPsort,2)-1 -size(r2_Y_SingleUnitsMATavg_LFPsort,2)]);

imagesc(sqrt(r2_X_SingleUnitsMATavg_LFPsort_by_freq_perf(:,1:end-2)));figure(gcf);
caxis([0 .3])
%set(gca,'YTick',[1,33,66,71,92,117],'YTickLabel',{'LMP','Delta','Mu','Gamma1','Gamma2','Gamma3'})
title('Spike SU performances (R - X-vel) sorted by LFP Dec1 feature freq and perf.')
xlabel('files')

figure;
imagesc(sqrt(r2_Y_SingleUnitsMATavg_LFPsort_by_freq_perf(:,1:end-2)));figure(gcf);
caxis([0 .3])
%set(gca,'YTick',[1,33,66,71,92,117],'YTickLabel',{'LMP','Delta','Mu','Gamma1','Gamma2','Gamma3'})
title('Spike SU performances (R - Y-vel) sorted by LFP Dec1 feature freq and perf.')
xlabel('files')

figure;
imagesc(sqrt(r2_X_indirectCh));figure(gcf);
caxis([0 .3])
xlabel('files')
title('Indirect spike channel SU decoder perf. (R - X-vel) during LFP BC')


figure;
imagesc(sqrt(r2_Y_indirectCh));figure(gcf);
caxis([0 .3])
xlabel('files')
title('Indirect spike channel SU decoder perf. (R - Y-vel) during LFP BC')
