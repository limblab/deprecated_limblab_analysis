function PlotTruncatedPaths(out_struct, plotmin, plotmax)

%========================= Function Description ==========================%
% This function plot Paths from go cue to the start of the hold period for
% successful trials of your choosing. Just define plotmin to plotmax.
%=========================================================================%

%======================== Initializations ================================%
% Close previously existing figures
close all;
% Initializations
[out_struct Goodtrialtable xCenter yCenter GoCueIndex EndTrialIndex] = Initializations(out_struct);
%=========================================================================%

% =============== Has the cursor entered the target? ======================

% Loop through the (successful!) trials of interest 
for N = plotmin:plotmax
    
% Get the time stamps for a single trial from GoCue until the End of trial
% event

SingleTrialPositionsX = out_struct.pos(GoCueIndex(1,N):EndTrialIndex(1,N),2);
SingleTrialPositionsY = out_struct.pos(GoCueIndex(1,N):EndTrialIndex(1,N),3);

% Loop backwards from the end of the trial
for A = length(SingleTrialPositionsX):-1:1
    % Ask: When was the last time the cursor was outside of the target?
    if (SingleTrialPositionsX(A) < Goodtrialtable(N,2) || SingleTrialPositionsX(A) > Goodtrialtable(N,4)) || (SingleTrialPositionsY(A) < Goodtrialtable(N,5) || SingleTrialPositionsY(A) > Goodtrialtable(N,3))
        LastTargetContact(N) = A; %Save the index of the SingleTrial positions for when the cursor was last outside of the target
        break % Break so you don't get earlier indices as well
    end
end

% If the last time you were out of the target was the last timestamp in the
% trial, subtract LastTargetContact by 1 so everything works out when you
% plot (Because I usually plot one timestamp MORE than LastTargetContact so
% I show the cursor IN in the target
if LastTargetContact(N) == length(SingleTrialPositionsX)
    LastTargetContact(N) = LastTargetContact(N)-1;
end
    

% ==================== Plot Paths =========================================
 % Plot a green square for the center target 
 % and a red square for the outer target

% Get target lengths so you can plot the squares
targetLengthX = abs(Goodtrialtable(N,4)-Goodtrialtable(N,2));
targetLengthY = abs(Goodtrialtable(N,5)-Goodtrialtable(N,3));
% Plot the squares
rectangle('Position',[Goodtrialtable(N,2),(Goodtrialtable(N,3)-targetLengthY),targetLengthX,targetLengthY], 'LineWidth',2,'LineStyle','-', 'FaceColor', 'r');
rectangle('Position',[0-(targetLengthX/2), 0-(targetLengthY/2),targetLengthX,targetLengthY], 'LineWidth',2,'LineStyle','--','FaceColor', 'g');

% Plot the path length from GoCue to the last target entrance 
% before the hold period
%hold on; plot(SingleTrialPositionsX(1:LastTargetContact(N)+1),SingleTrialPositionsY(1:LastTargetContact(N)+1),'w');

% Make the background black and the axes equal
set(subplot(1,1,1),'Color',[0.5 0.5 0.5])
axis equal; axis([-12 12 -12 12]);


end