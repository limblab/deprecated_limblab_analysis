function [filter, varargout]=BuildModel(binnedData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, varargin)
%    [filter, varargout] = BuildModel(binnedData, dataPath, UseAllInputsOption, xvalidate_flag)
%
%       filter: structure of filter data (neuronIDs,H,P,emgguide,fillen,binsize)
%       varargout = {PredData}
%           [PredData]      : structure with EMG prediction data (fit)
%       binnedData          : data structure to build model from
%       dataPath            : string of the path of the data folder
%       UseAllInputsOption  : 1 to use all inputs, 2 to specify a neuronID file
%       PolynomialOrder     : order of the Weiner non-linearity (0=no Polynomial)
%       varargin = {PredEMG, PredForce, PredCursPos,Use_Thresh} : flags to include EMG, Force, Cursor Position and Thresholding in the prediction model (0=no,1=yes)

   addpath ..\mimo\
   
    if ~isstruct(binnedData)
        binnedData = LoadDataStruct(binnedData, 'binned');
    end

    binsize = binnedData.timeframe(2)-binnedData.timeframe(1);
    
    if nargout > 2
        disp('Wrong number of output arguments');
        return;
    end    
    
    % default value for prediction flags
    PredEMG = 1;
    PredForce = 0;
    PredCursPos = 0;
    Use_Thresh = 0;
    
    %overwrite if specified in arguments
    if nargin > 5
        PredEMG = varargin{1};
        if nargin > 6
            PredForce = varargin{2};
            if nargin > 7
                PredCursPos = varargin{3};
                if nargin > 8
                    Use_Thresh = varargin{4};
                end
            end
        end
    end
    
    if ~(PredEMG || PredForce || PredCursPos)
        disp('No Outputs are Selected, Model Building Cancelled');
        return;
    end
    
    %%%Need to be able to find which column(s) is the requested input(s) and only
    %%%use those to build the models.
    %%
    %%%Default is to use all the available inputs, otherwise ask for a list of
    %%%the ones you want to use.
    %%
    %%%desiredInputs are the columns in the firing rate matrix that are to be
    %%%used as inputs for the models  
    
    numberinputs=size(binnedData.spikeguide,1);
    neuronChannels=zeros(numberinputs,2);
    for k=1:numberinputs
        temp=deblank(binnedData.spikeguide(k,:));
        I = findstr(temp, 'u');
        neuronChannels(k,1)=str2double(temp(1,3:(I-1)));
        neuronChannels(k,2)=str2double(temp(1,(I+1):size(temp,2)));
        clear temp I
    end
    
    if  UseAllInputsOption
