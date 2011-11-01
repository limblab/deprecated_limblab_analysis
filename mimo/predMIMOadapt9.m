function  [Pred_Out, Inputs_new, H_new]= predMIMOadapt9(Inputs,H,LR, ExpectedOutput, Adapt_lag)
%
%   predMIMOadapt8 calculates predictions and modifies the filter H based
%     on a learning rate (LR) by comparing signals prediction with their
%     expected values.
%
%   argout: Pred_Out   : the predictions made with this adaptive algorithm
%           Inputs_new :
%
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
%   Adapt_lag = [numBinsBefore numBinsAfter].
%       This is the number of bins relative to the first column of ExpectedOutput
%       over which to measure the prediction error and processing adaptation.


[numpts,Nin]=size(Inputs);
[nr,Nout]=size(H);
numlags=nr/Nin;

%Allocate memory for the outputs
Pred_Out=zeros(numpts,Nout);
H_new = H;

%Duplicate and shift firing rate to account for time history; each time lag
%is considered as a different input.
%e.g. 10 neurons with 5 time lag = 50 inputs with no time lag
Inputs_new = Inputs(numlags:numpts,:);
Inputs = DuplicateAndShift(Inputs,numlags);

%startbin for inputs
startbin = 1;

for Bin = 1:size(ExpectedOutput,1)

    endbin = ExpectedOutput(Bin,1);

    %Calculate predictions for new segment of data
    Pred_Out(startbin:endbin,:) = predMIMOCE1(Inputs(startbin:endbin,:),H_new,numlags);
    
    %measure prediction error over an window of length Adapt_lag at end of the data segment
    Err = Pred_Out(endbin-Adapt_lag:endbin,:) - repmat(ExpectedOutput(Bin,2:end),Adapt_lag+1,1);

    %update H accordingly
    dH = -LR*2*Err'*Inputs(endbin-Adapt_lag:endbin,:);
    H_new = H_new + dH';
            
    %initialize for next segment
    startbin=endbin+1;
end

%Complete the predictions after last Adapt_bin
if numpts > endbin
    Pred_Out(startbin:end,:) = predMIMOCE1(Inputs(startbin:end,:),H_new,numlags);
end

assignin('base','H_new',H_new);
Pred_Out=Pred_Out(numlags:numpts,:);

end