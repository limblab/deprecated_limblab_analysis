function NEVNSx = concatenate_NEVs(filepath,file_prefix)
% Batch combine NEVs and NSxs

    if exist([filepath file_prefix '-concat.mat'],'file')
        disp('Files already concatenated. Loading existing file.')
        load([filepath,file_prefix,'-concat.mat'])
        if (NEVNSx.MetaTags.NumFilesConcat ~= length(dir([filepath file_prefix '*.nev'])))
            disp('Adding new files')
            NEVNSx = concatenate_files(filepath,file_prefix);
        end
    else
        NEVNSx = concatenate_files(filepath,file_prefix);
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
            NEVNSx(iNEV).NEV = openNEV('read', [filepath NEVlist(iNEV).name],'nosave');
        end
    end
    for iNS2 = 1:length(NS2list)
        NEVNSx(iNS2).NS2 = openNSx('read', [filepath NS2list(iNS2).name],'precision','short');
        num_zeros = fix((NEVNSx(iNS2).NEV.Data.SerialDigitalIO.TimeStampSec(end)-size(NEVNSx(iNS2).NS2.Data,2)/1000)*1000);
        NEVNSx(iNS2).NS2.Data = [zeros(size(NEVNSx(iNS2).NS2.Data,1),num_zeros) NEVNSx(iNS2).NS2.Data];
        NEVNSx(iNS2).NS2.MetaTags.DataPoints = NEVNSx(iNS2).NS2.MetaTags.DataPoints + num_zeros;
        NEVNSx(iNS2).NS2.MetaTags.DataDurationSec = NEVNSx(iNS2).NS2.MetaTags.DataDurationSec + num_zeros/1000;        
    end
    for iNS3 = 1:length(NS3list)
        NEVNSx(iNS3).NS3 = openNSx('read', [filepath NS3list(iNS3).name],'precision','short');        
        num_zeros = fix((NEVNSx(iNS3).NEV.Data.SerialDigitalIO.TimeStampSec(end)-size(NEVNSx(iNS3).NS3.Data,2)/2000)*2000);
        NEVNSx(iNS3).NS3.Data = [zeros(size(NEVNSx(iNS3).NS3.Data,1),num_zeros) NEVNSx(iNS3).NS3.Data];
        NEVNSx(iNS3).NS3.MetaTags.DataPoints = NEVNSx(iNS3).NS3.MetaTags.DataPoints + num_zeros;
        NEVNSx(iNS3).NS3.MetaTags.DataDurationSec = NEVNSx(iNS3).NS3.MetaTags.DataDurationSec + num_zeros/2000;
    end
    for iNS4 = 1:length(NS4list)
        NEVNSx(iNS4).NS4 = openNSx('read', [filepath NS4list(iNS4).name],'precision','short');
        num_zeros = fix((NEVNSx(iNS4).NEV.Data.SerialDigitalIO.TimeStampSec(end)-size(NEVNSx(iNS4).NS4.Data,2)/10000)*10000);
        NEVNSx(iNS4).NS4.Data = [zeros(size(NEVNSx(iNS4).NS4.Data,1),num_zeros) NEVNSx(iNS4).NS4.Data];
        NEVNSx(iNS4).NS4.MetaTags.DataPoints = NEVNSx(iNS4).NS4.MetaTags.DataPoints + num_zeros;
        NEVNSx(iNS4).NS4.MetaTags.DataDurationSec = NEVNSx(iNS4).NS4.MetaTags.DataDurationSec + num_zeros/10000;
    end
    for iNS5 = 1:length(NS5list)
        NEVNSx(iNS5).NS5 = openNSx('read', [filepath NS5list(iNS5).name],'precision','short');
        num_zeros = fix((NEVNSx(iNS5).NEV.Data.SerialDigitalIO.TimeStampSec(end)-size(NEVNSx(iNS5).NS5.Data,2)/30000)*30000);
        NEVNSx(iNS5).NS5.Data = [zeros(size(NEVNSx(iNS5).NS5.Data,1),num_zeros) NEVNSx(iNS5).NS5.Data];
        NEVNSx(iNS5).NS5.MetaTags.DataPoints = NEVNSx(iNS5).NS5.MetaTags.DataPoints + num_zeros;
        NEVNSx(iNS5).NS5.MetaTags.DataDurationSec = NEVNSx(iNS5).NS5.MetaTags.DataDurationSec + num_zeros/30000;
    end

    NEVNSx = combineNSxNEV(NEVNSx,NEVlist);
end
