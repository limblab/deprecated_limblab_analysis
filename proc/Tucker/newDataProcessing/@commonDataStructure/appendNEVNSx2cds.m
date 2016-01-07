function appendNEVNSx2cds(cds,NEVNSx,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %appendNEVNSx2cds(NEVNSx,varargin)
    %appends data from the NEVNSx object to the end of the cds. To ensure 
    %that data is processed correctly, the NEVNSx will be converted to a 
    %new cds object using the flags passed the new NEVNSx will be time 
    %shifted by the length of the source data in the cds plus a 1 s lag. 
    %After time shifting all fields will be appended to the end of the 
    %matching fields of the original cds and the new cds deleted. After
    %running this function, some fields of cds.meta will be converted from
    %strings or numbers to cell arrays, where each cell contains the data
    %from one of the source files. The data for the appended file will
    %appear second. If a series of files are appended for example, the
    %source file names will be stored in order as a cell array of strings
    %
    %appendNEVNSx2cds is a wrapper for appendcds2cds
    
    cds2=commonDataStructure();
    cds2.NEVNSx2cds(NEVNSx,varargin{:});
    
    cds.appendCds2cds(cds2)
    clear cds2
    cds.addOperation(mfilename('fullpath'),varargin)
end