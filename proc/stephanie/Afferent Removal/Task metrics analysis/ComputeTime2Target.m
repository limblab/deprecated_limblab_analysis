function Time2TargetStruct = ComputeTime2Target(out_struct)

%========================= Function Description ==========================%
% This function returns a struct, Time2TargetStruct:
% Struct structure -----------------------------------------------------
%                Target#: [Time2Trial] for Target #
%     Time2TargetSummary: [Time2Trial mean for Target # ... Time2TargetFull_mean]
%        Time2TargetFull: [Time2Trial TargetNumber] 
%=========================================================================%

%======================== Initializations ================================%
% Initializations 
[out_struct Goodtrialtable xCenter yCenter GoCueIndex EndTrialIndex] = Initializations(out_struct);
% Get LastTargetContact
[LastTargetContact] = CursorInTargetCheck(out_struct, Goodtrialtable, xCenter, yCenter, GoCueIndex, EndTrialIndex);
%=========================================================================%

% ======================Calculate Time to Target ==========================

% Take LastTargetHold - go cue time
Time2Target =  LastTargetContact'*0.001;
% Concatenate Time2Target array to the target number array
Time2TargetFull = cat(2,Time2Target,(Goodtrialtable(:,10)));
%=========================================================================%


% ======================= Put data in a struct ===========================%
% Get trial table so you know what all the possible targets are
trialtable = wf_trial_table(out_struct);
% Get the maximum number of targets
NumOfTargets = max(trialtable(:,10));

% Uses a loop to create a struct variable for each target, and put the
% Time2Target data for each target in their proper variable
for N=1:NumOfTargets
    Time2TargetStruct.(['Target' num2str(N)]) = Time2TargetFull(find(Time2TargetFull(:,2) == N));
end 

% Loop again to put the average Time2Target data in another summary struct variable
for N =1:NumOfTargets
Time2TargetStruct.Time2TargetSummary(N,1) = mean(Time2TargetStruct.(['Target' num2str(N)])); 
end

% Put your full Time2Target data and your summary struct variable in the
% general Time2TargetStruct that you return with this function
Time2TargetStruct.Time2TargetFull = Time2TargetFull;
Time2TargetStruct.Time2TargetSummary(NumOfTargets+1,1) = mean(Time2TargetFull(:,1));


end
