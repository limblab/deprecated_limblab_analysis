%runpredfp6 
%Uses MRSpredictionsfromfp6allDecoderBuild
input = 1;
Usefeatmat = 1;
%Use 1 if loading files from folder structure, use 2 if using list of
%filenames and obtaining path from citadel

%Usefeatmat = 1 if loading featMat for decoding

%% Implement file i/o strategy

if input == 1 % Remember to clear featind if building decoders on diff feat
    % Need proper folder structure if using input = 1
    
    direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Mini';
    %Set directory to desired directory
    cd(direct);

    Days=dir(direct);
    Days(1:2)=[];
    DaysNames={Days.name};
    
elseif input == 2
    % Need to start out with list of file names if using input =2
    %DaysNames = [{kinStructOut.name}' {kinStructOut.decoder_age}'];
    DaysNames = [BDFlist_all mat2cell(DecoderAges(:),repmat(1,length(BDFlist_all),1),1)];
    %DaysNames = DaysNames(cellfun(@isnan,{kinStructOut.decoder_age})==0,:);
    direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Mini';
    
end

for i = 1%:length(DaysNames)]
    if input == 1
%         DayName = [direct,'\',DaysNames{i},'\'];
%         cd(DayName);
% 
%         %Get mat file names and create decoder
%         Files=dir(DayName);
%         FileNames={Files.name};
        MATfiles = DaysNames;
%         MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'_Spike_LFP.*(?<!poly.*)\.mat'))==0);
%         if isempty(MATfiles)
%             fprintf(1,'no MAT files found.  Make sure no files have ''only'' in the filename\n.')
%             disp('quitting...')
%             return
%         end
%     
    else
        MATfiles = 1;
        DecoderAge = DaysNames{i,2};
    end

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
    for l=1:length(MATfiles)
        
        if input == 1
            fnam = MATfiles{l}
            fname=[direct,'\',DaysNames{i},'\',fnam];
            load(fnam);
        
        elseif input == 2
            fnam =  findBDFonCitadel(DaysNames{i})
            try
                load(fnam)
            catch exception
                continue
            end
            
        end
        %% Declare input variables within loop that vary in each loop iteration:
        
        if exist('out_struct','var')
            bdf = out_struct;
            clear out_struct
        end
        
        if Usefeatmat == 0
        [sig, samplerate, words, fp, numberOfFps, adfreq, fp_start_time, fp_stop_time,...
            fptimes, analog_time_base] = SetPredictionsInputVar(bdf);
        
        % Began to write code to input featMat than decided it wouldn't be
        % worth the effort (for now at least).
        elseif Usefeatmat == 1 
            if exist('featindBEST','var')
                featMat = featMat(:,featindBEST(1:nfeat))';
            end           
            sig = y;
            adfreq = 2000;
            samplerate = 2000;
            fp = []; 
            numberOfFps = 94;
            fp_start_time = [];
            fp_stop_time = [];
            fptimes = []; 
            analog_time_base = [];
        end
        
        %% If building a decoder offline and using it to decode subsequent 
        %files, automatically load file and select best H from first file
        if l == 2 && Usefeatmat == 0
            Firstfilename = [sname,'tik6 velpred ',num2str(nfeat),' feats lambda',...
               num2str(lambda),'poly',num2str(PolynomialOrder),' ',num2str(numlags),...
               'lags','causal','.mat'];
            [Hbest, r2best, featindBEST, Pbest] = BESTdecoderLoad(Firstfilename,direct,Usefeatmat);
            
        elseif  l == 1 && Usefeatmat == 1
            Firstfilename = MATfiles{l}
            [Hbest, r2best, featindBEST, Pbest] = BESTdecoderLoad(Firstfilename,direct,Usefeatmat);
            clear bestc bestf featind H P
            continue
         end
        
        %% Create directory for decoder outputs
        if input == 1 && l == 1
        mkdir('Decoders')
        sname=[direct,'\','Decoders','\',fnam];
        
        elseif input == 1 && l ~= 1
        sname=[direct,'\','Decoders','\',fnam];
        
        elseif input == 2
        sname=[direct,'\',DaysNames{i}];
        end
        
        %% Determine which type of decoding is being done
        
        if exist('Hbest','var') && exist('featindBEST','var')
            % Use if inputting a decoder, also don't 'clear' H in loop
            H = Hbest; 
            featind = featindBEST;
            P = Pbest;
            disp('Warning: A decoder already exists and is being input for predictions')
            
        elseif exist('featindBEST','var') && ~exist('Hbest','var')
            % If not inputting H matrix but using the same features to
            % build decoder (pseudo decoder case)
            H = []; 
            P = [];
            featind = featindBEST;
            nfeat = length(featind);
            disp('Warning: featureind already exists or was not cleared in loop')
            
        else
            % If not inputting H matrix, and make sure featind not input to decoder fxn
            H = [];
            featind = [];
            P = [];
        end
        

        
        %% Run Prediction Code
        [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,...
         y,featMat,ytnew,xtnew,predtbase,P,featind] =... %,sr]...
         MRSpredictionsfromfp6all(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,...
         samplerate,fp,fptimes,analog_time_base,fnam,windowsize,nfeat,PolynomialOrder,...
         Use_Thresh,H,words,emgsamplerate,lambda,0,featind,P,featMat);
        
        %% Save output
        %save([sname,'velpred Using LFP Decoder from first HC file.mat'],'v*','y*','x*','r*','best*','H','feat*','P*','Use*','binsize');
        if exist('DecoderAge','var')
            save([sname,'tik6 velpred ',num2str(nfeat),' feats lambda',num2str(lambda),'poly',num2str(PolynomialOrder),' ',num2str(numlags),'lags','causal','.mat'],'v*','y*','x*','r*','best*','H','feat*','P*','Use*','binsize','DecoderAge','predtbase');
        else
            save([sname,'tik6 velpred ',num2str(nfeat),' feats lambda',num2str(lambda),'poly',num2str(PolynomialOrder),' ',num2str(numlags),'lags','causal','.mat'],'v*','y*','x*','r*','best*','H','feat*','P*','Use*','binsize','predtbase');
        end
        clear v* y* x* r* best* bdf out_struct featind... 
              sig numberOfFps samplerate fp fptimes analog_time_base fnam words 
        
        clear H featind P 
        
        %clear Hbest featindBEST Pbest if building decoders on different
        % features/decoders
          
        close all

    end
    
    clear featind H 
    %if using decoder from online LFP control/building pseudo decoders 
                                 
    %clear Hbest & featindBEST & Pbest if building decoders on different
    % features/decoders
    
    clear sig signalType numberOfFps binsize folds numlags...
        numsides samplerate fp fptimes analog_time_base fnam windowsize nfeat...        
        PolynomialOrder Use_Thresh words emgsamplerate lambda
                                                                            
    
    direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Mini';
    %Set directory to desired directory
if input == 1
    cd(direct);

    Days=dir(direct);
    Days(1:2)=[];
    DaysNames={Days.name};
end
end