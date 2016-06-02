%% Gyrus (UEA) data comparison

% Isometric within (crossvalidated)
R2_Iso_Gyr_Within = R2;
MSE_Iso_Gyr_Within = mse;
VAF_Iso_Gyr_Within = vaf;
clear R2 mse vaf

% Isometric across
R2_Iso_Gyr_Across = R2;
MSE_Iso_Gyr_Across = mse;
VAF_Iso_Gyr_Across = vaf;
clear R2 mse vaf


R2_Gyr_IsoAoverIsoW = R2_Iso_Gyr_Across./R2_Iso_Gyr_Within;
MSE_Gyr_IsoWoverIsoA = MSE_Iso_Gyr_Within./R2_Iso_Gyr_Across;


% Wrist Movement within
R2_WM_Gyr_Within = R2;
MSE_WM_Gyr_Within = mse;
VAF_WM_Gyr_Within = vaf;
clear R2 mse vaf

% Wrist Movement across
R2_WM_Gyr_Across = R2;
MSE_WM_Gyr_Across = mse;
VAF_WM_Gyr_Across = vaf;
clear R2 mse vaf


R2_Gyr_WMAoverWMW = R2_WM_Gyr_Across./R2_WM_Gyr_Within;
MSE_Gyr_WMWoverWMA = MSE_WM_Gyr_Within./R2_WM_Gyr_Across;


%% Hybrid on Iso. Hybrid on WM.

%Hybrid on Iso
R2_IW_Gyr_onIso = R2;
MSE_IW_Gyr_onIso = mse;
VAF_IW_Gyr_onIso = vaf;
clear R2 mse vaf

%Hybrid on WM
R2_IW_Gyr_onWM = R2;
MSE_IW_Gyr_onWM = mse;
VAF_IW_Gyr_onWM = vaf;
clear R2 mse vaf

R2_Gyr_HyboverIso = R2_IW_Gyr_onIso./R2_Iso_Gyr_Within;
MSE_Gyr_HyboverIso = MSE_IW_Gyr_onIso./MSE_Iso_Gyr_Within;

R2_Gyr_HyboverWM = R2_IW_Gyr_onWM./R2_WM_Gyr_Within;
MSE_Gyr_HyboverWM = MSE_IW_Gyr_onWM./MSE_WM_Gyr_Within;

%%%%%%%%%%

R2_Gyr_HybonIoverWonI = R2_IW_Gyr_onIso./R2_WM_Gyr_Across;
MSE_Gyr_HybonIoverWonI = MSE_IW_Gyr_onIso./MSE_WM_Gyr_Across;

R2_Gyr_HybonWoverIonW = R2_IW_Gyr_onWM./R2_Iso_Gyr_Across;
MSE_Gyr_HybonWoverIonW = MSE_IW_Gyr_onWM./MSE_Iso_Gyr_Across;

%%%%% 

R2_Gyr_WacrossoverHybonIso = R2_WM_Gyr_Across./R2_IW_Gyr_onIso;
MSE_Gyr_WacrossoverHybonIso = MSE_WM_Gyr_Across./MSE_IW_Gyr_onIso;

R2_Gyr_IacrossoverHybonWM = R2_Iso_Gyr_Across./R2_IW_Gyr_onWM;
MSE_Gyr_IacrossoverHybonWM = MSE_Iso_Gyr_Across./MSE_IW_Gyr_onWM;


%% Hybrid on Iso over WM on Iso & Hybrid on WM over Iso on WM

figure
R2GHIA = subplot(2,2,1);
bar(R2_Gyr_HybonIoverWonI)
title('Gyrus | R2 | Hybrid on Iso over WM across')
mseGHIA = subplot(2,2,3);
bar(MSE_Gyr_HybonIoverWonI)
title('Gyrus | MSE | Hybrid on Iso over WM across')

R2GHWA = subplot(2,2,2);
bar(R2_Gyr_HybonWoverIonW)
title('Gyrus | R2 | Hybrid on WM over Iso across')
mseGHWA = subplot(2,2,4);
bar(MSE_Gyr_HybonWoverIonW)
title('Gyrus | MSE | Hybrid on WM over Iso across')

% linkaxes([R2GHIA R2GHWA], 'y')
% linkaxes([mseGHIA mseGHWA], 'y')

%% Hybrid on Iso over WM on Iso & Hybrid on WM over Iso on WM


figure
R2GHIA = subplot(2,2,1);
bar(R2_Gyr_HybonIoverWonI)
title('Gyrus | R2 | Hybrid on Iso over WM across')
mseGHIA = subplot(2,2,3);
bar(MSE_Gyr_HybonIoverWonI)
title('Gyrus | MSE | Hybrid on Iso over WM across')

R2GHWA = subplot(2,2,2);
bar(R2_Gyr_HybonWoverIonW)
title('Gyrus | R2 | Hybrid on WM over Iso across')
mseGHWA = subplot(2,2,4);
bar(MSE_Gyr_HybonWoverIonW)
title('Gyrus | MSE | Hybrid on WM over Iso across')



%% Hybrid on Iso over Iso on Iso and Hybrid on WM over WM on WM

%%%
figure
subplot(2,2,1);
bar(R2_Gyr_HyboverIso)
title('Gyrus | R2 | Hybrid on Iso over Iso within')
HIoII_MSE = subplot(2,2,3);
bar(MSE_Gyr_HyboverIso)
title('Gyrus | MSE | Hybrid on Iso over Iso within')

subplot(2,2,2);
bar(R2_Gyr_HyboverWM)
title('Gyrus | R2 | Hybrid on WM over WM within')
subplot(2,2,4);
bar(MSE_Gyr_HyboverWM)
title('Gyrus | MSE | Hybrid on WM over WM within')



%%
% figure
% R2GHI = subplot(2,2,1);
% bar(R2_Gyr_HyboverIso2half)
% title('Gyrus | R2 | Hybrid over Iso 2nd half')
% mseGHI = subplot(2,2,3);
% bar(MSE_Gyr_Hybover2halfIso)
% title('Gyrus | MSE | Hybrid over Iso 2nd half')
% 
% R2GHW = subplot(2,2,2);
% bar(R2_Gyr_HyboverWM2half)
% title('Gyrus | R2 | Hybrid over WM 2nd half')
% mseGHW = subplot(2,2,4);
% bar(MSE_Gyr_HyboverWM2half)
% title('Gyrus | MSE | Hybrid over WM 2nd half')
% 
% %linkaxes([R2GHI R2GHW], 'y')
% %linkaxes([mseGW mseGI], 'y')


%%








%% Isometric and WM within

figure
R2GI = subplot(2,2,1);
bar(R2_Gyr_IsoAoverIsoW)
title('Gyrus | R2 | Isometric | Across:Within')
mseGI = subplot(2,2,3);
bar(MSE_Gyr_IsoWoverIsoA)
title('Gyrus | MSE | Isometric | Within:Across')

R2GW = subplot(2,2,2);
bar(R2_Gyr_WMAoverWMW)
title('Gyrus | R2 | Wrist Movement | Across:Within')
mseGW = subplot(2,2,4);
bar(MSE_Gyr_WMWoverWMA)
title('Gyrus | MSE | Wrist Movement | Within:Across')

%linkaxes([R2GW R2GI], 'y')
%linkaxes([mseGI mseGW], 'y')
%%
