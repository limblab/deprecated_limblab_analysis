function PlotTrajectoriesToTargets(out_struct,plotSuccessful)
% Plot curosor trajectories to targets
     colors = distinguishable_colors(9);

  

if plotSuccessful == 1
        PlotTargets(out_struct);
        title('All successful movements')
       trialtable = GetFixTrialTable(out_struct,'learnadapt',1);
for j=1:length(trialtable(:,1))
        % Get GoCueIndex and EndTrialIndex
    timediff = abs(out_struct.pos(:,1) - trialtable(j,7));
    GoCueIndex = max(find(timediff == min(timediff)));
    timediff = abs(out_struct.pos(:,1) - trialtable(j,8));
    EndTrialIndex = max(find(timediff == min(timediff)));
    
    trialX = (out_struct.pos(GoCueIndex:EndTrialIndex,2));
    trialY = (out_struct.pos(GoCueIndex:EndTrialIndex,3));
    switch trialtable(j,10)
        case 1
            plot(trialX,trialY,'Color',colors(1,:))
        case 2
            plot(trialX,trialY,'Color',colors(2,:))
        case 3
            plot(trialX,trialY,'Color',colors(3,:))
        case 4
            plot(trialX,trialY,'Color',colors(4,:))
        case 5
            plot(trialX,trialY,'Color',colors(5,:))
        case 6
            plot(trialX,trialY,'Color',colors(6,:))
        case 7
            plot(trialX,trialY,'Color',colors(7,:))
        case 8
            plot(trialX,trialY,'Color',colors(9,:))  
    end
end
end




if plotSuccessful == 0
    PlotTargets(out_struct)
    trialtable = GetFixTrialTable(out_struct,'learnadapt',0);
for j=1:length(trialtable(:,1))
        % Get GoCueIndex and EndTrialIndex
    timediff = abs(out_struct.pos(:,1) - trialtable(j,7));
    GoCueIndex = max(find(timediff == min(timediff)));
    timediff = abs(out_struct.pos(:,1) - trialtable(j,8));
    EndTrialIndex = max(find(timediff == min(timediff)));
    
    trialX = (out_struct.pos(GoCueIndex:EndTrialIndex,2));
    trialY = (out_struct.pos(GoCueIndex:EndTrialIndex,3));
    switch trialtable(j,10)
       case 1
            plot(trialX,trialY,'Color',colors(1,:))
        case 2
            plot(trialX,trialY,'Color',colors(2,:))
        case 3
            plot(trialX,trialY,'Color',colors(3,:))
        case 4
            plot(trialX,trialY,'Color',colors(4,:))
        case 5
            plot(trialX,trialY,'Color',colors(5,:))
        case 6
            plot(trialX,trialY,'Color',colors(6,:))
        case 7
            plot(trialX,trialY,'Color',colors(7,:))
        case 8
            plot(trialX,trialY,'Color',colors(9,:))  
    end
    end
end



% Plot the first successful trajectory for each target
PlotTargets(out_struct)
title('First sucessful movement to target')
trialtable = GetFixTrialTable(out_struct,'learnadapt',1);
[~, TgtInd] = unique(trialtable(:,10));
for k=1:length(TgtInd)
    index = TgtInd(k);
    % Get GoCueIndex and EndTrialIndex
    timediff = abs(out_struct.pos(:,1) - trialtable(index,7));
    GoCueIndex = max(find(timediff == min(timediff)));
    timediff = abs(out_struct.pos(:,1) - trialtable(index,8));
    EndTrialIndex = max(find(timediff == min(timediff)));
    
    trialX = (out_struct.pos(GoCueIndex:EndTrialIndex,2));
    trialY = (out_struct.pos(GoCueIndex:EndTrialIndex,3));
    switch trialtable(index,10)
        case 1
            plot(trialX,trialY,'Color',colors(1,:),'LineWidth',1.5)
        case 2
            plot(trialX,trialY,'Color',colors(2,:),'LineWidth',1.5)
        case 3
            plot(trialX,trialY,'Color',colors(3,:),'LineWidth',1.5)
        case 4
            plot(trialX,trialY,'Color',colors(4,:),'LineWidth',1.5)
        case 5
            plot(trialX,trialY,'Color',colors(5,:),'LineWidth',1.5)
        case 6
            plot(trialX,trialY,'Color',colors(6,:),'LineWidth',1.5)
        case 7
            plot(trialX,trialY,'Color',colors(7,:),'LineWidth',1.5)
        case 8
            plot(trialX,trialY,'Color',colors(9,:),'LineWidth',1.5)  
    end
