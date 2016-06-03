function newDataSet = splitDataFileWrtTgt(origDataSet,targets,historyBins)

%concatenate data from a file so that the output data set includes only
%trials for the list of targets provided in argin. Extracts entire trials,
%from trial start, to start of next trial.
%to conserve spike history, neural data has to be duplicated and shifted
%by historyBins bins

numTrials = size(origDataSet.tt,1);
binsize   = round((origDataSet.timeframe(2)-origDataSet.timeframe(1))*1000)/1000;

spikeData = DuplicateAndShift(origDataSet.spikeratedata,historyBins);

allValidBins  = [];
allValidTrials= [];

for i = 1:numTrials
    if any(origDataSet.tt(i,10) == targets)
        trialStart = origDataSet.tt(i,1);
        if i==numTrials
            trialEnd = origDataSet.tt(i,9);
        else
            trialEnd = origDataSet.tt(i+1,1);
        end
        
        origBinStart = find(origDataSet.timeframe>=trialStart,1,'first');
        origBinEnd   = find(origDataSet.timeframe<=trialEnd  ,1,'last' );
        
        allValidBins   = [allValidBins origBinStart:origBinEnd];
        allValidTrials = [allValidTrials i];
    end
end

numNewBins               = length(allValidBins);
newDataSet.timeframe     = (0:binsize:binsize*(numNewBins-1))';
newDataSet.spikeratedata = spikeData(allValidBins,:);
newDataSet.emgdatabin    = origDataSet.emgdatabin(allValidBins,:);
newDataSet.emgguide      = origDataSet.emgguide;
newDataSet.forcelabels   = origDataSet.forcelabels;
newDataSet.forcedatabin  = origDataSet.forcedatabin(allValidBins,:);
newDataSet.spikeguide    = origDataSet.spikeguide;
newDataSet.cursorposbin  = origDataSet.cursorposbin(allValidBins,:);
newDataSet.cursorposlabels=origDataSet.cursorposlabels; 
newDataSet.tt            = origDataSet.tt(allValidTrials,:);
    
end