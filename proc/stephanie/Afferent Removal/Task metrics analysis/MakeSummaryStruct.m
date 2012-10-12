% Put all data into a FullSummary struct

clc;
allFiles = who('IsoTaskMetrics*');
for i = 1:length(allFiles)
    FullSummary.Time2Target.Target1(i) = eval([allFiles{i} '.Time2Target.Time2TargetSummary(1)']);
    FullSummary.Time2Target.Target5(i) = eval([allFiles{i} '.Time2Target.Time2TargetSummary(5)']);
    FullSummary.PathLength.Target1(i) = eval([allFiles{i} '.PathLength.PathLengthSummary(1)']);
    FullSummary.PathLength.Target5(i) = eval([allFiles{i} '.PathLength.PathLengthSummary(5)']);
end


[T2T_h_Targets,T2T_p_Targets] = ttest2(FullSummary.Time2Target.Target1, FullSummary.Time2Target.Target5)
[PL_h_Targets,PL_p_Targets] = ttest2(FullSummary.PathLength.Target1, FullSummary.PathLength.Target5)

blockedFiles = who('*B');
for i = 1:length(blockedFiles)
    FullSummary.Time2Target.Blocked_Target1(i) = eval([blockedFiles{i} '.Time2Target.Time2TargetSummary(1)']);
    FullSummary.Time2Target.Blocked_Target5(i) = eval([blockedFiles{i} '.Time2Target.Time2TargetSummary(5)']);
    FullSummary.PathLength.Blocked_Target1(i) = eval([blockedFiles{i} '.PathLength.PathLengthSummary(1)']);
    FullSummary.PathLength.Blocked_Target5(i) = eval([blockedFiles{i} '.PathLength.PathLengthSummary(5)']);
end


unblockedFiles = who('*U');
for i = 1:length(unblockedFiles)
    FullSummary.Time2Target.Unblocked_Target1(i) = eval([unblockedFiles{i} '.Time2Target.Time2TargetSummary(1)']);
    FullSummary.Time2Target.Unblocked_Target5(i) = eval([unblockedFiles{i} '.Time2Target.Time2TargetSummary(5)']);
    FullSummary.PathLength.Unblocked_Target1(i) = eval([unblockedFiles{i} '.PathLength.PathLengthSummary(1)']);
    FullSummary.PathLength.Unblocked_Target5(i) = eval([unblockedFiles{i} '.PathLength.PathLengthSummary(5)']);
end

 
[T2T_h_AfferentsTarget1,T2T_p_AfferentsTarget1] = ttest2(FullSummary.Time2Target.Unblocked_Target1, FullSummary.Time2Target.Blocked_Target1)
[T2T_h_AfferentsTarget5,T2T_p_AfferentsTarget5] = ttest2(FullSummary.Time2Target.Unblocked_Target5, FullSummary.Time2Target.Blocked_Target5)
[PL_h_AfferentsTarget1,PL_p_AfferentsTarget1] = ttest2(FullSummary.PathLength.Unblocked_Target1, FullSummary.PathLength.Blocked_Target1)
[PL_h_AfferentsTarget5,PL_p_AfferentsTarget5] = ttest2(FullSummary.PathLength.Unblocked_Target5, FullSummary.PathLength.Blocked_Target5)
 
 