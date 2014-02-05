%runpredfp6
%Uses MRSpredictionsfromfp6allDecoderBuild
input = 2;
%file list name
MATfiles = Mini_COfilenames;

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
for l=1:length(MATfiles)

    if input == 2
        fnam =  findBDFonCitadel(MATfiles{l})
        try
            load(fnam)
        catch exception
            continue
        end

    end
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
[vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2all,vaftr,TotalUnits,TotalSpikes_PerUnit,PhaseMat,H{l}] =... %,sr]...
    predictionsfromSpikeByFPphase(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
    samplerate,fp,fptimes,analog_time_base,fnam,windowsize,nfeat,PolynomialOrder,...
    Use_Thresh,[],words,emgsamplerate,lambda,0,[],[],[],bdf, cells); %< --- last input is featmat
toc

    vafAll{l} = vaf;
    vmeanAllX(:,:,l) = vmean(:,:,1);
    vmeanAllY(:,:,l) = vmean(:,:,2);
    vmeanAllXY(:,:,l) = mean(vmean,3);
    vsdAll{l} = vsd;
    r2mAllX(:,:,l) = r2m(:,:,1);
    r2mAllY(:,:,l) = r2m(:,:,2);
    r2mAllXY(:,:,l) = mean(r2m,3);
    r2sdAll{l} = r2sd;
    r2Allfiles{l} = r2all;
    TotalUnitsAll(:,:,l) = TotalUnits;
    TotalSpikes_PerUnitAll{l} = TotalSpikes_PerUnit;
    TotalSpikes_AllUnits(:,:,l) = sum(TotalSpikes_PerUnit,3);

%% Save output
save(['MiniSpikesByPhase_CO_10files tik6 velpred poly',num2str(PolynomialOrder),' ',num2str(numlags),'lags','causal','.mat'],'v*','r*','Total*','PhaseMat','H');
%%
if 0
    %bandLabelsY=LFP_AllFreq_Online_Sorted_NoDelta(:,2);
    %[uBands,uBandYticks,~]=unique(bandLabelsY);
    uBandYticks=[1,3,5,10,15,20,25,30];
    allBands={'0-4','8-12','20-30','70-80','120-130','170-180','220-230','270-280'};
    set(gca,'YTick',uBandYticks,'YTickLabel',allBands)
    uBandXticks=[1:8];
    allXBands={'0','pi/4','pi/2','3pi/4','pi','5pi/4','3pi/2','7pi/4'};
    set(gca,'XTick',uBandXticks,'XTickLabel',allXBands)
    xlabel('Phase')
    ylabel('Frequency (Hz)')
end
