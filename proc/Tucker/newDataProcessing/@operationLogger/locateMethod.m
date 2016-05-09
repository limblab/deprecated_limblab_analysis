function methodPath=locateMethod(obj,className,methodName)
    %locateMethod is a method of the operationLogger superclass, and should
    %be saved in the @operationLogger folder
    %
    %methodPath=locateMethod(className,methodName)
    %locateMethod returns the path to the method definition file if it is
    %in the matlab command path. This function only works for methods that
    %are defined in stand-alone files, and will NOT find functions that are
    %identified in the main classdef file with the execption of the class
    %constructor. 
    
    if strcmp(className,methodName)
        methodPath=which(className);
        return
    end
    %if we weren't looking for the constructor, try looking for the method
    %in the class definition folder:
    classPath=which(className);%gets the path of the classdef file, e.g.: ...\@className\className.m
    methodPath=[classPath(1:find(classPath==filesep,1,'last')),methodName,'.m'];
    if ~isempty(dir(methodPath))
        return
    else
        %If we didn't find the method in the class folder, check the 
        %superclasses of className:
        superclassList=superclasses(className);
        for i=1:length(superclassList)
            classPath=which(superclassList{i});
            methodPath=[classPath(1:find(classPath==filesep,1,'last')),methodName,'.m'];
            if ~isempty(dir(methodPath))
                return
            end
        end
        %if we didn't find the method in any of the superclasses return an
        %error:
        error('locateMethod:methodNotFound',['could not find the method: ',methodName, ' in class: ',className,' or in any parent class of ',className])
    end
end