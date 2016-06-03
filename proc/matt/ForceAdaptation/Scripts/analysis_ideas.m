%% Compare spike and factor decoding between CO and RT
% load CO and RT data
% check to make sure neurons match in both files
% find factors and trajectories
% decode velocity from spikes
% decode velocity from factors
close all;
clear;
clc;

numlags = 10;
binsize = 0.05;
foldLength = 60;
BDF2BinArgs = struct('binsize',binsize,'starttime',0,'stoptime',0,'EMG_hp',50,'EMG_lp',10,'minFiringRate',0,'NormData',0,'FindStates',0,'Unsorted',0,'TriKernel',0,'sig',0.04,'ArtRemEnable',0,'NumChan',10,'TimeWind',5e-04);
DecoderOptions = struct('foldlength',foldLength,'numPCs',0,'PredEMGs',0,'PredCursPos',0,'PredVeloc',1,'PredTarg',0,'PredForce',0,'PredCompVeloc',0,'PredMoveDir',0,'fillen',numlags*binsize,'UseAllInputs',1,'PolynomialOrder',3,'Use_Thresh',0,'Use_EMGs',0,'Use_Ridge',0,'Use_SD',0);

load('F:\Chewie\M1\BDFStructs\2015-11-03\Chewie_M1_CO_CS_BL_11032015.mat');
if BDF2BinArgs.ArtRemEnable
    disp('Looking for Artifacts...');
    out_struct = artifact_removal(out_struct,BDF2BinArgs.NumChan,BDF2BinArgs.TimeWind, 1);
end
co = convertBDF2binned_Matt(out_struct,BDF2BinArgs);

load('F:\Chewie\M1\BDFStructs\2015-11-03\Chewie_M1_RT_CS_BL_11032015.mat');
if BDF2BinArgs.ArtRemEnable
    disp('Looking for Artifacts...');
    out_struct = artifact_removal(out_struct,BDF2BinArgs.NumChan,BDF2BinArgs.TimeWind, 1);
end
rt = convertBDF2binned_Matt(out_struct,BDF2BinArgs);

% get cross validated performance of each decoder
[co_mfxval_R2, co_mfxval_vaf, ~, ~] = mfxval_Matt(co, DecoderOptions);
[rt_mfxval_R2, rt_mfxval_vaf, ~, ~] = mfxval_Matt(rt, DecoderOptions);

% now test each decoder on the other dataset
[co_filt, pred_co] = BuildModel_Matt(co, DecoderOptions);
[rt_filt, pred_rt] = BuildModel_Matt(rt, DecoderOptions);

[pred, ~] = predictSignals_Matt(co_filt,rt,false,false,DecoderOptions.numPCs);
[co_rt_r2,co_rt_vaf,~] = ActualvsOLPred_Matt(pred_rt,pred,0,0);
[pred, ~] = predictSignals_Matt(rt_filt,co,false,false,DecoderOptions.numPCs);
[rt_co_r2,rt_co_vaf,~] = ActualvsOLPred_Matt(co,pred,0,0);

{mean(co_mfxval_vaf,2) mean(rt_mfxval_vaf,2) mean(co_rt_vaf,2) mean(rt_co_vaf,2)}

%% Look at movements in manifold during learning
% load adaptation data for epochs
% check to make sure neurons match in all files
% find low-D representation and manifold
% project FR into manifold over course of learning and look at variability (systematic change across manifold?)

%% Compare GPFA planning trajectories in CO and RT task
% load CO and RT data
% check to make sure neurons match in both files
% do GPFA
% group RT reaches based on direction in 8 bins to match CO targets
% separate RT groups based on whether the starting point was near the center (ie more or less like CO reaches)
% plot trajectories between target presentation and movement, look for similarities in neural space

%% Study GPFA planning trajectories in RT task
% load RT task data
% do GPFA
% plot planning trajectories in M1/PMd and color-code based on things like upcoming distance, starting position, etc

%% Look for dynamical system representations in RT task
% load RT task data
% do GPFA (can't do PCA because I can't average across trials)