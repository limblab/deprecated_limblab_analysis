function functionlist=get_user_dependencies(fname)
    %returns a cell array with strings containing the functions that the
    %function fname depends on
    
    if ~isempty(strfind(fname,'@'))
        %we have a class method here. since class methods return all
        %class methods as dependencies we need to handle that specially or
        %we wind up in an infinite regress and hit the recursion limit
        %right away
        functionlist=depfun_limblab(fname,'-toponly','-quiet');
        return
    end
    functionlist={};
    command_list=depfun_limblab(fname,'-toponly','-quiet');
    functionlist=command_list(1);
    for i=2:length(command_list)%skip the first element since that is the calling function
        if strfind(command_list{i},matlabroot)
            continue
        else
            temp=get_user_dependencies(command_list{i});
            if isempty(temp)
                functionlist(length(functionlist)+1)=command_list(i);
            else
                functionlist=[functionlist;temp];
            end
        end
    end
end