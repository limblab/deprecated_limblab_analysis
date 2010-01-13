WF_task = 1;
MG_task = 2;
BD_task = 3;

%% Indicate which task you are using this code for:
task = MG_task;

%% Editable Parameters
%default:
% EMG_vector = [3 4 5 9]; %Thor
EMG_vector = [1 2 5 9 10]; %Theo
time_before_reward = 2;
time_after_reward = 1;

switch task
    case WF_task
        CR_ts = Get_Center_and_Reward_ts(out_struct);
        % CR_ts = [ts tgt] : Nx2 array, N=2xNumReward ([ts reward])
        %   tgt = 0 if ts corresponds to Center Hold (Go_Cue)
        %   tgt = Tid if ts corresponds to Reward time of target Tid (Tid = 1 to numTargets)
        R_ts = CR_ts(CR_ts(:,2)~=0 & CR_ts(:,1)<binnedData.timeframe(end,1),:);
    case MG_task
        GR_ts = Get_GR_ts_MG(out_struct);
        %  GR_ts = [ts tgt_id gdt_id]
        %         where tgt_id and gdt_id = [1 to tgt/gdt max] for Rewards ts
        %         and tgt_id and gdt_id = 0 for TouchPad (Go_Cue) ts
        R_ts = GR_ts(GR_ts(:,3)~=0 & GR_ts(:,1)<binnedData.timeframe(end,1),:);
    case BD_task
        % Get the ts for Go Cue and Rewards
        GR_ts = Get_GR_ts_BD(out_struct);
        % GR_ts = [ts reward] : Nx2 array, N=2xNumReward
        %   reward = 0 if ts corresponds to Go_Cue or touchPad hold
        %   reward = 1 if ts corresponds to Reward time
        R_ts = GR_ts(GR_ts(:,2)~=0 & GR_ts(:,1)<binnedData.timeframe(end,1),:);
end

%% 2.1-Calculate Average Signals around Reward Time:
%default
signals = [binnedData.timeframe binnedData.emgdatabin(:,EMG_vector)];
[S,S_TVP] = TVP_tgt(signals,R_ts,time_before_reward,time_after_reward);
% clear signals;

%% 2.2- Generate plots of S and S_TVP
% for i=1:size(S,3)
%     figure;
%     theta = 0:2*pi()/(size(S,2)-1):2*pi();
% %     rho = [S(i,:) S(i,1)];
%     rho = [S(1,2:end,i) S(1,2,i)];
%     polar(theta,rho)
% end

for i = 1:size(S_TVP,3)
    figure;
    plot(S_TVP(:,1,i),S_TVP(:,2:end,i));
    hold on;
     plot(S(:,1,i),S(:,2:end,i));
end


%% 2.3 Modify time_before and time_after for TVP if desired
%use patterns from time_bef until time_aft around reward ts

switch task
    case WF_task
        time_before_reward = 1.5;
        time_aftet_reward =  0.5;
    case MG_task
        time_before_reward = 1.6;
        time_after_reward =  -0.5;
    case BD_task
        time_before_reward = 1;
        time_after_reward = 0;
end
%and update Templates:
[S,S_TVP] = TVP_tgt(signals,R_ts,time_before_reward,time_after_reward);

%% 3.1- Generate the Data to be used for Model Building

    [ModelData] = Get_Model_Data_TVPatterns(binnedData,S,R_ts);
    [ModelData_TVP] = Get_Model_Data_TVPatterns(binnedData,S_TVP,R_ts);
    ModelData.emgguide = binnedData.emgguide(EMG_vector,:);
    ModelData_TVP.emgguide = binnedData.emgguide(EMG_vector,:);

%% 3.2- Plot Model Data vs. Actual Data to Compare
figure;
subplot(3,1,1); plot(ModelData_TVP.timeframe,ModelData_TVP.emgdatabin(:,:)); title('TVP');
subplot(3,1,2); plot(ModelData.timeframe,ModelData.emgdatabin(:,:)); title('Fixed templates');
subplot(3,1,3); plot(binnedData.timeframe,binnedData.emgdatabin(:,EMG_vector)); title('Actual Data');

%% 4 - Build the Model using the Model Data built with templates

dataPath = '';
fillen = 0.2;
UseAllInputsOption = 1;
PolynomialOrder = 2;

[filter_TVP,PredModelData_TVP] = BuildModel_Templates(ModelData_TVP,  '', fillen, UseAllInputsOption, PolynomialOrder);
[filter,PredModelData] = BuildModel_Templates(ModelData,  dataPath, fillen, UseAllInputsOption, PolynomialOrder);

% clear ModelData;
 
%% 5-Generate predictions using the Model and plot against Actual Data

ActualData = binnedData;
ActualData.emgdatabin = binnedData.emgdatabin(:,EMG_vector);
ActualData.emgguide   = binnedData.emgguide(EMG_vector,:);

[PredData_TVP] = predictSignals(filter_TVP,ActualData);
[PredData] = predictSignals(filter,ActualData);

%Normalize predictions and actual data between 0 and 200
for i = 1:length(EMG_vector)
    ActualData.emgdatabin(:,i) = 200*ActualData.emgdatabin(:,i)/max(ActualData.emgdatabin(:,i));
    PredData.preddatabin(:,i) = 200*PredData.preddatabin(:,i)/max(PredData.preddatabin(:,i));
    PredData_TVP.preddatabin(:,i) = 200*PredData_TVP.preddatabin(:,i)/max(PredData_TVP.preddatabin(:,i));
end

plotflag=1;
%TV Patterns
ActualvsOLPred(ActualData, PredData_TVP, plotflag);
%static Patterns
ActualvsOLPred(ActualData, PredData, plotflag);


