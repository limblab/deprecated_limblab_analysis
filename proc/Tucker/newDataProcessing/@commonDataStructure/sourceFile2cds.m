function sourceFile2cds(cds,folderPath,fileName,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %sourceFile2cds(folderPath,fileName) loads the file(s) specified into an
    %NEVNSx and then loads it into the cds using NEVNSx2cds. fileName can
    %be any prefix accepted by cerebus2NEVNSx
    
    NEVNSx=cerebus2NEVNSx(folderPath,fileName);
    cds.NEVNSx2cds(NEVNSx,varargin{:});
    cds.addOperation(mfilename('fullpath'))
end