function Hybrid_Kevin_EMGlist=Kevin_HybridData_EMGQualityInfo()
% Kevin_HybridData

% % evaluating muscle quality out of a full set of FCU FCR ECU ECR FDS FDP
% Hybrid_Kevin_05152015 = [FCR ECU ECR EDC FDS];  % not FCU or FDS. Got this from WM
% Hybrid_Kevin_05192015 = [FCR ECU ECR EDC FDS];
% Hybrid_Kevin_05202015 = [FCR ECU ECR EDC FDP];  % FDP looks good! FDS doesn't. FCU is crap
% Hybrid_Kevin_05212015 = [FCR ECU ECR EDC FDS FDP]; % FCU is shot
% Hybrid_Kevin_05252015 = [FCR ECU ECR EDC FDS FDP]; % FCU is shot. FDS looks good in one WM file but not another
% Hybrid_Kevin_05262015 = [FCR ECU ECR EDC FDP];  % no fcu, no fds
% Hybrid_Kevin_06032015 = [FCR ECU ECR EDC FDS FDP]; % fcu is shot. some of the other signals have sinusoidal noise in addition to signal
% Hybrid_Kevin_06042015 = [FCR ECU ECR EDC FDS FDP];  % same as 0603
% Hybrid_Kevin_06062015 = [FCU FCR ECU ECR EDC FDS FDP]; %the gang's all here!
% Hybrid_Kevin_06082015 = [FCU FCR ECU ECR EDC FDS FDP]; % FCU is questionable. keeping it, but maybe it's bad.

%%
% JUST THE WRIST MUSCLES
% evaluating muscle quality out of a full set of FCU FCR ECU ECR
Hybrid_Kevin_EMGlist{1,1} = '051515'; Hybrid_Kevin_EMGlist{1,2}=['FCR'; 'ECU'; 'ECR'];  % not FCU or FDS. Got this from WM
Hybrid_Kevin_EMGlist{2,1} = '051915'; Hybrid_Kevin_EMGlist{2,2} = ['FCR'; 'ECU'; 'ECR'];
Hybrid_Kevin_EMGlist{3,1} = '052015'; Hybrid_Kevin_EMGlist{3,2} = ['FCR'; 'ECU'; 'ECR'];  % FDP looks good! FDS doesn't. FCU is crap
Hybrid_Kevin_EMGlist{4,1} = '052115'; Hybrid_Kevin_EMGlist{4,2} = ['FCR'; 'ECU'; 'ECR'];% FCU is shot
Hybrid_Kevin_EMGlist{5,1} = '052515'; Hybrid_Kevin_EMGlist{5,2} = ['FCR'; 'ECU'; 'ECR'];% FCU is shot. FDS looks good in one WM file but not another
Hybrid_Kevin_EMGlist{6,1} = '052615'; Hybrid_Kevin_EMGlist{6,2} = ['FCR'; 'ECU'; 'ECR']; % no fcu, no fds
Hybrid_Kevin_EMGlist{7,1} = '060315'; Hybrid_Kevin_EMGlist{7,2} = ['FCR'; 'ECU'; 'ECR']; % fcu is shot. some of the other signals have sinusoidal noise in addition to signal
Hybrid_Kevin_EMGlist{8,1} = '060415'; Hybrid_Kevin_EMGlist{8,2} = ['FCR'; 'ECU'; 'ECR'];  % same as 0603
Hybrid_Kevin_EMGlist{9,1} = '060615'; Hybrid_Kevin_EMGlist{9,2} = ['FCU'; 'FCR'; 'ECU'; 'ECR']; %the gang's all here!
Hybrid_Kevin_EMGlist{10,1} = '060815';Hybrid_Kevin_EMGlist{10,2} = ['FCU'; 'FCR'; 'ECU'; 'ECR']; % FCU is questionable. keeping it, but maybe it's bad.


end
