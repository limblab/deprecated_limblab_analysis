%runpredfp6
%Uses MRSpredictionsfromfp6allDecoderBuild
input = 2;
Usefeatmat = 0;
%Use 1 if loading files from folder structure, use 2 if using list of
%filenames and obtaining path from citadel
%Usefeatmat = 1 if loading featMat for decoding, 0 if not.

%% ***Declare all input arguments that stay constant through all loop
% iterations outside loop (vars to be declared inside loop are commented out below):

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

%% Begin iterating through files
% for l=1:length(MATfiles)
%
%     if input == 1
fnam = ['abc'];% MATfiles{l}
%         fname=[direct,'\',DaysNames{i},'\',fnam];
%         load(fnam);
%
%     elseif input == 2
%         fnam =  findBDFonCitadel(DaysNames{i})
%         try
%             load(fnam)
%         catch exception
%             continue
%         end
%
%     end
%% Declare input variables within loop that vary in each loop iteration:

if exist('out_struct','var')
    bdf = out_struct;
    clear out_struct
end

cells = unit_list(bdf);

if Usefeatmat == 0
    [sig, samplerate, words, fp, numberOfFps, adfreq, fp_start_time, fp_stop_time,fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
end

tic
%% Run Prediction Code
[vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2all,vaftr,TotalUnits,TotalSpikes_PerUnit,PhaseMat,H] =... %,sr]...
    predictionsfromSpikeByFPphase(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
    samplerate,fp,fptimes,analog_time_base,fnam,windowsize,nfeat,PolynomialOrder,...
    Use_Thresh,[],words,emgsamplerate,lambda,0,[],[],[],bdf, cells); %< --- last input is featmat
toc
%% Save output
save(['ChewieSpikesByPhase_CO tik6 velpred poly',num2str(PolynomialOrder),' ',num2str(numlags),'lags','causal','.mat'],'v*','y*','r*','Total*','PhaseMat');