end

% Plot the LAST successful trajectory for each target
PlotTargets(out_struct)
title('Last successful movement to target')
trialtable = GetFixTrialTable(out_struct,'learnadapt',1);
trialtable = flipud(trialtable); % flip order of trialtable so you get the last trials first
[~, TgtInd] = unique(trialtable(:,10));
for k=1:length(TgtInd)
    index = TgtInd(k);
    % Get GoCueIndex and EndTrialIndex
    timediff = abs(out_struct.pos(:,1) - trialtable(index,7));
    GoCueIndex = max(find(timediff == min(timediff)));
    timediff = abs(out_struct.pos(:,1) - trialtable(index,8));
    EndTrialIndex = max(find(timediff == min(timediff)));
    
    trialX = (out_struct.pos(GoCueIndex:EndTrialIndex,2));
    trialY = (out_struct.pos(GoCueIndex:EndTrialIndex,3));
    switch trialtable(index,10)
        case 1
            plot(trialX,trialY,'Color',colors(1,:),'LineWidth',1.5)
        case 2
            plot(trialX,trialY,'Color',colors(2,:),'LineWidth',1.5)
        case 3
            plot(trialX,trialY,'Color',colors(3,:),'LineWidth',1.5)
        case 4
            plot(trialX,trialY,'Color',colors(4,:),'LineWidth',1.5)
        case 5
            plot(trialX,trialY,'Color',colors(5,:),'LineWidth',1.5)
        case 6
            plot(trialX,trialY,'Color',colors(6,:),'LineWidth',1.5)
        case 7
            plot(trialX,trialY,'Color',colors(7,:),'LineWidth',1.5)
        case 8
            plot(trialX,trialY,'Color',colors(9,:),'LineWidth',1.5)  
    end
end

% Plot the LAST 20 successful trajectory for each target
if plotSuccessful==1
PlotTargets(out_struct)
title('Last 15 successful movements to target')
trialtable = GetFixTrialTable(out_struct,'learnadapt',1);
trialtable = flipud(trialtable); % flip order of trialtable so you get the last trials first
TgtInd = 1:15;
for k=1:length(TgtInd)
    index = TgtInd(k);
    % Get GoCueIndex and EndTrialIndex
    timediff = abs(out_struct.pos(:,1) - trialtable(index,7));
    GoCueIndex = max(find(timediff == min(timediff)));
    timediff = abs(out_struct.pos(:,1) - trialtable(index,8));
    EndTrialIndex = max(find(timediff == min(timediff)));
    
    trialX = (out_struct.pos(GoCueIndex:EndTrialIndex,2));
    trialY = (out_struct.pos(GoCueIndex:EndTrialIndex,3));
    switch trialtable(index,10)
        case 1
            plot(trialX,trialY,'Color',colors(1,:),'LineWidth',1.5)
        case 2
            plot(trialX,trialY,'Color',colors(2,:),'LineWidth',1.5)
        case 3
            plot(trialX,trialY,'Color',colors(3,:),'LineWidth',1.5)
        case 4
            plot(trialX,trialY,'Color',colors(4,:),'LineWidth',1.5)
        case 5
            plot(trialX,trialY,'Color',colors(5,:),'LineWidth',1.5)
        case 6
            plot(trialX,trialY,'Color',colors(6,:),'LineWidth',1.5)
        case 7
            plot(trialX,trialY,'Color',colors(7,:),'LineWidth',1.5)
        case 8
            plot(trialX,trialY,'Color',colors(9,:),'LineWidth',1.5)  
    end
