function FullTaskMetrics = CombineStructs(struct1, struct2)

% Specifically, this mfile combines the metrics in the IsoTaskMetrics
% structs. It combines:
%  - Percent successful (average)
%  - Time2Target (cat for Targets 1-5, Full. Ave for Summary)
%  - PathLength (cat for Targets 1-5, Full. Ave for Summary)
%  - AngleError
%  - File info for each file gets saved


FullTaskMetrics.PercentofSuccessfulTrials = (struct1.PercentofSuccessfulTrials+struct2.PercentofSuccessfulTrials)/2;

for i=1:5
    FullTaskMetrics.Time2Target.(['Target' num2str(i)]) = cat(1, struct1.Time2Target.(['Target' num2str(i)]), struct2.Time2Target.(['Target' num2str(i)]));
    FullTaskMetrics.PathLength.(['Target' num2str(i)]) = cat(1, struct1.PathLength.(['Target' num2str(i)]), struct2.PathLength.(['Target' num2str(i)]));
    FullTaskMetrics.AngleError.MonkeyAngles.(['Target' num2str(i)]) = cat(1, struct1.AngleError.MonkeyAngles.(['Target' num2str(i)]), struct2.AngleError.MonkeyAngles.(['Target' num2str(i)]));
    FullTaskMetrics.AngleError.ActualAngles.(['Target' num2str(i)]) = cat(1, struct1.AngleError.ActualAngles.(['Target' num2str(i)]), struct2.AngleError.ActualAngles.(['Target' num2str(i)]));
    FullTaskMetrics.AngleError.AngleErrors.(['Target' num2str(i)]) = cat(1, struct1.AngleError.AngleErrors.(['Target' num2str(i)]), struct2.AngleError.AngleErrors.(['Target' num2str(i)]));
end

FullTaskMetrics.AngleError.ErrorAngleFull = cat(1, struct1.AngleError.AngleErrorFull, struct2.AngleError.AngleErrorFull);
FullTaskMetrics.File_Info1 = struct1.File_Info;
FullTaskMetrics.File_Info2= struct2.File_Info;

end