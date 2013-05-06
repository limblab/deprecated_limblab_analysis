function [Power,Spikes,yLFP,PosLFP,ySpike,PosSpike,Words] = GetPower_SpikeRates_batch(inputFileList);
%Uses GetPower_SpikeRates to solely calculate and output spike rate and
%power for select files

% InputFileList - list of files to get power and spike rates

Usefeatmat = 0;
%Usefeatmat = 1 if loading featMat for decoding

%% Implement file i/o strategy

% Need to start out with list of file names if using input =2
%DaysNames = [{kinStructOut.name}' {kinStructOut.decoder_age}'];
DaysNames = [inputFileList];
MATfiles = DaysNames;
%DaysNames = DaysNames(cellfun(@isnan,{kinStructOut.decoder_age})==0,:);
direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Mini';

for i = 1%:length(DaysNames)]
    
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
        
        fnam =  findBDFonCitadel(DaysNames{i})
        load(fnam)
        
        
        %% Declare input variables within loop that vary in each loop iteration:
        
        if exist('out_struct','var')
            bdf = out_struct;
            clear out_struct
        end
        
        [sig, samplerate, words, fp, numberOfFps, adfreq, fp_start_time, fp_stop_time,...
            fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
        
        %% Run Prediction Code
        [PA, yLFP, PosLFP, x, ySpike, PosSpike] =...
            GetPower_SpikeRates(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
            samplerate,fp,fptimes,analog_time_base,fnam,windowsize,nfeat,PolynomialOrder,...
            Use_Thresh,[],words,emgsamplerate,lambda,0,bdf,binsize);
        
        Vel = bdf.vel;
        Pos = bdf.pos;
        Acc = bdf.acc;
        Words = bdf.words;
        
        Power{l} = PA;
        Spikes{l} = x;
        %% Save output
        
        save('Chewie_Gam3Power_SpikeRates_Early_Late_Training','Power','Spikes','yLFP','PosLFP','ySpike','PosSpike','Words');
        
    end
end