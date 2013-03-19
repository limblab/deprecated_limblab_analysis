dataPath = ':/';
Bin_FileName = 'Spike_03-19-13_WF_001.mat';

lambda = 10; % parameter for regularization

%% N2F
%Predicting Force from N2P Decoder
pred_out = [0,0,1,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 1; % N2P
[filt1 aux] = BuildFilter_reg(binnedData,pred_out,input_type,PolynomialOrder,lambda);

% saving data
Filt_FileName = [Bin_FileName(1:end-4) '_N2P_Decoder.mat'];
filt1.FromData = Bin_FileName;
[Filt_FileName, PathName] = saveDataStruct(filt1,dataPath,Filt_FileName,'filter');        
Filt_FullFileName = fullfile(PathName,Filt_FileName);
save(Filt_FullFileName, '-append','-struct','filt1');

%% Cascade Decoder 
% Calculating PredEMGs
pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 1; % N2E
[filt2a, OLPredData_N2E] = BuildFilter_reg(binnedData,pred_out,input_type,PolynomialOrder,lambda);
OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin; % input for the E2F decoder
% Calculating E2P Decoder
pred_out = [0,0,1,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 1; % use EMGs as inputs
PolynomialOrder = 1; % E2P
[filt2b, OLauxData] = BuildFilter_reg(binnedData,pred_out,input_type,PolynomialOrder);

% saving EMG data
Filt_FileName = [Bin_FileName(1:end-4) '_N2E_Decoder.mat'];
filt2a.FromData = Bin_FileName;
[Filt_FileName, PathName] = saveDataStruct(filt2a,dataPath,Filt_FileName,'filter');        
Filt_FullFileName = fullfile(PathName,Filt_FileName);
save(Filt_FullFileName, '-append','-struct','filt2a');

% saving E2P data
Filt_FileName = [Bin_FileName(1:end-4) '_E2P_Decoder.mat'];
filt2b.FromData = Bin_FileName;
[Filt_FileName, PathName] = saveDataStruct(filt2b,dataPath,Filt_FileName,'filter');        
Filt_FullFileName = fullfile(PathName,Filt_FileName);
save(Filt_FullFileName, '-append','-struct','filt2b');

