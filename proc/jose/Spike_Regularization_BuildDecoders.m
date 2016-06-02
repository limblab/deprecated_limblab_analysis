BinDataPath = 'Y:\Spike_10I3\BinnedData\2013-05-07';
FilterPath  = 'Y:\Spike_10I3\SavedFilters\2013-05-07';
Bin_FileName = 'Spike_2013-05-07_WF_002_0to18m40s.mat';

lambda = 10; % parameter for regularization

if ~exist(FilterPath,'dir')
	mkdir(FilterPath);
end

binnedData = LoadDataStruct([BinDataPath '\' Bin_FileName]);

if isempty(binnedData)
    error('could not find file %s',[BinDataPath '\' Bin_FileName]);
end

%% N2F
%Predicting Force from N2P Decoder
pred_out = [0,0,1,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 1; % N2P
fprintf('Computing Direct Force decoder...');
[filt1 aux] = BuildFilter_reg(binnedData,pred_out,input_type,PolynomialOrder,lambda);
fprintf('Done\n');

% saving data
Filt_FileName = [Bin_FileName(1:end-4) '_N2P_R_Decoder.mat'];
fprintf('Saving file %s ...',Filt_FileName);
filt1.FromData = Bin_FileName;
Filt_FullFileName = fullfile(FilterPath,Filt_FileName);
save(Filt_FullFileName, '-struct','filt1');
fprintf('Done\n');

%% Cascade Decoder 
% Calculating PredEMGs
pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 1; % N2E
fprintf('Computing N2E decoder...');
[filt2a, OLPredData_N2E] = BuildFilter_reg(binnedData,pred_out,input_type,PolynomialOrder,lambda);
fprintf('Done\n');
% OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin; % input for the E2F decoder
% Calculating E2P Decoder
pred_out = [0,0,1,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 1; % use EMGs as inputs
PolynomialOrder = 1; % E2P
fprintf('Computing E2F decoder...');
[filt2b, OLauxData] = BuildFilter_reg(binnedData,pred_out,input_type,PolynomialOrder);
fprintf('Done\n');

% saving EMG data
Filt_FileName = [Bin_FileName(1:end-4) '_N2E_R_Decoder.mat'];
filt2a.FromData = Bin_FileName;
% [Filt_FileName, PathName] = saveDataStruct(filt2a,FilterPath,Filt_FileName,'filter');        
Filt_FullFileName = fullfile(FilterPath,Filt_FileName);
fprintf('Saving file %s ...',Filt_FileName);
save(Filt_FullFileName, '-struct','filt2a');
fprintf('Done\n');

% saving E2P data
Filt_FileName = [Bin_FileName(1:end-4) '_E2P_R_Decoder.mat'];
filt2b.FromData = Bin_FileName;
% [Filt_FileName, PathName] = saveDataStruct(filt2b,FilterPath,Filt_FileName,'filter');        
Filt_FullFileName = fullfile(FilterPath,Filt_FileName);
fprintf('Saving file %s ...',Filt_FileName);
save(Filt_FullFileName,'-struct','filt2b');
fprintf('Done\n');

