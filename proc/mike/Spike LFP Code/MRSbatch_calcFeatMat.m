%Script to calculate feature matrices and feature/output corr coef from a file list
%Uses MRScalcFeatMat

%% Implement file i/o strategy

%DaysNames = [{kinStructOut.name}' {kinStructOut.decoder_age}'];
DaysNames = [{Chewie_LFP_BC_Decoder1_filenames} {Mini_LFP_BC_Decoder1_filenames};...
    {Chewie_LFP1_HC_filenames} {Mini_LFP1_HC_filenames};...
    {ChewieSpikeBCFileNames} {MiniSpikeBCFileNames};
    {ChewieLFP2fileNames} {MiniLFP2fileNames};
    {ChewieLFP4fileNames} {MiniLFP4fileNames}];
%DaysNames = DaysNames(cellfun(@isnan,{kinStructOut.decoder_age})==0,:);
maindir = ['C:\Documents and Settings\Administrator\Desktop\Mike_Data\',...
           'Spike LFP Decoding\Working Data'];

for k = 2:size(DaysNames,1)
    
    for i = 2:size(DaysNames,2)
        
        if i == 1
            Monkey = 'Chewie';
        else
            Monkey = 'Mini';
        end
        
        if k == 1
            direct = ['C:\Documents and Settings\Administrator\Desktop\Mike_Data\',...
                      'Spike LFP Decoding\Working Data\Feature Matrices\LFP BC Dec1',...
                      '\',Monkey];
                  
            direct2 = ['C:\Users\M.R.Scheid\Documents\Mike_Data\Spike LFP Decoding\',...
                      'Working Data\Feature Matrices\LFP BC Dec1','\',Monkey];
                  
            cd(direct)
               
        elseif k == 2
            direct = ['C:\Documents and Settings\Administrator\Desktop\Mike_Data\',...
                      'Spike LFP Decoding\Working Data\Feature Matrices\LFP HC Dec1',...
                      '\',Monkey];
                  
            direct2 = ['C:\Users\M.R.Scheid\Documents\Mike_Data\Spike LFP Decoding\',...
                      'Working Data\Feature Matrices\LFP HC Dec1','\',Monkey];
            
            cd(direct)
            
        elseif k == 3
            direct = ['C:\Documents and Settings\Administrator\Desktop\Mike_Data\',...
                      'Spike LFP Decoding\Working Data\Feature Matrices\Spike BC',...
                      '\',Monkey];
                  
            direct2 = ['C:\Users\M.R.Scheid\Documents\Mike_Data\Spike LFP Decoding\',...
                      'Working Data\Feature Matrices\Spike BC','\',Monkey];
  
            cd(direct)
            
        elseif k == 4
            direct = ['C:\Documents and Settings\Administrator\Desktop\Mike_Data\',...
                      'Spike LFP Decoding\Working Data\Feature Matrices\LFP BC Dec2',...
                      '\',Monkey];
                  
            direct2 = ['C:\Users\M.R.Scheid\Documents\Mike_Data\Spike LFP Decoding\',...
                      'Working Data\Feature Matrices\LFP BC Dec2','\',Monkey];
  
            cd(direct)
        
        elseif k == 5
            direct = ['C:\Documents and Settings\Administrator\Desktop\Mike_Data\',...
                      'Spike LFP Decoding\Working Data\Feature Matrices\LFP BC Dec4',...
                      '\',Monkey];
                  
            direct2 = ['C:\Users\M.R.Scheid\Documents\Mike_Data\Spike LFP Decoding\',...
                      'Working Data\Feature Matrices\LFP BC Dec4','\',Monkey];
  
            cd(direct)
        end
                  

        MATfiles = DaysNames{k,i};
        
        %% ***Declare all input arguments that stay constant through all loop
        % iterations outside loop (vars to be declared inside loop are commented out below):
        
        %sig
        signalType = 'vel';
        %numberOfFps
        binsize = .1;
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
        if (i == 2) && (k == 2)
            start = 122;
        else
            start = 1;
        end
        
        for l=start:length(MATfiles)
            
            fnam =  findBDFonCitadel(MATfiles{l,1})
            
            try
                load(fnam)
            catch
                FailedFiles{i,k}(l,:) = fnam;
                continue
            end
            
            
            %% Declare input variables within loop that vary in each loop iteration:
            
            if exist('out_struct','var')
                bdf = out_struct;
                clear out_struct
            end
            
            try
                [sig, samplerate, words, fp, numberOfFps, adfreq, fp_start_time, fp_stop_time,...
                fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
            catch
                FailedFiles{i,k}(l,:) = fnam;
                continue
            end
            

            
            %% Run Prediction Code
            try
            [PB R sortedR sortedFeatInd y] =...
                MRScalcFeatMat(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
                samplerate,fp,fptimes,analog_time_base,fnam,windowsize,nfeat,PolynomialOrder,...
                Use_Thresh,[],words,emgsamplerate,lambda,0,[],[],[],1);
            catch
                FailedFiles{i,k}(l,:) = fnam;
                continue
            end
            
            GOBFilePaths{i,k}(l) = {[direct,'\',MATfiles{l,1}(1:end-4),'FeatMat','.mat']};
            LaptopFilePaths{i,k}(l) = {[direct2,'\',MATfiles{l,1}(1:end-4),'FeatMat','.mat']};
            
            AllCorrCoefs{i,k}{l} = R;
            AllsortedR{i,k}{l}(:,1) = sortedR;
            AllsortedR{i,k}{l}(:,2) = sortedFeatInd;
            
            %% Save output
           
                save([MATfiles{l,1}(1:end-4),'FeatMat','.mat'],'PB');
                
                if exist('FailedFiles','var')
                    save([maindir,'\','FeatMatFilePaths_CorrCoefs'],'GOBFilePaths','LaptopFilePaths','All*','FailedFiles','DaysNames','Chewie*','Mini*');
                else
                    save([maindir,'\','FeatMatFilePaths_CorrCoefs'],'GOBFilePaths','LaptopFilePaths','All*','DaysNames','Chewie*','Mini*');
                end
            
            close all
            
        end
        
        clear sig samplerate words fp numberOfFps adfreq fp_start_time fp_stop_time...
              fptimes analog_time_base bdf
    end
end
