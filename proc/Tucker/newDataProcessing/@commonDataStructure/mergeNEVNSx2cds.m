function mergeNEVNSx2cds(cds,NEVNSx,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %mergeNEVNSx2cds(NEVNSx,varargin)
    %merges data from an NEVNSx into the calling cds. If additional
    %arguments are passed in, mergeNEVNSx2cds will assume the input is a
    %cell array of strings, where each string is an option for the 
    %NEVNSx2dcs function, for instance, 'noforce' will prevent merging
    %force from the NEVNSx into the cds. if no additional arguments are 
    %passed then mergeNEVNSx2cds will merge all fields
    %
    %mergeNEVNSx2cds is a wrapper for mergecds2cds, please see that
    %function for details of operation.
    
    
    %parse varargin so we only generate the fields we need from the NEVNSx
    

    cds2=commonDataStructure();
    cds2.NEVNSx2cds(NEVNSx,varargin{:});
    
    cds.mergecds2cds(cds2)
    
    clear cds2
    cds.addOperation(mfilename('fullpath'),varargin)
end