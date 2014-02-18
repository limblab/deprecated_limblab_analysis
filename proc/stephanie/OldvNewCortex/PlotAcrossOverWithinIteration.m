% Iso predicted by Hyb over Iso by Iso 
%and WM predicted by Hyb over WM by WM

%PlotAcrossOverWithinIteration

figure
IsobyWMWithin_R2_It = subplot(1,2,1);
bar(Mean_R2_IbyWoverIbyI_Gyr_It,'c')
hold all
h1 = errorbar(Mean_R2_IbyWoverIbyI_Gyr_It, std_R2_IbyWoverIbyI_Gyr_It);
set(h1,'linestyle','none')
axis([0 7 0 1.2])
title('May 7, 2013 | Gyrus | R2 | Iteration | Iso-predicted-by-WM:Iso-within')

WMbyIsoWithin_R2_It = subplot(1,2,2);
bar(Mean_R2_WbyIoverWbyW_Gyr_It,'c')
hold all
h2 = errorbar(Mean_R2_WbyIoverWbyW_Gyr_It, std_R2_WbyIoverWbyW_Gyr_It);
set(h2,'linestyle','none')
axis([0 7 0 1.2])
title('Gyrus | R2 | Iteration | WM-predicted-by-Iso:WM-within')


