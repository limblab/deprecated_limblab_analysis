function [ReducedPreds ActualModes] = testReducedH(binnedData, RedH, u1, u2)
ActualMuscles = binnedData.emgdatabin;
MeasuredMode1 = ActualMuscles*u1;
MeasuredMode2 = ActualMuscles*u2;
Modes = cat(2,MeasuredMode1,MeasuredMode2);
[ReducedPreds,~,ActualModes]=predMIMO4(binnedData.spikeratedata,RedH,1,1,Modes);
end