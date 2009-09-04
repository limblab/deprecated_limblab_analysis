function [filter, varargout]=BuildModel(binnedData, dataPath, fillen, UseAllInputsOption, PolynomialOrder)
%    [filter, varargout] = BuildModel(binnedData, dataPath, UseAllInputsOption, xvalidate_flag)
%
%       filter: structure of filter data (neuronIDs,H,P,emgguide,fillen,binsize)
%       varargout = {PredData, xval_R2}
%           [PredData]      : structure with EMG prediction data (fit)
%           [xval_R2]       : result of the multifold cross-validation
%       binnedData          : data structure to build model from
%       dataPath            : string of the path of the data folder
%       UseAllInputsOption  : 1 to use all inputs, 2 to specify a neuronID file
%       PolynomialOrder     : order of the Weiner non-linearity

    addpath ..\mimo\
   
    if ~isstruct(binnedData)
        binnedData = LoadDataStruct(binnedData, 'binned');
    end

    binsize = binnedData.timeframe(2)-binnedData.timeframe(1);
    
    if nargout > 3
        disp('Wrong number of output arguments');
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

%    if isfield(binnedData,'timeframeave')
%        Inputs = binnedData.spikerateave(:,desiredInputs);
%        Outputs = binnedData.emgavebin;
%    else
       Inputs = binnedData.spikeratedata(:,desiredInputs);
       Outputs=binnedData.emgdatabin;
%    end

    %%%The following calculates the linear filters (H) that relate the inputs and outputs
    [H,v,mcc]=filMIMO3(Inputs,Outputs,numlags,numsides,1);
    
%% Then, find polynomial and % ***evaluate the model***
                    %% don't evaluate model in this version

    %%Predict EMGs
    fs=1; numsides=1;
    
    [PredictedEMGs,spikeDataNew,ActualEMGsNew]=predMIMO3(Inputs,H,numsides,fs,Outputs);

    %%%Find a Wiener Cascade Nonlinearity
    for z=1:size(PredictedEMGs,2)
        [P(z,:)] = WienerNonlinearity(PredictedEMGs(:,z), ActualEMGsNew(:,z), PolynomialOrder);
        %[P(z,:)] = WienerNonlinearity([detrend(Y(:,z),'constant')+mean(Yact(:,z))], [detrend(Yact(:,z),'constant')+mean(Yact(:,z))], PolynomialOrder, 'plot');
    end

  
%% Outputs

    filter = struct('neuronIDs', neuronIDs, 'H', H, 'P', P, 'emgguide', binnedData.emgguide,'fillen',fillen, 'binsize', binsize);

    if nargout > 1
               
        PredData = struct('predemgbin', PredictedEMGs, 'timeframe',binnedData.timeframe(numlags:end),'spikeratedata',spikeDataNew,'emgguide',binnedData.emgguide,'spikeguide',binnedData.spikeguide);
        
        varargout(1) = {PredData};
    end
    
    if nargout > 2
        varargout(2) = {xval_R2};
    end
    
end


