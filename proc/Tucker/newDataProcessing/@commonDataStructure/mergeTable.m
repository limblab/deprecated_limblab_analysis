function mergeTable(cds,fieldName,mergeData)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %mergeTable accepts a field name and a table, and merges the data in
    %the table into the existing field of the cds this is used to merge
    %data from two separate files into a single table in the cds. For
    %instance, LFP data might be collected on 2 arrays using 2 different
    %cerebus systems, and merged into a single LFP field in the cds.
    %
    %mergeTable tries to find the time window where data exists in both
    %cds.(fieldName) and the mergeData and truncates cds.(fieldName) to
    %that range. This may result in a restricted range when compared to the
    %original cds. This may also result in fields of the cds with different
    %ranges
    
    tstart=cds.(fieldName).t(1);
    tend=cds.(fieldName).t(end);
    dt=cds.(fieldName).t(2)-tstart;
    tstart2=mergeData.t(1);
    tend2=mergeData.t(end);
    dt2=cds.(fieldName).t(2)-tstart;
    %check our frequencies
    if dt~=dt2
        error('mergeTable:differentFrequency',['Field: ',fieldName,' was collected at different frequencies in the cds and the new data and cannot be merged. Either re-load both data sets using the same filterspec, or refilter the data in one of the cds structures using decimation to get to the frequencies to match'])
    end
    %check if we have duplicate columns:
    for j=1:length(cds.(fieldName).Properties.VariableNames)
        if ~isempty(find(cell2mat({strcmp(mergeData.Properties.VariableNames,cds.fieldName.Properties.VariableNames{j})}),1,'first'))
            error('mergeTable:duplicateColumns',['the column label: ',cds.fieldName.Properties.VariableNames{j},' exists in the ',fieldName,' field of both cds and new data. All columns in the cds and new data except time must have different labels in order to merge'])
        end
    end
    mask=cell2mat({~strcmp(cds.fieldName.Properties.VariableNames,'t')});
    set(cds,fieldName,...
        [cds.(fieldName)(find(cds.(fieldName).t>=max(tstart,tstart2),1,'first'):find(cds.(fieldName).t>=min(tend,tend2),1,'first'),:),...
        mergeData(find(mergeData.t>=max(tstart,tstart2),1,'first'):find(mergeData.t>=min(tend,tend2),1,'first'),(mask))])
    
    cds.addOperation(mfilename('fullpath'),fieldName);
end
                    