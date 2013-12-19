function [r2_X_SingleUnits,r2_Y_SingleUnits,H_SingleUnits]=batch_SFDrunpredfp6_saveFeatMat(Monkeys,featind)

dbstop if error

signalType = 'vel';
binsize = .05;                  % we are locked in to this bin size because of BC days
folds = 10;
numlags = 10;
numsides = 1;
windowsize= 256;
nfeat = 150;
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
        catch exception
            continue
        end
        
        fpAssignScript
        if exist('out_struct','var')
            bdf = out_struct;
            clear out_struct
        end
        bdf.vel=removeVelocityArtifacts(bdf.vel);
        sig=bdf.vel;
        H = [];
        P = [];
        numberOfFps=size(fp,1);
        
        % Run Prediction Code
        [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,bestf{l},bestc{l},H,bestfeat,x,...
            y,featMat,ytnew,xtnew,predtbase,~] =... %,sr]...
            MRSpredictionsSingleUnitfromfp6all(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
            samprate,fp,fptimes,sig(:,1),fnam,windowsize,nfeat,PolynomialOrder,...
            Use_Thresh,H,[],emgsamplerate,lambda,0,featind);
        
        H_SingleUnits(:,l,m) = H';                                          %#ok<*AGROW>
        if ~exist('H_SingleUnits.mat','file')
            HbankDays{1}=MATfiles{l};
        else
            HbankDays{l}=MATfiles{l};
        end
        save('H_SingleUnits.mat','H_SingleUnits','HbankDays','bestf','bestc','featind')
        
        clear v* y* x* r* bdf out_struct sig numfp samprate fp ...
            fptimes analog_times fnam words
        close all
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Test single feature decoders on test set %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fC = 1;
    for k = length(MATfiles)-6:length(MATfiles)-1        
        for q = 1:length(MATfiles)
            if q==1                
                try
                    fnam=findBDFonCitadel(MATfiles{k});
                    fprintf(1,'testing on %s...\n',MATfiles{k})
                    load(fnam)
                    bdf{k}=out_struct;
                catch exception
                    continue
                end
            else
                out_struct=bdf{k};
            end
            fpAssignScript
            out_struct.vel=removeVelocityArtifacts(out_struct.vel);
            sig=out_struct.vel;
            H = [];
            P = [];
            
            [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,~,~,H,bestfeat,x,...
                y,featMat,ytnew,xtnew,predtbase,P,~] =... %,sr]...
                MRSpredictionsSingleUnitfromfp6all(sig,signalType,numberOfFps,binsize, ...
                folds,numlags,numsides,samprate,fp,fptimes,sig(:,1),fnam,windowsize, ...
                nfeat,PolynomialOrder,Use_Thresh,H_SingleUnits(:,q),[],... % <- Empty words for BC, pass in for HC
                emgsamplerate,lambda,0,featind,0,[]);
            
            close all, clear fp numfp analog_times fptimes
            
            vaf_X_SingleUnits{m,q,fC} = squeeze(vaf(:,1,:));
            vaf_Y_SingleUnits{m,q,fC} = squeeze(vaf(:,2,:));
            
            r2_X_SingleUnits{m,q,fC} = squeeze(r2(:,1,:));
            r2_Y_SingleUnits{m,q,fC} = squeeze(r2(:,2,:));
            KQ=[k q];
            save([mfilename,'_interstitial.mat'],'vaf_X_SingleUnits', ...
                'vaf_Y_SingleUnits','r2_X_SingleUnits', ...
                'r2_Y_SingleUnits','featind','H_SingleUnits','KQ');
        end        
        fC = fC+1;
    end
end

return
% Plot code

for q = 1%:size(Onlinefeatind,2)
    
    [C,sortInd]=sortrows(Onlinefeatind(:,q));
    featind_bychan = C;
    
    for j = 1:length(featind_bychan)
        bestc_bychan(j,q) = ceil(featind_bychan(j)/6);
        
        if rem(featind_bychan(j),6) ~=0
            bestf_bychan(j,q) = rem(featind_bychan(j),6);
        else
            bestf_bychan(j,q) = 6;
        end
        
    end
end

