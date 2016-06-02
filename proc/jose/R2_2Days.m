function [R2_N2F,R2_14PC,R2_11PC,R2_8PC,R2_CD] = R2_2Days()

dataPath = 'C:\Users\Jose Luis\Desktop\Spike\replicate_RealData\CascadevsN2P\';

%% training data

[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Hand Control BinnedData File');
    datafile = fullfile(PathName,FileName_tmp);
    % Verify if the file indeed exists
if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
        % It exists.
        load(datafile,'binnedData'); % datafile automatically loaded as binnedData
else
        % It doesn't exist.
        warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
        uiwait(warndlg(warningMessage));
end

%% Filters
% N2F
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 3; % N2F
[filt_N2F, aux] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder);
% PC
data=binnedData.spikeratedata;  
[W, pc, eigV] = princomp(data);
% only 14 PC  
PC14_Data = binnedData;
PC14_Data.spikeratedata = pc(:,1:14);
PC14_Data.spikeguide = binnedData.spikeguide(1:14,:);
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 3; % N2F
[filt_14PC, aux] = BuildFilter(PC14_Data,pred_out,input_type,PolynomialOrder);
% only 11 PC  
PC11_Data = binnedData;
PC11_Data.spikeratedata = pc(:,1:11);
PC11_Data.spikeguide = binnedData.spikeguide(1:11,:);
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 3; % N2F
[filt_11PC, aux] = BuildFilter(PC11_Data,pred_out,input_type,PolynomialOrder);
% only 8 PC  
PC8_Data = binnedData;
PC8_Data.spikeratedata = pc(:,1:8);
PC8_Data.spikeguide = binnedData.spikeguide(1:8,:);
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 3; % N2F
[filt_8PC, aux] = BuildFilter(PC8_Data,pred_out,input_type,PolynomialOrder);
% CD
pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 2; % N2E
[filt_N2E, aux] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder);
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 1; % use EMGs as inputs
PolynomialOrder = 3; % E2F
[filt_E2F, aux] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder);

%% Test Data

[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Hand Control BinnedData File');
    datafile = fullfile(PathName,FileName_tmp);
    % Verify if the file indeed exists
if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
        % It exists.
        load(datafile,'binnedData'); % datafile automatically loaded as binnedData
else
        % It doesn't exist.
        warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
        uiwait(warndlg(warningMessage));
end

%% Predictions
% N2F
Pred_N2F = predictSignals(filt_N2F,binnedData);
Act_Fx = binnedData.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = binnedData.forcedatabin(10:end,2);
ActF = [Act_Fx,Act_Fy]; % same for PC
Pred_Fx = Pred_N2F.preddatabin(:,1);
Pred_Fy = Pred_N2F.preddatabin(:,2);
P_N2F = [Pred_Fx,Pred_Fy];
R2_N2F = CalculateR2(ActF,P_N2F);
% PC
data=binnedData.spikeratedata;  
[W, pc, eigV] = princomp(data);
% only 14 PC  
PC14_Data = binnedData;
PC14_Data.spikeratedata = pc(:,1:14);
PC14_Data.spikeguide = binnedData.spikeguide(1:14,:);
% 14PC
Pred_14PC = predictSignals(filt_14PC,PC14_Data);
Pred_Fx = Pred_14PC.preddatabin(:,1);
Pred_Fy = Pred_14PC.preddatabin(:,2);
P_14PC = [Pred_Fx,Pred_Fy];
R2_14PC = CalculateR2(ActF,P_14PC);
% only 11 PC  
PC11_Data = binnedData;
PC11_Data.spikeratedata = pc(:,1:11);
PC11_Data.spikeguide = binnedData.spikeguide(1:11,:);
% 11PC
Pred_11PC = predictSignals(filt_11PC,PC11_Data);
Pred_Fx = Pred_11PC.preddatabin(:,1);
Pred_Fy = Pred_11PC.preddatabin(:,2);
P_11PC = [Pred_Fx,Pred_Fy];
R2_11PC = CalculateR2(ActF,P_11PC);
% only 11 PC  
PC8_Data = binnedData;
PC8_Data.spikeratedata = pc(:,1:8);
PC8_Data.spikeguide = binnedData.spikeguide(1:8,:);
% 8PC
Pred_8PC = predictSignals(filt_8PC,PC8_Data);
Pred_Fx = Pred_8PC.preddatabin(:,1);
Pred_Fy = Pred_8PC.preddatabin(:,2);
P_8PC = [Pred_Fx,Pred_Fy];
R2_8PC = CalculateR2(ActF,P_8PC);
% CD
Pred_E = predictSignals(filt_N2E,binnedData);
Pred_E.emgdatabin = Pred_E.preddatabin; % input for the E2F decoder
Pred_CD = predictSignals(filt_E2F,Pred_E);
Act_Fx = binnedData.forcedatabin(19:end,1); % double lag
Act_Fy = binnedData.forcedatabin(19:end,2);
ActF = [Act_Fx,Act_Fy]; % same for PC
Pred_Fx = Pred_CD.preddatabin(:,1);
Pred_Fy = Pred_CD.preddatabin(:,2);
P_CD = [Pred_Fx,Pred_Fy];
R2_CD = CalculateR2(ActF,P_CD);