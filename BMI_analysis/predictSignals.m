function [PredData, varargout] = predictSignals(varargin)

filter       = varargin{1};
BinnedData   = varargin{2};
if nargin    >= 3
    FiltPred = varargin{3};
    Adapt_Enable = false;
    if nargin > 3
        Adapt_Enable = varargin{4};
        LR = varargin{5};
        Adapt_lag = varargin{6};
        if nargin > 6
            numPCs = varargin{7};
        end
    end
else
    FiltPred = false;
    Adapt_Enable = false;
end

if ischar(filter)
    filter = LoadDataStruct(filter,'filter');
end
if ischar(BinnedData)
    BinnedData = LoadDataStruct(BinnedData,'binned');
end

binsize = BinnedData.timeframe(2)-BinnedData.timeframe(1);
numlags = round(filter.fillen/binsize); %round in case of floating point errror

%get usable units from filter info
matchingInputs = FindMatchingNeurons(BinnedData.spikeguide,filter.neuronIDs);

%% Inputs:
%populate spike data for data units matching the filter units
usableSpikeData = zeros(size(BinnedData.spikeratedata,1),size(filter.neuronIDs,1));
usableSpikeData(:,logical(matchingInputs)) = BinnedData.spikeratedata(:,nonzeros(matchingInputs));

% Uncomment next line to use EMGs as model inputs:
%usableSpikeData=BinnedData.emgdatabin;


if isfield(filter, 'PC')
    % use PCs as model inputs
    usableSpikeData = usableSpikeData*filter.PC(:,1:numPCs);
end

%% Outputs:  assign memory with real or dummy data, just cause predMIMO requires something there
% just send dummy data as outputs for the function
ActualData=zeros(size(usableSpikeData));

%% Use the neural filter to predict the Data
numsides=1; fs=1;
if Adapt_Enable
    % only test on Force for now
    ActualData = BinnedData.cursorposbin;
%     ActualData = BinnedData.forcedatabin;
%     ActualData = BinnedData.emgdatabin;
%     LR = 1e-7; %Learning rate
    binsize = round(1000*(BinnedData.timeframe(2)-BinnedData.timeframe(1)))/1000;
    %find bins at which to measure error
%     w = BD_Words;
    
    %use a 500ms window before Adapt_bins to measure force error:
    Lag_bins =  round(Adapt_lag/(BinnedData.timeframe(2)-BinnedData.timeframe(1)))-1;
    

% %     Adapt_ts = BinnedData.words( bitor(BinnedData.words(:,2)==w.Go_Cue,isWord(BinnedData.words,'endtrial')),1);
%     Go_ts  = BinnedData.words(BinnedData.words(:,2)==w.Go_Cue,1);
%     Pos0   = zeros(length(Go_ts),1);
%     Go_ts  = [Go_ts Pos0];
%     EOT_ts = BinnedData.words(isWord(BinnedData.words,'endtrial'),1);
%     EOT_ts = [EOT_ts type1];
% 
%     Adapt_ts = [Go_ts;EOT_ts];
    

     Adapt_ts = get_tgt_center(BinnedData); %includes only trials ending with a reward
%     Adapt_ts = get_tgt_center_EOT(BinnedData); %includes all trials ending with Reward or Failure
    Adapt_bins = [ceil((Adapt_ts(:,1)-BinnedData.timeframe(1))/binsize) Adapt_ts(:,2:end)]; %convert first column of Adapt_ts to bins
    Adapt_bins = Adapt_bins(Adapt_bins(:,1)>Lag_bins,:); %remove first adapt step if too early
    
%     [PredictedData,spikeDataNew,Hnew] = predMIMOadapt8(usableSpikeData,filter.H,LR,Adapt_bins,Lag_bins);    
     [PredictedData,spikeDataNew,Hnew] = predMIMOadapt7b(usableSpikeData,filter.H,LR,Adapt_bins,Lag_bins);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt6(usableSpikeData,filter.H,ActualData,LR,Adapt_bins,Lag_bins);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt5(usableSpikeData,filter.H,ActualData,LR);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt4(usableSpikeData,filter.H,ActualData,LR,Adapt_bins,window);
