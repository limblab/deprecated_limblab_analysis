function [AveFRacrosstrials MaxFRacrosstrials] = epochFRmanyTrials(Event1,Event2, binSize,out_struct,trialtableforTgt, unitIndex)



% Inputs
% Event1: The first event after which you want to find timestamps
% Event2: The event after which you don't want to find timestamps





allTS = []; ts = [];
 for  i = 1%:length(trialtableforTgt(:,1))
     binVals =  (binSize/2):binSize:Event2(i)-Event1(i);
     spikes = find((out_struct.units(1,unitIndex).ts >= Event1(i))&(out_struct.units(1,unitIndex).ts <= Event2(i)));
     ts = out_struct.units(1,unitIndex).ts(spikes);
     ts = ts-Event1(i);
     countsPerBin = hist(ts,binVals)   
    FRinHzforEachtrial = (countsPerBin/binSize) %in hz
    AveFRforEachtrial(i,1) = mean(FRinHzforEachtrial)
     
 end



