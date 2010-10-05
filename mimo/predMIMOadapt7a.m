function  [Pred_Out, Inputs_new, H_new]= predMIMOadapt7(Inputs,H,LR,Adapt_bins,Adapt_lag)
%
%   predMIMOadapt7 calculates predictions and modifies the filter H based
%     on a learning rate (LR) by comparing signals prediction with their
%     expected values.
%   Adapt_bins is a 2 column array of Bin index around which to modify the
%     weights in H in the first column, and corresponding target x and y position
%     the 2nd and 3rd column Adapt_bins = [Bin_index tgt_x tgt_y];
%   Adapt_lag is the number of bins relative to ts for which to
%     measure the prediction error (e.g. 9 => 500ms before with 50ms bins


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

for Bin = 1:size(Adapt_bins,1)

    endbin = Adapt_bins(Bin,1);

    %Calculate predictions for new segment of data
    Pred_Out(startbin:endbin,:) = predMIMOCE1(Inputs(startbin:endbin,:),H_new,numlags);
    
    %measure prediction error over an window of length Adapt_lag at end of the data segment
    Err = Pred_Out(endbin-Adapt_lag:endbin,:) - repmat(Adapt_bins(Bin,2:end),Adapt_lag+1,1);

    %update H accordingly
    dH = -LR*2*Err'*Inputs(endbin-Adapt_lag:endbin,:);
    H_new = H_new + dH';
    
    %redo predictions with corrected H - correct as you go:
    Pred_Out(startbin:endbin,:) = predMIMOCE1(Inputs(startbin:endbin,:),H_new,numlags);
            
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