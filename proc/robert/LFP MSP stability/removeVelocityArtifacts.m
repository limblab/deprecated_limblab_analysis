function cleanSignal=removeVelocityArtifacts(velStruct,rejectionThreshold)

% syntax cleanSignal=removeVelocityArtifacts(velStruct,rejectionThreshold);
%
%       INPUTS
%               velStruct           - the outstruct.vel array, should have 
%                                     N rows, 3 columns.  Column 1 is time (s).
%               rejectionThreshold  - velocities higher than this will be
%                                     capped. Default value is 100 
%       OUTPUTS
%               cleanSignal         - copy of the original signal, with
%                                     artifacts removed.

if nargin < 2
    rejectionThreshold=100;
end

for j=2:size(velStruct,2)
    clear badinds badepoch badstartinds badendinds
    badinds=find(abs(velStruct(:,j)) > rejectionThreshold);
    if ~isempty(badinds)
        badepoch=find(diff(badinds)>1);
        badstartinds=[badinds(1); rowBoat(badinds(badepoch+1))];
        badendinds=[badinds(badepoch); rowBoat(badinds(end))];
        if badendinds(end)==size(velStruct,1)
            badendinds(end)=badendinds(end)-1;
        end
        if badstartinds(1)==1   % If at the very beginning of the file, 
                                % need a 0 at start of file
            velStruct(1,j)=velStruct(badendinds(1)+1,j);
            badstartinds(1)=2;
        end
        for i=1:length(badstartinds)
            velStruct(badstartinds(i):badendinds(i),j)=interp1([(badstartinds(i)-1) ...
                (badendinds(i)+1)],[velStruct(badstartinds(i)-1,j) velStruct(badendinds(i)+1,j)], ...
                (badstartinds(i):badendinds(i)));
        end
%     else
%         signalNew(:,j)=signalIn(:,j);
    end
end
cleanSignal=velStruct;
