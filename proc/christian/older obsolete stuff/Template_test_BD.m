timeWindow = 1;
samplefreq = 20;
w = BD_Words;

%% 1- Find ave EMG patterns around reward ts

% Get the ts for Go Cue and Rewards
GR_ts = Get_GR_ts_BD(out_struct);
    % GR_ts = Get_GR_ts_MG() =  Nx2 array, N=2xNumReward ([ts reward])
    %   reward = 0 if ts corresponds to touchPad hold
    %   reward = 1 if ts corresponds to Reward time

% Get the reward ts
R_ts = GR_ts(GR_ts(:,3)~=0,1);

% clear out_struct;

signals = [binnedData.timeframe binnedData.emgdatabin(:,:)];
%ave EMG patterns from -2 sec to 1 sec after rewards:
S_TVP = PWTH(signals,out_struct.words,w.Reward,2,1);

%mean EMG in each muscle over timeWindow before rewards:
S=ave_sigs_BD(signals,GR_ts,timeWindow);

% clear signals;

%% 1.5- Generate plots of S
for i=2:size(S,1)
    figure;
    theta = 0:2*pi()/size(S,2):2*pi();
    rho = [S(i,:) S(i,1)];
    polar(theta,rho)
end
figure; plot(S_TVP(:,1),S_TVP(:,2:end));


%% 2- Use expected EMG patterns along with Actual spike data to Build a Model

%use patterns over the 1 sec before reward ts
S_TVP = S_TVP(S_TVP(:,1)>=-1 & S_TVP(:,1)<=0,:);


[ModelData] = Get_Model_Data_TVPatterns(binnedData,S_TVP,R_ts);

% clear binnedData CR_ts S timeWindow samplefreq;

dataPath = '';
fillen = 0.25;
UseAllInputsOption = 1;
PolynomialOrder = 2;

[filter,PredModelData] = BuildModel_Templates(ModelData, dataPath, fillen, UseAllInputsOption, PolynomialOrder);
% clear ModelData;
%

[PredData] = predictSignals(filter,binnedData);

EMGvector = [1 2 3 4 5 6 7 8 9 10 11 12];
ActualData = binnedData;
ActualData.emgdatabin = binnedData.emgdatabin(:,EMGvector);
ActualData.emgguide   = binnedData.emgguide  (EMGvector,:);

plotflag=1;
ActualvsOLPred(ActualData, PredData, plotflag);
% 
% for i = 1:4
% 
%     figure; plot(BinnedData.emgdatabin(:,EMGvector(i)),'k');
%     hold on;
%     plot(PredictedData.preddatabin(:,i),'r');
% end

%          BuildModel_Templates(binnedData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, varargin)