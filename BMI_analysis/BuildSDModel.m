function [Models] = BuildSDModel(binnedData, options)
% argout
%       1.Models                : a structure (or a cell array of structures) containing the computed model(s)
%                               (neuronIDs,H,P,emgguide,fillen,binsize,etc.
% Argin
%        options             : structure with fields:
%           fillen              : filter length in seconds (tipically 0.5)
%           UseAllInputs        : 1 to use all inputs, 0 to specify a neuronID file, or a NeuronIDs array
%           PolynomialOrder     : order of the Weiner non-linearity (0=no Polynomial)
%           PredEMG, PredForce, PredCursPos, PredVeloc, numPCs :
%                               flags to include EMG, Force, Cursor Position
%                               and Velocity in the prediction model
%                               (0=no,1=yes), if numPCs is present, will
%                               use numPCs components as inputs instead of
%                               spikeratedata
%           Use_Thresh,Use_EMGs,Use_Ridge:
%                               options to fit only data above a certain
%                               threshold, use EMGs as inputs instead of
%                               spikes, or use a ridge regression to fit model
%           plotflag            : plot predictions after xval
%
%       Note on options: not every possible fields have to be present in
%       the option structure
%       
%% Argument handling
   
    if ~isstruct(binnedData)
        binnedData = LoadDataStruct(binnedData);
    end

    binsize = double(binnedData.timeframe(2)-binnedData.timeframe(1));
    
    % default values for options:
    default_options = ModelBuildingDefault();
    % fill other options as provided
    all_option_names = fieldnames(default_options);
    for i=1:numel(all_option_names)
        if ~isfield(options,all_option_names(i))
            options.(all_option_names{i}) = default_options.(all_option_names{i});
        end
    end
    
    if ~(options.PredEMGs || options.PredForce || options.PredCursPos || options.PredVeloc)
        disp('No Outputs are Selected, Model Building Cancelled');
        filter = [];
        varargout = {};
        return;
    end


%%  Inputs
%%%Need to be able to find which column(s) is the requested input(s) and only
%%%use those to build the models.
%%
%%%Default is to use all the available inputs, otherwise ask for a list of
%%%the ones you want to use.
%%
%%%desiredInputs are the columns in the firing rate matrix that are to be
%%%used as inputs for the models  
if size(options.UseAllInputs,1)>1
    NeuronIDs = options.UseAllInputs;
    desiredInputs = get_desired_inputs(binnedData.spikeguide, neuronIDs);
elseif options.UseAllInputs
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
    Models ={};
    return;
end

%% Setup Inputs/Outputs

numlags= round(options.fillen/binsize); %%%Designate the length of the filters/number of time lags
    % round helps getting rid of floating point error but care should
    % be taken in making sure fillen is a multiple of binsize.
numsides=1;     %%%For a one-sided or causal filter

% Duplicate and shift neural channels so we don't have to look in the past with the linear filter.
Inputs = DuplicateAndShift(binnedData.spikeratedata(:,desiredInputs),numlags);
numlags = 1;

%Uncomment next line to use EMG as inputs for predictions
%     Inputs = binnedData.emgdatabin;

if options.numPCs > 0
    [PCoeffs,Inputs] = princomp(zscore(Inputs));
    Inputs = Inputs(:,1:numPCs);
    Inputs = Inputs*binnedData.PC(:,1:options.numPCs);
else
    PCoeffs = [];
end

Outputs = [];
OutNames = [];

if options.PredEMGs
    Outputs= [Outputs binnedData.emgdatabin];
    OutNames = [OutNames binnedData.emgguide];
end
if options.PredForce
    Outputs = [Outputs binnedData.forcedatabin];
    OutNames = [OutNames; binnedData.forcelabels];
end
if options.PredCursPos
    Outputs = [Outputs binnedData.cursorposbin];
    OutNames = [OutNames;  binnedData.cursorposlabels];
end
if options.PredVeloc
    Outputs = [Outputs binnedData.velocbin];
    OutNames = [OutNames;  binnedData.veloclabels];
end    

%% 1- Calculate Fixed Linear Decoder:
% disp('calculating general decoder');
% [H,v,mcc]=filMIMO4(Inputs,Outputs,numlags,numsides,1);
% 
% % Add non-linearity if applicable    
% [PredictedData,spikeDataNew,ActualDataNew]=predMIMO4(Inputs,H,numsides,1,Outputs);
% if options.PolynomialOrder
%     numouts = size(PredictedData,2);
%     P = zeros(options.PolynomialOrder+1,numouts);
%     %%%Find a Wiener Cascade Nonlinearity
%     for z=1:size(PredictedData,2)
%         %Find and apply polynomial
%         [P(:,z)] = WienerNonlinearity(PredictedData(:,z), ActualDataNew(:,z), options.PolynomialOrder);
%         PredictedData(:,z) = polyval(P(:,z),PredictedData(:,z));
%     end
% else
%     P=[];
% end
% 
% 
% general_decoder = struct('neuronIDs', neuronIDs, 'H', H, 'P', P,'outnames', OutNames,'fillen',options.fillen, 'binsize', binsize,'PC',PCoeffs);
% Models{1} = general_decoder;

%% Now calculate a model for each State:
if options.Use_SD
    
    numStates = 1+range(binnedData.states(:,options.Use_SD));
    for state = 1:numStates

%         Ins = DS_spikes(state-1==binnedData.states(:,state),:);
        Ins = Inputs (state-1==binnedData.states(:,options.Use_SD),:);
        Outs= Outputs(state-1==binnedData.states(:,options.Use_SD),:);

        if isempty(Ins) || isempty(Outs)
            continue;
        end

        %% Calculate a model for each state
        %     Ins = detrend(Ins, 'constant'); Outs=detrend(Outs, 'constant');
        %     H = Ins\Outs;
        %     toc;
        fprintf('Calculating model for state %d\n',state-1);
        [H,v,mcc]=filMIMO4(Ins,Outs,numlags,numsides,1);

        %% Add non-linearity if applicable    
        [PredictedData,spikeDataNew,ActualDataNew]=predMIMO4(Ins,H,numsides,1,Outs);
    %     PredictedData = Ins*H;
    %     ActualDataNew = Outs;
        if options.PolynomialOrder
            numouts = size(PredictedData,2);
            P = zeros(options.PolynomialOrder+1,numouts);
            %%%Find a Wiener Cascade Nonlinearity
            for z=1:size(PredictedData,2)
                %Find and apply polynomial
                [P(:,z)] = WienerNonlinearity(PredictedData(:,z), ActualDataNew(:,z), options.PolynomialOrder);
                PredictedData(:,z) = polyval(P(:,z),PredictedData(:,z));
            end
        else
            P=[];
        end
        
        Models{state} = struct('neuronIDs', neuronIDs, 'H', H, 'P', P,'outnames', OutNames,'fillen',options.fillen, 'binsize', binsize,'PC',PCoeffs);
    end
end