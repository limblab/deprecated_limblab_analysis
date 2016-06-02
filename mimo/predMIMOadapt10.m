function  [Pred_Out, Inputs_new, H_new]= predMIMOadapt10(Inputs, ExpectedOutput, H, Adapt)
%
%   predMIMOadapt8 calculates predictions and modifies the filter H based
%     on a learning rate (LR) by comparing signals prediction with their
%     expected values.
%
%   argout: Pred_Out   : the predictions made with this adaptive algorithm
%           Inputs_new : same as Inputs, but truncated at the beginning for
%
%   Inputs : neural activity for the whole file to analyse size:[Numbins x NumUnits]
%
%   H: Original decoder weights size: [(NumUnits*Numlags) x NumOutputs]
%
%   LR: Learning Rate (typically ~ 1e-7)
%
%   ExpectedOutput = [bin out1 out2 ... outN]
%       The first column is the bin number (not timestamp) of either GO_Cue or
%       End_Trial, or any time around which we can evaluate prediction
%       errors, and make decoder adaptation. The remaining columns contain
%       the expected output values for this period of time.
%     
%   Adapt =  This is a structure with Adaptation parameters.
%   Adapt.LR          : learning rate Typically ~ 1e-7
%   Adapt.EMGpatterns : provides the expected EMG values from which to measure prediction
%                       errors. This is an array of size (numTargets+1) x numEMGs, the first
%                       row provides the EMG estimate during rest state (touch pad or center)
%                       and each following rows contain the expected EMG values in each muscle
%                       for each target
%   Adapt.Lag         : This is the number of bin before each "Reward" or "Go Cue" over which
%                       we want to compare our predictions with the expected EMG values.
%   Adapt.Period      : This is the number of error measurements we make before attempting to
%                       modify the weights in H. i.e. Adaptation takes place every "Adapt.Period"
%                       rows of "ExpectedOutputs"
%
% ----------------------------------------------------------------------------------------------


[numpts,Nin]=size(Inputs);
[nr,Nout]=size(H);
numlags=nr/Nin;

%Allocate memory for the outputs
Pred_Out=zeros(numpts,Nout);
H_new = H;
Inputs_new = Inputs(numlags:numpts,:);

% Beginning of the Adaptation Period
startSeg = 1;

% variable to store Inputs and Error signals over adaptation windows
ErrSeg   = zeros(Adapt.Lag*Adapt.Period,Nout);
InputSeg = zeros(Adapt.Lag*Adapt.Period,nr );

numAdapt = floor(size(ExpectedOutput,1)/Adapt.Period);

for i = 1:numAdapt

    %End of data segment for adaptation
    endSeg = ExpectedOutput(i*Adapt.Period,1);
    
    %Duplicate and shift just for this segment *but include spikedata numlag bins before
    %so we don't loose filter lenght information max(1,startSeg-numlag+1) should accomplish
    % that while ensuring we do not look before beginning of data
    numSegPts = length(max(1,startSeg-numlags+1):endSeg);
    Input_tmp = DuplicateAndShift(Inputs(max(1,startSeg-numlags+1):endSeg,:),numlags);
    % now we can remove these extra bins at the beginning
    extraBins = numSegPts-(endSeg-startSeg+1);
    Input_tmp = Input_tmp(extraBins+1:end,:);
    
    %Calculate predictions for new segment of data
    Pred_Out(startSeg:endSeg,:) = predMIMOCE1(Input_tmp,H_new,numlags);
    
    %Calculate error signals for this segment
    for AdaptBin = 1:Adapt.Period
        
        %index in Expected Output:
        bin_idx = (i-1)*Adapt.Period+AdaptBin;
        
        %indexes for error and input signals for this segment
        IdxStart = (AdaptBin-1)*Adapt.Lag+1;
        IdxEnd   = IdxStart + Adapt.Lag -1 ;

        %measure prediction error over an window of length
        % Adapt.Lag before bins in ExpectedOutput(:,1)
        AdaptEnd      = ExpectedOutput(bin_idx,1);
        AdaptStart    = AdaptEnd - (Adapt.Lag-1);
        
        ErrSeg(IdxStart:IdxEnd,:)   = repmat(ExpectedOutput(bin_idx,2:end),Adapt.Lag,1)...
                                             - Pred_Out(AdaptStart:AdaptEnd,:);

        % store corresponding inputs to calculate dH later
        % indexes are different because we use only a segment of Inputs at a time
        % (because of memory issues)
        AdaptEnd   = AdaptEnd   - (startSeg-1);
        AdaptStart = AdaptStart - (startSeg-1);
        InputSeg(IdxStart:IdxEnd,:) = Input_tmp(AdaptStart:AdaptEnd,:);

    end
    
    %update H according to error measurement
    dH = Adapt.LR*ErrSeg'*InputSeg;
    H_new = H_new + dH';

%     %redo predictions with corrected H - correct as you go:
%     Pred_Out(startSeg:endSeg,:) = predMIMOCE1(Input_tmp,H_new,numlags);

    %initialize for next segment
    startSeg=endSeg+1;
end

%Complete the predictions after last Adaptation:
if numpts > endSeg
    Pred_Out(startSeg:end,:) = predMIMOCE1(Inputs(startSeg:end,:),H_new,numlags);
end

% clip beginning of predictions because they are garbage
% (wrong Inputs history at very beginning before numlags)
Pred_Out=Pred_Out(numlags:numpts,:);

end