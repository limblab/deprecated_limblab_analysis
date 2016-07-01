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

    numlags= 1; %round(fillen/binsize); %%%Designate the length of the filters/number of time lags
        %% round helps getting rid of floating point error but care should
        %% be taken in making sure fillen is a multiple of binsize.
    numsides=1;     %%%For a one-sided or causal filter

    Inputs = binnedData.spikeratedata(:,desiredInputs);

    Outputs = [];
    OutNames = [];
    

        Outputs = [Outputs binnedData.cursorposbin];
        OutNames = [OutNames;  binnedData.cursorposlabels];
condition_desired = 10^3;
         Outputs = double(Outputs);
         Inputs = double(Inputs);
    %%%The following calculates the linear filters (H) that relate the inputs and outputs
%     Inputs = DuplicateAndShift(Inputs,numlags); numlags = 1;
% %     H = Inputs\Outputs; 
  % [H,v,mcc]=filMIMO3(Inputs,Outputs,numlags,numsides,1);
  model = train_ridge(Inputs, Outputs, condition_desired);
%     H = MIMOCE1(Inputs,Outputs,numlags);