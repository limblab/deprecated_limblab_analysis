function addOperation(ex,operation,varargin)
    %this is a method function for the experiment class, and
    %should be located in a folder '@experiment' with the class
    %definition file and other method files
    %
    %ex.addOperation(operation)
    %adds an entry to the processedWith field in the experiment structure. 
    %'operation' must be a string containing the path to the m-file with
    %the script or function defining the operation performed. If the m-file
    %is part of a git repository, addOperation will also log the current
    %hash of the repo. It is assumed that the repo will be the Miller
    %Limblab repo, but this will not be checked during operation.
    %ex.addOperation(operation,opData)
    %If desired, data pertaining to the operation can also be logged. For 
    %instance, during a filtering operation, the filterSpec object might be 
    %saved to keep a record of the filter used
    %
    %to include in a new script try the following code:
    %   scriptName=mfilename('fullpath');
    %   ex.addOperation(scriptName)
    %
    %if you have some data to include, such as the kinematic filter
    %specification during refiltering, try something like this:
    %   ex.addOperation('ex.kin.refilter',ex.kin.fc)
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
        meta=ex.meta;
        meta.processedWith=[meta.processedWith;{fname,date,hostname,username,gitLog,fileLog,opData}];
        set(ex,'meta',meta)
end