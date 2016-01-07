function mergeFile2cds(cds,folderPath,fileName,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %mergeFile2cds(folderPath,fileName)
    %appends data from the file named fileName, found in folder folderPath
    %will only take fields that appear in the origin cds. data from the new
    %file will be loaded into an NEVNSx object, and then passed to the
    %cds.mergeNEVNSx2cds method. Please see that method for details.
    %variable inputs are data processing flags such as lab number,
    %'noforce', etc. See NEVNSx2cds for details
    NEVNSx=cerebus2NEVNSx(folderPath,fileName);
    cds.appendNEVNSx2cds(NEVNSx,varargin{:});
    cds.addOperation(mfilename('fullpath'))
end