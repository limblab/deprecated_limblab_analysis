function gitLog=getGitLog(path)
    %takes the full path to an m-file and searches all the parent folders
    %to see if the file is in a git repository. At the first git repository
    % getGitLog will pull the git log into a string and then  break it into
    % a cell array, where each cell is one line of the log
    
    %find the main git folder if it exists:
    logString=[];
    temp=path;
    [~,fname,~]=fileparts(path);
    while length(temp)>=4 % if we haven't gotten down to the core drive, e.g. C:/
        temp=fileparts(temp);%cut the last folder off temp
        if (exist([temp,filesep,'.git'],'file'))==7
            % we have the path to the git directory for this file
            logString=evalc(['!git --git_dir ',temp,filesep,'.git log']);
            %check whether the filename we are looking for is part of the
            %repository:
            gitFileList=evalc(['!git --git_dir ',temp,filesep,'.git log']);
            if ~isempty( strfind(gitFileList,fname))
                %if our file was in this repo, then break
                break
            else
                %if the file was not in the repo, reset and continue
                %scanning parent folders
                logString=[];
            end
        end
    end

    if ~isempty(logString)
        %if we found a git log, break it into a cell array:
        gitLog=strsplit(logString,'\n');
    else
        gitLog=[];
    end
end