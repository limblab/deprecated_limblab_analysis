function vafAll=batch_EFP_phaseRandomDecode(PathName)

% syntax vafAll=batch_EFP_phaseRandomDecode(PathName);
%
% this is the function to run for phase randomization!
%       (for EFP data)
%
% in general, this script does the same thing as
% batch_buildLFPpositionDecoderRDF.m, but should operate on files that were
% output from Marc's n2matM4.m code, meaning that fp is loaded into the
% workspace, not built from the bdf.  Also, the naming convention to
% distinguish data files from output/decoder files is different.

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

% include only files that have the pattern 
% Chewie|Mini EFP ddd fp4.mat
% where ddd are digits

MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'(Chewie|Mini)EFP(L?)[0-9]{3}fp4\.mat'))==0);
if isempty(MATfiles)
    fprintf(1,'no MAT files found.\n')
    disp('quitting...')
    return
end

for n=1:length(MATfiles)
    FileName=MATfiles{n};
    % only load the variable you want.  
    load(FileName,'bdf')
    fnam=FileName(1:end-4);
    load(FileName,'fp')

    % randomize phase of fp inputs
    fp=pharand(fp')';
    
    % either position or velocity
    signal='pos';
    sig=bdf.(signal);
    
    numfp=size(fp,1);
    load(FileName,'fs')
    fptimes=1/fs:1/fs:size(fp,2)/fs;
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
        fs,fp,fptimes,fptimes,fnam,wsz,nfeat,PolynomialOrder, ...
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
    clear FileName fnam bdf emgsamplerate sig emgchans analog_times signal disJoint fpchans fp samprate numfp numsides fptimes
    clear folds numlags wsz nfeat PolynomialOrder smoothfeats binsize vaf vmean vsd y_test y_pred r2mean r2sd r2 vaftr bestf bestc
    clear H EMGchanNames Use_Thresh formatstr k lambda str words fse temg P cells uList x* y*
end
