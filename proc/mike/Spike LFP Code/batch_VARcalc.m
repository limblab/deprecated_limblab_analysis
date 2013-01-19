Monkeys = [{Chewie_filenames} {Mini_filenames}];

direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding';

signalType = 'vel';
binsize = .1;
folds = 10;
numlags = 10;
numsides = 1;
windowsize= 256;
nfeat = 150;
PolynomialOrder = 0;  %for Wiener Nonlinear cascade
Use_Thresh = 0;
emgsamplerate = 1000;
lambda = 1;

for m = 1%:length(Monkeys)
    
    featindBEST = Onlinefeatind(:,m);
    
    MATfiles = Monkeys{m};
    
    for q = 1:length(MATfiles)
        
        fnam =  findBDFonCitadel(MATfiles{q})

        try
            load(fnam)
        catch exception
            continue
        end
            
        if exist('out_struct','var')
            bdf = out_struct;
            clear out_struct
        end
        
        [sig, samplerate, words, fp, numberOfFps, adfreq, fp_start_time, fp_stop_time,...
            fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
        
        H = [];
        P = [];
        featind = featindBEST;
        nfeat = length(featind);
        
        [LFPvar bestc bestf] =... %,sr]...
            VARcalc(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
            samplerate,fp,fptimes,analog_time_base,fnam,windowsize,nfeat,PolynomialOrder,...
            Use_Thresh,[],words,emgsamplerate,lambda,0,featind,0,[]);
        
        close all
        
        VAFcalc{q,m} = LFPvar;
        Allbestc{q,m} = bestc;
        Allbestf{q,m} = bestf;
        
        save('SingleChLFP_BC_Decoder1VAR_Chewie_Mini_Output.mat','VAFcalc*','All*');
    end
end

