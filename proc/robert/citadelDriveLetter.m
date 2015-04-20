function driveLetter=citadelDriveLetter

% syntax driveLetter=citadelDriveLetter;
%
% returns the drive letter to citadel, if it is mapped as a network drive.
% relies on parsing the output of the DOS command 'net use'.  If
% successful, 'net use' returns something like (equals signs are mine):
% ========================================================================
%
% New connections will be remembered.
% 
% 
% Status       Local     Remote                    Network
% 
% -------------------------------------------------------------------------------
% OK           X:        \\APU-PC\Apu-Data         Microsoft Windows Network
% OK           Y:        \\citadel\limblab         Microsoft Windows Network
% OK           Z:        \\citadel\data            Microsoft Windows Network
% The command completed successfully.


[status,result]=dos('net use');

if status==0
    driveLetter=regexp(result,'[A-Z](?=:\s*\\\\citadel\\data)','match','once');
    if isempty(driveLetter)
        driveLetter=regexp(result,'[A-Z](?=:\s*\\\\165.124.111.182\\data)','match','once');
    end
else
    error(result)
end




