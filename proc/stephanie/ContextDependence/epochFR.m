function [AveFRacrosstrials MaxFRacrosstrials] = epochFR(Event1,Event2, binSize,out_struct,trialtableforTgt, unitIndex)


% Inputs
% Event1: The first event after which you want to find timestamps
% Event2: The event after which you don't want to find timestamps
% Output
% AveFRacrosstrials = Ave firing rate during this epoch across all trials
                        % (in hz)



binVals =  (binSize/2):binSize:Event2-Event1;
allTS = []; ts = [];
 for  i = 1:length(trialtableforTgt(:,1))
     spikes = find((out_struct.units(1,unitIndex).ts >= Event1(i))&(out_struct.units(1,unitIndex).ts <= Event2(i)));
     ts = out_struct.units(1,unitIndex).ts(spikes);
     ts = ts-Event1(i);
     allTS = cat(1,allTS,ts);
     
 end
 countsPerBin = hist(allTS,binVals);
 FRacrosstrials = (countsPerBin/binSize)/(length(trialtableforTgt)); %in hz
 AveFRacrosstrials = mean(FRacrosstrials);
 MaxFRacrosstrials = max(FRacrosstrials);

