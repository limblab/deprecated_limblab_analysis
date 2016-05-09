classdef operationLogger < matlab.mixin.SetGet
    %class implementing a logger to be used as a superclass for other
    %functions such as the commonDataStructure or experiment classes
    %the operationLogger class has a single property 'operationLog' and a
    %single method: addOperation is a subclass of matlab.mixin.SetGet and
    %as a result is a handle class and has set and get methods implemented
    properties (SetAccess=private, GetAccess=public,SetObservable=true)
        operationLog
    end
    methods (Static = true)
        %constructor
        function OL=operationLogger()
            processedWith={'operation','function','file path','date','computer name','user name','Git log','File log','operation_data'};
            set(OL,'operationLog',processedWith)
        end
    end
    methods
        %set methods
        function set.operationLog(OL,processedWith)
            if size(processedWith,2)~=9
                error('operationLog:badLogEntry','The operation log must have 9 columns')
            elseif ~iscellstr(processedWith(2:end,1))
                error('operationLog:badOperationEntry','all operation entries must be strings')
            elseif ~iscellstr(processedWith(2:end,2))
                error('operationLog:badFunctionEntry','all function entries must be strings')
            elseif ~iscellstr(processedWith(2:end,3))
                error('operationLog:badFilePathEntry','all file paths must be strings')
            elseif ~iscellstr(processedWith(2:end,4))
                error('operationLog:badDateEntry','all dates must be strings')
            elseif ~iscellstr(processedWith(2:end,5))
                error('operationLog:badComputerNameEntry','all computer name entries must be strings')
            elseif ~iscellstr(processedWith(2:end,6))
                error('operationLog:badUserNameEntry','all user names must be strings')
            elseif size(processedWith,1)>1 && (~isstruct(cell2mat(processedWith(2:end,7))) || ~isfield(cell2mat(processedWith(2:end,7)),'hash') || ~isfield(cell2mat(processedWith(2:end,7)),'date'))
                error('operationLog:badGitLogEntry','all git logs must be structures with 3 elements: hash, author and date ')
            elseif size(processedWith,1)>1 && (~isstruct(cell2mat(processedWith(2:end,8))) || ~isfield(cell2mat(processedWith(2:end,8)),'hash') || ~isfield(cell2mat(processedWith(2:end,8)),'date'))
                error('operationLog:badFileLogEntry','all file logs must be structures with 3 elements: hash, author and date ')
            else
                OL.operationLog=processedWith;
            end
        end
    end
    methods (Static = false, Access = protected, Hidden=true)
        %general methods
        addOperation(obj,operation,opPath,varargin)
        methodPath=locateMethod(obj,className,methodName)
        varargout=getGitLog(obj,opPath)
        [uName,hName]=getUserHost(obj)
    end
end