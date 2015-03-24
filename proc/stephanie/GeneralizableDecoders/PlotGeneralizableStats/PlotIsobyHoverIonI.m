% Iso predicted by Hyb over Iso by Iso 
%and WM predicted by Hyb over WM by WM

function PlotHybridAcrossOverWithin

figure
IsobyHybWithin_R2 = subplot(2,2,1);
bar(R2_IbyHoverIbyI_Gyr)
title('Gyrus | R2 | Iso-predicted-by-Hyb:Iso-within')
IsobyHybWithin_MSE = subplot(2,2,3);
bar(MSe_IbyHoverIbyI_Gyr)
title('Gyrus | MSE | Iso-predicted-by-Hyb:Iso-within')

WMbyHybWithin_R2 = subplot(2,2,2);
bar(R2_WbyHoverWbyW_Gyr)
title('Gyrus | R2 | WM-predicted-by-Hyb:WM-within')
WMbyHybWithin_MSE = subplot(2,2,4);
bar(R2_WbyHoverWbyW_Gyr)
title('Gyrus | MSE | WM-predicted-by-Hyb:WM-within')

%linkaxes([IsobyHybWithin_R2 WMbyHybWithin_R2], 'y')
%linkaxes([IsobyHybWithin_MSE WMbyHybWithin_MSE], 'y')

 end