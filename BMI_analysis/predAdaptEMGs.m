function [PredictedData,Inputs_new,Hnew] = predAdaptEMGs(BinnedData,Inputs,H,Adapt)
%
% [PredictedData,Inputs_new,Hnew] = predAdaptEMGs(BinnedData,Inputs,H,Adapt)
%
%   This function makes EMG predictions based on the neural activity provided
%       in "Inputs", according to the decoder weights provided in "H". It also
%       changes the weigths in "H" according to the adaptation rules provided
%       in "Adapt"
%
% Predicted Data    : The predicted EMG data
% Inputs_new        : Same as Inputs, but truncated at the beginning by the filter lenght
% Hnew
%
% Adapt =  This is a structure with Adaptation parameters.
% Adapt.LR          : learning rate Typically ~ 1e-7
% Adapt.EMGpatterns : provides the expected EMG values from which to measure prediction
%                   errors. This is an array of size (numTargets+1) x numEMGs, the first
%                   row provides the EMG estimate during rest state (touch pad or center)
%                   and each following rows contain the expected EMG values in each muscle
%                   for each target
% Adapt.Lag         : This is the number of bin before each "Reward" or "Go Cue" over which
%                   we want to compare our predictions with the expected EMG values.
% Adapt.Period      : This is the number of error measurements we make before attempting to
%                   modify the weights in H. i.e. Adaptation takes place every "Adapt.Period"
%                   rows of "ExpectedOutputs"
%
% -----------------------------------------------------------------------------------------

% multiplying then dividing by 1000 because of occasional floating point error that leads to
% calculating binsize of e.g. 0.0499999s instead of 0.05s
binsize = round(1000*(BinnedData.timeframe(2)-BinnedData.timeframe(1)))/1000;

% How many bins should we look back to measure error:
Lag_bins =  round(Adapt.Lag/(BinnedData.timeframe(2)-BinnedData.timeframe(1)));

% Find times at which error detection should occur.
%  Adapt_ts : is an array of size (num_ts x numEMGs+1), containing all the valid "Reward"
%             and "Go" time stamp in the first column, and the corresponding expected
%             EMG values for each muscles in the columns 2:end
% Adapt_ts = get_expected_EMGs_MG(BinnedData.trialtable,Adapt.EMGpatterns);
Adapt_ts = get_expected_EMGs_WF(BinnedData.trialtable,Adapt.EMGpatterns);

%convert first column of Adapt_ts to bins
Adapt_bins = [ceil((Adapt_ts(:,1)-BinnedData.timeframe(1))/binsize) Adapt_ts(:,2:end)];
%remove first adapt step if too early
Adapt_bins = Adapt_bins(Adapt_bins(:,1)>Lag_bins,:);

%Predict data
[PredictedData,Inputs_new,Hnew] = predMIMOadapt10(Inputs,Adapt_bins,H,Adapt);
% [PredictedData,Inputs_new,Hnew] = predMIMOadapt9(Inputs,H,Adapt.LR,Adapt_bins,Lag_bins);

end