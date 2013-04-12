function NEVNSx = concatenate_NEVs(filepath,file_prefix)
% Batch combine NEVs and NSxs
% filepath = 'D:\Data\Kevin_12A2\Data\NPMK_test\';
% file_prefix = 'Kevin_2013-04-03_UF';

NEVlist = dir([filepath file_prefix '*.nev']);
NS2list = dir([filepath file_prefix '*.ns2']);
NS3list = dir([filepath file_prefix '*.ns3']);
NS4list = dir([filepath file_prefix '*.ns4']);
NS5list = dir([filepath file_prefix '*.ns5']);

NEVNSx = struct('NEV',[],'NS2',[],'NS3',[],'NS4',[],'NS5',[]);

for iNEV = 1:length(NEVlist)
    NEVNSx(iNEV).NEV = openNEV('read', [filepath NEVlist(iNEV).name]);
end
for iNS2 = 1:length(NS2list)
    NEVNSx(iNS2).NS2 = openNSx('read', [filepath NS2list(iNS2).name]);
end
for iNS3 = 1:length(NS3list)
    NEVNSx(iNS3).NS3 = openNSx('read', [filepath NS3list(iNS3).name]);
end
for iNS4 = 1:length(NS4list)
    NEVNSx(iNS4).NS4 = openNSx('read', [filepath NS4list(iNS4).name]);
end
for iNS5 = 1:length(NS5list)
    NEVNSx(iNS5).NS5 = openNSx('read', [filepath NS5list(iNS5).name]);
end

NEVNSx = combineNSxNEV(NEVNSx);
