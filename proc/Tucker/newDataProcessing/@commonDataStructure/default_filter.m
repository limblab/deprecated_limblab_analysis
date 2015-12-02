function filter_params=default_filter()
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %default_filter returns the default filter settings field for the
    %common_data_strucutre class
    
    filter_params.poles=8;
    filter_params.cutoff=25;
    filter_params.kin_SR=100;
end