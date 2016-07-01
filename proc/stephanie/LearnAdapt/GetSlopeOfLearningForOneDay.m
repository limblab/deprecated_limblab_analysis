function slope = GetSlopeOfLearningForOneDay(TrialsStruct, TrialsPerEpoch)



PercentSuccesses = ComputeTotalSuccessOverTime_trialbasis(TrialsStruct, TrialsPerEpoch);

xaxis = 1:length(PercentSuccesses);
% plot(xaxis,PercentSuccesses,'*')
% ylim([0 1])
% MillerFigure

linearCoefficients = polyfit(xaxis, PercentSuccesses, 1);
slope = linearCoefficients(1);


end