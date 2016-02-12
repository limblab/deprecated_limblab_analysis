function kinStructOut=addToKinStruct(kinStructIn,toAdd)

% syntax kinStructOut=addToKinStruct(kinStructIn,toAdd)
%
%       INPUTS: kinStructIn
%               toAdd           - 2 element vector, [startIndex stopIndex]
%
% this function is meant to be run after some change has been made to the
% code of get_cursor_kinematics or its associated batch file.  Run through
% all the days in the current kinStruct, but just let it flow.  The
% internal code is handling whatever additions need to be made.  Just make
% sure to incorporate the new & improved kinStruct into the output, and
% clean up appropriately at each iteration of the loop.

addToKinStruct_startFolder=pwd;

if nargin < 2
    kinAddIndex=1;
    kinStopIndex=length(kinStructIn);
else
    kinAddIndex=toAdd(1);
    kinStopIndex=toAdd(end);
end

while kinAddIndex <= kinStopIndex
    % findBDFonCitadel or findBDFonGOB is 100% a game-time decision; it
    % depends on what's being added.  Specifically, it depends on what code
    % needs to run in order to add the desired field.  For example, adding
    % in a .duration field to the kinStruct would not require re-running
    % get_cursor_kinematics at all, so can use findBDFonCitadel which will
    % skip get_cursor_kinematics for the existing BC files.  Adding in 
    % a .control field, on the other hand, requires looking at decoder 
    % files and decoder Types for the brain control files, which basically 
    % means re-running get_cursor_kinematics.  hitRate2 also required a re-run.
    try
        if ismac
            % this is mostly for testing/troubleshooting the code, as running
            % batch_get_cursor_kinematics from the network files is not
            % currently supported when we need get_cursor_kinematics to modify
            % the brain control files.  They will be skipped, as they've
            % already been done, and the corrected code won't have a chance to
            % correct the values in kinStruct (and in the BDFs themselves).
            [PathName,~,~]=FileParts(findBDFonCitadel(kinStructIn(kinAddIndex).name));
        else
            [PathName,~,~]=FileParts(findBDFonBumbleBeeMan(kinStructIn(kinAddIndex).name,1));
        end
        batch_get_cursor_kinematics
        [~,bigK_ind,littleK_ind]=intersect({kinStructIn.name},{kinStruct.name});
        kinStructOut(bigK_ind)=kinStruct(littleK_ind);
        % put a copy of kinStruct on citadel.
        [remoteFolder2,~,~]=FileParts(findBDFonCitadel(kinStructIn(kinAddIndex).name));
        if exist(regexprep(remoteFolder2,'bdf|BDFs','FilterFiles'),'dir')==7
            save(fullfile(regexprep(remoteFolder2,'bdf|BDFs','FilterFiles'),'kinStruct.mat'),'kinStruct')
        else
            save(fullfile(regexprep(remoteFolder2,'bdf|BDFs','Filter files'),'kinStruct.mat'),'kinStruct')
        end
    catch ME
        kinAddIndex=kinAddIndex+1;
        continue
    end
    
    kinAddIndex=kinAddIndex+length(bigK_ind);
    % clean up
    clear kinStruct FileNames Files MATfiles PathName batchIndex 
    cd(addToKinStruct_startFolder)
    save(['kinStructAll_',datestr(today),'.mat'],'kinStructOut')
end