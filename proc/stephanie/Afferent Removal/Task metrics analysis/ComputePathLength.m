function PathLengthStruct = ComputePathLength(out_struct)

%========================= Function Description ==========================%
% This function returns a struct, ComputerPathLengthStruct:
% Struct structure -----------------------------------------------------
%                Target#: [PathLength] for Target #
%      PathLengthSummary: [PathLength mean for Target # ... PathLengthFull_mean]
%         PathLengthFull: [PathLength TargetNumber] 
% -----------------------------------------------------------------------

%======================== Initializations ================================%
% Initializations 
[out_struct Goodtrialtable xCenter yCenter GoCueIndex EndTrialIndex] = Initializations(out_struct);
% Get LastTargetContact
[LastTargetContact] = CursorInTargetCheck(out_struct, Goodtrialtable, xCenter, yCenter, GoCueIndex, EndTrialIndex);
%=========================================================================%

% ===================== Calculate Path Length =============================
% Initialize PathLength array
PathLength = ones(length(Goodtrialtable),1);
% Loop through the successful trials
for N = 1:length(Goodtrialtable)
    % Isolate X and Y positions for a single trial
    SingleTrialPositionsX = out_struct.pos(GoCueIndex(1,N):10:GoCueIndex(1,N)+LastTargetContact(1,N),2);
    SingleTrialPositionsY = out_struct.pos(GoCueIndex(1,N):10:GoCueIndex(1,N)+LastTargetContact(1,N),3);
    % Get the difference in position between timestamps for X and Y
    DeltaX =(diff(SingleTrialPositionsX)); DeltaY = (diff(SingleTrialPositionsY));
    % Compute the distance moved in each timestep
    Edist = ones(length(DeltaX),1);
    for M = 1:length(DeltaX)
        Edist(M) = sqrt(DeltaX(M)^2+DeltaY(M)^2); %Pythagorean theorem
        PathLength(N) = sum(Edist);  % Sum all the distances for path length
    end    
end

% Concatenate PathLength to the targets
PathLengthFull = cat(2,PathLength,(Goodtrialtable(:,10)));
%=========================================================================%


% ======================= Put data in a struct ===========================%
% Get trial table so you know what all the possible targets are
trialtable = wf_trial_table(out_struct);
% Get the maximum number of targets
NumOfTargets = max(trialtable(:,10));

% Uses a loop to create a struct variable for each target, and put the
% PathLength data for each target in their proper variable
for N=1:NumOfTargets
   PathLengthStruct.(['Target' num2str(N)]) = PathLengthFull(find(PathLengthFull(:,2) == N));
end 

% Loop again to put the average Time2Target data in another summary struct variable
for N =1:NumOfTargets
PathLengthStruct.PathLengthSummary(N,1) = mean(PathLengthStruct.(['Target' num2str(N)])); 
end

% Put your full PathLength data and your summary struct variable in the
% general PathLengthStruct that you return with this function
PathLengthStruct.PathLengthFull = PathLengthFull;
PathLengthStruct.PathLengthSummary(NumOfTargets+1,1) = mean(PathLengthFull(:,1));


end


