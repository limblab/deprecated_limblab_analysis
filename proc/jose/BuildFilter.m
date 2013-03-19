function [filt_struct, OffLPredData] = BuildFilter(trainData,pred_out,input_type,PolynomialOrder)

% BuildFilterWiener: build a wiener decoder from a data set
% trainData        : data binned at 50 ms
% pred_out         : vector containing the outputs you want to predict
%                    [PredEMG, PredForce, PredCursPos,PredVeloc]
%                    e.g. if you want to predForce, pred_out=[0,1,0,0]
% input_type       : 0 ... neurons as inputs
%                    1 ... EMGs as inputs
% PolynomialOrder  : order of the Weiner non-linearity (0=no Polynomial)
 
% % By Jose: jose.albsab@gmail.com  / 10-18-12

% Default Path
dataPath = ':\'; 

%% Building Decoder
UseAllInputsOption = 1; % use all inputs
fillen = 0.5;            % filter length (in seconds)
PredEMG = pred_out(1);
PredForce = pred_out(2);
PredCursPos = pred_out(3);
PredVeloc = pred_out(4);
%% Output
[filt_struct, OffLPredData] = BuildModel(trainData,dataPath,fillen,UseAllInputsOption,...
    PolynomialOrder,PredEMG, PredForce, PredCursPos,PredVeloc,[],input_type);
