function [r2_X_SingleUnits,r2_Y_SingleUnits,H_SingleUnits,bestc,bestf]=divide_SFDrunpredfp6_saveFeatMat(Monkeys,featind,resumeFromPartial)

if nargin < 3
    resumeFromPartial=0;
end
dbstop if error

signalType = 'vel';
binsize = .05;                  % we are locked in to this bin size because of BC days
folds = 10;
numlags = 10;
numsides = 1;
windowsize= 256;
nfeat = 576;
PolynomialOrder = 0;  %for Wiener Nonlinear cascade
Use_Thresh = 0;
emgsamplerate = 1000;
lambda = 1;

%H_SingleUnits = cell([150,171,2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Begin building Single Feature Decoders %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir('featMats')
for m = 1:length(Monkeys) % 1 == Chewie, 2 == Mini
    DaysNames = Monkeys{m};
    MATfiles = DaysNames;
    
    % Begin iterating through files
    for l=1:length(MATfiles)
        if exist('H_SingleUnits.mat','file')
            if ~exist('H_SingleUnits','var')
                load('H_SingleUnits.mat')
            end
            if ~isempty(intersect(MATfiles(l),HbankDays))
                continue
            end
        end
        fnam=findBDFonCitadel(DaysNames{l}); fprintf(1,'\n%s\n',fnam);
        try
            load(fnam)
        catch exception                                                     %#ok<*NASGU>
            continue
        end
        
        if exist('bdf','var')
            out_struct=bdf; clear bdf
        end
        try
            fpAssignScript2
        catch exception
            if strcmp(exception.identifier,'MATLAB:nonExistentField')
                fpAssignScript
            else
                rethrow(exception)
            end
        end
        if exist('out_struct','var')
            bdf = out_struct;
            clear out_struct
        end
        % remove sections from fp and sig, if they correspond to velocity
        % blowups.  removeVelocityArtifacts.m just interpolates around
        % those sections, we want to remove them entirely.
        [bdf.vel,badStartInds,badEndInds]=removeVelocityArtifacts(bdf.vel);
        sig=bdf.vel;
        
        H = [];
        P = [];
        numberOfFps=size(fp,1);
        
        % Run Prediction Code
        [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,bestf{l},bestc{l},H,bestfeat,x,...
            y,featMat,ytnew,xtnew,predtbase,~] =... %,sr]...
            MRSpredictionsSingleUnitfromfp6all(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
            samprate,fp,fptimes,sig(:,1),fnam,windowsize,nfeat,PolynomialOrder,...
            Use_Thresh,H,[],emgsamplerate,lambda,0,featind);                %#ok<*ASGLU>
        
        H_SingleUnits(:,l,m) = H';                                          %#ok<*AGROW>
        if ~exist('H_SingleUnits.mat','file')
            HbankDays{1}=MATfiles{l};
        else
            HbankDays{l}=MATfiles{l};
        end
        save('H_SingleUnits.mat','H_SingleUnits','HbankDays','bestf','bestc','featind')
        dayNameRoot=regexp(DaysNames{l},'.*(?=\.mat)','match','once');
        if isempty(dayNameRoot), dayNameRoot=DaysNames{l}; end
        varName=['featMat_',dayNameRoot];
        varName2=['sig_',dayNameRoot];
        varName3=['binnedSig_',dayNameRoot];
        eval([varName,'=featMat;'])
        eval([varName2,'=sig;'])
        eval([varName3,'=y;'])
        save(fullfile('featMats',[varName,'.mat']),varName,varName2,varName3)
        clear v* y* x* r* bdf out_struct sig numfp samprate fp ...
            fptimes analog_times fnam words featMat* sig_* binnedSig*
%         close all
    end
    
    % concatenate all featMats and binnedSigs, divide up as desired, then
    % re-save as dummy files of the designated length.
    D=dir('featMats'); D(1:2)=[];
    featMatToDivide=[]; binnedSigToDivide=[];
    for n=1:length(D)
        S=load(fullfile('featMats',D(n).name),'featMat*','binnedSig*');
        varNames=fieldnames(S);
        featMatToDivide=[featMatToDivide; ...
            S.(varNames{cellfun(@isempty,regexp(varNames,'featMat.*'))==0})];
        binnedSigToDivide=[binnedSigToDivide; ...
            S.(varNames{cellfun(@isempty,regexp(varNames,'binnedSig.*'))==0})];
        clear S varNames
    end, clear n D
    % trim the omnibus arrays to a size that is an even multiple of the
    % divideFactor
    divideFactor=40;
    fprintf(1,'\n\nsaving %d files in folder pseudoFeatMats.\n\n',divideFactor);
    fold_length=floor(size(featMatToDivide,1)/divideFactor);
    fprintf(1,'fold length is %d\n\n',fold_length);
    featMatToDivide(fold_length*divideFactor+1:end,:)=[];
    binnedSigToDivide(fold_length*divideFactor+1:end,:)=[];
    % now, divide and re-save.  Eliminate the original files, or creat a
    % new sub-sub-director.  
    mkdir('pseudoFeatMats')
    for n=1:divideFactor
        eval(['featMat',sprintf('%02d',n),'=featMatToDivide(((n-1)*fold_length+1):(n*fold_length),:);'])
        eval(['binnedSig',sprintf('%02d',n),'=binnedSigToDivide(((n-1)*fold_length+1):(n*fold_length),:);'])
        save(fullfile('pseudoFeatMats',['file',sprintf('%02d',n),'.mat']), ...
            ['featMat',sprintf('%02d',n)],['binnedSig',sprintf('%02d',n)], ...
            'fold_length','divideFactor')
        clear(['featMat',sprintf('%02d',n)],['binnedSig',sprintf('%02d',n)])
        fprintf(1,'file %02d\n',n);
    end, clear n binnedSigToDivide featMatToDivide
    
    % now, we're operating from the psuedo featMats and binnedSigs
    MATfiles=dir('pseudoFeatMats'); MATfiles(1:2)=[];
    MATfiles={MATfiles.name}';
    % we need to re-run the first part of the loop, to get the H matrices
    for l=1:length(MATfiles)
        fprintf(1,'\nre-calculating H matrix for %s.\n',MATfiles{l});
        if exist('H_SingleUnits_div.mat','file')
            if ~exist('H_SingleUnits_div','var')
                load('H_SingleUnits_div.mat')
            end
            if ~isempty(intersect(MATfiles(l),HbankDiv))
                continue
            end
        end
        S=load(fullfile('pseudoFeatMats',MATfiles{l}));
        varNames=fieldnames(S);
        featMat=S.(varNames{cellfun(@isempty,regexp(varNames,'featMat.*'))==0});
        binnedSig=S.(varNames{cellfun(@isempty,regexp(varNames,'binnedSig.*'))==0});
        fptimes=rowBoat((1:size(binnedSig,1))*binsize);
        % substitute featMat for fp, binnedSig for sig, and generate time
        % vectors.        
        H = [];
        P = [];
        numberOfFps=size(featMat,2);
        
        % Run Prediction Code
        [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,bestf{l},bestc{l},H,bestfeat,x,...
            y,featMat,ytnew,xtnew,predtbase,~] =... %,sr]...
            MRSpredictionsSingleUnitfromfp6all([fptimes, binnedSig],signalType, ...
            numberOfFps,binsize,folds,numlags,numsides,...
            20,featMat,fptimes,fptimes,MATfiles{l},windowsize,nfeat,PolynomialOrder,...
            Use_Thresh,H,[],emgsamplerate,lambda,0,featind,0,featMat);                %#ok<*ASGLU>
        
        H_SingleUnits_div(:,l,m) = H';                                          %#ok<*AGROW>
        if ~exist('H_SingleUnits_div.mat','file')
            HbankDiv{1}=MATfiles{l};
        else
            HbankDiv{l}=MATfiles{l};
        end
        save('H_SingleUnits_div.mat','H_SingleUnits_div','HbankDiv','bestf','bestc','featind')
        clear v* y* x* r* bdf out_struct sig numfp samprate fp ...
            fptimes analog_times fnam words featMat* sig_* 
    end    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Test single feature decoders on test set %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numFilesToTest=6;
    if exist('resumeFromPartial','var')==1 && resumeFromPartial==1
        % only fully filled-out columns are of any use to us
        load([mfilename,'_interstitial.mat'],'vaf_X_SingleUnits', ...
            'vaf_Y_SingleUnits','r2_X_SingleUnits','r2_Y_SingleUnits');
        fC=find(sum(squeeze(cellfun(@isempty,vaf_X_SingleUnits(m,:,:))==0),1) < ...
            size(vaf_X_SingleUnits,2),1,'first');
        vaf_X_SingleUnits=cat(3,vaf_X_SingleUnits(:,:,1:(fC-1)), ...
            cell(size(vaf_X_SingleUnits,1),size(vaf_X_SingleUnits,2),numel(fC:numFilesToTest)));
        vaf_Y_SingleUnits=cat(3,vaf_Y_SingleUnits(:,:,1:(fC-1)), ...
            cell(size(vaf_Y_SingleUnits,1),size(vaf_Y_SingleUnits,2),numel(fC:numFilesToTest)));
        r2_X_SingleUnits=cat(3,r2_X_SingleUnits(:,:,1:(fC-1)), ...
            cell(size(r2_X_SingleUnits,1),size(r2_X_SingleUnits,2),numel(fC:numFilesToTest)));
        r2_Y_SingleUnits=cat(3,r2_Y_SingleUnits(:,:,1:(fC-1)), ...
            cell(size(r2_Y_SingleUnits,1),size(r2_Y_SingleUnits,2),numel(fC:numFilesToTest)));
        kSpan=(length(MATfiles)-numFilesToTest+fC-1):(length(MATfiles)-1);
        fprintf(1,'Resuming from file %d of %d\n',fC,numFilesToTest);
    else
        fC = 1;
        kSpan=length(MATfiles)-numFilesToTest:length(MATfiles)-1;
    end
    for k=kSpan
        for q=1:length(MATfiles);
            if q==1
                try
                    varName=['featMat',regexp(MATfiles{k},'[0-9]+(?=\.mat)','match','once')];
                    varName2=['binnedSig',regexp(MATfiles{k},'[0-9]+(?=\.mat)','match','once')];
                    load(fullfile('pseudoFeatMats',MATfiles{k}),varName,varName2)
                    featMat=eval(varName); clear(varName)
                    sig{k}=eval(varName2); clear(varName2)
                catch exception
                    continue
                end
            end
            fprintf(1,'\ntesting %s on %s...\n',MATfiles{q},MATfiles{k})

            H = [];
            P = [];
            numfp=96; fp=[]; fptimes=[]; fnam=''; samprate=1000;
            fptimes=rowBoat((1:size(featMat,1))*binsize);
            
            [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,~,~,H,bestfeat,x,...
                y,featMat,ytnew,xtnew,predtbase,P,~] =... %,sr]...
                MRSpredictionsSingleUnitfromfp6all([fptimes, sig{k}],signalType,numfp,binsize, ...
                folds,numlags,numsides,samprate,fp,fptimes,fptimes,fnam,windowsize, ...
                nfeat,PolynomialOrder,Use_Thresh,H_SingleUnits_div(:,q),[],... % <- Empty words for BC, pass in for HC
                emgsamplerate,lambda,0,featind,0,featMat);
            
            clear fp numfp analog_times fptimes
            
            vaf_X_SingleUnits{m,q,fC} = squeeze(vaf(:,1,:));
            vaf_Y_SingleUnits{m,q,fC} = squeeze(vaf(:,2,:));
            
            r2_X_SingleUnits{m,q,fC} = squeeze(r2(:,1,:));
            r2_Y_SingleUnits{m,q,fC} = squeeze(r2(:,2,:));
            KQ=[k q];
            save([mfilename,'_interstitial.mat'],'vaf_X_SingleUnits', ...
                'vaf_Y_SingleUnits','r2_X_SingleUnits', ...
                'r2_Y_SingleUnits','featind','KQ');
        end        
        fC = fC+1;
    end
end
