function [InTarget_FirstTimestamp InTarget_LastTimestamp] = cursorInTarget(out_struct, trialtable);

InTarget = zeros(length(trialtable),15);
for i=1:length(trialtable)
    
    Go2EndIndices = []; XinTarget = []; YinTarget = [];
    Go2EndInTargetIndices = [];

    %look between outer target on and trial table
    endtime = trialtable(i,8);
    gocue = trialtable(i,7);
    % Get the position indices between gocue and endtime
    Go2EndIndicesPos = find(out_struct.pos(:,1) >= gocue & out_struct.pos(:,1) <= endtime );
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

    % Get the first and last timestasmps for when the cursor was in the target
    InTarget_FirstTimestamp(i) = out_struct.pos(Go2EndInTargetIndices(1),1);
    InTarget_LastTimestamp(i) = out_struct.pos(Go2EndInTargetIndices(end),1);
    
end