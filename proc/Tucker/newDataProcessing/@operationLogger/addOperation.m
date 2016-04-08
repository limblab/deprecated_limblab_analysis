function addOperation(obj,operation,opPath,varargin)
    %addOperation is a method of the operationLogger superclass and should
    %be saved in the @operationLogger folder
    %
    %adds an operation log entry to the operationLogger.operationLog field.
    %addOperation(obj,operation,opPath,varargin)
    %-obj is the calling class object
    %-operation is a string containing a description of the operation. If 
    %   no description is needed simply use the function name or similar
    %-opPath is the full path to the source file for the function/method
    %-optionally the user can pass a structure containing data relavent to
    %   the operation. After a filtering operation for instance the user 
    %   might pass a filterConfig object describing the filter parameters
    %
    %The processedWith field must be an nx9 cell array. Columns of the cell 
    %array will contain:
    %1      operation description passed by the user
    %2      function/method name
    %3      full path to the function/method source code
    %4      date when addOperation inserted the row
    %5      hostname of the computer running the code
    %6      username of the logged in user
    %7      git log data for the repo
    %8      git log data for the function/method source file
    %9      operation data passed by the user
    
    %set the operation data variable
        if ~isempty(varargin)
            opData=varargin{1};
        else
            opData='No operation data';
        end
    
    %get the host computer name, and the user name
        [username,hostname]=getUserHost();
    
    %get git log information for the specified operation file
        [gitLog, fileLog]=getGitLog(opPath);
    %append the current data to the cds.meta.processedWith field
        [~,fname,~]=fileparts(opPath);
        tmp=obj.operationLog;
        tmp=[tmp;{operation,fname,opPath,date,hostname,username,gitLog,fileLog,opData}];
        set(obj,'operationLog',tmp)
end