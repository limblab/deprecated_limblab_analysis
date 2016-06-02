function [filter, varargout]=train_reg(binnedData,dataPath, fillen, UseAllInputsOption, PolynomialOrder, varargin)
%    [filter, varargout] = BuildModel(binnedData, dataPath, UseAllInputsOption, xvalidate_flag)
%
%       filter: structure of filter data (neuronIDs,H,P,emgguide,fillen,binsize)
%       varargout = {PredData}
%           [PredData]      : structure with EMG prediction data (fit)
%       binnedData          : data structure to build model from
%       dataPath            : string of the path of the data folder
%       fillen              : filter length (in seconds)
%       UseAllInputsOption  : 1 to use all inputs, 0 to specify a neuronID file, or a NeuronIDs array
%       PolynomialOrder     : order of the Weiner non-linearity (0=no Polynomial)
%       varargin = {PredEMG, PredForce, PredCursPos,PredVeloc,numPCs}
%                           :   flags to include EMG, Force, Cursor Position
%                               and Velocity in the prediction model
%                               (0=no,1=yes), if numPCs is present, will
%                               use numPCs components as inputs instead of
%                               spikeratedata
%
   
    if ~isstruct(binnedData)
        binnedData = LoadDataStruct(binnedData);
    end

    binsize = double(binnedData.timeframe(2)-binnedData.timeframe(1));
    
    if nargout > 2
        disp('Wrong number of output arguments');
        return;
    end    
    
    % default values for prediction flags
    PredEMG      = 1;
    PredForce    = 0;
    PredCursPos  = 0;
    PredVeloc    = 0;
    Use_EMGs     = 0;
    Use_Reg      = 0;

    
    %overwrite if specified in arguments
    if nargin > 5
        PredEMG = varargin{1};
        if nargin > 6
            PredForce = varargin{2};
            if nargin > 7
                PredCursPos = varargin{3};
                if nargin > 8
                    PredVeloc = varargin{4};
                    if nargin > 9
                        Use_EMGs =varargin{5};
                        if nargin >10
                            lambda = varargin{6};
                        end
                    end
                end
            end
        end
    end
    
    if ~(PredEMG || PredForce || PredCursPos || PredVeloc)
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
    if size(UseAllInputsOption,1)>1
        NeuronIDs = UseAllInputsOption;
        desiredInputs = get_desired_inputs(binnedData.spikeguide, neuronIDs);
    elseif UseAllInputsOption
%        disp('Using all available inputs')
        neuronIDs=spikeguide2neuronIDs(binnedData.spikeguide);
        desiredInputs=1:size(neuronIDs,1);
    else
        if ~exist('NeuronIDsFile','var')
            [FileName, PathName] =uigetfile([dataPath '\NeuronIDfiles\' '*.mat'],'Filename of desired inputs? ');
            NeuronIDsFile = [PathName FileName];
        end
        neuronIDs = load(NeuronIDsFile);
        field_name = fieldnames(neuronIDs);
        neuronIDs = getfield(neuronIDs, field_name{:});
        desiredInputs = get_desired_inputs(binnedData.spikeguide, neuronIDs);
    end
    if isempty(desiredInputs)
        disp('Incompatible Data; Model Building Aborted');
        filter = [];
        if nargout > 1
            varargout(1) = {[]};
        end
        return;
    end


%% Calculate the filter

    numlags= round(fillen/binsize);%Designate the length of the filters/number of time lags
                                   % round helps getting rid of floating point error but care should
                                   % be taken in making sure fillen is a multiple of binsize.
    

    %Select decoder inputs:
    if Use_EMGs
        Inputs = binnedData.emgdatabin;
        input_type = 'EMG';
    else
        Inputs = binnedData.spikeratedata(:,desiredInputs);
        input_type = 'spike';
    end

%     Inputs = DuplicateAndShift(binnedData.spikeratedata(:,desiredInputs),numlags); numlags = 1;
           
    Outputs = [];
    OutNames = [];
    
    %Decoder Outputs:
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
    if PredVeloc
        Outputs = [Outputs binnedData.velocbin];
        OutNames = [OutNames;  binnedData.veloclabels];
    end 
    numOutputs = size(Outputs,2);
        
    InputMean = mean(Inputs);
    OutputMean= mean(Outputs);
    Inputs = detrend(Inputs,'constant');
    Outputs= detrend(Outputs,'constant');        
    %The following calculates the linear filters (H) that relate the inputs and outputs
   
    if nargin >10
        H=filter_reg(Inputs,Outputs,numlags,lambda);
    else
        H=filter_reg(Inputs,Outputs,numlags);        
    end
    
%     H = MIMOCE1(Inputs,Outputs,numlags);\
%     H = Inputs\Outputs;
%     Inputs = DuplicateAndShift(Inputs,numlags); numlags = 1;

    
%% Then, add non-linearity if applicable

    fs=1; numsides=1;
    
    [PredictedData,spikeDataNew,ActualDataNew]=predMIMO3(Inputs,H,numsides,fs,Outputs);
    

% %     PredictedData = Inputs*H;
% %     LP = 5; %10 Hz low pass...
% %     PredictedData = FiltPred(PredictedData,1/binsize,LP);
% %     ActualDataNew = Outputs;
% %     spikeDataNew = binnedData.spikeratedata(numlags:end,:);
    
    P=[];    
    T=[];
    patch = [];
    
    if PolynomialOrder
        %%%Find a Wiener Cascade Nonlinearity
        for z=1:size(PredictedData,2)
            %Find and apply polynomial
            [P(:,z)] = WienerNonlinearity(PredictedData(:,z), ActualDataNew(:,z), PolynomialOrder);        
            PredictedData(:,z) = polyval(P(:,z),PredictedData(:,z));
        end
    end
    
%% Add back the Output mean
for i=1:numOutputs
    PredictedData(:,i) = PredictedData(:,i)+OutputMean(i);
end  
    
%% Outputs

    filter = struct('neuronIDs', neuronIDs,...
                    'input_mean',InputMean,...
                    'output_mean', OutputMean,...
                    'H', H,...
                    'P', P,...
                    'T',T,...
                    'patch',patch,...
                    'outnames', OutNames,...
                    'fillen',fillen,...
                    'binsize', binsize,...
                    'input_type',input_type);
    
   if nargout > 1
         PredData = struct('preddatabin', PredictedData, 'timeframe', ...
			 binnedData.timeframe(numlags:end),'spikeratedata',spikeDataNew, ...
			 'outnames',OutNames,'spikeguide',binnedData.spikeguide, ...
			 'vaf',RcoeffDet(PredictedData,ActualDataNew),'actualData',ActualDataNew);
% %          PredData = struct('preddatabin', PredictedData, 'timeframe',binnedData.timeframe,'outnames',OutNames,'spikeguide',binnedData.spikeguide);
        varargout{1} = PredData;
    end
    
end