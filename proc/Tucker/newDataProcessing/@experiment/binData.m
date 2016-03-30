function binData(ex)
    %binData is a method of the experiment class, and should be found
    %in the @experiment folder with the main class definition
    
    error('binData:notDefined','binData is not yet written')
    
    %get the continuous data into a table:
    continuousBins=[];
    for i=1:length(ex.binConfig.continuousLabels)
        currLabel=ex.binConfig.continuousLabels{i};
        currNames=ex.(currLabel).data.Properties.VariableNames;
        tempContTable=array2table(decimateData(ex.(currLabel).data{:,:},ex.binConfig.fc),'VariableNames',currNames);
        continuousBins=[continuousBins,tempContTable];
    end
    %get the units into a table:
    rateBins=ex.calcFR;
    %put the binned data into the appropriate sub-field of the ex.bin
    %object:
    set(ex.bin,'bins',[continuousBins,rateBins])
end