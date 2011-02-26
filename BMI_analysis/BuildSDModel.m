function [Models] = BuildSDModel(binnedData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, varargin)
% Outputs:
%       1.Models                : a structure (or a cell array of structures) containing the computed model(s)
%                               (neuronIDs,H,P,emgguide,fillen,binsize,etc.
% Inputs:
%       1.binnedData          : data structure to build model from
%       2.fillen              : Filter length, in seconds
%       3.dataPath            : string of the path of the data folder
%       4.UseAllInputsOption  : 1 to use all inputs, 0 to specify a neuronID file, or a NeuronIDs array
%       5.PolynomialOrder     : order of the Weiner non-linearity (0=no Polynomial)
%       6-11 varargin :
%          6.PredEMG, 7.PredForce,8.PredCursPos,9.PredVeloc
%                         : flags to include EMG, Force, Cursor Position
%                           and Thresholding in the prediction model (0=no,1=yes).
%          10.Use_State   : if non-zero, the function will return as many models as there are
%                           different classification in binnedData.states(:,Use_State). Use_State
%                           is both a flag to enable multiple decoders and an index 
%                           to select the classification method.
%          11. numPCs     : if non-zero, it uses N = numPCs principal components as inputs instead of
%                           the spike rate of all the units
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
    Use_State    = 0;
    numPCs       = 0;
    if isfield(binnedData,'PC')
        PCoeffs = binnedData.PC;
    else
        PCoeffs      = [];
    end
    
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
                        Use_State = varargin{5};
                        if nargin > 10
                            numPCs = varargin{6};
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
    
%%  Inputs
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

%% Setup Inputs/Outputs

    numlags= round(fillen/binsize); %%%Designate the length of the filters/number of time lags
        %% round helps getting rid of floating point error but care should
        %% be taken in making sure fillen is a multiple of binsize.
    numsides=1;     %%%For a one-sided or causal filter

    % Duplicate and shift neural channels so we don't have to look in the past with the linear filter.
    Inputs = DuplicateAndShift(binnedData.spikeratedata(:,desiredInputs),numlags);
    numlags = 1;
    
    %Uncomment next line to use EMG as inputs for predictions
%     Inputs = binnedData.emgdatabin;

    if numPCs > 0
%         [PCoeffs,Inputs] = princomp(zscore(Inputs));
%         Inputs = Inputs(:,1:numPCs);
        Inputs = Inputs*binnedData.PC(:,1:numPCs);
    end
        
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
    if PredVeloc
        Outputs = [Outputs binnedData.velocbin];
        OutNames = [OutNames;  binnedData.veloclabels];
    end    
    
    if Use_State
        numStates = 1+range(binnedData.states(:,Use_State));
        Models = cell(1,numStates);
    else
        numStates = 1;
    end
   
for state = 1:numStates
    
    if Use_State
    %     Ins = DS_spikes(state-1==binnedData.states(:,state),:);
        Ins = Inputs (state-1==binnedData.states(:,Use_State),:);
        Outs= Outputs(state-1==binnedData.states(:,Use_State),:);
    else
        Ins = Inputs;
        Outs= Outputs;
    end
        
%% Calculate a model for each state

%     disp('building model using left divide...');
%     tic;
%     Ins = detrend(Ins, 'constant'); Outs=detrend(Outs, 'constant');
%     H = Ins\Outs;
%     toc;
     
%     disp('building model using filMIMO3...');
%     tic;
    [H,v,mcc]=filMIMO3(Ins,Outs,numlags,numsides,1);    
%     toc;

    
%% Add non-linearity if applicable    
     
    [PredictedData,spikeDataNew,ActualDataNew]=predMIMO3(Ins,H,numsides,1,Outs);
%     PredictedData = Ins*H;
%     ActualDataNew = Outs;
    P=[];    

    if PolynomialOrder
        %%%Find a Wiener Cascade Nonlinearity
        for z=1:size(PredictedData,2)
            %Find and apply polynomial
            [P(z,:)] = WienerNonlinearity(PredictedData(:,z), ActualDataNew(:,z), PolynomialOrder);
            PredictedData(:,z) = polyval(P(z,:),PredictedData(:,z));
        end
    end
%% Outputs
    filter = struct('neuronIDs', neuronIDs, 'H', H, 'P', P,'outnames', OutNames,'fillen',fillen, 'binsize', binsize,'PC',PCoeffs);
    if Use_State
        Models{state} = filter;
    else
        Models = filter;
    end
end

end
%% Thresholding function:
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
