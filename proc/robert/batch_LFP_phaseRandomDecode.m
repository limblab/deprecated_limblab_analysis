function vafAll=batch_LFP_phaseRandomDecode(PathName)

% syntax vafAll=batch_LFP_phaseRandomDecode(PathName);
%
% this is the function to run for phase randomization!
%       (for LFP data)
%

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

MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'(Chewie|Mini)SpikeLFP[0-9]{3}\.mat'))==0);
if isempty(MATfiles)
    fprintf(1,'no MAT files found.\n')
    disp('quitting...')
    return
else
    fprintf(1,'%d files.\n',length(MATfiles))
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

    % randomize phase of fp inputs
    fp=pharand(fp')';
    
    numfp=size(fp,1);
    numsides=1;
    temg=fptimes;

    Use_Thresh=0; words=[]; lambda=1;

    disp('assigning tunable parameters and building the decoder...')
    folds=10;
    numlags=10;
    wsz=256;
    nfeat=150;
    PolynomialOrder=3;
    smoothfeats=0;
    binsize=0.1;
    if exist('fnam','var')~=1
        fnam='';
    end
    
    % in runpredfp_emgonly.m, temg takes the place of analog_times and so
    % it is substituted in its place in the input list below.
    [vaf,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = ...
        predictionsfromfp6(sig,signal,numfp,binsize,folds,numlags,numsides, ...
        fs,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
        Use_Thresh,words,fs,lambda,smoothfeats);
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
    
    vaf
    
    formatstr='%s vaf mean across folds: ';
    for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
    formatstr=[formatstr, '\n'];
    
    fprintf(1,formatstr,signal,mean(vaf,1))
    fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))

%     if exist('outputs','dir')==0, mkdir('outputs'), end
    % comment the next clear statement to do in-depth troubleshooting
    clear PA PB Pmat
%     save(['outputs\',fnam,'tik emgpred ',num2str(nfeat),' feats lambda',num2str(lambda),' poly',num2str(PolynomialOrder),'.mat'], ...
%         'v*','y*','x*','r*','best*','H','feat*','P*','Use*','fse','temg','binsize','sr','smoothfeats','EMGchanNames');

    % clear all the outputs of the LFP predictions analysis, so there's no
    % confussion when things are re-generated for the spike prediction
    % analysis.
    vafAll{n}=vaf;
    clear vaf vmean vsd y_test y_pred r2mean r2sd r2 vaftr bestf bestc H bestfeat x y featMat ytnew xtnew predtbase P featind sr
    clear FileName fnam bdf emgsamplerate sig emgchans analog_times disJoint fpchans fp samprate numfp numsides fptimes
    clear folds numlags wsz nfeat PolynomialOrder smoothfeats binsize
    clear H EMGchanNames Use_Thresh formatstr k lambda str words fse temg P cells uList x* y*
end

fprintf(1,'\n\n\ndone for %s.\n\n\n',signal)
assignin('base','MATfiles',MATfiles)