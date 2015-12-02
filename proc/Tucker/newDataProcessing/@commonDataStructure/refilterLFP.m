function refilterLFP(cds)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %
    data=cds.LFP{:,:};
    data=decimateData(data,cds.LFPFilterConfig);
    data=array2table(data,'VariableNames',cds.LFP.Properties.VariableNames);
    data.Properties.VariableUnits=cds.LFP.Properties.VariableUnits;
    data.Properties.VariableDescriptions=cds.LFP.Properties.VariableDescriptions;
    data.Properties.Description=cds.LFP.Properties.Description;
    set( cds,'LFP',data)
    addOperation(mfilename('fullpath'),cds.LFPFilterConfig)
end