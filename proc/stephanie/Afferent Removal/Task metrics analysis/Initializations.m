function [out_struct Goodtrialtable xCenter yCenter GoCueIndex EndTrialIndex] = Initializations(out_struct)



clc; clearvars -except out_struct
trialtable = wf_trial_table(out_struct);
timeframe = out_struct.pos(:,1);
Goodtrialtable = trialtable(trialtable(:,9)==82,:);


% Get the coordinates for the center of the outer target for each trial
for N = 1:length(Goodtrialtable)
        xCenter(N,1) = (Goodtrialtable(N,4)+Goodtrialtable(N,2))/2;
        yCenter(N,1) = (Goodtrialtable(N,5)+Goodtrialtable(N,3))/2;
end


% Get the time bin for the Go Cue (GoCueIndex)
for N = 1:length(Goodtrialtable)
        timediff = abs(timeframe - Goodtrialtable(N,7));
        GoCueIndex(N) = max(find(timediff == min(timediff)));
end

% find the time indices for EndTrial
EndTrialIndex = ones(1,length(Goodtrialtable));
for N = 1:length(Goodtrialtable)
        timediff = abs(timeframe - Goodtrialtable(N,8));
        EndTrialIndex(N) = max(find(timediff == min(timediff)));
end

end
