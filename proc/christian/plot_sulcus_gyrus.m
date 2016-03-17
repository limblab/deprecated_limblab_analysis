cf_sulcus = [];
cf_gyrus  = [];

for i = 1:size(neuronIDs,1)
   
    if neuronIDs(i,1)>96
        cf_sulcus = [cf_sulcus; neuronIDs(i,:) max_cf(i)];
    else
        cf_gyrus  = [cf_gyrus;  neuronIDs(i,:) max_cf(i)];
    end
end

mean_corr = [mean(cf_gyrus(:,3)) mean(cf_sulcus(:,3))];
se_corr   = [std(c_gyrus(:,3))/sqrt(size(c_gyrus,1)) std(c_sulcus(:,3))/sqrt(size(c_sulcus,1))];

barwitherr(2*se_corr,mean_corr);
set(gca,'XTickLabel',{'Gyrus','Sulcus'})
title(sprintf('correlation between firing rate and Force\nJango_IsoCenterOut_UtahFMAsEMGs_101013_001'));