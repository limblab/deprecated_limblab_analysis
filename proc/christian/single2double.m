function binnedData = single2double(binnedData)

binnedData.timeframe = double(binnedData.timeframe);
binnedData.emgdatabin = double(binnedData.emgdatabin);
binnedData.forcedatabin = double(binnedData.forcedatabin);
binnedData.spikeratedata = double(binnedData.spikeratedata);
binnedData.cursorposbin   = double(binnedData.cursorposbin);

end

