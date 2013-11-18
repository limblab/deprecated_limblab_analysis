%runpredfp6
%Uses MRSpredictionsSingleUnitfromfp6all

Batchinput = 2;
%Need proper folder structure if using Batchinput = 1
%Need to start out with list of file names if usingBatchinput =2

Usefeatmat = 0;
%Usefeatmat = 1 if loading featMat for decoding

Monkeys = [{MiniLFP2fileNames}];

direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Mini';
%Set directory to desired directory
cd(direct);

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

%H_SingleUnits = cell([150,171,2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Begin building Single Feature Decoders %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for m = 1%:length(Monkeys) 1 == Chewie, 2 == Mini
    
    featindBEST = Onlinefeatind(:,m);
    
    %     if Batchinput == 1 % Remember to clear featind if building decoders on diff feat
    %
    %
    %         direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Chewie';
    %         Set directory to desired directory
    %         cd(direct);
    %
    %         Days=dir(direct);
    %         Days(1:2)=[];
    %         DaysNames={Days.name};
    %
    %         MATfiles = DaysNames;
    %
    %     elseif Batchinput == 2
    %         %
    %         %         DaysNames = [{kinStructOut.name}'
    %         %         {kinStructOut.decoder_age}'];
    DaysNames = Monkeys{m};
    MATfiles = DaysNames;
    %         %         DaysNames = DaysNames(cellfun(@isnan,{kinStructOut.decoder_age})==0,:); % %
    %         %         direct = 'C:\Documents andSettings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Chewie';
    %
    %     end
    %
    %     %% Begin iterating through files
    %
    %     for l=1%:length(MATfiles)
    %         if Batchinput == 1
    %             fnam = MATfiles{l}
    %             sname=[direct,'\','Decoders','\',fnam];
    %             load(fnam);
    %
    %         elseif Batchinput == 2
    %             fnam =  findBDFonCitadel(DaysNames{l})
    %             sname=[direct,'\',DaysNames{l}];
    %             try
    %                 load(fnam)
    %             catch exception
    %                 continue
    %             end
    %
    %         end
    %
    %         if exist('out_struct','var')
    %             bdf = out_struct;
    %             clear out_struct
    %         end
    %
    %         if Usefeatmat == 0
    %             try
    %                 [sig, samplerate, words, fp, numberOfFps, adfreq, fp_start_time, fp_stop_time,...
    %                     fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
    %             catch exception
    %                 continue
    %             end
    %         elseif Usefeatmat == 1
    %             if exist('featindBEST','var')
    %                 featMat = featMat(:,featindBEST(1:nfeat))';
    %             end
    %             sig = y;
    %             adfreq = 2000;
    %             samplerate = 2000;
    %             fp = [];
    %             numberOfFps = 94;
    %             fp_start_time = [];
    %             fp_stop_time = [];
    %             fptimes = [];
    %             analog_time_base = [];
    %         end
    %
    %         %% Create directory for decoder outputs
    %         if Batchinput == 1 && l == 1
    %             mkdir('Decoders')
    %             sname=[direct,'\','Decoders','\',fnam];
    %
    %         elseif Batchinput == 1 && l ~= 1
    %             sname=[direct,'\','Decoders','\',fnam];
    %
    %         elseif Batchinput == 2
    %             sname=[direct,'\',DaysNames{l}];
    %         end
    %
    %         %% Determine which type of decoding is being done
    %
    %         if exist('Hbest','var') && exist('featindBEST','var')
    %             % Use if inputting a decoder, also don't 'clear' H in loop
    %             H = Hbest;
    %             featind = featindBEST;
    %             P = Pbest;
    %             disp('Warning: A decoder already exists and is being Batchinput for predictions')
    %
    %         elseif exist('featindBEST','var') && ~exist('Hbest','var')
    %             % If not inputting H matrix but using the same features to
    %             % build decoder (pseudo decoder case)
    %             H = [];
    %             P = [];
    %             featind = featindBEST;
    %             nfeat = length(featind);
    %             disp('Warning: featureind already exists or was not cleared in loop')
    %
    %         else
    %             % If not Batchinputting H matrix, and make sure featind is not input to decoder fxn
    %             H = [];
    %             featind = [];
    %             P = [];
    %         end
    %
    %         %% Run Prediction Code
    %         [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,...
    %             y,featMat,ytnew,xtnew,predtbase,~,featind] =... %,sr]...
    %             MRSpredictionsSingleUnitfromfp6all(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
    %             samplerate,fp,fptimes,analog_time_base,fnam,windowsize,nfeat,PolynomialOrder,...
    %             Use_Thresh,H,words,emgsamplerate,lambda,0,featind,P,[]);
    %
    %         H_SingleUnits(:,l,m) = H';
    %         %P_SingleUnits{l} = P;
    %
    %         %% Save output
    %         save([sname,'tik6 velpred ',num2str(nfeat),' feats lambda',num2str(lambda),'poly',num2str(PolynomialOrder),' ',num2str(numlags),'lags','causal','.mat'],'v*','y*','x*','r*','best*','H','feat*','P*','Use*','binsize','predtbase');
    %
    %         clear v* y* x* r* best* bdf out_struct featind...
    %             sig numberOfFps samplerate fp fptimes analog_time_base fnam words
    %
    %         clear H featind P
    %         %clear Hbest featindBEST Pbest if building decoders on different
    %         % features/decoders
    %         close all
    %
    %     end
    %
    %     clear featind H
    %     %if using decoder from online LFP control/building pseudo decoders
    %
    %     %clear Hbest & featindBEST & Pbest if building decoders on different
    %     %features/decoders
    %
    %     clear sig fp fptimes analog_time_base fnam words
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Test single feature decoders on test set %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     fnam =  findBDFonCitadel(MATfiles{end})
    %     sname=[direct,'\',DaysNames{length(MATfiles)}];
    %     load(fnam)
    fC = 1;
    for k = length(MATfiles)-6:length(MATfiles)-1
        
        fnam =  findBDFonCitadel(MATfiles{k})
        sname=[direct,'\',DaysNames{length(MATfiles)}];
        try
            load(fnam)
        catch exception
            continue
        end
        
        featMat = [];
        
        if exist('out_struct','var')
            bdf = out_struct;
            clear out_struct
        end
        
        [sig, samplerate,words, fp, numberOfFps, adfreq, fp_start_time, fp_stop_time,...
            fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
        
        
        for q = 1:length(MATfiles)
            
            H = [];
            P = [];
            featind = featindBEST;
            nfeat = length(featind);
            
            %***MRS 6/20/13 - There is a bug somewhere in the predictions code when inputting 
            %the featMat, don't do this until the bug is worked out
            
            [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,...
                y,featMat,ytnew,xtnew,predtbase,P,~] =... %,sr]...
                MRSpredictionsSingleUnitfromfp6all(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
                samplerate,fp,fptimes,analog_time_base,fnam,windowsize,nfeat,PolynomialOrder,...
                Use_Thresh,H_SingleUnits(:,q,1),[]...<- Empty words for BC, pass in for HC 
                ,emgsamplerate,lambda,0,featind,0,[]);
            
            close all
            
            vaf_X_SingleUnits{m,q,fC} = squeeze(vaf(:,1,:));
            vaf_Y_SingleUnits{m,q,fC} = squeeze(vaf(:,2,:));
            
            r2_X_SingleUnits{m,q,fC} = squeeze(r2(:,1,:));
            r2_Y_SingleUnits{m,q,fC} = squeeze(r2(:,2,:));
            
            
            save('SingleChLFP_LFP_BC_Decoder2_Mini_LastSixFilesTest_Output.mat','vaf*','r2*','featind*','H_SingleUnits');
        end
        
        fC = fC+1;
    end
end



%% Plot code

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