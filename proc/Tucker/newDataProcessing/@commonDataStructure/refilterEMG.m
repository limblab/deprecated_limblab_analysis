function refilterEMG(cds)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %
    data=cds.EMG{:,:};
    data=decimateData(data,cds.EMGFilterConfig);
    data=array2table(data,'VariableNames',cds.EMG.Properties.VariableNames);
    data.Properties.VariableUnits=cds.EMG.Properties.VariableUnits;
    data.Properties.VariableDescriptions=cds.EMG.Properties.VariableDescriptions;
    data.Properties.Description=cds.EMG.Properties.Description;
    set( cds,'EMG',data)
    addOperation(mfilename('fullpath'),cds.EMGFilterConfig)
end