end
end



% % Plot the last five movements to each target
% PlotTargets(out_struct)
% title('Last five successful movements to each target')
% trialtable = GetFixTrialTable(out_struct,'learnadapt',1);
% trialtable = flipud(trialtable); % flip order of trialtable so you get the last trials first
% [SuccessfulTargetIDs, ~] = unique(trialtable(:,10));
% for T = 1:SuccessfulTargetIDs
%    SuccessfulTrialsPerTarget = find(trialtable(:,10)==SuccessfulTargetIDs)
% for k=1:length(TgtInd)
%     index = TgtInd(k);
%     % Get GoCueIndex and EndTrialIndex
%     timediff = abs(out_struct.pos(:,1) - trialtable(index,7));
%     GoCueIndex = max(find(timediff == min(timediff)));
%     timediff = abs(out_struct.pos(:,1) - trialtable(index,8));
%     EndTrialIndex = max(find(timediff == min(timediff)));
%     
%     trialX = (out_struct.pos(GoCueIndex:EndTrialIndex,2));
%     trialY = (out_struct.pos(GoCueIndex:EndTrialIndex,3));
%     switch trialtable(index,10)
%         case 1
%             plot(trialX,trialY,'Color',colors(1,:),'LineWidth',1.5)
%         case 2
%             plot(trialX,trialY,'Color',colors(2,:),'LineWidth',1.5)
%         case 3
%             plot(trialX,trialY,'Color',colors(3,:),'LineWidth',1.5)
%         case 4
%             plot(trialX,trialY,'Color',colors(4,:),'LineWidth',1.5)
%         case 5
%             plot(trialX,trialY,'Color',colors(5,:),'LineWidth',1.5)
%         case 6
%             plot(trialX,trialY,'Color',colors(6,:),'LineWidth',1.5)
%         case 7
%             plot(trialX,trialY,'Color',colors(7,:),'LineWidth',1.5)
%         case 8
%             plot(trialX,trialY,'Color',colors(9,:),'LineWidth',1.5)  
%     end
% end


% Plot the first trajectory for each target regardless of success
PlotTargets(out_struct)
title('First movement to target')
trialtable = GetFixTrialTable(out_struct,'learnadapt',0);
[~, TgtInd] = unique(trialtable(:,10));
for k=1:length(TgtInd)
    index = TgtInd(k);
    % Get GoCueIndex and EndTrialIndex
    timediff = abs(out_struct.pos(:,1) - trialtable(index,7));
    GoCueIndex = max(find(timediff == min(timediff)));
    timediff = abs(out_struct.pos(:,1) - trialtable(index,8));
    EndTrialIndex = max(find(timediff == min(timediff)));
    
    trialX = (out_struct.pos(GoCueIndex:EndTrialIndex,2));
    trialY = (out_struct.pos(GoCueIndex:EndTrialIndex,3));
    switch trialtable(index,10)
        case 1
            plot(trialX,trialY,'Color',colors(1,:),'LineWidth',1.5)
        case 2
            plot(trialX,trialY,'Color',colors(2,:),'LineWidth',1.5)
        case 3
            plot(trialX,trialY,'Color',colors(3,:),'LineWidth',1.5)
        case 4
            plot(trialX,trialY,'Color',colors(4,:),'LineWidth',1.5)
        case 5
            plot(trialX,trialY,'Color',colors(5,:),'LineWidth',1.5)
        case 6
            plot(trialX,trialY,'Color',colors(6,:),'LineWidth',1.5)
        case 7
            plot(trialX,trialY,'Color',colors(7,:),'LineWidth',1.5)
        case 8
            plot(trialX,trialY,'Color',colors(9,:),'LineWidth',1.5)  
    end
end




end

     