%        disp('Using all available inputs')
        neuronIDs=neuronChannels;
        desiredInputs=1:numberinputs;
     else
        [FileName, PathName] =uigetfile([dataPath '\NeuronIDfiles\' '*.mat'],'Filename of desired inputs? ');
        [neuronIDs] = loadneuronIDs([PathName FileName]);
        numberinputs=size(neuronIDs,1);
        for k=1:numberinputs
            temp=neuronIDs(k,:);
            spot=find((neuronChannels(:,1)==temp(1,1)) & (neuronChannels(:,2)==temp(1,2)));
            desiredInputs(1,k)=spot;
            clear temp spot
        end
    end


%% Calculate the filter

    numlags= round(fillen/binsize); %%%Designate the length of the filters/number of time lags
        %% round helps getting rid of floating point error but care should
        %% be taken in making sure fillen is a multiple of binsize.
    numsides=1;     %%%For a one-sided or causal filter

    Inputs = binnedData.spikeratedata(:,desiredInputs);
    
    %Uncomment next line to use EMG as inputs for predictions
%     Inputs = binnedData.emgdatabin;
   
    Outputs = [];
    OutNames = [];
    
    if PredEMG
       Outputs= [Outputs binnedData.emgdatabin];
       OutNames = [OutNames binnedData.emgguide];
    end
    if PredForce
        Outputs = [Outputs binnedData.forcedatabin];
        OutNames = [OutNames; binnedData.forcelabels];
    end
    if PredCursPos
        Outputs = [Outputs binnedData.cursorposbin];
        OutNames = [OutNames;  binnedData.cursorposlabels];
    end
        
    %%%The following calculates the linear filters (H) that relate the inputs and outputs
    [H,v,mcc]=filMIMO3(Inputs,Outputs,numlags,numsides,1);
    
%% Then, add non-linearity

    fs=1; numsides=1;
    
    [PredictedData,spikeDataNew,ActualDataNew]=predMIMO3(Inputs,H,numsides,fs,Outputs);

    P=[];    
    T=[];
    patch = [];
    
    if PolynomialOrder
        %%%Find a Wiener Cascade Nonlinearity
        for z=1:size(PredictedData,2)
            if Use_Thresh            
                %Find Threshold
                T_default = 1.25*std(PredictedData(:,z));
                [T(z,1), T(z,2), patch(z)] = findThresh(ActualDataNew(:,z),PredictedData(:,z),T_default);
                IncludedDataPoints = or(PredictedData(:,z)>=T(z,2),PredictedData(:,z)<=T(z,1));

                %Apply Threshold to linear predictions and Actual Data
                PredictedData_Thresh = PredictedData(IncludedDataPoints,z);
                ActualData_Thresh = ActualDataNew(IncludedDataPoints,z);

                %Replace thresholded data with patches consisting of 1/3 of the data to find the polynomial 
                Pred_patches = [ (patch(z)+(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ...
                                 (patch(z)-(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ];
                Act_patches = mean(ActualDataNew(~IncludedDataPoints,z)) * ones(1,length(Pred_patches));

                %Find Polynomial to Thresholded Data
                [P(z,:)] = WienerNonlinearity([PredictedData_Thresh; Pred_patches'], [ActualData_Thresh; Act_patches'], PolynomialOrder,'plot');
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%% Use only one of the following 2 lines:
                %
                %   1-Use the threshold only to find polynomial, but not in the model data
%                 T=[]; patch=[];                
                %
                %   2-Use the threshold both for the polynomial and to replace low predictions by the predefined value
                PredictedData(~IncludedDataPoints,z)= patch(z);
                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                %Find and apply polynomial
                [P(z,:)] = WienerNonlinearity(PredictedData(:,z), ActualDataNew(:,z), PolynomialOrder,'plot');
            end
            PredictedData(:,z) = polyval(P(z,:),PredictedData(:,z));
        end
    end
  
%% Outputs

    filter = struct('neuronIDs', neuronIDs, 'H', H, 'P', P, 'T',T,'patch',patch,'outnames', OutNames,'fillen',fillen, 'binsize', binsize);

    if nargout > 1
               
        PredData = struct('preddatabin', PredictedData, 'timeframe',binnedData.timeframe(numlags:end),'spikeratedata',spikeDataNew,'outnames',OutNames,'spikeguide',binnedData.spikeguide);
        
        varargout(1) = {PredData};
    end
    
    
end

function [Tinf, Tsup, patch] = findThresh(ActualData,LinPred,T)

    thresholding = 1;
    h = figure;
    xT = [0 length(LinPred)];
    offset = mean(LinPred)-mean(ActualData);
    LinPred = LinPred-offset;
    Tsup=mean(LinPred)+T;
    Tinf=mean(LinPred)-T;
    patch = mean(ActualData);
    
        while thresholding
            hold off; axis('auto');
            plot(ActualData,'b');
            hold on;
            plot(LinPred,'r');
            plot(xT,[Tsup Tsup],'k--',xT,[Tinf Tinf],'k--');
            legend('Actual Data', 'Linear Fit','Threshold');
            axis('manual');
            reply = input(sprintf('Redefine High Threshold? [%g] : ',Tsup));
            if ~isempty(reply)
                Tsup = reply;
            else
                thresholding=0;
            end
        end
        thresholding=1;
        while thresholding
            axis('auto');
            hold off;
            plot(ActualData,'b');
            hold on;
            plot(LinPred,'r');
            plot(xT,[Tsup Tsup],'k--',xT,[Tinf Tinf],'k--');
            legend('Actual Data', 'Linear Fit','Threshold');
            axis('manual');
            reply = input(sprintf('Redefine Low Threshold? [%g] : ',Tinf));
            if ~isempty(reply)
                Tinf = reply;
            else
                thresholding=0;
            end
        end
        thresholding=1;
        while thresholding
            axis('auto');
            hold off;
            plot(ActualData,'b');
            hold on;
            plot(LinPred,'r');
            plot(xT,[Tsup Tsup],'k--',xT,[Tinf Tinf],'k--', xT,[patch patch],'g');
            legend('Actual Data', 'Linear Fit','Threshold');
            axis('manual');
            reply = input(sprintf('Redefine Threshold Value? [%g] : ',patch));
            if ~isempty(reply)
                patch = reply;
            else
                thresholding=0;
            end
        end
        Tsup = Tsup+offset;
        Tinf = Tinf+offset;
        patch = patch+offset;
        
    close(h);
end
