% function concatenate_spikes

filepath = 'D:\Data\Kevin_12A2\Data\NPMK_test\';
file_prefix = 'Kevin_2013-04-04_UF';

filelist = dir([filepath file_prefix '*.nev']);
[~,smallest_file] = min([filelist.bytes]);

new_file_suffix = '-concat';
if exist([filepath,file_prefix,new_file_suffix,'.mat'])
    disp('Concatenated file already exists, skipping concatenation.')
else
    concatenate_NEVs(filepath,file_prefix,new_file_suffix);
end

copyfile([filepath filelist(smallest_file).name],[filepath file_prefix '-spikes.nev'])

load([filepath file_prefix new_file_suffix '.mat'],'NEV')
clear NS2 NS3 NS4 NS5

NEV = artifact_removal(NEV,5,.001);

saveNEVSpikes(NEV.Data.Spikes,[file_prefix '-spikes.nev'],[filepath file_prefix '-spikes.nev'])

sorted = input('Have you sorted the new file? Y or N: ','s');

if strcmp(sorted,'Y')
    spikesNEV = openNEV('read', [filepath file_prefix '-spikes-s.nev']);
    load([filepath file_prefix new_file_suffix '.mat'],'NEV')    
    NEV.Data.Spikes = spikesNEV.Data.Spikes;
    save([filepath file_prefix new_file_suffix '.mat'],'NEV','-append')
end
% end
