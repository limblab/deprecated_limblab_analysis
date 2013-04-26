function NEVNSx = concatenate_NEVs(filepath,file_prefix)
% Batch combine NEVs and NSxs

    if exist([filepath file_prefix '-concat.mat'],'file')
        disp('Files already concatenated. Loading existing file.')
        load([filepath,file_prefix,'-concat.mat'])
        if (NEVNSx.MetaTags.NumFilesConcat ~= length(dir([filepath file_prefix '*.nev'])))
            disp('Adding new files')
            NEVNSx = concatenate_files(filepath,file_prefix);
            NEVNSx.NEV = artifact_removal(NEVNSx.NEV,3,0.001);
            save([filepath,file_prefix,'-concat.mat'],'NEVNSx')
        end
    else
        NEVNSx = concatenate_files(filepath,file_prefix);
        NEVNSx.NEV = artifact_removal(NEVNSx.NEV,3,0.001);
        save([filepath,file_prefix,'-concat.mat'],'NEVNSx')
    end   
    
end

function NEVNSx = concatenate_files(filepath,file_prefix)
    NEVlist_sorted = dir([filepath file_prefix '*-s.mat']);
    NEVlist = dir([filepath file_prefix '*.nev']);
    NS2list = dir([filepath file_prefix '*.ns2']);
    NS3list = dir([filepath file_prefix '*.ns3']);
    NS4list = dir([filepath file_prefix '*.ns4']);
    NS5list = dir([filepath file_prefix '*.ns5']);

    if isempty(NEVlist)
        disp('File(s) not found, aborting.')
        return
    end
    NEVNSx = struct('NEV',[],'NS2',[],'NS3',[],'NS4',[],'NS5',[]);
    
    if length(NEVlist_sorted)==length(NEVlist)
        for iNEV = 1:length(NEVlist)
            clear NEV
            load([filepath NEVlist_sorted(iNEV).name]);
            NEVNSx(iNEV).NEV = NEV;
        end
    else
        for iNEV = 1:length(NEVlist)
            NEVNSx(iNEV).NEV = openNEV('read', [filepath NEVlist(iNEV).name]);
        end
    end
    for iNS2 = 1:length(NS2list)
        NEVNSx(iNS2).NS2 = openNSx('read', [filepath NS2list(iNS2).name],'precision','short');
    end
    for iNS3 = 1:length(NS3list)
        NEVNSx(iNS3).NS3 = openNSx('read', [filepath NS3list(iNS3).name],'precision','short');
    end
    for iNS4 = 1:length(NS4list)
        NEVNSx(iNS4).NS4 = openNSx('read', [filepath NS4list(iNS4).name],'precision','short');
    end
    for iNS5 = 1:length(NS5list)
        NEVNSx(iNS5).NS5 = openNSx('read', [filepath NS5list(iNS5).name],'precision','short');
    end

    NEVNSx = combineNSxNEV(NEVNSx,NEVlist);
end
