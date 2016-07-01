function [LastTargetContact] = CursorInTargetCheck(out_struct, Goodtrialtable, xCenter, yCenter, GoCueIndex, EndTrialIndex)


% =============== Has the cursor entered the target? ======================

NumOfLoops = length(Goodtrialtable(:,1));

for N = 1:NumOfLoops % Loop through the good trials
    
% Look through the time stamps for a single trial
SingleTrialPositionsX = out_struct.pos(GoCueIndex(1,N):EndTrialIndex(1,N),2);
SingleTrialPositionsY = out_struct.pos(GoCueIndex(1,N):EndTrialIndex(1,N),3);
% Loop backwards from the end of the trial
for A = length(SingleTrialPositionsX):-1:1
    % When was the last time the cursor was outside of the target?
    if (SingleTrialPositionsX(A) < Goodtrialtable(N,2) || SingleTrialPositionsX(A) > Goodtrialtable(N,4)) || (SingleTrialPositionsY(A) < Goodtrialtable(N,5) || SingleTrialPositionsY(A) > Goodtrialtable(N,3))
        LastTargetContact(N) = A;
        break
    end
end

end