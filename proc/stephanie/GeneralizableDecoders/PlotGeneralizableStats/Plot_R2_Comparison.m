Mean_R2_WbyH_Gyr_It = mean(R2_WbyH_Gyr_Iteration);
Mean_R2_IbyH_Gyr_It = mean(R2_IbyH_Gyr_Iteration);
Mean_R2_IbyI_Gyr_It = mean(R2_IbyI_Gyr_Iteration);
Mean_R2_WbyW_Gyr_It = mean(R2_WbyW_Gyr_Iteration);

Mean_R2_WbyI_Gyr_It = mean(R2_WbyI_Gyr_Iteration);
Mean_R2_IbyW_Gyr_It = mean(R2_IbyW_Gyr_Iteration);

std_R2_WbyH_Gyr_It = std(R2_WbyH_Gyr_Iteration);
std_R2_IbyH_Gyr_It = std(R2_IbyH_Gyr_Iteration);
std_R2_IbyI_Gyr_It = std(R2_IbyI_Gyr_Iteration);
std_R2_WbyW_Gyr_It = std(R2_WbyW_Gyr_Iteration);

std_R2_WbyI_Gyr_It = std(R2_WbyI_Gyr_Iteration);
std_R2_IbyW_Gyr_It = std(R2_IbyW_Gyr_Iteration);

%%%%%%%%%%%%%%%%%%%%%



Mean_WbyW_and_WbyH = [Mean_R2_WbyW_Gyr_It(1,:); Mean_R2_WbyH_Gyr_It(1,:); Mean_R2_WbyI_Gyr_It(1,:)]';
std_WbyW_and_WbyH = [std_R2_WbyW_Gyr_It(1,:); std_R2_WbyH_Gyr_It(1,:); std_R2_WbyI_Gyr_It(1,:)]';

h1 = subplot(2,1,1);
barwitherr(std_WbyW_and_WbyH, Mean_WbyW_and_WbyH)


Mean_IbyI_and_IbyH = [Mean_R2_IbyI_Gyr_It(1,:); Mean_R2_IbyH_Gyr_It(1,:);  Mean_R2_IbyW_Gyr_It(1,:)]';
std_IbyI_and_IbyH = [std_R2_IbyI_Gyr_It(1,:); std_R2_IbyH_Gyr_It(1,:); std_R2_IbyW_Gyr_It(1,:)]';

h2=subplot(2,1,2);
barwitherr(std_IbyI_and_IbyH, Mean_IbyI_and_IbyH)

legend(h1,'Movement Within', 'Hybrid on Movement', 'Iso on Movement')
title(h1,'R-squared for EMG predictions | Movement Task')
 set(h1,'XTickLabel',{'FR' 'FM' 'FU' 'EU' 'EM' 'ER'})

title(h2,'R-squared for EMG predictions | Isometric Task')
legend(h2,'Isometric Within', 'Hybrid on Isometric', 'Movement on Iso')
set(h2,'XTickLabel',{'FR' 'FM' 'FU' 'EU' 'EM' 'ER'})



