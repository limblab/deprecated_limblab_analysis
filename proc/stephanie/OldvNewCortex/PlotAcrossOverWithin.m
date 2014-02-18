% Across over within predictions with just Iso and WM
function PlotAcrossOverWithin

figure
IsobyWMWithin_R2 = subplot(2,2,1);
bar(R2_IbyWoverIbyI_Gyr)
title('Gyrus | R2 | Iso-predicted-by-WM:Iso-within')
IsobyWMWithin_MSE = subplot(2,2,3);
bar(MSe_IbyWoverIbyI_Gyr)
title('Gyrus | MSE | Iso-predicted-by-WM:Iso-within')

WMbyIsoWithin_R2 = subplot(2,2,2);
bar(R2_WbyIoverWbyW_Gyr)
title('Gyrus | R2 | WM-predicted-by-Iso:WM-within')
WMbyIsoWithin_MSE = subplot(2,2,4);
bar(R2_WbyIoverWbyW_Gyr)
title('Gyrus | MSE | WM-predicted-by-Iso:WM-within')


%linkaxes([IsobyWMWithin_R2 WMbyIsoWithin_R2], 'y')
%linkaxes([IsobyWMWithin_MSE WMbyIsoWithin_MSE], 'y')

end