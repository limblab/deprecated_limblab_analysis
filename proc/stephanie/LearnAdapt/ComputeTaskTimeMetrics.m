function [T2TfirstStruct T2TlastStruct DialInTimeStruct TargetEntriesStruct TrialsStruct] = ComputeTaskTimeMetrics(out_struct)
% [T2TfirstStruct_base T2TlastStruct_base DialInTimeStruct_base TargetEntriesStruct_base TrialsStruct_base] = ComputeTaskTimeMetrics(out_struct_base)
% [T2TfirstStruct_rot T2TlastStruct_rot DialInTimeStruct_rot TargetEntriesStruct_rot TrialsStruct_rot] = ComputeTaskTimeMetrics(out_struct_rot)
% [T2TfirstStruct_ref T2TlastStruct_ref DialInTimeStruct_ref TargetEntriesStruct_ref TrialsStruct_ref] = ComputeTaskTimeMetrics(out_struct_ref)

%========================= Function Description ==========================%
% This function returns several struct with metrics in them
% Struct structure -----------------------------------------------------
%                Target#: [Metric] for Target #
%     Time2TargetSummary: [Metric mean for Target # ... DailInTimeFull_mean]
%        Time2TargetFull: [Metric TargetNumber] 
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

% =============== Has the cursor entered the target? ======================

trialtable = GetFixTrialTable(out_struct,'learnadapt',1);
AllTrialtable = GetFixTrialTable(out_struct,'learnadapt',0);
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
    TimeIndexForTargetEntry = GoCueIndex(i)+find(diff(TargetContact)==1);
    GoCueTime = out_struct.pos(GoCueIndex(i));
    if isempty(TimeIndexForTargetEntry)
        FirstTargetEntry(i) = nan; LastTargetEntry(i) = nan; DialInTime(i) = nan;
        T2Tfirst(i) = nan; T2Tlast(i) = nan;
    else
    FirstTargetEntry = out_struct.pos(TimeIndexForTargetEntry(1));
    LastTargetEntry = out_struct.pos(TimeIndexForTargetEntry(end));
    DialInTime(i,1) = LastTargetEntry-FirstTargetEntry;
    T2Tfirst(i,1) = FirstTargetEntry - GoCueTime;
    T2Tfirst(i,2) = FirstTargetEntry;
    T2Tlast(i,1) = LastTargetEntry - GoCueTime;
    T2Tlast(i,2) = LastTargetEntry;
    
%     SingleTrialPositionsX = out_struct.pos(GoCueIndex(i):10:GoCueIndex(i)+LastTargetContact(i),2);
%     SingleTrialPositionsY = out_struct.pos(GoCueIndex(i):10:GoCueIndex(i)+LastTargetContact(i),3);
%     % Get the difference in position between timestamps for X and Y
%     DeltaX =(diff(SingleTrialPositionsX)); DeltaY = (diff(SingleTrialPositionsY));
%     % Compute the distance moved in each timestep
%     Edist = ones(length(DeltaX),1);
%     for M = 1:length(DeltaX)
%         Edist(M) = sqrt(DeltaX(M)^2+DeltaY(M)^2); %Pythagorean theorem
%         PathLength(i,1) = sum(Edist);  % Sum all the distances for path length
    end
end




% Uses a loop to create a struct variable for each target, and put the
% metric data for each target in their proper variable
NumOfTargets = max(trialtable(:,10));
for N=1:NumOfTargets
    T2TfirstStruct.(['Target' num2str(N)]) = T2Tfirst(find(trialtable(:,10) == N),:);
    T2TlastStruct.(['Target' num2str(N)]) = T2Tlast(find(trialtable(:,10) == N),:);
    DialInTimeStruct.(['Target' num2str(N)]) = DialInTime(find(trialtable(:,10) == N),:);
    TargetEntriesStruct.(['Target' num2str(N)]) = NumTargetEntries(find(trialtable(:,10) == N),:);
    TrialsStruct.(['Target' num2str(N)])(:,1) = AllTrialtable(find(AllTrialtable(:,10) == N),9); 
    TrialsStruct.(['Target' num2str(N)])(:,2) = AllTrialtable(find(AllTrialtable(:,10) == N),8); 
end 

% Loop again to put the average data in another summary struct variable
for N =1:NumOfTargets
T2TfirstStruct.T2TfirstSummary(N,1) = mean(T2TfirstStruct.(['Target' num2str(N)])(:,1)); 
T2TlastStruct.T2TlastSummary(N,1) = mean(T2TlastStruct.(['Target' num2str(N)])(:,1)); 
DialInTimeStruct.DialInTimeSummary(N,1) = mean(DialInTimeStruct.(['Target' num2str(N)])(:,1)); 
TargetEntriesStruct.TargetEntriesSummary(N,1) = mean(TargetEntriesStruct.(['Target' num2str(N)])(:,1)); 
end

% Put your full Time2Target data and your summary struct variable in the
% general Time2TargetStruct that you return with this function
T2TfirstStruct.T2TfirstFull(:,1) = T2Tfirst(:,1); T2TfirstStruct.T2TfirstFull(:,2) = T2Tfirst(:,2); T2TfirstStruct.T2TfirstFull(:,3) = trialtable(:,10); T2TfirstStruct.T2TfirstFull(:,4) = trialtable(:,9);
T2TfirstStruct.T2TfirstSummary(NumOfTargets+1,1) = mean(T2TfirstStruct.T2TfirstFull(:,1));
%--------------------------------------------------------------------------------------------
T2TlastStruct.T2TlastFull(:,1) = T2Tlast(:,1); T2TlastStruct.T2TlastFull(:,2) = T2Tlast(:,2); T2TlastStruct.T2TlastFull(:,3) = trialtable(:,10);T2TlastStruct.T2TlastFull(:,4) = trialtable(:,9);
T2TlastStruct.T2TlastSummary(NumOfTargets+1,1) = mean(T2TlastStruct.T2TlastFull(:,1));
%--------------------------------------------------------------------------------------------
DialInTimeStruct.DialInTimeFull(:,1) = DialInTime; DialInTimeStruct.DialInTimeFull(:,2) = trialtable(:,10);DialInTimeStruct.DialInTimeFull(:,3) = trialtable(:,9);
DialInTimeStruct.DialInTimeSummary(NumOfTargets+1,1) = mean(DialInTimeStruct.DialInTimeFull(:,1));
%--------------------------------------------------------------------------------------------
TargetEntriesStruct.TargetEntriesFull(:,1) = NumTargetEntries; TargetEntriesStruct.TargetEntriesFull(:,2) = trialtable(:,10);TargetEntriesStruct.TargetEntriesFull(:,3) = trialtable(:,9);
TargetEntriesStruct.TargetEntriesSummary(NumOfTargets+1,1) = mean(TargetEntriesStruct.TargetEntriesFull(:,1));
%--------------------------------------------------------------------------------------------
TrialsStruct.TrialsFull = AllTrialtable(:,9); TrialsStruct.TrialsFull(:,2) = AllTrialtable(:,8);



end
