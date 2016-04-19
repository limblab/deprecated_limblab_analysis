function [uName,hName]=getUserHost(obj)
    %getUserHost is a method of the operationLogger superclass and should 
    %be saved in the @operationLogger folder with the other class methods
    %
    %getUserHost is a function that tries to detect the host environment
    %and return the user and host names. This is intended for use with
    %commonDataStructure and experiment class methods but can be used as a
    %stand alone function. No input is required for this function
    if ispc
        [~,hostname]=unix('hostname');
        username=strtrim(getenv('UserName'));
    elseif ismac
        [~,hostname]=unix('scutil --get ComputerName');
        [~,username]=unix('whoami');
    else
        hostname=[];
        username=[];
    end

    uName=strtrim(username);
    hName=strtrim(hostname);
end