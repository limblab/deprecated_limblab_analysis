function BaselineFR = Calc_BaselineFR(binnedData,Center_ts,numBins)
    %% Find Baseline FR at 'Go_Cue' (center hold)

    numUnits = size(binnedData.spikeratedata,2);
    numCenters= size(Center_ts,1);


    AveFR_tmp = zeros(numCenters,numUnits);

    for i=1:length(Center_ts)
        timewindow = find( binnedData.timeframe(:,1)<=Center_ts(i),numBins,'last');
        if ~isempty(timewindow)
            AveFR_tmp(i,:) = mean( binnedData.spikeratedata(timewindow,:));
        end
    end
    BaselineFR = mean(AveFR_tmp);
end
