%% Calculate KL-MI for gamma 1 (30-100 Hz)
numfolds = 20;
numfiles = 4;
KL_dist = zeros(size(p_i_ThetaGamma,1));

for j = 1:size(p_i_ThetaGamma,1)
    mu(j) = mean(p_i_ThetaGamma(j,:));
    
    for i = 1:size(p_i_ThetaGamma,2)
        KL_dist(j) = KL_dist(j) + p_i_ThetaGamma(j,i) * log(p_i_ThetaGamma(j,i)/mu(j));
    end
    
    KL_dist_norm(j) = KL_dist(j)/log(size(p_i_ThetaGamma,2));
    
end

KL_dist_norm_MAT = reshape(KL_dist_norm,numfolds,numfiles)
FileIndex = repmat([1 2 3 4],10,1);
figure
boxplot(KL_dist_norm_MAT)
xlim([0 5])
xlabel('Files')
ylabel('30-100 Hz Modulation Index')

%% Calculate KL-MI for gamma 2 (80 -150 Hz)

KL_dist2 = zeros(size(p_i_ThetaGamma2,1));

for j = 1:size(p_i_ThetaGamma2,1)
    mu(j) = mean(p_i_ThetaGamma2(j,:));
    
    for i = 1:size(p_i_ThetaGamma2,2)
        KL_dist2(j) = KL_dist2(j) + p_i_ThetaGamma2(j,i) * log(p_i_ThetaGamma2(j,i)/mu(j));
    end
    
    KL_dist_norm2(j) = KL_dist2(j)/log(size(p_i_ThetaGamma2,2));
    
end

%% Calculate KL-MI for gamma 2 (80 -150 Hz) with randomized theta phase 
KL_dist2_rand = zeros(size(p_i_ThetaGamma2_RandPhase,1));

for j = 1:size(p_i_ThetaGamma2_RandPhase,1)
    mu(j) = mean(p_i_ThetaGamma2_RandPhase(j,:));
    
    for i = 1:size(p_i_ThetaGamma2_RandPhase,2)
        KL_dist2_rand(j) = KL_dist2_rand(j) + p_i_ThetaGamma2_RandPhase(j,i) * log(p_i_ThetaGamma2_RandPhase(j,i)/mu(j));
    end
    
    KL_dist_norm2_rand(j) = KL_dist2_rand(j)/log(size(p_i_ThetaGamma2_RandPhase,2));
    
end

%% Calculate KL-MI for gamma (30 - 80 Hz) with randomized theta phase 
KL_dist_rand = zeros(size(p_i_ThetaGamma2_RandPhase,1));

for j = 1:size(p_i_ThetaGamma2_RandPhase,1)
    mu(j) = mean(p_i_ThetaGamma_RandPhase(j,:));
    
    for i = 1:size(p_i_ThetaGamma_RandPhase,2)
        KL_dist_rand(j) = KL_dist_rand(j) + p_i_ThetaGamma_RandPhase(j,i) * log(p_i_ThetaGamma_RandPhase(j,i)/mu(j));
    end
    
    KL_dist_norm_rand(j) = KL_dist_rand(j)/log(size(p_i_ThetaGamma_RandPhase,2));
    
end

%% Plot KL-MI for gamma (80-150 Hz)
KL_dist_norm2_rand_MAT = reshape(KL_dist_norm2_rand,numfolds,numfiles);
KL_dist_norm2_MAT = reshape(KL_dist_norm2,numfolds,numfiles);


[H,P] = ttest(KL_dist_norm2,KL_dist_norm2_rand,.05,'both')

figure; errorbar(mean(KL_dist_norm2_MAT),std(KL_dist_norm2_MAT)/sqrt(numfolds),'o')
hold on; plot([0:5],repmat(mean(KL_dist_norm2_rand),1,6),'--')

xlabel('Days Since Starting 2D-NF Task')

[AX,H1,H2] = plotyy([1:4],mean(KL_dist_norm2_MAT),[1:4],PercentSuccess_File);

set(get(AX(1),'Ylabel'),'String','80-150 Hz Modulation Index') 
set(get(AX(2),'Ylabel'),'String','Percent Success')

xticks = [1 2 3 4];
xlabels = {'Day 1','Day 3','Day 5', 'Day 7'};
set(gca,'XTick',xticks,'XTickLabel',xlabels)


[p,table,stats] = anova1(KL_dist_norm2_MAT)
figure
multcompare(stats)

keyboard
%% Plot KL_MI for gamma (30-80 Hz)
KL_dist_norm_rand_MAT = reshape(KL_dist_norm_rand,numfolds,numfiles);
KL_dist_norm_MAT = reshape(KL_dist_norm,numfolds,numfiles);

[H,P] = ttest(KL_dist_norm,KL_dist_norm_rand,.05,'both')

figure; errorbar(mean(KL_dist_norm_MAT),std(KL_dist_norm_MAT)/sqrt(numfolds),'o')
hold on; plot([0:5],repmat(mean(KL_dist_norm_rand),1,6),'--')

xlabel('Days Since Starting 2D-NF Task')

[AX,H1,H2] = plotyy([1:4],mean(KL_dist_norm_MAT),[1:4],PercentSuccess_File);

set(get(AX(1),'Ylabel'),'String','30-80 Hz Modulation Index') 
set(get(AX(2),'Ylabel'),'String','Percent Success')

xticks = [1 2 3 4];
xlabels = {'Day 1','Day 3','Day 5', 'Day 7'};
set(gca,'XTick',xticks,'XTickLabel',xlabels)

[p,table,stats] = anova1(KL_dist_norm_MAT)
figure
multcompare(stats)

    
    