%% Gyrus (UEA) data comparison

% Isometric within 
R2_IbyI_Gyr = R2;
MSE_IbyI_Gyr = mse;
VAF_IbyI_Gyr = vaf;
clear R2 mse vaf

% Isometric predicted by wrist movement
R2_IbyW_Gyr = R2;
MSE_IbyW_Gyr = mse;
VAF_IbyW_Gyr= vaf;
clear R2 mse vaf

% Wrist Movement within
R2_WbyW_Gyr = R2;
MSE_WbW_Gyr = mse;
VAF_WbyW_Gyr = vaf;
clear R2 mse vaf

% Wrist movement predicted by isometric
R2_WbyI_Gyr = R2;
MSE_WbyI_Gyr = mse;
VAF_WbyI_Gyr = vaf;
clear R2 mse vaf

%(across divided by within)
R2_IbyWoverIbyI_Gyr = R2_IbyW_Gyr./R2_IbyI_Gyr; %(across divided by within)
MSE_IbyWoverIbyI_Gyr = MSE_IbyW_Gyr/MSE_IbyI_Gyr;

%(across divided by within)
R2_WbyIoverWbyW_Gyr = R2_WbyI_Gyr./R2_WbyW_Gyr;
MSE_WMWoverWMA_Gyr = MSE_WM_Gyr./R2_WbyW_Gyr;


%% Hybrid on Iso. Hybrid on WM.

%Isometric predicted by hybrid
R2_IbyH_Gyr = R2;
MSE_IbyH_Gyr = mse;
VAF_IbyH_Gyr = vaf;
clear R2 mse vaf

%Wrist movement predicted by hybrid
R2_WbyH_Gyr = R2;
MSE_WbyH_Gyr = mse;
VAF_WbyH_Gyr = vaf;
clear R2 mse vaf

% Iso predicted by hybrid over Iso predicted by Iso
R2_IbyHoverIbyI_Gyr = R2_IbyH_Gyr./R2_IbyI_Gyr;
MSE_IbyHoverIbyI_Gyr = MSE_IbyH_Gyr/MSE_IbyI_Gyr;

% WM predicted by hybrid over WM predicted by WM
R2_WbyHoverWbyW_Gyr = R2_WbyH_Gyr./R2_WbyW_Gyr;
MSE_WbyHoverWbyW_Gyr = MSE_WbyH_Gyr/MSE_WbyW_Gyr;

%%

% Iso predicted by WM over Iso predicted by Hyb
R2_IbyWoverIbyH = R2_IbyW_Gyr./R2_IbyH_Gyr;
MSE_IbyWoverIbyH = MSE_IbyW_Gyr./MSE_IbyH_Gyr;

% WM predicted by Iso over WM predicted by Hyb
R2_WbyIoverWbyH = R2_WbyI_Gyr./R2_WbyH_Gyr;
MSE_WbyIoverWbyH = MSE_WbyI_Gyr./R2_WbyH_Gyr;