r2_X_SingleUnitsFirstFile = cell2mat(r2_X_SingleUnits{:,:,1});
r2_X_SingleUnitsFirstFile(isnan(r2_X_SingleUnitsFirstFile)==1) = 0;
%r2_X_SingleUnitsFirstFile = reshape(r2_X_SingleUnitsFirstFile,[150,size(H_SingleUnits,2),size(H_SingleUnits,2)]);
% r2_X_SingleUnitsAvg = mean(r2_X_SingleUnitsFirstFile,3);

r2_Y_SingleUnitsFirstFile = cell2mat(r2_Y_SingleUnits);
r2_Y_SingleUnitsFirstFile(isnan(r2_Y_SingleUnitsFirstFile)==1) = 0;
%r2_Y_SingleUnitsFirstFile = reshape(r2_Y_SingleUnitsFirstFile,[150,size(H_SingleUnits,2),size(H_SingleUnits,2)]);
% r2_Y_SingleUnitsAvg = mean(r2_Y_SingleUnitsFirstFile,3);


r2_X_SingleUnitsFirstFileDec1_HC = [r2_X_SingleUnitsFirstFile bestf_bychan(:,1)];
r2_Y_SingleUnitsFirstFileDec1_HC = [r2_Y_SingleUnitsFirstFile bestf_bychan(:,1)];

r2_X_SingleUnitsFirstFileDec1_HCSorted = sortrows(r2_X_SingleUnitsFirstFileDec1_HC,[size(r2_X_SingleUnitsFirstFileDec1_HC,2) -1]);
r2_Y_SingleUnitsFirstFileDec1_HCSorted = sortrows(r2_Y_SingleUnitsFirstFileDec1_HC,[size(r2_Y_SingleUnitsFirstFileDec1_HC,2) -1]);
imagesc(sqrt(r2_X_SingleUnitsFirstFileDec1_HCSorted(:,1:end-2)));figure(gcf);
title('X Vel Single Feature Dec 1 First File Performance Hand Control-- Chewie')

%imagesc(sqrt(r2_X_SingleUnitsFirstFileDec1_HCSorted(:,First_File_Index(:))));figure(gcf);
% set(gca,'YTick',[1,78,98,123],'YTickLabel',{'LMP','Delta','130-200','200-300'})
% set(gca,'YTick',[1,84,124,126,138],'YTickLabel',{'LMP','Delta','Mu','130-200','200-300'})
% set(gca,'YTick',[1,87,124,128,137],'YTickLabel',{'LMP','Delta','70-110','130-200','200-300'})
% set(gca,'YTick',[1,83,102,131,135,140],'YTickLabel',{'LMP','Delta','Mu','70-110','130-200','200-300'})
% %set(gca,'YTick',[1,33,66,71,92,117],'YTickLabel',{'LMP','Delta','Mu','70-110','130-200','200-300'})
caxis([0 .6])

% set(gca,'YTick',[1,72,121,137],'YTickLabel',{'LMP','Delta','130-200','200-300'})
figure;
%r2_Y_SingleUnitsFirstFileAvgDec1_HCSorted = sortrows(r2_Y_SingleUnitsFirstFileAvgDec1_HC,[length(r2_Y_SingleUnitsFirstFileAvgDec1_HC) -8]);
imagesc(sqrt(r2_Y_SingleUnitsFirstFileDec1_HCSorted(:,1:end-2)));figure(gcf);
%figure;
%imagesc(sqrt(r2_Y_SingleUnitsFirstFileDec1_HCSorted(:,First_File_Index(:))));figure(gcf);
title('Y Vel Single Feature Dec 1 First File Performance Hand Control -- Chewie')
% set(gca,'YTick',[1,72,121,137],'YTickLabel',{'LMP','Delta','130-200','200-300'})
% set(gca,'XTick',[1:4:96],'XTickLabel',{Chewie_LFP1_FirstFileNames{1:4:96,2}})
% %set(gca,'XTick',[1, 50, 100, 150, 200,224],'XTickLabel',{'9-01-2011','12-29-2011', '2-02-2012', '3-28-2012', '5-22-2012','7-23-2012'})
% %set(gca,'YTick',[1,33,66,71,92,117],'YTickLabel',{'LMP','Delta','Mu','70-110','130-200','200-300'})
caxis([0 .6])