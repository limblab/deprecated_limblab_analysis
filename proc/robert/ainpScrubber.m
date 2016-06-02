function newEMGnames=ainpScrubber(oldEMGnames)

% In some of the early data files, ainp channels did not get renamed to
% EMG_whatever channels.  

newEMGnames={'EMG_Bic','EMG_Tri','EMG_Adel','EMG_Pdel'};

ainpChansPresent=find(cellfun(@isempty,regexp(oldEMGnames,'ainp[0-9]+'))==0);
switch length(ainpChansPresent)
    case 0
        newEMGnames='';
    case 4
        return
    otherwise
        newEMGnames=newEMGnames(ainpChansPresent);
end