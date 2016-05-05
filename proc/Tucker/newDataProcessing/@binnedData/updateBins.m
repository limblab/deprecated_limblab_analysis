function updateBins(bd,bins)
    %method function of the binnedData class. This method should be saved
    %in the @binnedData folder.
    % 
    %updateBins is a wrapper function allowing functions or methods to
    %update the actual binned data table of the binnedData class
    set(bd,'bins',bins)
    evntData=loggingListenerEventData('updateBins',[]);
    notify(bd,'updatedBins',evntData)
end