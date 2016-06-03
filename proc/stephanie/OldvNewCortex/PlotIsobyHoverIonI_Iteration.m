% Iso predicted by Hyb over Iso by Iso 
%and WM predicted by Hyb over WM by WM

%PlotHybridAcrossOverWithin

figure
IsobyHybWithin_R2_It = subplot(1,2,1);
bar(Mean_R2_IbyHoverIbyI_Gyr_It,'c')
hold all
h1 = errorbar(Mean_R2_IbyHoverIbyI_Gyr_It, std_R2_IbyHoverIbyI_Gyr_It);
set(h1,'linestyle','none')
axis([0 7 0 1.2])
title('May 7, 2013 | Gyrus | R2 | Iteration | Iso-predicted-by-Hyb:Iso-within')

WMbyHybWithin_R2_It = subplot(1,2,2);
bar(Mean_R2_WbyHoverWbyW_Gyr_It,'c')
hold all
h2 = errorbar(Mean_R2_WbyHoverWbyW_Gyr_It, std_R2_WbyHoverWbyW_Gyr_It);
set(h2,'linestyle','none')
axis([0 7 0 1.2])
title('Gyrus | R2 | Iteration | WM-predicted-by-Hyb:WM-within')



%linkaxes([IsobyHybWithin_R2_It WMbyHybWithin_R2_It], 'y')

  