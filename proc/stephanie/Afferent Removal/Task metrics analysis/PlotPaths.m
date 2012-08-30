function PlotPaths(LastTargetContact) 

% For a binned data file

close all;

for N = 2%:length(Goodtrialtable)
    
    
SingleTrialPositionsX = out_struct.pos(GoCueIndex(1,N):EndTrialIndex(1,N),2);
SingleTrialPositionsY = out_struct.pos(GoCueIndex(1,N):EndTrialIndex(1,N),3);
DeltaX =(diff(SingleTrialPositionsX)); DeltaY = (diff(SingleTrialPositionsY));
Edist = ones(length(DeltaX),1);
for M = 1:length(DeltaX)
Edist(M) = sqrt(DeltaX(M)^2+DeltaY(M)^2);
PathLength(N) = sum(Edist);
end

targetLengthX = abs(Goodtrialtable(N,4)-Goodtrialtable(N,2));
targetLengthY = abs(Goodtrialtable(N,5)-Goodtrialtable(N,3));

%figure;
rectangle('Position',[Goodtrialtable(N,2),(Goodtrialtable(N,3)-targetLengthY),targetLengthX,targetLengthY], 'LineWidth',2,'LineStyle','-', 'FaceColor', 'r');
rectangle('Position',[0-(targetLengthX/2), 0-(targetLengthY/2),targetLengthX,targetLengthY], 'LineWidth',2,'LineStyle','--','FaceColor', 'g');
hold on; plot(SingleTrialPositionsX(1:LastTargetContact(N)+1),SingleTrialPositionsY(1:LastTargetContact(N)+1),'w');
set(subplot(1,1,1),'Color',[0.5 0.5 0.5])
axis equal; axis([-12 12 -12 12]);

end

end