function addOperation(cds,operation,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %cds.addOperation(operation)
    %adds an entry to the processedWith field in the cds structure. 
    %'operation' must be a string containing the path to the m-file with
    %the script or function defining the operation performed. If the m-file
    %is part of a git repository, addOperation will also log the current
    %hash of the repo. It is assumed that the repo will be the Miller
    %Limblab repo, but this will not be checked during operation.
    %cds.addOperation(operation,opData)
    %If desired, data pertaining to the operation can also be logged. For 
    %instance, during a filtering operation, the filterSpec object might be 
    %saved to keep a record of the filter used
    %
    %to include in a new script try the following code:
    %   scriptName=mfilename('fullpath');
    %   cds.addOperation(scriptName)
    %
    %if you have some data to include, such as the kinematic filter
    %specification, try something like this:
    %   scriptName=mfilename('fullpath');
    %   cds.addOperation(scriptName,cds.kinFilterConfig)
    %
    
    %set the operation data variable
        if ~isempty(varargin)
            opData=varargin{1};
        else
            opData='No operation data';
        end
    
    %get the host computer name, and the user name
        [username,hostname]=getUserHost();
    
    %get git log information for the specified operation file
        [gitLog, fileLog]=getGitLog(operation);
    %append the current data to the cds.meta.processedWith field
        [~,fname,~]=fileparts(operation);
        meta=cds.meta;
        meta.processedWith=[meta.processedWith;{fname,date,hostname,username,gitLog,fileLog,opData}];
        set(cds,'meta',meta)
end