%     [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt3(usableSpikeData,filter.H,ActualData,LR,Adapt_bins,window);
%    [PredictedData,spikeDataNew,ActualEMGsNew,Hnew] = predMIMOadapt1(usableSpikeData,filter.H,ActualData,LR);
    varargout(1) = {Hnew};
else
    [PredictedData,spikeDataNew,ActualEMGsNew]=predMIMO3(usableSpikeData,filter.H,numsides,fs,ActualData);
%     [PredictedData]=predMIMOCE1(usableSpikeData,filter.H,numlags);
%     PredictedData = PredictedData(numlags:end,:);
    varargout(1) = {filter.H};
end

clear ActualData spikeData;

%% Threshold: apply threshold to predicted data
if isfield(filter, 'T')
if ~isempty(filter.T)
    BetweenThresholds = false(size(PredictedData));
    for z=1:size(PredictedData,2)
            BetweenThresholds(:,z) = and(PredictedData(:,z)>=filter.T(z,1),PredictedData(:,z)<=filter.T(z,2));
            PredictedData(BetweenThresholds(:,z),z)= filter.patch(z);
    end
end 
end
%% If you have one, convolve the predictions with a Wiener cascade polynomial.
if ~isempty(filter.P)
    Ynonlinear=zeros(size(PredictedData));
    for z=1:size(PredictedData,2);
        Ynonlinear(:,z) = polyval(filter.P(z,:),PredictedData(:,z));
    end
    PredictedData=Ynonlinear;
end

%% Smooth EMG Predictions, moving average with variable length based on 1st deriv of ave FR
%% 1 - Binary average lag time
% if FiltPred
%     PredictedData_S = zeros(size(PredictedData));
%     
%     PredRate = round(1/(BinnedData.timeframe(2)-BinnedData.timeframe(1)));
%     Pred_smoothlag_max = int32(0.5*PredRate); % whatever number of bins that makes 500ms
%     Pred_smoothlag_min = 0; %no smoothing.
%     
%     %abs of first derivative of (5-point smoothed) firing rate
%     FR_smoothlag = 5; %5-point moving average
%     AveFR = mean(spikeDataNew,2);
%     AveFR_S = tsmovavg(AveFR','m',FR_smoothlag);
%     AveFR(FR_smoothlag:end) = AveFR_S(FR_smoothlag:end);
%     
%     FR_mod = [ 0; abs(diff(AveFR)) ]; %abs of first derivative
% %    FR_mod = 1-(FR_mod/max(FR_mod));%normalize & inverse
% 
%     threshold = mean(FR_mod)+std(FR_mod);
%     FR_thresh = false(length(FR_mod),1);
%     FR_thresh( FR_mod >= threshold) = true;
% 
%     %now "debounce" threshold signal
%     offset_FR_thresh = [FR_thresh(2:end); false];
%     risingEdge   = find(~FR_thresh &  offset_FR_thresh);
%     clear offset_FR_thresh;
%     minBinDuration = 0.300*PredRate; %300 ms in number of bins (20Hz->6bins)
%     debounced_FR_thresh = false(size(FR_thresh));
%     
%     step =1;    
%     for i = 1:step:length(risingEdge)-minBinDuration
%         if mean(FR_thresh(risingEdge(i):risingEdge(i)+minBinDuration))>0.5
%             %mostly "up" -> debounce up
%             debounced_FR_thresh(risingEdge(i):risingEdge(i)+minBinDuration) = true;
%             step = find(risingEdge(i+1:end)-risingEdge(i)>minBinDuration,1);
%             if ~step
%                 break;
%             end
%         else
%             step = 1;
%         end
%     end     
%     
%     %higher cortical modulation -> shorter moving window for preds
%     FR_EMG_delta = round(0.1*PredRate); %100ms delay (in number of bins) between FR_mod and Preds
%     PredictedData_S(1:FR_EMG_delta) = PredictedData(1:FR_EMG_delta);
%     max_lag = FR_EMG_delta;
%         
%     FR_thresh = debounced_FR_thresh;
%     for i=1+FR_EMG_delta:size(PredictedData,1);
%         smooth_flag = true;
%         if FR_thresh(i-FR_EMG_delta)
%              %cortical activity is changing, don't smooth Preds
%             Pred_smoothlag = Pred_smoothlag_min;
%             if smooth_flag
%                 %we just entered a change in cortical activity
%                 %reset max_lag to 0 so future lag won't include
%                 %predictions older than this point
%                 max_lag = 0;
%                 smooth_flag = false;
%             end
%         else
%             %no much change in cortical activity, smooth preds
%             Pred_smoothlag = Pred_smoothlag_max;
%             smooth_flag = true;
%         end
%         Pred_smoothlag = min(max_lag,Pred_smoothlag); % in case Pred_smoothlag is longer than previous data
%         PredictedData_S(i,:) = mean(PredictedData((i-Pred_smoothlag):i,:),1);
%         max_lag = max_lag+1;
%     end
%     PredictedData = PredictedData_S;
%     clear PredictedData_S;
% end

%% 2- truely variable window length
% if FiltPred
%     PredictedData_S = zeros(size(PredictedData));
%     
%     PredRate = round(1/binsize);
%     Pred_smoothlag_max = round(0.5*PredRate); % whatever number of bins that makes 500ms
%     
%     %abs of first derivative of (5-point smoothed) firing rate
%     FR_smoothlag = 5; %5-point moving average
%     AveFR = mean(spikeDataNew,2);
%     AveFR_S = tsmovavg(AveFR','m',FR_smoothlag);
%     AveFR(FR_smoothlag:end) = AveFR_S(FR_smoothlag:end);
%     
%     FR_mod = [ 0; abs(diff(AveFR)) ]; %abs of first derivative
%     FR_mod = 1-(FR_mod/max(FR_mod));%normalize & inverse
%     %use exponential to weight average window length:
%     % weigth w is set so when FR_mod is average, window = 63%*Pred_smoothlag_max
%     w = log(1-(1/exp(1)))/(mean(FR_mod)-1);
%     mod_index = round(  Pred_smoothlag_max * exp( w * (FR_mod-1))  );
%     
%     %then make sure mod_index do not increase by more than one from one
%     %bin to the next (it can and should decrease as fast as it is though)
%     mod_index_offset = [NaN; mod_index(1:end-1)];
%     steep_rises = mod_index-mod_index_offset > 1;
%     while any(steep_rises)
%         mod_index(steep_rises) = mod_index(find(steep_rises)-1)+1;
%         mod_index_offset = [NaN; mod_index(1:end-1)];
%         steep_rises = mod_index-mod_index_offset > 1;
%     end
%     
%     %higher cortical modulation -> shorter moving window for preds
%     FR_EMG_delta = round(0.1*PredRate); %100ms delay (in number of bins) between FR_mod and Preds
%     PredictedData_S(1:FR_EMG_delta) = PredictedData(1:FR_EMG_delta);
%     
%     for i=1+FR_EMG_delta:size(PredictedData,1);
%         
%         Pred_smoothlag = mod_index(i-FR_EMG_delta);
%         Pred_smoothlag = min(i-1,Pred_smoothlag);        
%         PredictedData_S(i,:) = mean(PredictedData((i-Pred_smoothlag):i,:),1);
%     end
%     PredictedData = PredictedData_S;
%     clear PredictedData_S;
% end
%% 3- Varying a LP filter's time constant
if FiltPred
    
    RC_max = 0.2; % 200ms
    
    %Smooth Firing Rate:
    RC = 0.1; %100 ms
    AveFR = SmoothLP(mean(spikeDataNew,2), binsize, RC);
 
    %abs of first derivative of AveFR
    FR_mod = [ 0; abs(diff(AveFR)) ]; %abs of first derivative
    FR_mod = 1-(FR_mod/max(FR_mod)); %normalize & inverse
    
    %weight exponentially from 0 to RC_max with a sigmoid:
    Top = RC_max;Bottom = 0;V50 = 0.6;Slope = 0.1;
    RC = Bottom + (Top-Bottom)./(1+exp((V50-FR_mod)/Slope));

    %then make sure RC do not increase by more than binsize from one
    %bin to the next (it can and should decrease fast when appropriate though)
    RC_offset = [NaN; RC(1:end-1)];
    steep_rises = RC-RC_offset > binsize;
    max_inc = binsize-0.0001;
    while any(steep_rises)
        RC(steep_rises) = RC(find(steep_rises)-1) + max_inc;
        RC_offset = [NaN; RC(1:end-1)];
        steep_rises = RC-RC_offset > binsize;
    end

    %Smooth Predictions:
    dt = binsize;
    for i=2:size(PredictedData,1)
        a = dt/(RC(i)+dt);
        PredictedData(i,:)= PredictedData(i-1,:) + a*( PredictedData(i,:)-PredictedData(i-1,:) );
    end
end

%% Aggregate Outputs in a Structure

[numpts,Nx]=size(usableSpikeData);
[nr,Ny]=size(filter.H);
fillen=nr/Nx;
timeframeNew = BinnedData.timeframe(fillen:numpts);
spikeDataNew = usableSpikeData(fillen:numpts,:);
%timeframeNew = BinnedData.timeframe(fillen+1:numpts); % to account for additional bin removed at beginning of PredictedEMGs

PredData = struct('timeframe', timeframeNew,...
                  'preddatabin', PredictedData,...
                  'spikeratedata', spikeDataNew,...
                  'outnames',filter.outnames,...
                  'spikeguide', filter.neuronIDs);

end
    