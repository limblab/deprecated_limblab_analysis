function [R2_NL R2_L]=R2_CDNonLinear()

% This function plots the impulse transfer Function of the Cascade Decoder
% given N different dataset

%% GUI Training Data

dataPath = 'C:\Users\Jose Luis\Desktop\Spike\replicate_RealData\CascadevsN2P\';

[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Hand Control Training File');
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

%% Decoders 
% Calculating PredEMGs NonLinear
pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 2; % N2E .. Non Linear
[filt_N2E1, aux] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder);
% Calculating E2F Decoder
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 1; % use EMGs as inputs
PolynomialOrder = 3; % E2F
[filt_E2F, aux] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder);

% Calculating PredEMGs Linear
pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 1; % N2E .. Linear
[filt_N2E2, aux] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder);

%% GUI Test Data

dataPath = 'C:\Users\Jose Luis\Desktop\Spike\replicate_RealData\CascadevsN2P\';

[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Hand Control Test File');
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

%% Pred Another Day 
% Calculating PredEMGs NonLinear
OLPredData_N2E = predictSignals(filt_N2E1,binnedData);
OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin; % input for the E2F decoder
% Calculating E2F Decoder
PredF_CD = predictSignals(filt_E2F,OLPredData_N2E);
Pred_Fx1 = PredF_CD.preddatabin(:,1);
Pred_Fy1 = PredF_CD.preddatabin(:,2);

% Calculating PredEMGs Linear
OLPredData_N2E = predictSignals(filt_N2E2,binnedData);
OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin; % input for the E2F decoder
% Calculating E2F Decoder
PredF_CD = predictSignals(filt_E2F,OLPredData_N2E);
Pred_Fx2 = PredF_CD.preddatabin(:,1);
Pred_Fy2 = PredF_CD.preddatabin(:,2);

%% R2
% Actual Force
ActFx = binnedData.forcedatabin(19:end,1); % double lag
ActFy = binnedData.forcedatabin(19:end,2);
ActF = [ActFx,ActFy];

% Non Linear
PredF1 = [Pred_Fx1,Pred_Fy1];
R2_NL = CalculateR2(ActF,PredF1);

% Linear
PredF2 = [Pred_Fx2,Pred_Fy2];
R2_L = CalculateR2(ActF,PredF2);


