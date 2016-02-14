function [SingleChanVAF_AllFiles_X SingleChanVAF_AllFiles_Y SingleChanR_AllFiles_X SingleChanR_AllFiles_Y bestc_bychan bestf_bychan FileList] = batch_calc_vaf_BCcursor_bychan(FileList, H, P, bestc, bestf)

% This function calculates the vaf contribution of each feature to online BC cursor position

% FileList  - list of files to run

% H         - decoder to test
% bestc     - channels used in decoder
% bestf     - features on each channel used in decoder

%% ***Declare all input arguments that stay constant through all loop
% iterations outside loop (vars to be declared inside loop are commented
% out below):
%sig
signalType = 'vel';
%numberOfFps
binsize = .05;
folds = 10;
numlags = 10;
numsides = 1;
%samprate
%fp
%fptimes
%analog_times
%fnam
%***Variable Arguments In (varargin)***
windowsize= 256;
nfeat = 150;
PolynomialOrder = 3;  %for Wiener Nonlinear cascade
Use_Thresh = 0;
%H
%words
emgsamplerate = 1000;
lambda = 1;
%smoothfeats

[C,sortInd]=sortrows([bestc' bestf']);
bestc_bychan = C(:,1);
bestf_bychan = C(:,2);
        
%% Change to directory with PB matrices
direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Working Data';
disp(['Currently using ', direct, ' as the PB matrix diretory, is this correct?'])
keyboard
cd(direct);

%% Start calculating vafs for single features

for i = [32:43 87:102]%length(FileList)

    fnam =  findBDFonCitadel(FileList{i})
    load(fnam)
    
    %load([FileList{i}(1:end-4),'FeatMat.mat'])
    
    [sig samplerate words fp numberOfFps adfreq fp_start_time fp_stop_time...
        fptimes analog_time_base] = SetPredictionsInputVar(out_struct);
    
    [PB, ~, ~, ~, y] =...
        MRScalcFeatMat(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
        samplerate,fp,fptimes,analog_time_base,fnam,windowsize,nfeat,PolynomialOrder,...
        Use_Thresh,[],words,emgsamplerate,lambda,0,[],[],[],3);
    
    [y_predAllFeat] = calc_vaf_BCcursor_All(PB, y, H, bestc_bychan, bestf_bychan, P);
    
    [SingleChanVAF r2] = calc_vaf_BCcursor_bychan(PB, y, H, bestc_bychan, bestf_bychan, P, y_predAllFeat{1});
    
    SingleChanVAF_AllFiles_X(:,i) = SingleChanVAF(:,1)
    SingleChanVAF_AllFiles_Y(:,i) = SingleChanVAF(:,2)
    
    SingleChanR_AllFiles_X(:,i) = r2(:,1);
    SingleChanR_AllFiles_Y(:,i) = r2(:,2);
    
    save('ChewieSingleFeatVAFsOfflineBCCursorPred','SingleChan*','y_predAllFeat','best*','FileList', 'H', 'P')
    
end

for j = 1:length(featindBEST_Mini)
    bestc(j) = ceil(featindBEST_Mini(j)/6);
    
    if rem(featindBEST_Mini(j),6) ~=0
        bestf(j) = rem(featindBEST_Mini(j),6);
    else
        bestf(j) = 6;
    end
    
end

for i = 1: length(bestc)
    featindBEST_Mini(i) = (bestc(i)-1)*6 + bestf(i);
end