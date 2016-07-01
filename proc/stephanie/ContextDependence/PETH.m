%PETH
% function peth(tgtNo, preEvent, postEvent, save)

%foldername = 'Y:\user_folders\Stephanie\Data Analysis\ContextDependence\10-06-13\Jango_100613_2ForceLevels_Target2_Sorted\';

% Create trial table
trialtable = GetFixTrialTable(out_struct);
%--------------------------------------------------------------------------
% Separate out trial table into 2 and 3 force level trialtables
tgtNo = 2;
TgtNoindices = find(trialtable(:,10)==tgtNo);
trialtableforTgt = trialtable(TgtNoindices,:);
%--------------------------------------------------------------------------
% Create total position and velocity variable
totalPos = hypot(out_struct.pos(:,2),out_struct.pos(:,3));
Vel = diff(totalPos);
% Create df/dt variable
dFdT = diff(out_struct.pos);
dFdT(:,1) = out_struct.pos(2:end,1);
%--------------------------------------------------------------------------
% Get the indices for the sorted cells
sortedUnitIndices = []; ind=1;
for a = 1:length(out_struct.units)
    if out_struct.units(1,a).id(2)~=0
        sortedUnitIndices(ind) = a;
        ind = ind+1;
    end
end
%--------------------------------------------------------------------------

% Rasters aligned on movement
preEvent = 1;    %in s
postEvent = 2;   %in s
binSize = 0.025;  %in s
%numBins = (postEvent+preEvent)/binSize; Do I need this?
binVals =  (binSize/2)-preEvent:binSize:postEvent-(binSize/2);

% Find time when cursor is in the target
InTarget_FirstTimestamp = cursorInTarget(out_struct, trialtableforTgt);


for j = 1:10%:length(sortedUnitIndices)
    allTS = []; ts = [];
    figure;
    for  i = 1:length(trialtableforTgt(:,1))
        
        % Get the index for the neuron
        unitIndex = sortedUnitIndices(j);
        
        % Get your event times
        OTon(i) = trialtableforTgt(i,6);
        endTime = OTon(i)+postEvent;
        trialEnd(i) = trialtableforTgt(i,8);
        
        % Get your movement on timestamps
        PosInd = find((out_struct.pos(:,1) >= OTon(i)) & out_struct.pos(:,1) <= endTime);
        VelOTon2End = Vel(PosInd+1);
        [peak peakInd] = max(VelOTon2End);
        MoveONind = peakInd-10+PosInd(1);
        MoveON = out_struct.pos(MoveONind,1);
        
        % Plot force
        PosIndices = find((out_struct.pos(:,1) >= MoveON-preEvent)&(out_struct.pos(:,1) <= MoveON+postEvent));
        Xpos = out_struct.pos(PosIndices,2);
        Ypos = out_struct.pos(PosIndices,3);
        PosTime = out_struct.pos(PosIndices,1)-MoveON;
        
        % Plot dFdT
%         dFdTindices = find((dFdT(:,1) >= MoveON-preEvent)&(dFdT(:,1) <= MoveON+postEvent));
%         Xdfdt = dFdT(dFdTindices,2);
%         Ydfdt = dFdT(dFdTindices,3);
%         dfdtTime = dFdT(dFdTindices,1)-MoveON;
        
        % Plot spikes
        spikes = find((out_struct.units(1,unitIndex).ts >= MoveON-preEvent)&(out_struct.units(1,unitIndex).ts <= MoveON+postEvent));
        ts = out_struct.units(1,unitIndex).ts(spikes);
        ts = ts-MoveON;
        allTS = cat(1,allTS,ts);
        handle1 = subplot(3,1,1);
        hold on;
        plot([ts ts]', [(i-1)*ones(size(ts)),i*ones(size(ts))]','k')
        ylabel('Trials')
        title(num2str(cat(2,'Unit ID: ', num2str(out_struct.units(1,unitIndex).id))))
        
        % Plot EMGs
%         EMGindices = find((out_struct.emg.data(:,1) >= MoveON-preEvent)&(out_struct.emg.data(:,1) <= MoveON+postEvent));
%         EMGvalues = out_struct.emg.data(EMGindices,2:7);
%         EMGtime = out_struct.emg.data(EMGindices,1)-MoveON;
%         figure
%         colors = ['r' 'm' 'g' 'b' 'c' 'k']
%         for a = 1:6
%             plot(EMGtime,EMGvalues(:,a),colors(a))
%             hold on
%         end
        
        % Plot markers ----------------------------------------------------
        % Plot markers for OTon
        OTonTime = OTon(i) - MoveON;
        plot(OTonTime, i-.5, 'g*')
        
        % Plot markers for when the cursor is first in the target
        FirstInTargetTime(i) = InTarget_FirstTimestamp(i);
        plot(FirstInTargetTime(i)-MoveON, i-.5,'r*')
        
        % Plot markers for OTon
        trialEndTime = trialEnd(i) - MoveON;
        plot(trialEndTime, i-.5, 'b*')
        % -----------------------------------------------------------------
        
        % Plot X and Y position for the current trial
        h3 = subplot(3,1,3);
        hold on
        plot(PosTime,Xpos,'b-')
        plot(PosTime,Ypos,'g-')
        ylabel('Force')
        
    
        
        
    end
    
    % Plot ave firing rate across all trials
    subplot(3,1,2);
    countsPerBin = hist(allTS,binVals);
    hz = (countsPerBin/binSize)/(length(trialtableforTgt));
    plot(binVals,hz,'r*', 'LineWidth',2)
    ylabel('Hz')
    
    % Fix xaxis for subplot1
    set(handle1,'xlim',[PosTime(1) PosTime(end)])
    
    %Stats for FR across trials
    overallPeakHz = max(hz);
    %Stats 
    [AveFRforTargetHold(j,1) MaxFRforTargetHold(j,1)] = epochFR(FirstInTargetTime, FirstInTargetTime+0.5, binSize, out_struct,trialtableforTgt,unitIndex);
    [AveFRforCenterHold(j,1) MaxFRforCenterHold(j,1)] = epochFR(OTon-0.5, OTon, binSize, out_struct,trialtableforTgt,unitIndex);
    [AveFRforGoCuetoTarget(j,1) MaxFRforGoCuetoTarget(j,1)]= epochFR(OTon, FirstInTargetTime, binSize, out_struct,trialtableforTgt,unitIndex);
    [AveFRforRandom1(j,1) MaxFRforRandom1(j,1)] = epochFR(trialEnd, trialEnd+0.5, binSize, out_struct,trialtableforTgt,unitIndex);
    [AveFRforRandom2(j,1) MaxFRforRandom2(j,1)]= epochFR(trialEnd+0.5, trialEnd+1, binSize, out_struct,trialtableforTgt,unitIndex);
   
  % xlabel(h3,sprintf(' Time (seconds) \n\nOverallPeak:  %.2f\n AveFRforCenterHold: %2.2f              AveFRforTargetHold: %.2f\n AveFRforRandomHold1: %.2f        AveFRforRandomHold2  %.2f', overallPeakHz,AveFRforCenterHold,AveFRforTargetHold,AveFRforRandom1,AveFRforRandom2))
  
    % Save entire figure
    %saveas(gcf, strcat(foldername, 'unit',  num2str(out_struct.units(1,unitIndex).id),'.png'))
    
    
    %pause
    %close
end

