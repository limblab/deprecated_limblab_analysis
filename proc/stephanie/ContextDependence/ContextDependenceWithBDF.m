%Context dependence
% This script runs analyses for my context dependence study. This includes
% plotting mean force versus mean firing rate for individual cells
% Input: bdf

% Make trial table
trialtable = wf_trial_table(out_struct);

% Prune trial table ------------------------------------------------------
%Get rid of anomalies in the trial table (From Ricky)
remove_index = [];
for iCol=[2 3 4 5]
    [tempa tempb] = hist(trialtable(:,iCol),1000);
    cumsum_temp = cumsum(tempa/sum(tempa));
    remove_under = tempb(find(cumsum_temp<0.02,1,'last'));
    if ~isempty(remove_under)
        remove_under_idx = find(trialtable(:,iCol)<remove_under);
        if length(remove_under_idx)/size(trialtable,1)<0.02
            remove_index = [remove_index find(trialtable(:,iCol)<remove_under)'];
        end
    end
    remove_above = tempb(find(cumsum_temp>0.98,1,'first'));
    if ~isempty(remove_above)
        remove_above_idx = find(trialtable(:,iCol)>remove_above);
        if length(remove_above_idx)/size(trialtable,1)<0.02
            remove_index = [remove_index find(trialtable(:,iCol)>remove_above)'];
        end
    end
end
remove_index = unique(remove_index);
trialtable(remove_index,:) = [];

%Extra pruning
%Get rid of anomalies in the trial table
getrid =  find(trialtable(:,7) == -1);
trialtable(getrid,:)=[];
%Get rid of failed trials
failures =  find(trialtable(:,9) ~= 82);
trialtable(failures,:)=[];
% -------------------------------------------------------------------------

%Fix trial table for the task
%Numbers the targets 1-3 going from low to high force
TNumbers = unique(sort(trialtable(:,2)));
for i=1:length(trialtable)
    switch trialtable(i,2)
        case TNumbers(1)
            trialtable(i,10)=1;
        case TNumbers(2)
            trialtable(i,10)=2;
        case TNumbers(3)
            trialtable(i,10)=3;
    end
end
% -------------------------------------------------------------------------


% For each trial, get end of trial time
% go back in time until

InTarget = zeros(length(trialtable),15);
for i=1:length(trialtable)
    
          
    Go2EndIndices = []; XinTarget = []; YinTarget = [];
    Go2EndInTargetIndices = [];
    
    %look between outer target on and trial table
    endtime = trialtable(i,8);
    gocue = trialtable(i,7);
    % Get the position indices between gocue and endtime
    Go2EndIndicesPos = find( out_struct.pos(:,1) >= gocue & out_struct.pos(:,1) <= endtime );
    % Find the position indices for when Xpos is in the etarget and for
    % when Ypos
    % is in the target
    XinTarget = out_struct.pos(Go2EndIndicesPos,2) > abs(trialtable(i,2)) & out_struct.pos(Go2EndIndicesPos,2) < abs(trialtable(i,4));
    YinTarget = out_struct.pos(Go2EndIndicesPos,3) > trialtable(i,5) & out_struct.pos(Go2EndIndicesPos,3) < trialtable(i,3);
    
    % Loop backwards to get the indices when both Xpos and Ypos are in the target,
    % meaning that the actual cursor is in the target
    InTargetIndices = [];
    counter = 1;
    for j = length(Go2EndIndicesPos):-1:1
        if XinTarget(j) && YinTarget(j) == 1
            InTargetIndices(counter,1) = j; %Indices where cursor in target
            counter = counter+1;
        else
            break
        end
    end
    
    % Put the indices in terms of the indices for position
    Go2EndInTargetIndices = Go2EndIndicesPos(InTargetIndices);
    % Flip so the indices are in order
    Go2EndInTargetIndices  = flipud(Go2EndInTargetIndices)';
    if isempty(Go2EndInTargetIndices);
        continue
    end
    
    % Get the first and last timestasmps for when the cursor was in the target
    InTarget_FirstTimestamp = out_struct.pos(Go2EndInTargetIndices(1),1);
    InTarget_LastTimestamp = out_struct.pos(Go2EndInTargetIndices(end),1);
    
  
    % Find the force indices for when the cursor is in the trial
    InTarget_ForceIndices = find( out_struct.force.data(:,1) >= InTarget_FirstTimestamp & out_struct.force.data(:,1) <= InTarget_LastTimestamp );
    % Cycle through and get the total force (Pythagorean)    
     TrialForce = [];
     for b = 1:length(InTarget_ForceIndices)
         % Get the average force during this epoch for every successful trial
         TrialForce(b) = hypot(out_struct.force.data(InTarget_ForceIndices(b),2), out_struct.force.data(InTarget_ForceIndices(b),3));
     end
     MeanTrialForce(i,1) = mean(TrialForce);
     MeanTrialForce(i,2) = trialtable(i,10); 
     
    
    
%%Center target-----------------------------------------------------------------------------------------------   
% Get time for Outer Target On and subtract 0.5s (the hold time) to get
% when the monkey go into the center target
OTon = trialtable(i,6);
CenterStart = OTon-0.5;

% Find the force indices for when the cursor is in the trial
InCenter_ForceIndices = find( out_struct.force.data(:,1) >= CenterStart & out_struct.force.data(:,1) <= OTon );
% Cycle through and get the total force (Pythagorean)
CenterForce = [];
for b = 1:length(InCenter_ForceIndices)
    % Get the average force during this epoch for every successful trial
    CenterForce(b) = hypot(out_struct.force.data(InCenter_ForceIndices(b),2), out_struct.force.data(InCenter_ForceIndices(b),3));
end
MeanCenterForce(i,1) = mean(CenterForce);

% Get the average firing rate during center hold for every successful trial
for c= 1%:100%:length(binnedData.spikeratedata(1,:)) %cycle through each cell
    % Find the force indices for when the cursor is in the trial
    InCenter_SpikeIndices = find( out_struct.units(1,c).ts >= CenterStart & out_struct.units(1,c).ts <= OTon  );
    MeanCenterSpikeRate(i,c) = length(InCenter_SpikeIndices)/(OTon-CenterStart);
end
    
    
    
%%------------------------------------------------------------------------------------------------------------   
     % Get the average firing rate during this epoch for every successful trial
        for c= 1%:100%:length(binnedData.spikeratedata(1,:)) %cycle through each cell
                  
            % Find the force indices for when the cursor is in the trial
            InTarget_SpikeIndices = find( out_struct.units(1,c).ts >= InTarget_FirstTimestamp & out_struct.units(1,c).ts <= InTarget_LastTimestamp );
            MeanTrialSpikeRate(i,c) = length(InTarget_SpikeIndices)/(InTarget_LastTimestamp-InTarget_FirstTimestamp);
       
        end
%------------------------------------------------------------------------------------------------------------ 

   
        
end

for c = 1%:100
    slopeandint(c,:) = polyfit(MeanTrialForce(:,1),MeanTrialSpikeRate(:,c),1); 
end

% Plot average force (x) versus average firing rate (y)
cell = 1;
figure
plot(MeanTrialForce(:,1),MeanTrialSpikeRate(:,cell),'b*')
hold on
xlabel('Force')
ylabel('Firing rate (spikes/second)')
plot(MeanCenterForce(:,1),MeanCenterSpikeRate(:,cell),'g*')


% Isolate the TwoLevel data from the entire set
ThreeLevelIndices = find(MeanTrialForce(:,2) == 3);
TwoLevelMeanTrialForce = MeanTrialForce; TwoLevelMeanTrialSpikeRate = MeanTrialSpikeRate;
TwoLevelMeanTrialForce(ThreeLevelIndices,:) = [];
TwoLevelMeanTrialSpikeRate(ThreeLevelIndices,:) = [];



% Fit a line to the plot - 3 levels
% modelVars = polyfit(MeanTrialForce(:,1),MeanTrialSpikeRate(:,cell),1); % least squares fitting to a line
% yint = modelVars(2) % y-intercept of the fitted line
% slope = modelVars(1) % slope of fitted lines
% fit = yint+slope*MeanTrialForce(:,1);
% plot(MeanTrialForce(:,1),fit,'g')
% text(400, 60, ['Slope =  ',num2str(slope)])

% Fit a line to the plot - First two levels
modelVars = polyfit(TwoLevelMeanTrialForce(:,1),TwoLevelMeanTrialSpikeRate(:,cell),1); % least squares fitting to a line
yint = modelVars(2) % y-intercept of the fitted line
slope = modelVars(1) % slope of fitted lines
fit = yint+slope*TwoLevelMeanTrialForce(:,1);
plot(TwoLevelMeanTrialForce(:,1),fit,'c')
text(400, 20, ['Slope =  ',num2str(slope)],'FontSize', 10)
xlim([150 550])
ylim([0 25])