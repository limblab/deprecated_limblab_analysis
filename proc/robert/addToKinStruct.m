function kinStructOut=addToKinStruct(kinStructIn,kinAddIndex)

% this function is meant to be run after some change has been made to the
% code of get_cursor_kinematics or its associated batch file.  Run through
% all the days in the current kinStruct, but just let it flow.  The
% internal code is handling whatever additions need to be made.  Just make
% sure to incorporate the new & improved kinStruct into the output, and
% clean up appropriately at each iteration of the loop.

startFolder=pwd;

if nargin < 2
    kinAddIndex=1;
end

while kinAddIndex < length(kinStructIn)
    % findBDFonCitadel or findBDFonGOB is 100% a game-time decision; it
    % depends on what's being added.  Specifically, it depends on what code
    % needs to run in order to add the desired field.  For example, adding
    % in a .duration field to the kinStruct would not require re-running
    % get_cursor_kinematics at all, so can use findBDFonCitadel which will
    % skip the existing BC files.  Adding in a .control field, on the other
    % hand, requires looking at decoder files and decoder Types for the
    % brain control files, which basically means re-running
    % get_cursor_kinematics.  The hitRate2 also required a re-run.
    if ismac
        % this is mostly for testing/troubleshooting the code, as running
        % batch_get_cursor_kinematics from the network files is not
        % currently supported when we need get_cursor_kinematics to modify
        % the brain control files.  They will be skipped, as they've
        % already been done, and the corrected code won't have a chance to
        % correct the values in kinStruct (and in the BDFs themselves).
        if verLessThan('matlab','7.11')
            [PathName,~,~,~]=fileparts(findBDFonCitadel(kinStructIn(kinAddIndex).name));
        else
            [PathName,~,~]=fileparts(findBDFonCitadel(kinStructIn(kinAddIndex).name));
        end
    else
        if verLessThan('matlab','7.11')
            [PathName,~,~,~]=fileparts(findBDFonGOB(kinStructIn(kinAddIndex).name));
        else
            [PathName,~,~]=fileparts(findBDFonGOB(kinStructIn(kinAddIndex).name));
        end
    end
    batch_get_cursor_kinematics
    % if we're re-running batch_get_cursor_kinematics, then the only time
    % needed should be to load up the file.  It won't actually re-run
    % get_cursor_kinematics if we hand it the network version of the file,
    % so all we need to do after it runs is make sure the updated version
    % of kinStruct makes it out.
    [~,bigK_ind,littleK_ind]=intersect({kinStructIn.name},{kinStruct.name});
    kinStructOut(bigK_ind)=kinStruct(littleK_ind);
    kinAddIndex=kinAddIndex+length(bigK_ind);
    % clean up
    clear kinStruct FileNames Files MATfiles PathName batchIndex 
    cd(startFolder), save(['kinStructAll_',datestr(today),'.mat'],'kinStructOut')
end