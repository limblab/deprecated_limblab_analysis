function bin_settings=default_bin_settings(cds)
%this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %default_bin_settings
    %takes no special input. Returns a structure with the default settings
    %for binning the cds into a subsampled bin_data_structure
    
    bin_settings.frequency=20;
    bin_settings.FR_func='binned';%viable options are 'binned','gaussian','triangle'
end