
close;

for N = 1:10
    
    
SingleTrialPositionsX = binnedData.cursorposbin(GoCueIndex(1,N):EndTrialIndex(1,N),1);
SingleTrialPositionsY = binnedData.cursorposbin(GoCueIndex(1,N):EndTrialIndex(1,N),2);
DeltaX =(diff(SingleTrialPositionsX)); DeltaY = (diff(SingleTrialPositionsY));
Edist = ones(length(DeltaX),1);
for M = 1:length(DeltaX)
Edist(M) = sqrt(DeltaX(M)^2+DeltaY(M)^2);
PathLength(N) = sum(Edist);
end

figure;
plot(SingleTrialPositionsX,SingleTrialPositionsY); hold on; plot(xCenter(N),yCenter(N),'r*')
axis([-12 12 -12 12])

end