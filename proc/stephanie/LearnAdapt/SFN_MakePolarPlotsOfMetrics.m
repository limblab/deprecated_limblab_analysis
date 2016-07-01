
function SFN_MakePolarPlotsOfMetrics(out_struct)

[T2TfirstStruct T2TlastStruct DialInTimeStruct TargetEntriesStruct TrialsStruct] = ComputeTaskTimeMetrics(out_struct);
meanVals = []; stdVals = []; steVals = [];
for i = 1:8
meanVals(i,:) = mean(eval(['T2TfirstStruct.Target' num2str(i)]));
stdVals(i,:) = std(eval(['T2TfirstStruct.Target' num2str(i)]));
steVals(i) = stdVals(i,1)/sqrt(length(eval(['T2TfirstStruct.Target' num2str(i)])));
end
meanVals = (meanVals(:,1))'; 
plusSTE = meanVals+steVals;
minusSTE = meanVals-steVals;

PolarPlotMeanAndSTE(meanVals, plusSTE, minusSTE,'k');

end