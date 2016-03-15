 function refilter(analog,cellNum)
    %refilter is a method of the analogData class and should be saved in
    %the @analogData folder
    data=analog.data{cellNum};
    data=decimateData(data{:,:},fd.fdFilterConfig);
    data=array2table(data,'VariableNames',fd.data.Properties.VariableNames);
    data.Properties.VariableUnits=fd.data.Properties.VariableUnits;
    data.Properties.VariableDescriptions=fd.data.Properties.VariableDescriptions;
    data.Properties.Description=fd.data.Properties.Description;
    analog.data{cellNum}=data;
end