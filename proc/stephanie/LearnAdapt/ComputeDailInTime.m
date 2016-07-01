function [T2Tfirst T2Tlast DialIn] = ComputeTaskTimeMetrics(out_struct)

%========================= Function Description ==========================%
% This function returns a struct, DailInTime:
% Struct structure -----------------------------------------------------
%                Target#: [DailInTime] for Target #
%     Time2TargetSummary: [DailInTime mean for Target # ... DailInTimeFull_mean]
%        Time2TargetFull: [DailInTime TargetNumber] 
%=========================================================================%
% Trialtable Format
%    1: Start time
%  2-5: Target              -- ULx ULy LRx LRy
%    6: Outer target (OT) 'on' time
%    7: Go cue
%    8: Trial End time
%    9: Trial result        -- R, A, I, or F 
%   10: Target ID           -- Target ID (based on location)
%=========================================================================%
[out_struct Goodtrialtable xCenter yCenter GoCueIndex EndTrialIndex] = Initializations(out_struct)

% =============== Has the cursor entered the target? ======================

trialtable = GetFixTrialTable(out_struct,'learnadapt');
% Get the time bin for the Go Cue (GoCueIndex)
for N = 1:length(trialtable(:,1))
        timediff = abs(out_struct.pos(:,1) - trialtable(N,7));
        GoCueIndex(N,1) = max(find(timediff == min(timediff)));
        timediff = abs(out_struct.pos(:,1) - trialtable(N,8));
        EndTrialIndex(N,1) = max(find(timediff == min(timediff)));
end

for i = 1:length(trialtable(:,1));% Loop through the good trials
    
    % Get target side size
    sideX = trialtable(i,4)-trialtable(i,2);
    sideY = trialtable(i,3)-trialtable(i,5);
    % Get lower left target coordinates
    LLx = trialtable(i,2); LLy = trialtable(i,5);    
    % Look through the time stamps for a single trial
    SingleTrialPositionsX = out_struct.pos(GoCueIndex(i):EndTrialIndex(i),2);
    SingleTrialPositionsY = out_struct.pos(GoCueIndex(i):EndTrialIndex(i),3);
    indices = find(out_struct.pos(GoCueIndex(i):EndTrialIndex(i),1))';
    
    % Find when cursor is in the target
    TargetContact = SingleTrialPositionsX <= (LLx+sideX) & SingleTrialPositionsX >= LLx & SingleTrialPositionsY <= (LLy+sideY) & SingleTrialPositionsY >= LLy;
    NumTargetEntries(i,1) = length(find(diff(TargetContact)==1));
    SingleTrial 
 GoCueIndex(i)+find(diff(TargetContact)==1)
end







end


 % Loop backwards from the end of the trial
%     for A = length(SingleTrialPositionsX):-1:1
%         % When was the last time the cursor was outside of the target?
%         if (SingleTrialPositionsX(A) < Goodtrialtable(N,2) || SingleTrialPositionsX(A) > Goodtrialtable(N,4)) || (SingleTrialPositionsY(A) < Goodtrialtable(N,5) || SingleTrialPositionsY(A) > Goodtrialtable(N,3))
%             LastTargetContact(N,1) = A;
%             break
%         end
%     end