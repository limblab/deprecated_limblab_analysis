function [mMinEpochRate,mMaxEpochRate,meanUnitFiring]=firingRange(bdfIn,unitInd,maxFactor)

% syntax firingRange(bdfIn)
%
%   INPUTS:
%           bdfIn     - 3 options:
%                       (char)   path to a bdf .mat file
%                       (char)   name of a pre-loaded bdf struct
%                       (struct) bdf-formatted struct variable.
%           unitInd   - number of the unit we're examining, in
%                       sortClient-centric format.
%           maxFactor - for thresholding the position data.  Can be 1
%                       element or 2, if 2 elements, the first is the 
%                       factor for the upper threshold, the 2nd is the
%                       factor for the lower threshold.  Default is 0.7 but
%                       this can vary pretty widely, so check it for your
%                       file.
%
%   OUTPUTS:
%           mMinEpochRate  - the mean for the negative-deflection maxima
%           mMaxEpochRate  - the mean for the positive-deflection maxima
%           meanUnitFiring - overall mean firing rate for the unit.

if isstruct(bdfIn)
    stoptime=bdfIn.meta.duration;
    bdfIn=inputname(1);
else
    stoptime=0.0;
end

if nargin < 3
    maxFactor=0.7;
end

binsize=0.05; starttime=0; MinFiringRate=0; 
disp('Converting BDF structure to binned data, please wait...');
binnedData = convertBDF2binned(bdfIn,binsize,starttime,stoptime,5,0,MinFiringRate);

% assume x_pos
xPos=binnedData.cursorposbin(:,cellfun(@isempty, ...
    regexp(cellstr(binnedData.cursorposlabels),'x_pos'))==0);
figure, plot(binnedData.timeframe,xPos), hold on
xPos=filtfilt(ones(1,25)/25,1,double(xPos));
plot(binnedData.timeframe,xPos,'g')
unitFiring=binnedData.spikeratedata(:,cellfun(@isempty,regexp(cellstr(binnedData.spikeguide), ...
    ['ee',sprintf('%02d',unitInd),'u1']))==0);

maxFactorUp=maxFactor(1);
maxFactorDown=maxFactor(1); 
if length(maxFactor) > 1
    maxFactorDown=maxFactor(2);
end
plot(get(gca,'Xlim'),[0 0]+maxFactorUp*max(xPos),'r--')
plot(get(gca,'Xlim'),[0 0]+maxFactorDown*min(xPos),'r--')

maxInds=find(xPos > (maxFactorUp*max(xPos)));
startTimes=binnedData.timeframe(maxInds(diff([1; maxInds])>1))-binsize;
endTimes=binnedData.timeframe([maxInds(diff(maxInds)>1); maxInds(end)]);
startTimes=startTimes-1;
endTimes=endTimes-1;
maxEpochRate=[];
for n=1:length(startTimes)
    maxEpochRate=[maxEpochRate; unitFiring(binnedData.timeframe>=startTimes(n) & ...
        binnedData.timeframe<=endTimes(n))];
end

minInds=find(xPos < (maxFactorDown*min(xPos)));
startTimes=binnedData.timeframe(minInds(diff([1; minInds])>1))-binsize;
endTimes=binnedData.timeframe([minInds(diff(minInds)>1); minInds(end)]);
startTimes=startTimes-1;
endTimes=endTimes-1;
minEpochRate=[];
for n=1:length(startTimes)
    minEpochRate=[minEpochRate; unitFiring(binnedData.timeframe>=startTimes(n) & ...
        binnedData.timeframe<=endTimes(n))];
end


mMinEpochRate=mean(minEpochRate);
mMaxEpochRate=mean(maxEpochRate);
meanUnitFiring=mean(unitFiring);



