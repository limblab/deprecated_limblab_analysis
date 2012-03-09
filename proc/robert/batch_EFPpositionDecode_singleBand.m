function vaf_bands=batch_EFPpositionDecode_singleBand(PathName)

% syntax vaf_bands=batch_EFPpositionDecode_singleBand(PathName);
%
% this is the function to run for single-band analysis. 
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

REstr='(Chewie|Mini)EFPL?[0-9]{3}tik velpred 150 feats( lambda1)?\.mat';
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,REstr))==0);
if isempty(MATfiles)
    fprintf(1,'no MAT files found.\n')
    disp('quitting...')
    return
end

featMat=[];
for n=1:length(MATfiles)
    FileName=MATfiles{n};
    % only load the variables you want.
    fnam=FileName(1:end-4);
    load(FileName,'featMat','y','binsize','Poly','UseThresh')
    
    words=[];
    folds=10;
    numlags=10;
    numsides=1;
    wsz=256;
    lambda=1;
    
    % for single band, limited by number of channels
    nfeat=size(featMat,2)/6;
    
    for m=1:6        
        [~,vaf_bands{n,m},~,~,~,~,~,~]=predonlyxy_newVAF(featMat(:,m:6:end),y, ...
            Poly,UseThresh,lambda,numlags,numsides,1/binsize,folds,nfeat,nan(1,2));
        
        fprintf(1,'\n\n\n\n\n=====================\nLFP predictions DONE\n====================\n\n\n\n')
        
        if exist('FileName','var')==1
            disp(FileName)
        end
        fprintf(1,'folds=%d\n',folds)
        fprintf(1,'numlags=%d\n',numlags)
        fprintf(1,'wsz=%d\n',wsz)
        fprintf(1,'nfeat=%d\n',nfeat)
        fprintf(1,'PolynomialOrder=%d\n',Poly)
%         fprintf(1,'smoothfeats=%d\n',smoothfeats)
        fprintf(1,'binsize=%.2f\n',binsize)
%         fprintf(1,'fs=%d\n',fs)
        
        vaf_bands{n,m}
        
        formatstr='%s vaf mean across folds: ';
        for k=1:size(vaf_bands{n,m},2), formatstr=[formatstr, '%.4f   ']; end
        formatstr=[formatstr, '\n'];
        
        fprintf(1,formatstr,'vel',mean(vaf_bands{n,m},1))
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

