%PrepTrainonTestData
% For binned file

tic

trialtable = binnedData.trialtable;
timeframe = binnedData.timeframe;
trialtable(66,:) = [];
trialtable(116,:) = [];


newPos = zeros(length(binnedData.cursorposbin),2);
fullind = [];
% Get rid of everything except the data 1 second before the trial ends
for a = 1:length(trialtable) 
    ind = find(timeframe >= (trialtable(a,8)-1) & timeframe <= trialtable(a,8));
    fullind = cat(1,fullind, ind);
        xCenter = (trialtable(a,4)+trialtable(a,2))/2;
        yCenter = (trialtable(a,5)+trialtable(a,3))/2;
        newPos(ind,1) = xCenter;
        newPos(ind,2) = yCenter;
end


emptyind = find(newPos(:,1) == 0 & newPos(:,1) == 0);
newPos(emptyind,:) = [];

%Update
binnedData.cursorposbin = newPos;
binnedData.timeframe(emptyind) = [];
binnedData.timeframe = [0:0.05:(length(binnedData.timeframe)/20-0.05)]';
binnedData.spikeratedata(emptyind,:) = [];



toc
