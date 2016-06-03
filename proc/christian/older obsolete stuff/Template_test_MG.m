timeWindow = 1;
samplefreq = 20;
w = MG_Words;

%% 1- Find EMG patterns for each targets and gadgets

% Get the ts for Go Cue and Rewards
GR_ts = Get_GR_ts_MG(out_struct);
%%%%  GR_ts = [ts tgt_id gdt_id]
%%%%         where tgt_id and gdt_id = [1 to tgt/gdt max] for Rewards ts
%%%%         and tgt_id and gdt_id = 0 for TouchPad (Go_Cue) ts
if isempty(GR_ts)
    GR_ts = Get_TPR_ts_MG(out_struct);
end

% Get the reward ts
R_ts = GR_ts(GR_ts(:,3)~=0,1);

% clear out_struct;

signals = [binnedData.timeframe binnedData.emgdatabin(:,:)];
S = ave_sigs_tgt_gdt(signals,GR_ts,timeWindow);

S_TVP = PWTH(signals,out_struct.words,w.Reward,2.5,2.5);

% clear signals;

%% 1.5- Generate polar plots of S
for i=2:size(S,1)
    figure;
    theta = 0:2*pi()/size(S,2):2*pi();
    rho = [S(i,:) S(i,1)];
    polar(theta,rho)
end
figure; plot(S_TVP(:,1),S_TVP(:,2:end));
%% 2- Use expected EMG patterns along with Actual spike data to Build a Model
% [ModelData, tmpData,ActualData] = Get_Rate_Template_pairs(binnedData,S,Center_ts,Reward_ts,timeWindow);

%[ModelData,ActualData_Mod] = Get_Model_Data_Template2(binnedData,S,GR_ts,timeWindow);


%use patterns over the 1 sec before reward ts up to 1 sec after
S_TVP = S_TVP(S_TVP(:,1)>=-1 & S_TVP(:,1)<=1,:);
[ModelData] = Get_Model_Data_TVPatterns(binnedData,S_TVP,R_ts);


% clear binnedData CR_ts S timeWindow samplefreq;

dataPath = '';
fillen = 0.25;
UseAllInputsOption = 1;
PolynomialOrder = 2;

[filter,PredModelData] = BuildModel_Templates(ModelData,  dataPath, fillen, UseAllInputsOption, PolynomialOrder);
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