%PETH
function Rasters(out_struct, trialtype, tgtNo, preEvent, postEvent, sorted, save)

%foldername = 'Y:\user_folders\Stephanie\Data Analysis\ContextDependence\Jaco\Jaco_031814_3ForceLevels_Target1_Sorted\';
trialtype = 'contextdep';



% Create trial table
trialtable = GetFixTrialTable(out_struct,trialtype);
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
% dFdT = diff(out_struct.pos);
% dFdT(:,1) = out_struct.pos(2:end,1);
%--------------------------------------------------------------------------
% Get the indices for the sorted cells
if sorted == 1;
sortedUnitIndices = []; ind=1;
for a = 1:length(out_struct.units)
    if out_struct.units(1,a).id(2)~=0
        sortedUnitIndices(ind) = a;
        ind = ind+1;
    end
end
else
    sortedUnitIndices = 1:1:length(out_struct.units);
end
%--------------------------------------------------------------------------

% Rasters aligned on movement
preEvent = 1;    %in s
postEvent = 2;   %in s
binSize = 0.025;  %in s
%numBins = (postEvent+preEvent)/binSize; Do I need this?
binVals =  (binSize/2)-preEvent:binSize:postEvent-(binSize/2);

% Find time when cursor is in the target
InTarget_FirstTimestamp =  trialtableforTgt(:,8)-0.5;


for j = 1%:length(sortedUnitIndices)
    allTS = []; ts = [];
    figure;
    for  i = 1:length(trialtableforTgt(:,1))
        
        % Get the index for the neuron
        unitIndex = sortedUnitIndices(j);
        
        % Initialize your AlignEvent
        AlignEvent = InTarget_FirstTimestamp(i);
        
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
        PosIndices = find((out_struct.pos(:,1) >= AlignEvent-preEvent)&(out_struct.pos(:,1) <= AlignEvent+postEvent));
        Xpos = out_struct.pos(PosIndices,2);
        Ypos = out_struct.pos(PosIndices,3);
        PosTime = out_struct.pos(PosIndices,1)-AlignEvent;
        
        % Plot dFdT
%         dFdTindices = find((dFdT(:,1) >= MoveON-preEvent)&(dFdT(:,1) <= MoveON+postEvent));
%         Xdfdt = dFdT(dFdTindices,2);
%         Ydfdt = dFdT(dFdTindices,3);
%         dfdtTime = dFdT(dFdTindices,1)-MoveON;
        
        % Plot spikes
        spikes = find((out_struct.units(1,unitIndex).ts >= AlignEvent-preEvent)&(out_struct.units(1,unitIndex).ts <= AlignEvent+postEvent));
        ts = out_struct.units(1,unitIndex).ts(spikes);
        ts = ts-AlignEvent;
        allTS = cat(1,allTS,ts);
        handle1 = subplot(3,1,1);
        hold on;
        plot([ts ts]', [(i-1)*ones(size(ts)),i*ones(size(ts))]','k')
        ylabel('Trials')
        findUnderscore = find(out_struct.meta.filename=='_',3); endName = findUnderscore(3);
        name = out_struct.meta.filename(find(out_struct.meta.filename=='\',1,'last')+1:1:endName-1);
        name = strrep(name,'_',' | ');
        title(num2str(cat(2 ,name, ' | Unit ID: ', num2str(out_struct.units(1,unitIndex).id),' | Target ', num2str(tgtNo))))
        
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
        OTonTime = OTon(i) - AlignEvent;
        plot(OTonTime, i-.5, 'g*')
        
        % Plot markers for when the cursor is first in the target
%         FirstInTargetTime(i) = InTarget_FirstTimestamp(i);
%         plot(FirstInTargetTime(i)-AlignEvent, i-.5,'r*')
        
        % Plot markers for OTon
        trialEndTime = trialEnd(i) - AlignEvent;
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
    plot(binVals,hz,'r-', 'LineWidth',2)
    ylabel('Hz')
    
    % Fix xaxis for subplot1
    set(handle1,'xlim',[PosTime(1) PosTime(end)])
    
    %Stats for FR across trials
    overallPeakHz = max(hz);
    %Stats 
%     [AveFRforTargetHold(j,1) MaxFRforTargetHold(j,1)] = epochFR(FirstInTargetTime, FirstInTargetTime+0.5, binSize, out_struct,trialtableforTgt,unitIndex);
%     [AveFRforCenterHold(j,1) MaxFRforCenterHold(j,1)] = epochFR(OTon-0.5, OTon, binSize, out_struct,trialtableforTgt,unitIndex);
%     [AveFRforGoCuetoTarget(j,1) MaxFRforGoCuetoTarget(j,1)]= epochFR(OTon, FirstInTargetTime, binSize, out_struct,trialtableforTgt,unitIndex);
%     [AveFRforRandom1(j,1) MaxFRforRandom1(j,1)] = epochFR(trialEnd, trialEnd+0.5, binSize, out_struct,trialtableforTgt,unitIndex);
%     [AveFRforRandom2(j,1) MaxFRforRandom2(j,1)]= epochFR(trialEnd+0.5, trialEnd+1, binSize, out_struct,trialtableforTgt,unitIndex);
%    
  % xlabel(h3,sprintf(' Time (seconds) \n\nOverallPeak:  %.2f\n AveFRforCenterHold: %2.2f              AveFRforTargetHold: %.2f\n AveFRforRandomHold1: %.2f        AveFRforRandomHold2  %.2f', overallPeakHz,AveFRforCenterHold,AveFRforTargetHold,AveFRforRandom1,AveFRforRandom2))
  
    % Save entire figure
    if save == 1
   saveas(gcf, strcat(foldername, 'unit',  num2str(out_struct.units(1,unitIndex).id),'.eps'))
   saveas(gcf, strcat(foldername, 'unit',  num2str(out_struct.units(1,unitIndex).id),'.fig'))
    end
    
    pause
    %close
end

