function [MeanTrialForce MeanTrialSpikeRate MeanCenterForce MeanCenterSpikeRate sortedUnitIndices] = ContextDependenceWithBDF3(out_struct)
%Context dependence
% This script runs analyses for my context dependence study. This includes
% plotting mean force versus mean firing rate for individual cells
% Input: bdf

% Make trial table
trialtable = GetFixTrialTable(out_struct,'contextdep');

% -------------------------------------------------------------------------

% Get sortedUnitIndices
sortedUnitIndices = getSortedUnitIndices(out_struct);


InTarget = zeros(length(trialtable),15);
for i=1:length(trialtable)


    Go2EndIndices = []; XinTarget = []; YinTarget = [];
    Go2EndInTargetIndices = [];

    %look between outer target on and trial table
    endTime = trialtable(i,8);
    startHold = trialtable(i,8)-0.5;


    % Find the force indices for when the cursor is in the trial
    InTarget_ForceIndices = find( out_struct.pos(:,1) >= startHold & out_struct.pos(:,1) <= endTime );
    % Cycle through and get the total force (Pythagorean)
    TrialForce = [];
    for b = 1:length(InTarget_ForceIndices)
        % Get the average force during this epoch for every successful trial
        TrialForce(b) = hypot(out_struct.pos(InTarget_ForceIndices(b),2), out_struct.pos(InTarget_ForceIndices(b),3));
    end
    MeanTrialForce(i,1) = mean(TrialForce);
    % Put target number in the meanTrialForce variable
    MeanTrialForce(i,2) = trialtable(i,10);



    %%Center target-----------------------------------------------------------------------------------------------
    % Get time for Outer Target On and subtract 0.5s (the hold time) to get
    % when the monkey go into the center target
    OTon = trialtable(i,6);
    CenterStart = OTon-0.5;

    % Find the force indices for when the cursor is in the trial
    InCenter_ForceIndices = find( out_struct.pos(:,1) >= CenterStart & out_struct.pos(:,1) <= OTon );
    % Cycle through and get the total force (Pythagorean)
    CenterForce = [];
    for b = 1:length(InCenter_ForceIndices)
        % Get the average force during this epoch for every successful trial
        CenterForce(b) = hypot(out_struct.pos(InCenter_ForceIndices(b),2), out_struct.pos(InCenter_ForceIndices(b),3));
    end
    MeanCenterForce(i,1) = mean(CenterForce);

    % Get the average firing rate during center hold for every successful trial
    for c= 1:length(sortedUnitIndices)
        unitInd = sortedUnitIndices(c);
        % Find the force indices for when the cursor is in the center
        InCenter_SpikeIndices = find( out_struct.units(1,unitInd).ts >= CenterStart & out_struct.units(1,unitInd).ts <= OTon  );
        MeanCenterSpikeRate(i,c) = length(InCenter_SpikeIndices)/(OTon-CenterStart);
        
        % Find the force indices for when the cursor is in the target
        InTarget_SpikeIndices = find( out_struct.units(1,unitInd).ts >= startHold & out_struct.units(1,unitInd).ts <= endTime );
        MeanTrialSpikeRate(i,c) = length(InTarget_SpikeIndices)/(0.5);

    end



   
end

end
