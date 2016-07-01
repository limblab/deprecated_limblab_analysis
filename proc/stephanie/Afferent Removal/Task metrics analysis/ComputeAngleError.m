function AngleErrorStruct = ComputeAngleError(out_struct)

% Check: Is the cursor outside of where the original target was?

clearvars -except out_struct

% Initialize Variables
[out_struct Goodtrialtable xCenter yCenter GoCueIndex EndTrialIndex] = Initializations(out_struct);

for N = 1:length(Goodtrialtable(:,1))
% Get the GoCuePositions for X and Y
GoCuePositionX = out_struct.pos(GoCueIndex(N),2);
GoCuePositionY = out_struct.pos(GoCueIndex(N),3);
        
%---------------

Time2React = .5; %seconds between GoCue and an end point you want to look at
BinsAfterGoCue = Time2React/0.001;
AfterGoCueIndex = GoCueIndex(N)+(Time2React/0.001);


PossibleX = out_struct.pos(AfterGoCueIndex-(199):AfterGoCueIndex,2);
PossibleY = out_struct.pos(AfterGoCueIndex-(199):AfterGoCueIndex,3);
AfterGoCuePositionX = mean(PossibleX); AfterGoCuePositionY = mean(PossibleY);

   
% Get the distance he has moved in the interval from GoCue to whatever
% Time2React is
Xtranslation = AfterGoCuePositionX - GoCuePositionX;
Ytranslation = AfterGoCuePositionY - GoCuePositionY;

% Find the monkey's angle
MonkAngles(N,1) = atan2(Ytranslation,Xtranslation) * 180/pi;

% Get the distance from GoCuePosition to the center of the cursor
XdistToTarget = xCenter(N) - GoCuePositionX;
YdistToTarget = yCenter(N) - GoCuePositionY;

% Find the actual angle
ActualAngles(N,1) = atan2(YdistToTarget,XdistToTarget) * 180/pi;

% Compute AngleError | The angle between where the monkey is at the GoCue
% and where the target is (AcutalAngle) and the angle between where the
% monkey is at the GoCue and where s/he is at Time2React later.
AngleError(N,1) = (ActualAngles(N,1) - MonkAngles(N,1));


end 

% Concatenate angles to targets
SuccessfulTargets = Goodtrialtable(:,10); % trialtable(trialtable(:,9)==82,10);
MonkAngles = cat(2,MonkAngles,SuccessfulTargets);
ActualAngles = cat(2,ActualAngles,SuccessfulTargets);
AngleErrorFull = cat(2,AngleError,SuccessfulTargets);


NumOfTargets = max(MonkAngles(:,2));

% Create a matrix where each column has the Monkangles for that target
for N=1:NumOfTargets
    AngleErrorStruct.MonkeyAngles.(['Target' num2str(N)]) = MonkAngles(find(MonkAngles(:,2) == N));
    % Create a matrix where each column has the Actualangles for that target
    AngleErrorStruct.ActualAngles.(['Target' num2str(N)]) = ActualAngles(find(ActualAngles(:,2) == N));
    % Create a matrix where each column has the Actualangles for that target
    AngleErrorStruct.AngleErrors.(['Target' num2str(N)]) = AngleErrorFull(find(AngleErrorFull(:,2) == N));
    % Loop again to put the average AngleError data in another summary struct variable
   AngleErrorStruct.AngleErrorSummary(N,1) = mean(AngleErrorStruct.AngleErrors.(['Target' num2str(N)]));
end


AngleErrorStruct.AngleErrorSummary(NumOfTargets+1,1) = mean(AngleErrorFull(:,1));
AngleErrorStruct.AngleErrorFull = AngleErrorFull;

end
