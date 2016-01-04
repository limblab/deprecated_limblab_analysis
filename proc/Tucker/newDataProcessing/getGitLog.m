function varargout=getGitLog(path,varargin)
    %takes the full path to an m-file and searches all the parent folders
    %to see if the file is in a git repository. At the first git repository
    % getGitLog will pull the git log into a string and then  break it into
    % a cell array, where each cell is one line of the log
    
    if ~isempty(varargin)
        fullLog=varargin{1};
    else
        fullLog=0;
    end
    
    gitLogString=[];
    temp=path;
    %get the git log for our file:
    if strcmp(path(end-1:end),'.m')
        [~,fileLogString]=system(['git log -1 ',path]);
    else
        [~,fileLogString]=system(['git log -1 ',path,'.m']);
    end
    if nargout==2
        fileLog=strsplit(fileLogString,'\n');
        if ~isempty(fileLogString)
            for i=1:length(fileLog)
                %get the commit hash
                if strfind(fileLog{i},'commit ')
                    fileLogStruct.hash=fileLog{i}(8:end);
                end
                %get the file author
                if strfind(fileLog{i},'Author: ')
                    fileLogStruct.author=fileLog{i}(8:end);
                end
                %get the commit user
                if strfind(fileLog{i},'Date:   ')
                    fileLogStruct.date=fileLog{i}(8:end);
                end
            end
        end
        
        varargout{2}=fileLogStruct;
    end
    if ~isempty( fileLogString)
        %if our file is in a git repo, find the home directory for the git repo
        while length(temp)>=4 % if we haven't gotten down to the core drive, e.g. C:/
            temp=fileparts(temp);%cut the last folder off temp
            if (exist([temp,filesep,'.git'],'file'))==7
                %if we are in the main git folder, get the log and break
                if fullLog
                    gitLogString=evalc(['!git --git-dir=',temp,filesep,'.git log']);
                else
                    gitLogString=evalc(['!git --git-dir=',temp,filesep,'.git log -1']);
                end
                break
            end
        end
        gitLog=strsplit(gitLogString,'\n');
        if ~isempty(gitLogString)
            for i=1:length(fileLog)
                %get the commit hash
                if strfind(gitLog{i},'commit ')
                    gitLogStruct.hash=gitLog{i}(8:end);
                end
                %get the file author
                if strfind(gitLog{i},'Author ')
                    gitLogStruct.author=gitLog{i}(8:end);
                end
                %get the commit user
                if strfind(gitLog{i},'Date:   ')
                    gitLogStruct.date=gitLog{i}(8:end);
                end
            end
        end
    
        varargout{1}=gitLogStruct;
        return
    else
        %if the file was not in a repo, set the logString as empty
        varargout{1}=[];
        return
    end
    
end