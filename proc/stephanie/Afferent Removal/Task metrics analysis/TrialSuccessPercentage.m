function PerSuccessfulTrials = TrialSuccessPercentage(out_struct)

trialtable = wf_trial_table(out_struct);
NumSuccesses = 0;
NumTrials = length(trialtable);
for N = 1:NumTrials
    if trialtable(N, 9) == 82;
        NumSuccesses = NumSuccesses + 1;
    end
end

PerSuccessfulTrials = NumSuccesses/NumTrials;
end

% Put data in a struct
%IsoTaskMetrics.PercentofSuccessfulTrials = PerSuccessfulTrials;