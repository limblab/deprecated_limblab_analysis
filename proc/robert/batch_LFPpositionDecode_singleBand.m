function vaf_bands=batch_LFPpositionDecode_singleBand(PathName)

% syntax vaf_bands=batch_LFPpositionDecode_singleBand(PathName);
%
% this is the function to run for single-band analysis for LFPs.  It runs
% from the BDFs, which is okay for LFP recordings because they utilize 96
% channels and nearly all of them are good (for the LFP/EFP/Spike paper).

if ~nargin
    PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\',...
        'select folder with data files');
    if exist(PathName,'dir')~=7
        disp('folder not valid.  aborting...')
        return
    end
end
cd(PathName)
Files=dir(PathName);
Files(1:2)=[];
FileNames={Files.name};

REstr='(Chewie|Mini)(Spike)LFP(L?)[0-9]{3}\.mat';

MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,REstr))==0);
if isempty(MATfiles)
    fprintf(1,'no MAT files found.\n')
    disp('quitting...')
    return
end

for n=1:length(MATfiles)
    FileName=MATfiles{n};
    fprintf(1,'loading %s.\n',FileName)
    load(FileName,'out_struct')
    fpAssignScript
    bdf=out_struct; clear out_struct
    fs=bdf.raw.analog.adfreq(1);
    
    fptimes=1/fs:1/fs:size(fp,2)/fs;
    % either position or velocity
    signal='vel';
    sig=bdf.(signal);
    analog_times=sig(:,1);

    if fs > 1000
        % want final fs to be 1000
        disp('downsampling to 1 kHz')
        samp_fact=fs/1000;
        downsampledTimeVector=linspace(fptimes(1)*samp_fact,fptimes(end),length(fptimes)/samp_fact);
        fp=interp1(fptimes,fp',downsampledTimeVector)';
        fptimes=downsampledTimeVector;
        downsampledTimeVector=linspace(analog_times(1),analog_times(end),length(analog_times)/samp_fact);
        downSampledBehaviorSignal=interp1(analog_times,sig(:,2:end),downsampledTimeVector);
        analog_times=downsampledTimeVector; clear downsampledTimeVector
        sig=[rowBoat(analog_times),downSampledBehaviorSignal];
        fs=1000;
    end
    
    numfp=size(fp,1);
    numsides=1;
    temg=fptimes;

    Use_Thresh=0; words=[]; lambda=1;

    disp('assigning tunable parameters and building the decoder...')
    folds=10;
    numlags=10;
    wsz=256;
    nfeat=90;
    PolynomialOrder=3;
    smoothfeats=0;
    binsize=0.1;
    if exist('fnam','var')~=1
        fnam='';
    end
    
    % gonna have to be a loop to do each of the single-band iterations.
    % How to collect data into VAF?
    for m=1:6
        [vaf_bands{n,m},~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = ...
            predictionsfromfp6(sig,signal,numfp,binsize,folds,numlags,numsides, ...
            fs,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
            Use_Thresh,words,fs,lambda,smoothfeats,m);
        close
        
        fprintf(1,'\n\n\n\n\n=====================\nLFP predictions DONE\n====================\n\n\n\n')
        
        if exist('FileName','var')==1
            disp(FileName)
        end
        fprintf(1,'folds=%d\n',folds)
        fprintf(1,'numlags=%d\n',numlags)
        fprintf(1,'wsz=%d\n',wsz)
        fprintf(1,'nfeat=%d\n',nfeat)
        fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
        fprintf(1,'smoothfeats=%d\n',smoothfeats)
        fprintf(1,'binsize=%.2f\n',binsize)
        fprintf(1,'fs=%d\n',fs)
        
        vaf_bands{n,m}
        
        formatstr='%s vaf mean across folds: ';
        for k=1:size(vaf_bands{n,m},2), formatstr=[formatstr, '%.4f   ']; end
        formatstr=[formatstr, '\n'];
        
        fprintf(1,formatstr,signal,mean(vaf_bands{n,m},1))
        fprintf(1,'overall mean vaf %.4f\n',mean(vaf_bands{n,m}(:)))
        
        % comment the next clear statement to do in-depth troubleshooting
        clear PA PB Pmat
    end
    % clear all the outputs of the LFP predictions analysis, so there's no
    % confussion when things are re-generated for the spike prediction
    % analysis.
    clear FileName fnam bdf emgsamplerate sig emgchans analog_times signal disJoint fpchans fp fs numfp numsides fptimes
    clear folds numlags wsz nfeat PolynomialOrder smoothfeats binsize vaf vmean vsd y_test y_pred r2mean r2sd r2 vaftr bestf bestc
    clear H EMGchanNames Use_Thresh formatstr k lambda str words fse temg P cells uList x* y*
end

